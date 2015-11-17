@isTest(seealldata = true)
private class AccountEmailOptResetJobTest {
	
	static testMethod void test() {
        Test.startTest();
        Id batchJobId = Database.executeBatch(new AccountEmailOptResetJob());
        Test.stopTest();
    }
}