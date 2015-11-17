@isTest
private class SL_Test_ContactTriggerHandler {
	
	@isTest 
	static void test_upsertOutlookSync() {

		List<Account> lstAcc = new List<Account>{
			new Account(Name='test1'), 
			new Account(Name='American Securities LLC')
		};
		insert lstAcc;

		List<Contact> lstCon = new List<Contact>{
			new Contact(LastName='test1', AccountId=lstAcc[0].Id), 
			new Contact(LastName='test2', AccountId=lstAcc[1].Id), 
			new Contact(LastName='test3', AccountId=lstAcc[1].Id), 
			new Contact(LastName='test4', AccountId=lstAcc[1].Id)
		};
		insert lstCon;

		List<Outlook_Sync__c> lstOS = new List<Outlook_Sync__c>{
			new Outlook_Sync__c(Contact__c=lstCon[3].Id, AS_Person__c=lstCon[1].Id),
			new Outlook_Sync__c(Contact__c=lstCon[3].Id, AS_Person__c=lstCon[2].Id)
		};
		insert lstOS;

		lstCon[0].AccountId = lstAcc[1].Id;
		update lstCon[0];
	}
}