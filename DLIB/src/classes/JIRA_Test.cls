/**
* @ClassName 		: JIRA_Test
* @JIRATicket   	: SILVERLINE-212
* @CreatedOn    	: 08/JAN/2014
* @ModifiedBy   	: Julia Kolesnik
* @Description 	 	: Test class for JIRA integration
*/ 

@isTest
private class JIRA_Test {
	static void createTestData() {
		pse__Proj__c newProj = new pse__Proj__c();
		newProj.Name = 'Proba';
		newProj.JIRA_Project_Name__c = 'PROB';
		insert newProj;
	}

	
    static testMethod void test_integration() {
        createTestData();
    	Test.startTest();

			JIRAWorklogsRefresh j = new JIRAWorklogsRefresh(new List<SF_Issue__c>());
			j = new JIRAWorklogsRefresh('PROB-123');
			j = new JIRAWorklogsRefresh();
			j.run();
  	
        	JIRAIssuesBatch bI = new JIRAIssuesBatch();

			bI.isMigration = true;
			bI.jql = 'updated>-2h';
			bI.numberOfHours = -999999;
			bI.runWorklogs = false;        	
			Database.executeBatch(bI);
			
			JIRAWorklogsBatch bW = new JIRAWorklogsBatch();
			Database.executeBatch(BW);
			
			new JIRAIssues.Issue();
			new JIRAIssues.Comment();
			new JIRAIssues.Field();
			new JIRAIssues.Timetracking();
			new JIRAIssues.Version();
			new JIRAIssues.Comments();
			new JIRAWorklogsRefresh.JIRAWorklogs();
			new JIRAWorklogsRefresh.Worklog();
			new JIRAWorklogsRefresh.Author();
        Test.stopTest();
    }
}