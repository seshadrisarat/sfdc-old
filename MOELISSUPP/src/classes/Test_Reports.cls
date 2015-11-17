@isTest
private class Test_Reports {
    public static testmethod void BuyersListReport_Test(){
    Account acc = new Account();
    acc.BillingStreet = 'test';
    acc.BillingCountry = 'test';
    acc.BillingCity = 'test';
    acc.BillingState = 'test';
    acc.BillingPostalCode = 'test';
    acc.Name = 'Test';
    insert acc;
    Contact cntct = new Contact();
    cntct.FirstName = 'Test';
    cntct.LastName = 'Test';
    cntct.Phone = '123';
    cntct.MobilePhone = '123';
    insert cntct;
    
    ID UserID = UserInfo.getUserId();
    Employee_Profile__c empl = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        empl.User_ID__c = UserID;
        insert empl;
    
    //Employee_Profile__c empl = [SELECT id, name FROM Employee_Profile__c LIMIT 1].get(0);
    Ibanking_Project__c deal = new Ibanking_Project__c();
    deal.Name = 'test deal';
    deal.Full_Description_of_Transaction__c = 'test descr';
    deal.Client__c = acc.id; 
    deal.Stage__c = 'Idea';
    
    insert deal;
    Date now  = Date.today();
    Potential_Buyer_Investor__c buyer = new Potential_Buyer_Investor__c();
    buyer.Type__c = 'Financial';
    buyer.TargetBuyer__c = acc.Id;
    buyer.Project__c = deal.Id;
    buyer.Initial_Contact_Made__c = now;
    buyer.Teaser_Sent__c = now;
    buyer.CA_Sent__c = now;
    buyer.CA_Under_Negotiation__c = now;
    buyer.CA_Signed__c = now;
    buyer.CIM_Info_Package_Sent__c = now;
    buyer.CIM_Info_Package_Returned__c = now;
    buyer.CIM_Number__c = '123';
    buyer.Mgmt_Presentation__c = now;
    buyer.Data_Room_Access__c = now;
    buyer.Declined__c = now;
    insert buyer;
    Potential_Buyer_Investor_Contact__c b_contact = new Potential_Buyer_Investor_Contact__c();
    b_contact.Target_Buyer__c = buyer.Id;
    b_contact.Contact__c = cntct.Id;
    insert b_contact;
    Potential_Buyer_Investor_Deal_Team__c b_dt = new Potential_Buyer_Investor_Deal_Team__c();
    b_dt.Target_Buyer__c = buyer.Id;
    b_dt.Banker__c = empl.Id;
    insert b_dt;
    Task task = new Task();
    task.WhatId = buyer.Id;
    task.ActivityDate = now;
    task.Subject = 'Other';
    task.Type = 'test';
    //task.OwnerId = empl.Id;
    insert task;
    Event event = new Event();
    event.WhatId = buyer.Id;
    event.StartDateTime = DateTime.now();
    event.DurationInMinutes = 90;
    event.Subject = 'Other';
    event.Type = 'test';
    //event.OwnerId = empl.Id;
    insert event;
    
    Test.startTest();
    ApexPages.currentPage().getParameters().put('did', deal.Id);
    BuyersListReport cls = new BuyersListReport();
    cls.getDealName();
    cls.getTable();
    cls.toXLS();
    Test.stopTest();
    delete deal;
  }
  
  public static testmethod void BuyersLogReport_Test(){
    Account acc = new Account();
    acc.BillingStreet = 'test';
    acc.BillingCountry = 'test';
    acc.BillingCity = 'test';
    acc.BillingState = 'test';
    acc.BillingPostalCode = 'test';
    acc.Name = 'Test';
    insert acc;
    
    Contact cntct = new Contact();
    cntct.AccountId = acc.Id;
    cntct.FirstName = 'Test';
    cntct.LastName = 'Test';
    cntct.Phone = '123';
    cntct.MobilePhone = '123';
    insert cntct;
    
    ID UserID = UserInfo.getUserId();
    Employee_Profile__c empl = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        empl.User_ID__c = UserID;
        insert empl;
    
    //Employee_Profile__c empl = [SELECT id, name FROM Employee_Profile__c LIMIT 1].get(0);
    Ibanking_Project__c deal = new Ibanking_Project__c();
    deal.Name = 'test deal';
    deal.Full_Description_of_Transaction__c = 'test descr';
    deal.Client__c = acc.id; 
    deal.Stage__c = 'Idea';
    insert deal;
    
    Date now  = Date.today();
    Potential_Buyer_Investor__c buyer = new Potential_Buyer_Investor__c();
    buyer.TargetBuyer__c = acc.Id;
    buyer.Project__c = deal.Id;
    buyer.Initial_Contact_Made__c = now;
    buyer.Teaser_Sent__c = now;
    buyer.CA_Sent__c = now;
    buyer.CA_Under_Negotiation__c = now;
    buyer.CA_Signed__c = now;
    buyer.CIM_Info_Package_Sent__c = now;
    buyer.CIM_Info_Package_Returned__c = now;
    buyer.CIM_Number__c = '123';
    buyer.Mgmt_Presentation__c = now;
    buyer.Data_Room_Access__c = now;
    buyer.Declined__c = now;
    insert buyer;
    Potential_Buyer_Investor_Contact__c b_contact = new Potential_Buyer_Investor_Contact__c();
    b_contact.Target_Buyer__c = buyer.Id;
    b_contact.Contact__c = cntct.Id;
    insert b_contact;
    Potential_Buyer_Investor_Deal_Team__c b_dt = new Potential_Buyer_Investor_Deal_Team__c();
    b_dt.Target_Buyer__c = buyer.Id;
    b_dt.Banker__c = empl.Id;
    insert b_dt;
    Task task = new Task();
    task.WhatId = buyer.Id;
    task.ActivityDate = now;
    task.Subject = 'Other';
    task.Type = 'test';
    //task.OwnerId = empl.Id;
    insert task;
    Event event = new Event();
    event.WhatId = buyer.Id;
    event.StartDateTime = DateTime.now();
    event.DurationInMinutes = 90;
    event.Subject = 'Other';
    event.Type = 'test';
    //event.OwnerId = empl.Id;
    insert event;
    
    Test.startTest();
    ApexPages.currentPage().getParameters().put('did', deal.Id);
    BuyersLogReport cls = new BuyersLogReport();
    cls.getDealName();
    cls.getTable();
    cls.toXLS();
    cls.getTargetBuyers();
    Test.stopTest();
    delete deal;
  }
  
  
  static testMethod void BuyersLogReport_Controller_Test() { 
    Account testAccount = new Account(Name='testAccount', Industry='Media', Type='Other', Public_Private__c='Public', CurrencyIsoCode='USD', Status__c='Active', Client_Code__c='99898', TickerSymbol='qwe', Website='test.com');
    insert testAccount;
    
    Contact testContact = new Contact(AccountId=testAccount.Id,FirstName='testFirstName', LastName='testLastName');
      insert testContact;

        Profile newProfile = [select Id from Profile limit 1];

        User newUser = [SELECT id, name FROM User LIMIT 1].get(0);

        Employee_Profile__c newEmployeeProfile = new Employee_Profile__c(First_Name__c='Eugen', Last_Name__c='Kryvobok',User_Id__c=newUser.Id);
        insert newEmployeeProfile;
    
    Test.startTest();
    // creating test data
      
    
    Ibanking_Project__c newDeal = new Ibanking_Project__c(Name='testTargetBuyers',
                              Requesting_conflict_clearance__c = 'No',
                              Client__c = testAccount.Id,
                              EmailTriggerParams__c='STAFFER, ProjectStaffRequest',
                              Est_Transaction_Size__c=12.4,
                              Full_Description_of_Transaction__c='descr',
                              Stage__c='Expense Code Request');
        newDeal.Milestone_Agreements_Received_Date__c     = date.newInstance(2009,01,01);
        newDeal.Milestone_AML_OFAC_Cleared_Date__c       = date.newInstance(2009,01,01);
        newDeal.Milestone_DealTeamConflictCheckCleared__c   = date.newInstance(2009,01,01);
        newDeal.Milestone_Expense_Code_Date__c         = date.newInstance(2009,01,01);
        newDeal.Milestone_FINCEN_Cleared_Date__c       = date.newInstance(2009,01,01);
        newDeal.Milestone_KYC_Cleared_Date__c         = date.newInstance(2009,01,01);
        newDeal.Milestone_NBRC_Approved_Date__c       = date.newInstance(2009,01,01);
        newDeal.Milestone_NBRC_Committee_Date__c       = date.newInstance(2009,01,01);
       // newDeal.Milestone_Staffing_Date__c           = date.newInstance(2009,01,01);
    
    insert newDeal; 
    //Potential_Buyer_Investor__c tb = new Potential_Buyer_Investor__c(Project__c=newDeal.Id);
    
    Date now  = Date.today();
    Potential_Buyer_Investor__c tb = new Potential_Buyer_Investor__c();
    
    tb.Type__c = 'Financial';
    tb.TargetBuyer__c = testAccount.Id;
    tb.Project__c = newDeal.Id;
    tb.Initial_Contact_Made__c = now;
    tb.Teaser_Sent__c = now;
    tb.CA_Sent__c = now;
    tb.CA_Under_Negotiation__c = now;
    tb.CA_Signed__c = now;
    tb.CIM_Info_Package_Sent__c = now;
    tb.CIM_Info_Package_Returned__c = now;
    tb.CIM_Number__c = '123';
    tb.Mgmt_Presentation__c = now;
    tb.Data_Room_Access__c = now;
    tb.Declined__c = now;
    insert tb;
    
    Potential_Buyer_Investor_Deal_Team__c tbr = new Potential_Buyer_Investor_Deal_Team__c(Target_Buyer__c=tb.Id);
    Potential_Buyer_Investor_Contact__c tbc = new Potential_Buyer_Investor_Contact__c(Target_Buyer__c=tb.Id, Contact__c=testContact.ID);
    insert tbr;
    insert tbc;

    buyersLogReport_Controller blrc = new buyersLogReport_Controller();
    blrc.isTest = true;
    
    // covering getProjectListItems()
    List<SelectOption> gpli = blrc.getProjectListItems();
    
    // covering getDealName()
    String gdn = blrc.getDealName();
    
    //covering toPDF()
    Pagereference tp = blrc.toPDF();
    
    // covering getTargetBuyersList() & getTargetedProfessionals(Id)
    // & getResponsibleUsers(Id)
    // but getActivitiesList(Id) is not covered. It's a read-only object.
    blrc.lProjectList = 'testTargetBuyers';
    blrc.getTargetBuyersList();
    
    Test.stopTest();
    
    delete tb;
    delete testAccount;
    delete newEmployeeProfile;
  }
  
  public static testMethod void NBRCReport_Test()
    {
      Account acc = new Account();
    acc.BillingStreet = 'test';
    acc.BillingCountry = 'test';
    acc.BillingCity = 'test';
    acc.BillingState = 'test';
    acc.BillingPostalCode = 'test';
    acc.Name = 'Test';
    insert acc;
    
      Ibanking_Project__c newIbanking_Project = new Ibanking_Project__c(
              Description__c='test test test test test test test test test test test test test test test test test test test test test test test test ',
              Full_Description_of_Transaction__c='test test test test test test test test test test test test test test test test test test test test test test test test ',
              Proposed_Fee_Structure__c='test test test test test test test test test test test test test test test test test test test test test test test test ',
              Client__c = acc.id,
              Stage__c = 'Idea');
      insert newIbanking_Project;
      System.currentPageReference().getParameters().put('did', newIbanking_Project.Id);
      NBRCReport newNBRCReport = new NBRCReport();
      List<Project_Resource__c> dt_list = newNBRCReport.getDealTeamMembers();
      List<Deal_Related_Parties__c>  drp_list = newNBRCReport.getDealRelatedParties();
      List<Project_Client_Contact__c>  dc_list = newNBRCReport.getDealContacts();
      List<Potential_Buyer_Investor__c>  dpbi_list = newNBRCReport.getPotentialBuyersInvestors();
      newNBRCReport.getChooserender();
      newNBRCReport.getChooserender2();
    }
    
    public static testMethod void TargetBuyersReportController_Test() {
        TargetBuyersReportController con = new TargetBuyersReportController();
        con.isTest = true;
        
        // covering getProjectListItems()
        List<SelectOption> projListItems = con.getProjectListItems();
        
        // covering getDealName()
        String dealName = con.getDealName();
        
        // covering toNullData()
        con.toNullData();
        
        //covering toPDF()
        Pagereference pr = con.toPDF();
        
        
        // covering 
        // getFinancialBuyersList() & getFinancialSubtotal()
        // & getStrategicBuyersList() & getStrategicSubtotal()
        // & getDeclinedBuyersList() & getDeclinedSubtotal()
        // & getTotal()
        Account testAccount = new Account(Name='testAccount');
        insert testAccount;

        Profile newProfile = [select Id from Profile limit 1];

        //User newUser = new User(Username='ekrivobok@yandex.ru',LastName='Kryvobok',Email='ekrivobok@yandex.ru',Alias='EuKr',CommunityNickname='EugenKr',TimeZoneSidKey='Pacific/Fiji',LocaleSidKey='ar',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',ProfileId=newProfile.Id);
        //insert newUser;

        id id1 = UserInfo.getUserId();
        User newUser = [select id from User where id=:id1];
        
        ID UserID = UserInfo.getUserId();
    Employee_Profile__c empl = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        empl.User_ID__c = UserID;
        insert empl;
        
        Employee_Profile__c newEmployeeProfile = new Employee_Profile__c(First_Name__c='Eugen', Last_Name__c='Kryvobok',User_Id__c=newUser.Id);
        insert newEmployeeProfile;
        
        ID iDealRT = null;
        
        RecordType[] recTypeIDs2  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Ibanking_Project__c' limit 1];
        for(RecordType rtItem: recTypeIDs2)
        {
            iDealRT = rtItem.ID;
        }
        
        
        Ibanking_Project__c newDeal = new Ibanking_Project__c(Requesting_conflict_clearance__c = 'No',RecordTypeId=iDealRT ,Transaction_Type__c='Public', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='tttest Test Deal', Industry__c='Other', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        //Ibanking_Project__c newDeal = [Select i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c, i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        newDeal.Name='TestProj';
        newDeal.Client__c = testAccount.Id;
        newDeal.EmailTriggerParams__c='STAFFER, ProjectStaffRequest';
        newDeal.Est_Transaction_Size__c=12.4;
        newDeal.Full_Description_of_Transaction__c='descr';
        newDeal.Stage__c='Expense Code Request';
        //newDeal.Staffer__c=newEmployeeProfile.Id;
        insert newDeal;
        
        newDeal.Milestone_Agreements_Received_Date__c       = date.newInstance(2009,01,01);
        newDeal.Milestone_AML_OFAC_Cleared_Date__c          = date.newInstance(2009,01,01);
        newDeal.Milestone_DealTeamConflictCheckCleared__c   = date.newInstance(2009,01,01);
        newDeal.Milestone_Expense_Code_Date__c              = date.newInstance(2009,01,01);
        newDeal.Milestone_FINCEN_Cleared_Date__c            = date.newInstance(2009,01,01);
        newDeal.Milestone_KYC_Cleared_Date__c               = date.newInstance(2009,01,01);
        newDeal.Milestone_NBRC_Approved_Date__c             = date.newInstance(2009,01,01);
        newDeal.Milestone_NBRC_Committee_Date__c            = date.newInstance(2009,01,01);
        //newDeal.Milestone_Staffing_Date__c                    = date.newInstance(2009,01,01);
        
        update newDeal;     
        
        
        ID testProjId = [select Id from Ibanking_Project__c where Name='TestProj'].Id;
        
        Potential_Buyer_Investor__c testBuyer1 = new Potential_Buyer_Investor__c(Type__c='Financial', Project__c=testProjId, TargetBuyer__c = testAccount.Id);
        Potential_Buyer_Investor__c testBuyer2 = new Potential_Buyer_Investor__c(Type__c='Strategic', Project__c=testProjId, TargetBuyer__c = testAccount.Id);
        Potential_Buyer_Investor__c testBuyer3 = new Potential_Buyer_Investor__c(Declined__c=Date.newInstance(2009,1,1),    Project__c=testProjId, TargetBuyer__c = testAccount.Id);
        insert testBuyer1;
        insert testBuyer2;
        insert testBuyer3;
        con.lProjectList = 'TestProj';
        List<Integer> tot = con.getTotal();
    }
}