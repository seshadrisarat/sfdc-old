@isTest
private class Test_Deal {

    @isTest
    static void testCompanyList_Search() {
      Test.startTest();
      CompanyList_Search cls1 = new CompanyList_Search();
      cls1.searchType='proj';
      cls1.searchFilterProj = cls1.searchFilter;
      cls1.addFilter();
      cls1.filterIndex = 0;
      cls1.changeFilter1();
      cls1.doSearch();
      cls1.changeType();

      cls1.addFilter();
      cls1.changeFilter1();
      cls1.voidAction();
      cls1.changeFilter2();
      cls1.doSearch();
      cls1.changeType();
      Test.stopTest();
    }


    static testMethod void DealContacts_Create_Test() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        Contact cntct = new Contact();
        cntct.AccountId = acc.Id;
        cntct.FirstName = 'Test';
        cntct.LastName = 'Test';
        insert cntct;
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c();
        IbankProjObj.Transaction_Sub_Type__c = 'Other';
        IbankProjObj.Transaction_Feature__c = 'Other';
        IbankProjObj.Client__c = acc.Id;
        insert IbankProjObj;
        Project_Client_Contact__c cnt = new Project_Client_Contact__c();
        cnt.Moelis_Project__c = IBankProjObj.Id;
        cnt.Client_Contact__c = cntct.Id;
        insert cnt;
        Test.startTest();
        DealContacts_Create cls = new DealContacts_Create(new Apexpages.Standardcontroller(cnt));
        cls.save();
        cls.save_new();
        cls.cancel();
        Test.stopTest();
    }
    
    static testmethod void DealRelParties_AddMultiple_Test(){
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        Contact cntct = new Contact();
        cntct.AccountId = acc.Id;
        cntct.FirstName = 'Test';
        cntct.LastName = 'Test';
        insert cntct;
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c();
        IbankProjObj.Transaction_Sub_Type__c = 'Other';
        IbankProjObj.Transaction_Feature__c = 'Other';
        IbankProjObj.Client__c = acc.Id;
        insert IbankProjObj;
        Project_Client_Contact__c cnt = new Project_Client_Contact__c();
        cnt.Moelis_Project__c = IBankProjObj.Id;
        cnt.Client_Contact__c = cntct.Id;
        insert cnt;
        Deal_Related_Parties__c rp = new Deal_Related_Parties__c();
        rp.Company__c = acc.Id;
        rp.Deal__c = IbankProjObj.Id;
        insert rp;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('did', IbankProjObj.Id);
        DealRelParties_AddMultiple cls = new DealRelParties_AddMultiple();
        cls.save();
        cls.AddNew();
        cls.save_close();
        cls.deleteContainer = '0';
        cls.ToDelete();
        Test.stopTest();
    }
    
    static testmethod void DealSharingRules_Test(){
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        Contact cntct = new Contact();
        cntct.AccountId = acc.Id;
        cntct.FirstName = 'Test';
        cntct.LastName = 'Test';
        insert cntct;
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c();
        IbankProjObj.Transaction_Sub_Type__c = 'Other';
        IbankProjObj.Transaction_Feature__c = 'Other';
        IbankProjObj.Client__c = acc.Id;
        insert IbankProjObj;
        Project_Client_Contact__c cnt = new Project_Client_Contact__c();
        cnt.Moelis_Project__c = IBankProjObj.Id;
        cnt.Client_Contact__c = cntct.Id;
        insert cnt;
        Deal_Related_Parties__c rp = new Deal_Related_Parties__c();
        rp.Company__c = acc.Id;
        rp.Deal__c = IbankProjObj.Id;
        insert rp;
        User newUser = [SELECT id, name FROM User WHERE IsActive = true LIMIT 1].get(0);
        Group newGroup = [SELECT id, name FROM Group LIMIT 1].get(0);
        Employee_Profile__c empl = new Employee_Profile__c();
        empl.First_Name__c = 'Test';
        empl.Last_Name__c = 'Test';
        empl.User_ID__c = newUser.Id;
        empl.Title__c = 'Managing Director';
        //empl.Contact__c = cntct.Id;
        insert empl;
        Project_Resource__c pr = new Project_Resource__c();
        pr.Project__c = IbankProjObj.Id;
        pr.Banker__c = empl.Id;
        pr.Status__c='Active';
        insert pr;
        Ibanking_Project__Share ps = new Ibanking_Project__Share();
        ps.ParentId = IbankProjObj.Id;
        ps.UserOrGroupId = newGroup.Id;
        ps.AccessLevel = 'Edit';
        ps.RowCause = 'Manual';
        insert ps;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('did', IbankProjObj.Id);
        DealSharingRules.UpdateShare(new List<Id>{IbankProjObj.Id});
        Test.stopTest();
    }
}