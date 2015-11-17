/****************************************************************************************
Name            : psaMilestone_Test
Author          : Julia Kolesnik
Created Date    : January 23, 2014
Description     : Test class for psaMilestone.trigger and psaMilestoneHandler.cls
******************************************************************************************/
@isTest
private class psaMilestone_Test {

    static testMethod void test_trigger() {
    	Account account = new Account();
    	account.Name = 'Test Acc';
    	insert account;
    	
    	Opportunity opp = new Opportunity(Name='Test Opp', StageName='Needs Analysis', Amount=25000);
        opp.CloseDate = date.newInstance(2011, 7, 11);
        opp.Projected_Start_Date__c = date.newInstance(2011, 7, 11).addDays(20);
        opp.AccountId = account.Id;
        insert opp;
    	
        pse__Proj__c proj = new pse__Proj__c();
        proj.pse__Opportunity__c = opp.Id;
        proj.Name = 'Test';
        proj.JIRA_Project_Name__c = 'TEST';
        proj.pse__Is_Active__c = true;
        proj.pse__Is_Billable__c = true;
        proj.pse__Allow_Timecards_Without_Assignment__c = true;
        insert proj;
        
        pse__Project_Phase__c projectPhase = new pse__Project_Phase__c();
        projectPhase.pse__Project__c = proj.Id;
        insert projectPhase;
        
        pse__Milestone__c parentmilestone = new pse__Milestone__c();
        parentmilestone.pse__Project__c = proj.Id;
        parentmilestone.pse__Default_Bill_Rate__c = 10;
        parentmilestone.pse__Target_Date__c = date.today();
        parentmilestone.pse__Actual_Date__c = Date.today();
        parentmilestone.Project_Phase__c = projectPhase.Id;
        parentmilestone.pse__Status__c = 'Open';
        parentmilestone.RecordTypeId = psaUtils.idRTParentTask;
        insert parentmilestone;
        
        pse__Milestone__c childmilestone = new pse__Milestone__c();
        childmilestone.pse__Project__c = proj.Id;
        childmilestone.Parent_Milestone__c = parentmilestone.Id;
        childmilestone.pse__Actual_Date__c = Date.today();
        childmilestone.pse__Target_Date__c = date.today();
        childmilestone.pse__Status__c = 'Open';
        childmilestone.Project_Phase__c = projectPhase.Id;
        childmilestone.RecordTypeId = psaUtils.idRTChildTask;
        insert childmilestone;
        
        for (pse__Project_Phase__c item:[Select Id, Status__c FROM pse__Project_Phase__c WHERE Id=:projectPhase.Id]) {
        	system.assertEquals(item.Status__c, 'Open');						
        }
        
        parentmilestone.pse__Status__c = 'Canceled';
        update parentmilestone;
        
        for (pse__Milestone__c item:[Select Id, pse__Status__c FROM pse__Milestone__c WHERE Id=:childmilestone.Id]) {
        	system.assertEquals(item.pse__Status__c, parentmilestone.pse__Status__c);						
        }
        
        for (pse__Project_Phase__c item:[Select Id, Status__c FROM pse__Project_Phase__c WHERE Id=:projectPhase.Id]) {
        	system.assertEquals(item.Status__c, 'Complete');						
        }
        
        parentmilestone.pse__Status__c = 'Open';
        update parentmilestone;
        
        for (pse__Project_Phase__c item:[Select Id, Status__c FROM pse__Project_Phase__c WHERE Id=:projectPhase.Id]) {
        	system.assertEquals(item.Status__c, 'In Progress');						
        }
    }
}