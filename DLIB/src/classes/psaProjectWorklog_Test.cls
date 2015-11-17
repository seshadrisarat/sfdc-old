/****************************************************************************************
Name            : psaMilestone_Test
Author          : Julia Kolesnik
Created Date    : January 28, 2014
Description     : Test class for psaProjectWorklog.trigger and psaProjectWorklogHandler.cls
******************************************************************************************/
@isTest
private class psaProjectWorklog_Test {

    static testMethod void test_trigger() {
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
        
        SF_Issue__c issue = new SF_Issue__c(Name='test-1');
        insert issue;

        Worklog__c worklog1 = new Worklog__c(sf_issue__c = issue.id, PSA_Project__c = proj.Id, PSA_Milestone__c = milestone.Id, JIRA_Contact__c = resource.Id);
        worklog1.JIRA_Start_Date__c = datetime.newInstance(date.today().toStartofWeek(), time.newInstance(1,0,0,0));
        worklog1.Hours__c = 2;
        
        test.startTest();
        insert worklog1;
        
        string key = (worklog1.PSA_Project__c+'|'+worklog1.PSA_Milestone__c+'|'+worklog1.JIRA_Contact__c+'|'+String.valueOf(worklog1.JIRA_Start_Date__c).substring(0,10));
        
        for (Worklog__c item:[Select Id, Hours__c, Timecard_Key__c, Day_Of_Week__c, Week_Start_Date__c, JIRA_Start_Date__c FROM Worklog__c WHERE Id=:worklog1.Id limit 1]) {
			system.assertEquals(item.Day_Of_Week__c,'Sunday');
			system.assertEquals(item.Timecard_Key__c, key);
			worklog1 = item;
		}
        
        for (pse__Timecard_Header__c item:[Select Id, Timecard_Key__c, pse__Monday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c, 
						pse__Thursday_Hours__c, pse__Friday_Hours__c, pse__Saturday_Hours__c, pse__Sunday_Hours__c,
						pse__Project__c, pse__Milestone__c, pse__Resource__c, pse__Start_Date__c FROM pse__Timecard_Header__c WHERE Timecard_Key__c=:key]) {
			system.assertEquals(item.pse__Sunday_Hours__c,worklog1.Hours__c);
			system.assertEquals(worklog1.Timecard_Key__c,item.Timecard_Key__c);
		}
		
		worklog1.Hours__c = 3;
		update worklog1;
		
		Worklog__c worklog2 = new Worklog__c(sf_issue__c = issue.id, PSA_Project__c = proj.Id, PSA_Milestone__c = milestone.Id, JIRA_Contact__c = resource.Id);
        worklog2.JIRA_Start_Date__c = date.today().toStartofWeek()+1;
        worklog2.Hours__c = 2;
        insert worklog2;
		
		for (pse__Timecard_Header__c item:[Select Id, Timecard_Key__c, pse__Monday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c, 
						pse__Thursday_Hours__c, pse__Friday_Hours__c, pse__Saturday_Hours__c, pse__Sunday_Hours__c,
						pse__Project__c, pse__Milestone__c, pse__Resource__c, pse__Start_Date__c FROM pse__Timecard_Header__c WHERE Timecard_Key__c=:key]) {
			system.assertEquals(item.pse__Sunday_Hours__c,worklog1.Hours__c);
			system.assertEquals(item.pse__Monday_Hours__c,worklog2.Hours__c);
		}
		
		delete worklog2;
		for (pse__Timecard_Header__c item:[Select Id, Timecard_Key__c, pse__Monday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c, 
						pse__Thursday_Hours__c, pse__Friday_Hours__c, pse__Saturday_Hours__c, pse__Sunday_Hours__c,
						pse__Project__c, pse__Milestone__c, pse__Resource__c, pse__Start_Date__c FROM pse__Timecard_Header__c WHERE Timecard_Key__c=:key]) {
			system.assertEquals(item.pse__Sunday_Hours__c,worklog1.Hours__c);
			system.assertEquals(item.pse__Monday_Hours__c,0);
		}
		
		test.stopTest();
    }
}