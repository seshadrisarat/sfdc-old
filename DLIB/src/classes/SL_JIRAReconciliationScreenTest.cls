/****************************************************************************************
Name            : SL_JIRAReconciliationScreenTest
Author          : Julia Kolesnik
Created Date    : March 04, 2014
Description     : Test class for SL_JIRAReconciliationScreenController.cls
******************************************************************************************/
@isTest
private class SL_JIRAReconciliationScreenTest {
	
	static testMethod void CreateData() {
    	pse__Proj__c proj = new pse__Proj__c();
        proj.Name = 'Prob';
        proj.JIRA_Project_Name__c = 'PROBA';
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
        
        SF_Issue__c issue = new SF_Issue__c(Name='test-1');
        insert issue;

        Worklog__c worklog1 = new Worklog__c(sf_issue__c = issue.id, PSA_Project__c = proj.Id, PSA_Milestone__c = milestone.Id, JIRA_Contact__c = resource.Id);//
        worklog1.JIRA_Start_Date__c = datetime.newInstance(date.today().toStartofWeek(), time.newInstance(0,0,0,0));
        worklog1.Hours__c = 2;
        insert worklog1;
        		
    }
	
	
    static testMethod void myUnitTest() {
    	CreateData();
        test.startTest();

        pse__timecard_header__c tch = new pse__timecard_header__c(pse__submitted__c = false, pse__resource__r = new Contact(LastName = 'test', JIra_User_Name__c = 'test'));

        new SL_JIRAReconciliationScreenController.Item(tch);
        new SL_JIRAReconciliationScreenController.WorklogItem();
        new SL_JIRAReconciliationScreenController.Author();
        new SL_JIRAReconciliationScreenController.Worklog();
        new SL_JIRAReconciliationScreenController.JIRAWorklog();
        new SL_JIRAReconciliationScreenController.Issue();
        new SL_JIRAReconciliationScreenController.JIRAIssue();

        SL_JIRAReconciliationScreenController ctrl = new SL_JIRAReconciliationScreenController();
        ctrl.tc.pse__Start_Date__c = datetime.newInstance(date.today().toStartofWeek(), time.newInstance(0,0,0,0)).date();
        ctrl.refresh();
        
        for (SL_JIRAReconciliationScreenController.Item item:ctrl.lstMatches) {
			item.IsSubmitted = true;
		}
		
		ctrl.approve();
		
		list<SL_JIRAReconciliationScreenController.Issue> lstI = SL_JIRAReconciliationScreenController.getIssuesFromJqlSearch('test');
		
		//list<SL_JIRAReconciliationScreenController.WorklogItem> lstW = SL_JIRAReconciliationScreenController.getWorklogInfo(Date.newInstance(2014,01,01), Date.newInstance(2014,01,07));
		
        test.stopTest();
    }
}