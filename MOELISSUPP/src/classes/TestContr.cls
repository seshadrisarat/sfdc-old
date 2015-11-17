/*

Modified: Privlad 02/23/2010 - task: 956
modified: Vika 03/19/2010 - Task #10065
modified: yuguziy 08/04/2010 - Task #10249
*/
public class TestContr {
    public boolean isTest {get;set;}
    public TestContr (MilestoneTracker controller) { isTest = false; }
    public TestContr() { isTest = false; }  
    public void start()
    {
        Opportunity op;
        if (isTest == true) {
            Opportunity testOpp = new Opportunity(name='test', StageName='5-Hold', CloseDate=date.newInstance(2009,1,1));
            insert testOpp;
            op = testOpp;
        } else {
            op = [select o.id, o.name from Opportunity o where o.id= '006Q0000002KpzlIAC'];
        }
        
        op.name = 'new one one one one';
        try
        {
            update op;
        }
        catch (DMLException ex)
        {
            system.debug('here is an error: ' + ex);
        }
        
        system.debug('here: ' + op);
    }
    
    public static testMethod void testThis() {
        MilestoneTracker mt = new MilestoneTracker();
        TestContr t = new TestContr(mt);
        t = new TestContr();
        t.isTest = true;
        t.start();
        
        
        ID iCompanyRT = null;
        ID iDealRT = null;
        RecordType[] recTypeIDs  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Account' limit 1];
        for(RecordType rtItem: recTypeIDs)
        {
            iCompanyRT = rtItem.ID;
        }

        RecordType[] recTypeIDs2  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Ibanking_Project__c' limit 1];
        for(RecordType rtItem: recTypeIDs2)
        {
            iDealRT = rtItem.ID;
        }
        
        Account accObj1 = new Account(Name='Company1',RecordTypeId=iCompanyRT,Type='Other',Industry='Other',Public_Private__c='Public',Client_Code__c='00001',EBITDA__c=2.0,Enterprise_Value__c=3.0,TickerSymbol='CSCO',Total_Revenue__c=10.0,Website='www.mail.ru');
        insert accObj1;
        
        ID UserID = UserInfo.getUserId();
        
        Employee_Profile__c emplObj = new Employee_Profile__c( Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        emplObj.User_ID__c = UserID;
        insert emplObj;
        
        String curEmployeeIDtest = ''+Timesheet.getCurEmployee().ID;

        //Test.startTest();
        
        
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c(RecordTypeId=iDealRT ,Transaction_Type__c='Sellside', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='Test Deal', Industry__c='FIG', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        IbankProjObj.Client__c = accObj1.ID;
        //IbankProjObj.Staffer__c = emplObj.ID;
        insert IbankProjObj;
        Call_Log__c cl = new Call_Log__c(Date__c = Date.today(),Organizer__c = emplObj.Id);
        insert cl;
        Call_Log_Deal__c cldeal = new Call_Log_Deal__c(Call_Log__c = cl.Id, Deal__c=IbankProjObj.Id);
        insert cldeal;
        //Ibanking_Project__c IbankProjObj = [Select i.website__c, i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c, i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        IbankProjObj.Client__c = accObj1.ID;
        //IbankProjObj.Staffer__c = emplObj.ID;
        IbankProjObj.Co_Advisors__c = 'Test textttt';
        IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        IbankProjObj.Stage__c = 'TTTEST!';


        update IbankProjObj;
        
        Project_Resource__c ProgResObj = new Project_Resource__c(Role__c='Other', Status__c='Active', Project__c=IbankProjObj.ID, Banker__c=emplObj.ID);
        insert ProgResObj;

        IbankProjObj.Name = 'Test Name-2';
        update IbankProjObj;
        
        //Select t.Name, t.Id, t.Employee__c, t.CurrencyIsoCode From TimeSheet_Summary__c t
        TimeSheet_Summary__c TSSummary = new TimeSheet_Summary__c(CurrencyIsoCode='USD');
        TSSummary.Name = 'Test TS Summary';
        TSSummary.Employee__c = emplObj.id;
        insert TSSummary;
        
        Date myDate = date.today();
        myDate = TimeTracker.getFirstMondayInWeek(myDate);
        String curPidIDTest = myDate.month()+'/'+myDate.day()+'/'+myDate.year();
        Time_Tracker__c ttTrack1 = new Time_Tracker__c(Week_Start_Date__c=myDate,Employee__c=emplObj.ID,Deal__c=IbankProjObj.ID);
        ttTrack1.Time_Sheet_Summary__c = TSSummary.id;
        insert ttTrack1;
        
        myDate.addDays(-7);
        Time_Tracker__c ttTrack2 = new Time_Tracker__c(Week_Start_Date__c=myDate,Employee__c=emplObj.ID,Deal__c=IbankProjObj.ID);
        ttTrack2.Time_Sheet_Summary__c = TSSummary.id;
        //insert ttTrack2;

        //delete ttTrack2;
        
        
    }
    
}