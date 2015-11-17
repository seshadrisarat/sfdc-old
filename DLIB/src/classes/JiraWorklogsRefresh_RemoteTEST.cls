@isTest
private class JiraWorklogsRefresh_RemoteTEST {
	
	@isTest static void test_method_one() {
		SF_Issue__C iss = new SF_Issue__C(Name='TEST-123');
		insert iss;
		JiraWorklogsRefresh_Remote.refreshWorklogsWithIssueDEL(iss.Id);
		JiraWorklogsRefresh_Remote.query('Select Id from Account');
		JiraWorklogsRefresh_Remote.refreshIssueWithKey('TEST-123');
	}
	
	
}