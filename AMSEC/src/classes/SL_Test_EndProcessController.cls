@isTest
private class SL_Test_EndProcessController {
	
	private static ApexPages.Standardcontroller sc;
	private static SL_EndProcessController ep;

	@isTest 
	static void test_EndClosedProcess() {

		Account objAcc = new Account(Name='TestAcc1');
		insert objAcc;

		Deal__c objDeal = new Deal__c(
			Deal_Status__c='Closed', 
			Buyer__c='American Securities', 
			Close_Date__c=System.today(), 
			Salesforce_Company__c=objAcc.Id
		);
		insert objDeal;

		External_Working_Group_Member__c objWG = new External_Working_Group_Member__c(Deal__c = objDeal.Id);
		insert objWG;

		sc = new ApexPages.StandardController(objDeal);

		ep = new SL_EndProcessController(sc);

		ep.getItems();

		ep.saveClosedProcess();
	}

	@isTest 
	static void test_EndDeadProcess() {

		Account objAcc = new Account(Name='TestAcc1');
		insert objAcc;

		Deal__c objDeal = new Deal__c(
			Deal_Status__c='Dead', 
			Buyer__c='American Securities', 
			Salesforce_Company__c=objAcc.Id
		);
		insert objDeal;

		sc = new ApexPages.StandardController(objDeal);

		ep = new SL_EndProcessController(sc);

		ep.getItems();

		ep.saveDeadProcess();
	}
}