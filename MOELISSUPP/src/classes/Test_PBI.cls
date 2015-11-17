@isTest
private class Test_PBI {
    static testMethod void PBI_AddMultiple_Test1() {
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
        Potential_Buyer_Investor__c pbi = new Potential_Buyer_Investor__c(TargetBuyer__c = acc.Id);
        pbi.Project__c = IbankProjObj.Id;
        insert pbi;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('pid', IbankProjObj.Id);
        PBI_AddMultiple cls = new PBI_AddMultiple();
        cls.AddNew();
        cls.deleteContainer = '0:1';
        cls.ToDelete();        
        Test.stopTest();
    }
    
    static testMethod void PBI_AddMultiple_Test2() {
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
        Potential_Buyer_Investor__c pbi = new Potential_Buyer_Investor__c(TargetBuyer__c = acc.Id);
        pbi.Project__c = IbankProjObj.Id;
        insert pbi;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('pid', IbankProjObj.Id);
        PBI_AddMultiple cls = new PBI_AddMultiple();
        cls.deleteContainer = '0';
        cls.ToDelete();        
        Test.stopTest();
    }
    
    static testMethod void PBI_AddMultiple_Test3() {
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
        Potential_Buyer_Investor__c pbi = new Potential_Buyer_Investor__c(TargetBuyer__c = acc.Id);
        pbi.Project__c = IbankProjObj.Id;
        insert pbi;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('pid', IbankProjObj.Id);
        PBI_AddMultiple cls = new PBI_AddMultiple();
        //cls.PBI_List.clear();
        //cls.PBI_List.add(pbi);
        cls.PBI_List.clear();
        try{
        	cls.save();
        }catch (Exception e){}
        try{
        	cls.save_close();
        }catch (Exception e){}
        //cls.save_close();
        Test.stopTest();
    }
    
    static testMethod void PBI_Contact_Create_Test() {
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
        Potential_Buyer_Investor__c pbi = new Potential_Buyer_Investor__c(TargetBuyer__c = acc.Id);
        pbi.Project__c = IbankProjObj.Id;
        insert pbi;
        Potential_Buyer_Investor_Contact__c pbic = new Potential_Buyer_Investor_Contact__c();
        pbic.Target_Buyer__c = pbi.Id;
        pbic.Contact__c = cntct.Id;
        insert pbic;
        Test.startTest();
        PBI_Contact_Create cls = new PBI_Contact_Create(new Apexpages.Standardcontroller(pbic));
        cls.save();
        cls.save_new();
        cls.cancel();
        Test.stopTest();
    }
    
    static testMethod void PBISharingRules_Test() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
		User newUser = [SELECT id, name FROM User LIMIT 1].get(0);
        Group newGroup = [SELECT id, name FROM Group LIMIT 1].get(0);
        Employee_Profile__c empl = new Employee_Profile__c();
		empl.First_Name__c = 'Test';
		empl.Last_Name__c = 'Test';
		empl.Title__c = 'Managing Director';
		empl.User_ID__c = newUser.Id;
		insert empl;
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c();
        IbankProjObj.Transaction_Sub_Type__c = 'Other';
        IbankProjObj.Transaction_Feature__c = 'Other';
        IbankProjObj.Client__c = acc.Id;
        insert IbankProjObj;
        Project_Resource__c pr = new Project_Resource__c();
        pr.Project__c = IbankProjObj.Id;
        pr.Banker__c = empl.Id;
        pr.Status__c='Active';
        insert pr;
        Potential_Buyer_Investor__c pbi = new Potential_Buyer_Investor__c(TargetBuyer__c = acc.Id);
        pbi.Project__c = IbankProjObj.Id;
        insert pbi;
        Potential_Buyer_Investor_Contact__c pbic = new Potential_Buyer_Investor_Contact__c();
        pbic.Target_Buyer__c = pbi.Id;
        pbic.Contact__c = cntct.Id;
        insert pbic;
        Potential_Buyer_Investor_Deal_Team__c pbidt = new Potential_Buyer_Investor_Deal_Team__c();
        pbidt.Target_Buyer__c = pbi.Id;
        pbidt.Banker__c = empl.Id;
        insert pbidt;
        
        Test.startTest();
        PBISharingRules.UpdateShare(new List<Id>{pbi.Id});
        Test.stopTest();
    }
}