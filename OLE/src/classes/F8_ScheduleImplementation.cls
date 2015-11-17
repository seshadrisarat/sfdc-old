public class F8_ScheduleImplementation 
  implements F8_ScheduleMain.IF8Schedule
{
/*
    Created by: Alex Romanchuk
    Created Date: 05/22/2014
    Description: Schedule Implementation - "hides" details of the scheduled class from scheduled job (to avoid problems with deployment). 
        Expects to be executed once a day
    Changes:    08/18/2014  Alex Romanchuk  Changed formula for case due date
                03/02/2015  Alex Romanchuk  Corrected distribution year for H2 and Q4 cases (prior year)
*/  
    public void Execute(SchedulableContext sc)
    {
        F8_ScheduleImplementation.Statement_Distribution();
    }

/*
Half-Year
July 31 (H1)
January 31 (H2)
*/
    public static map<string,string> m_HalfYear_MMDD_code=new map<string,string> {'0731'=>'H1','0131'=>'H2'};
/*
Quarterly
April 30 (Q1)
July 31 (Q2)
October 31 (Q3)
January 31 (Q4)
*/
    public static map<string,string> m_Quarterly_MMDD_code=new map<string,string> {'0430'=>'Q1','0731'=>'Q2','1031'=>'Q3','0131'=>'Q4'};
/*
Monthly
January 31 (Jan)
February 28 (Feb)
March 31 (Mar)
April 30 (Apr)
May 31 (May)
June 30 (Jun)
July 31 (Jul)
August 31 (Aug)
September  30 (Sep)
October 31 (Oct)
November 30 (Nov)
December 31 (Dec)
*/
    public static map<string,string> m_Monthly_MMDD_code=new map<string,string> {'0131'=>'Jan','0228'=>'Feb','0331'=>'Mar','0430'=>'Apr','0531'=>'May','0630'=>'Jun','0731'=>'Jul','0831'=>'Aug','0930'=>'Sep','1031'=>'Oct','1130'=>'Nov','1231'=>'Dec'};
    
/*
Record Type for Case "Statement Distribution"
*/
    public static id Account_RecordTypeId_AdminAcct {
        get {
            if(Account_RecordTypeId_AdminAcct==null) {
                Account_RecordTypeId_AdminAcct='012A00000019gDoIAI';
                list<recordtype> lrt=new List <recordtype>([select id, Name, SobjectType from recordtype where SOBJECTTYPE IN ('Case', 'Account')]);
                for(recordtype rt: lrt) { 
                    if(rt.Name=='Statement Distribution' && rt.SobjectType=='Case') Case_RecordTypeId_Statement=rt.Id; 
                    if(rt.Name=='Admin Acct' && rt.SobjectType=='Account') Account_RecordTypeId_AdminAcct=rt.Id; 
                } 
            }
            return Account_RecordTypeId_AdminAcct;
        }
        set;
    }
    public static id Case_RecordTypeId_Statement {
        get {
            if(Case_RecordTypeId_Statement==null) {
                Case_RecordTypeId_Statement='012A00000019gE4IAI';
                list<recordtype> lrt=new List <recordtype>([select id, Name, SobjectType from recordtype where SOBJECTTYPE IN ('Case', 'Account')]);
                for(recordtype rt: lrt) { 
                    if(rt.Name=='Statement Distribution' && rt.SobjectType=='Case') Case_RecordTypeId_Statement=rt.Id; 
                    if(rt.Name=='Admin Acct' && rt.SobjectType=='Account') Account_RecordTypeId_AdminAcct=rt.Id; 
                } 
            }
            return Case_RecordTypeId_Statement;
        }
        set;
    }

@future
    static public void Statement_Distribution() {
        //if today is not the day - exit
        string sYear=string.valueof(date.today().year());
        string sMonth=('00' + string.valueof(date.today().month())).right(2);
        string sDay=('00' + string.valueof(date.today().day())).right(2);
        
        string sMMDD=sMonth+sDay;
        id id_RunningUser=userinfo.getuserid();
        
        if(!m_HalfYear_MMDD_code.containsKey(sMMDD) && !m_Quarterly_MMDD_code.containsKey(sMMDD) && !m_Monthly_MMDD_code.containsKey(sMMDD)) return; //no need to check accounts
        
        //identify MM accounts that are candidates for statement distribution RecordTypeAdmin Acct
        //Payment_Frequency__c: if(FQ=='1') {My_Out='Monthly';} else if(FQ=='3') {My_Out='Quaterly';} else if(FQ=='6') {My_Out='Semi-Annually';}
        map<Id,Account> m_Id_MMCandidate=new Map<Id,Account>([SELECT Id, Name,MM_COCD__c,Payment_Frequency__c,Current_Period_Balance__c,Payment_Preference__c,Email_Statements__c,Royalty_Transfer_File__c,Include_CSV__c,Accounting_Days__c,OwnerId,Owner.IsActive,Prior_Period_Balance__c
            FROM Account WHERE MM_COCD__c!=null AND RecordType.Name='Admin Acct' AND Payment_Frequency__c IN ('Monthly','Quarterly','Half-Yearly')]);
        
        map<Id,string> m_AccountID_CaseSubject=new map<Id,string>();
        string sCurrent_Distribution_Period;
        for(Account acc:m_Id_MMCandidate.values()) {
            sCurrent_Distribution_Period='';
            //<Account.Name> - Statement Distribution - <Account.Period__c>-<Account.Year__c>
            if(m_HalfYear_MMDD_code.containsKey(sMMDD) && acc.Payment_Frequency__c=='Half-Yearly') sCurrent_Distribution_Period=m_HalfYear_MMDD_code.get(sMMDD);
            else if(m_Quarterly_MMDD_code.containsKey(sMMDD) && acc.Payment_Frequency__c=='Quarterly') sCurrent_Distribution_Period=m_Quarterly_MMDD_code.get(sMMDD);
            else if(m_Monthly_MMDD_code.containsKey(sMMDD) && acc.Payment_Frequency__c=='Monthly') sCurrent_Distribution_Period=m_Monthly_MMDD_code.get(sMMDD);

            if(sCurrent_Distribution_Period != '') m_AccountID_CaseSubject.put(acc.Id,acc.Name+' - Statement Distribution - '+sCurrent_Distribution_Period+'-'+sYear);
        }
        List<Case> lCaseExisting=new List<Case>([SELECT Id,AccountID,Subject FROM Case WHERE AccountID IN :m_AccountID_CaseSubject.keySet() AND Subject IN :m_AccountID_CaseSubject.Values() AND Type='Statement Distribution']);
        map<Id,Case> m_AccountID_Case=new Map<Id,Case>();
        for(Case cs: lCaseExisting) m_AccountID_Case.put(cs.AccountID,cs);
        
        List<Case> lCase_Add=new List<Case>();
        for(Account acc:m_Id_MMCandidate.values()) {
            sCurrent_Distribution_Period='';
            //<Account.Name> - Statement Distribution - <Account.Period__c>-<Account.Year__c>
            if(m_HalfYear_MMDD_code.containsKey(sMMDD) && acc.Payment_Frequency__c=='Half-Yearly') sCurrent_Distribution_Period=m_HalfYear_MMDD_code.get(sMMDD);
            else if(m_Quarterly_MMDD_code.containsKey(sMMDD) && acc.Payment_Frequency__c=='Quarterly') sCurrent_Distribution_Period=m_Quarterly_MMDD_code.get(sMMDD);
            else if(m_Monthly_MMDD_code.containsKey(sMMDD) && acc.Payment_Frequency__c=='Monthly') sCurrent_Distribution_Period=m_Monthly_MMDD_code.get(sMMDD);
            integer iAccounting_Days=(acc.Accounting_Days__c!=null)?(Integer.valueOf(acc.Accounting_Days__c)):(0);
            
            if(sCurrent_Distribution_Period != '' && !m_AccountID_Case.containsKey(acc.Id)) {
                string sYear_Effective=sYear;
                if(sCurrent_Distribution_Period=='H2' || sCurrent_Distribution_Period=='Q4') { sYear_Effective=string.valueof(integer.valueof(sYear_Effective) - 1  ); } //adjust to prior year
                lCase_Add.add (
                    new Case(
                        Subject=acc.Name+' - Statement Distribution - '+sCurrent_Distribution_Period+'-'+sYear_Effective
                        ,AccountID=acc.Id
                        ,Status='Open'
                        ,Origin='Automated'
                        ,Priority='Medium'
                        ,Type='Statement Distribution'
                        ,Reason = 'Statement Process'
                        ,Current_Period_Balance__c=acc.Current_Period_Balance__c
                        ,Prior_Period_Balance__c=acc.Prior_Period_Balance__c
                        ,Payment_Preference__c=acc.Payment_Preference__c
                        ,Email_Statements__c = acc.Email_Statements__c
                        ,Royalty_Transfer_File__c = acc.Royalty_Transfer_File__c
                        ,Include_CSV__c = acc.Include_CSV__c
                        ,Distribution_Period__c=sCurrent_Distribution_Period
                        ,Distribution_Year__c=sYear_Effective
                        ,RecordTypeID=Case_RecordTypeId_Statement
                        ,Due_Date__c=date.today().addDays(iAccounting_Days-30)
                        ,OwnerID=(acc.Owner.IsActive)?(acc.OwnerId):(id_RunningUser)
                        )
                );
            }
        }       
        if(lCase_Add.isEmpty()) return;
            
        try {
            insert lCase_Add;
            insert new  Log_Record__c(Source__c='F8_ScheduleImplementation.Statement_Distribution',     Severity_Level__c='INFO', Message__c='Created '+lCase_Add.size()+' "Statement Distribution" cases');
        } catch(Exception e) {
            insert new  Log_Record__c(Source__c='F8_ScheduleImplementation.Statement_Distribution',     Severity_Level__c='ERROR', Message__c='System Error creating "Statement Distribution" cases:\n'+e.getMessage());
        }           
    }
}