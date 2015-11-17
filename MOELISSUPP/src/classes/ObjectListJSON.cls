public with sharing class ObjectListJSON 
{
  public boolean checkByName { get; set; }
  public string ObjName { get; set; }
  public string ObjId { get; set; }
  public string SearchWord { get; set; }
  public ObjectListJSON () 
  {
    this.checkByName = false;
    if(System.currentPageReference().getParameters().get('ob')!=null && System.currentPageReference().getParameters().get('ob')!='')
        {
            this.ObjName = System.currentPageReference().getParameters().get('ob'); 
        }
        if(System.currentPageReference().getParameters().get('val')!=null && System.currentPageReference().getParameters().get('val')!='')
        {
            this.SearchWord = System.currentPageReference().getParameters().get('val'); 
        }
        if(System.currentPageReference().getParameters().get('Id')!=null && System.currentPageReference().getParameters().get('Id')!='')
        {
            this.ObjId = System.currentPageReference().getParameters().get('Id'); 
        }
        if(System.currentPageReference().getParameters().get('ch')!=null && System.currentPageReference().getParameters().get('ch')!='')
        {
            this.checkByName = true; 
        }
  }
  
  public List<Employee_Profile__c> getEmployeeProfileObjList()
    {
      List<Employee_Profile__c> ObjList = new List<Employee_Profile__c>();
      if(SearchWord != null && SearchWord != '') 
      {     
        String queryStr = 'SELECT Id, Name, Title__c   FROM Employee_Profile__c WHERE Name like \'%'+SearchWord+'%\' ORDER BY Name limit 50';
        ObjList = database.query(queryStr);
      }
      return ObjList;
    }
    
    public List<Employee_Profile__c> getEmployeeProfileByID()
    {
      List<Employee_Profile__c> ObjList = new List<Employee_Profile__c>();
      if(ObjId != null && ObjId != '') 
      {     
        String queryStr = 'SELECT Id, Name, Title__c   FROM Employee_Profile__c WHERE Id=\''+ObjId+'\' ORDER BY Name limit 1';
        ObjList = database.query(queryStr);
      }
      return ObjList;
    }
    
    public List<Contact> getContactObjList()
    {
      List<Contact> ObjList = new List<Contact>();
      if(SearchWord != null && SearchWord != '') 
      {     
        String queryStr = 'SELECT Id, Name,Account.Name   FROM Contact WHERE Name like \'%'+SearchWord+'%\' ORDER BY Name limit 50';
        ObjList = database.query(queryStr);
      }
      return ObjList;
    }
    
    public List<Contact> getContactByID()
    {
      List<Contact> ObjList = new List<Contact>();
      if(ObjId != null && ObjId != '') 
      {     
        String queryStr = 'SELECT Id, Name,Account.Name   FROM Contact WHERE Id=\''+ObjId+'\' ORDER BY Name limit 1';
        ObjList = database.query(queryStr);
      }
      return ObjList;
    }
    public List<Account> getAccountObjList()
    {
      List<Account> ObjList = new List<Account>();
      if(SearchWord != null && SearchWord != '') 
      {   
        // Edited: Sergey Brull, 08.06.2010, Task #10380  
        String queryStr = 'SELECT Id, Name   FROM Account WHERE Name like \'%'+SearchWord+'%\' ORDER BY Name limit 50';
        ObjList = database.query(queryStr);
      }
      return ObjList;
    }
    
    public static testMethod void testMyController()
    {
      ID iCompanyRT = null;
        ID iDealRT = null;
        RecordType[] recTypeIDs  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Account' limit 1];
        for(RecordType rtItem: recTypeIDs)
        {
            iCompanyRT = rtItem.ID;
        }

        RecordType[] recTypeIDs2  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Ibanking_Project__c' and Name like 'Capital%' limit 1];
        for(RecordType rtItem: recTypeIDs2)
        {
            iDealRT = rtItem.ID;
        }
        
        Account accObj1 = new Account(Name='Company1',RecordTypeId=iCompanyRT,Type='Other',Industry='Other',Public_Private__c='Public',Client_Code__c='00001',EBITDA__c=2.0,Enterprise_Value__c=3.0,TickerSymbol='CSCO',Total_Revenue__c=10.0,Website='www.mail.ru');
        insert accObj1;

    Contact testContact = new Contact(AccountId=accObj1.Id,FirstName='tttestFirstName', LastName='testLastName');
      insert testContact;
        
        ID UserID = UserInfo.getUserId();
        
        Employee_Profile__c emplObj = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        emplObj.User_ID__c = UserID;
        insert emplObj;
        
        String curEmployeeIDtest = ''+TimeTracker.getCurEmployee().ID;

        //Test.startTest();
        
        
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c(Requesting_conflict_clearance__c = 'No', RecordTypeId=iDealRT ,Transaction_Type__c='Public', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='tttest Test Deal', Industry__c='Other', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        IbankProjObj.Transaction_Sub_Type__c = 'Other';
        IbankProjObj.Transaction_Feature__c = 'Other';
        IbankProjObj.Client__c = accObj1.ID;
        //IbankProjObj.Staffer__c = emplObj.ID;
        insert IbankProjObj;
        
        //IbankProjObj = [Select i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c,  i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        IbankProjObj.Client__c = accObj1.ID;

        IbankProjObj.Co_Advisors__c = 'Test textttt';
        IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        IbankProjObj.Stage__c = 'TTTEST!';

        //IbankProjObj.Staffer__c = emplObj.ID;
        update IbankProjObj;
        
        System.currentPageReference().getParameters().put('ob', 'tttest');
        System.currentPageReference().getParameters().put('val', 'tttest');
        System.currentPageReference().getParameters().put('ch', 'true');
        System.currentPageReference().getParameters().put('id', testContact.Id);
        ObjectListJSON testClass = new ObjectListJSON();
        
        List<Employee_Profile__c> empList = testClass.getEmployeeProfileObjList();
        List<Contact> contactList = testClass.getContactObjList();
        List<Contact> contactListById = testClass.getContactByID();
        testClass.getEmployeeProfileByID();
    }
}