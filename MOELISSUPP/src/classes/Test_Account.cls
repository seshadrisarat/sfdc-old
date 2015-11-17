@isTest
private class Test_Account {
    static testMethod void Account_Change_DevCode_Test() {
        Account acc = new Account();
		acc.BillingStreet = 'test';
		acc.BillingCountry = 'test';
		acc.BillingCity = 'test';
		acc.BillingState = 'test';
		acc.BillingPostalCode = 'test';
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Test.startTest();
		ApexPages.currentPage().getParameters().put('aid', acc.Id);
		Account_Change_DevCode cls = new Account_Change_DevCode();
		cls.autoRun();
		Test.stopTest();
    }
    
    static testMethod void Account_Change_DevCode2_Test() {
        Account acc = new Account();
		acc.BillingStreet = 'test';
		acc.BillingCountry = 'test';
		acc.BillingCity = 'test';
		acc.BillingState = 'test';
		acc.BillingPostalCode = 'test';
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Account acc2 = new Account();
		acc2.Name = 'Test';
		insert acc2;
		Test.startTest();
		Account_Change_DevCode2.AutoUpdate(''+acc.Id);
		Account_Change_DevCode2.AutoUpdate(''+acc2.Id);
		Test.stopTest();
    }
    
    static testmethod void Account_Custom_Page_Test1() {
    	Account acc = new Account();
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
		Call_Log__c cl = new Call_Log__c();
		cl.Date__c = Date.today();
		insert cl;
		Call_Log_Contact__c clc_del = new Call_Log_Contact__c();
		clc_del.Call_Log__c = cl.Id;
		clc_del.Contact__c = cntct.Id;
		insert clc_del;
		Test.startTest();
		ApexPages.currentPage().getParameters().put('id', acc.Id);
		ApexPages.currentPage().getParameters().put('accid', acc.Id);
		ApexPages.currentPage().getParameters().put('delid', cl.Id);
		Account_Custom_Page cls = new Account_Custom_Page();
		cls.delRecord();
		test.stopTest();
    }
    
    static testmethod void Account_Custom_Page_Test2() {
    	Account acc = new Account();
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
		Call_Log__c cl = new Call_Log__c();
		cl.Date__c = Date.today();
		insert cl;
		Call_Log_Contact__c clc_del = new Call_Log_Contact__c();
		clc_del.Call_Log__c = cl.Id;
		clc_del.Contact__c = cntct.Id;
		insert clc_del;
		Test.startTest();
		ApexPages.currentPage().getParameters().put('id', acc.Id);
		Account_Custom_Page cls = new Account_Custom_Page();
		cls.getCallLogs();
		test.stopTest();
    }
    
    public static testmethod void Account_DealAwareness_total_Test() {
		// Preparing data
		Account accObj = new Account(Name = 'Test Account');
		insert accObj;
		Ibanking_Project__c testDeal = new Ibanking_Project__c(Name = 'Test Deal',Client__c = accObj.Id);
		insert testDeal;
		system.debug('*************** Account ****************** '+accObj);
		system.debug('*************** testDeal ****************** '+testDeal);
		
		// Insert test data in test db
		system.debug('*************** Inset in DB 3 Deals__c ******************');
		List<Ibanking_Project__c> deals = new List<Ibanking_Project__c>();
		for (Integer i=0; i<3; i++) {
			deals.add(new Ibanking_Project__c(Client__c = accObj.Id));
		}
		insert deals;
		
		system.debug('*************** Inset in DB 4 Deal_Related_Parties__c ******************');
		List<Deal_Related_Parties__c> drp = new List<Deal_Related_Parties__c>();
		for (Integer i=0; i<4; i++) {
			drp.add(new Deal_Related_Parties__c(Company__c = accObj.Id,Deal__c = testDeal.Id));
		}
		insert drp;
		
		system.debug('*************** Inset in DB 5 Potential_Buyer_Investor__c ******************');
		List<Potential_Buyer_Investor__c> pbi = new List<Potential_Buyer_Investor__c>();
		for (Integer i=0; i<5; i++) {
			pbi.add(new Potential_Buyer_Investor__c(TargetBuyer__c = accObj.Id,Project__c = testDeal.Id));
		}
		insert pbi;

		system.Test.startTest();
		
		Account_DealAwareness_total TestObj = new Account_DealAwareness_total();
		TestObj.accObj = accObj;
		
		// Running tests
		system.debug('========== TEST companyId ============ >>> '+TestObj.companyId);
		system.debug('========== TEST companyName ============ >>> '+TestObj.companyName);
		system.debug('========== TEST repLink ============ >>> '+TestObj.repLink);
		system.debug('========== TEST dealCount ============ >>> '+TestObj.dealCount);
		system.debug('========== TEST dealRelatedPartyCount ============ >>> '+TestObj.dealRelatedPartyCount);
		system.debug('========== TEST potentialBuyerInvestorCount ============ >>> '+TestObj.potentialBuyerInvestorCount);
		
		system.Test.stopTest();
	}
	
	public static testmethod void AccountHistoryComponentController_Test() {
		Account acc = new Account();
		acc.Name = 'Test';
		acc.Client_Code__c = 'test';
		insert acc;
		AccountHistory ah;
		List<AccountHistory> ahLst = new List<AccountHistory>();
		ah = new AccountHistory(AccountId=acc.Id);
		ah.Field = 'created';
		ahLst.add(ah);
		ah = new AccountHistory(AccountId=acc.Id);
		ah.Field = 'Description';
		ahLst.add(ah);
		ah = new AccountHistory(AccountId=acc.Id);
		ah.Field = 'Industry';
		ahLst.add(ah);
		insert ahLst;
		Test.startTest();
		AccountHistoryComponentController cls = new AccountHistoryComponentController();
		cls.accountId = acc.Id;
		cls.getHistories();
		AccountHistoryComponentController.returnFieldLabel('Subject');
		AccountHistoryComponentController.returnFieldLabel('Status');
		Test.stopTest();
	} 
}