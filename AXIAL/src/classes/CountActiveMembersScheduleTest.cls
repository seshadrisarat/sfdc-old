@isTest
private class CountActiveMembersScheduleTest {
	
	@isTest static void testExecute() {
		Account a = new Account(Investor_Classification__c='Client', Name='Test Acct');
		insert a;
		Test.startTest();
			CountActiveMembersSchedule j = new CountActiveMembersSchedule();
			j.runJob();
		Test.stopTest();
	}
	
}