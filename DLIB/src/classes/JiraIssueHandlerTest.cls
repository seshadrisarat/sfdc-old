@isTest
private class JiraIssueHandlerTest {
	
	@isTest static void itShouldUpdateMilestones() {
   	pse__Proj__c proj = new pse__Proj__c();
        proj.Name = 'Test';
        proj.JIRA_Project_Name__c = 'TEST';
        proj.pse__Is_Active__c = true;
        proj.pse__Is_Billable__c = true;
        proj.pse__Allow_Timecards_Without_Assignment__c = true;
        insert proj;
        
        pse__Milestone__c milestone = new pse__Milestone__c();
        milestone.pse__Project__c = proj.Id;
        milestone.pse__Default_Bill_Rate__c = 10;
        milestone.pse__Target_Date__c = date.today();
        insert milestone;
        
        Contact resource = new Contact();
        resource.LastName = 'Test LN';
        resource.pse__Is_Resource_Active__c = true;
        resource.pse__Is_Resource__c = true;
        insert resource;
        
        SF_Issue__c issue = new SF_Issue__c(Name='test-1', Project__c = proj.Id);
        insert issue;

        Worklog__c worklog1 = new Worklog__c(sf_issue__c = issue.id, PSA_Project__c = proj.Id, JIRA_Contact__c = resource.Id);
        worklog1.JIRA_Start_Date__c = datetime.newInstance(date.today().toStartofWeek(), time.newInstance(1,0,0,0));
        worklog1.Hours__c = 2;

        insert worklog1;

        test.startTest();
        
       	issue.Milestone__c = milestone.id;
       	update issue;

       	//system.assertEquals(issue.Milestone__c, worklog1.PSA_Milestone__c);

		test.stopTest();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}