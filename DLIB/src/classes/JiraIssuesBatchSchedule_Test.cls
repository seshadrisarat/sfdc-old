@isTest
private class JiraIssuesBatchSchedule_Test {
	
	@isTest static void test_method_one() {   
         Test.startTest();   
         	system.schedule( 'TEST - Jira Issues and Worklogs Hourly', '0 0 0/1 1/1 * ? *', new JiraIssuesBatchSchedule() );
         Test.stopTest();
	}
}