/****************************************************************************************
Name            : psaAssignmentHandlerTest
Author          : Julia Kolesnik
Created Date    : March 07, 2014
See				: https://silverline.jira.com/browse/SLFF-35
Description     : Test for psaAssignmentHandler.cls
******************************************************************************************/
@isTest
private class psaAssignmentHandlerTest {

    static testMethod void test_trigger() {
        createData();
        
        Test.startTest();
        system.debug(LoggingLevel.ERROR, 'Assignment about to insert...' + JSON.serialize(assignment));
        insert assignment;
        
        for (pse__Assignment__c item:[Select Id, pse__Bill_Rate__c FROM pse__Assignment__c WHERE Id=:assignment.Id limit 1]) 
        {
            system.assertEquals(item.pse__Bill_Rate__c, project.TA__c);
        }
        
        assignment.pse__Role__c = 'Subject Matter Expert';
        update assignment;
        
        for (pse__Assignment__c item:[Select Id, pse__Bill_Rate__c FROM pse__Assignment__c WHERE Id=:assignment.Id limit 1]) 
        {
            system.assertEquals(item.pse__Bill_Rate__c, project.SME__c);
        }
        
        project.SME__c = 222;
        update project;
        
        for (pse__Assignment__c item:[Select Id, pse__Bill_Rate__c FROM pse__Assignment__c WHERE Id=:assignment.Id limit 1]) 
        {
            system.assertEquals(item.pse__Bill_Rate__c, project.SME__c);
        }
        Test.stopTest();
    }
    
    private static void createData() {
		insert project;
		system.debug(LoggingLevel.ERROR, 'Project created' + JSON.serialize(project));
		insert resource;
		system.debug(LoggingLevel.ERROR, 'Resource created' + JSON.serialize(resource));
		insert schedule;
		system.debug(LoggingLevel.ERROR, 'Schedule created' + JSON.serialize(schedule));
		insert new pse__Permission_Control__c(pse__User__c=UserInfo.getUserId(), pse__Resource__c=resource.Id, pse__Timecard_Entry__c=true, pse__Timecard_Ops_Edit__c = true, pse__Staffing__c = true);
		insert new pse__Permission_Control__c(pse__User__c=UserInfo.getUserId(), pse__Project__c= project.Id, pse__Timecard_Ops_Edit__c = true, pse__Staffing__c=true);
		system.debug(LoggingLevel.ERROR, 'Permission controls created');
    }
    
    private static pse__Proj__c project {
		get {
			if (project == null) {
				project = new pse__Proj__c(
					Name = 'Test Project',
        			pse__Is_Active__c = true,
        			pse__Is_Billable__c = true,
        			BA__c = 100,
        			PC__c = 110,
        			EM__c = 120, 
        			SA__c = 130, 
					SME__c = 140, 
					SM__c = 150, 
					TA__c = 160,
        			pse__Allow_Timecards_Without_Assignment__c = true
				);
			}
			return project;
		} set;
	}
    
    private static pse__Assignment__c assignment {
		get {
			if (assignment == null) {
				assignment = new pse__Assignment__c(
					pse__Project__c = project.Id,
					pse__Resource__c = resource.Id,
					pse__Role__c = 'Technical Architect',
					pse__Is_Billable__c = true,
        			pse__Schedule__c = schedule.Id,
        			pse__Bill_Rate__c = 1
				);
			}
			return assignment;
		} set;
	}
	
	private static Contact resource {
		get {
			if (resource == null) {
				resource = new Contact(
					LastName = 'Test Contact',
					pse__Default_Cost_Rate__c = 100,
					pse__Resource_Role__c='Technical Architect'
				);
			}
			return resource;
		} set;
	}
	
	private static pse__Schedule__c schedule {
		get {
			if (schedule == null) {
				schedule = new pse__Schedule__c(
					pse__Start_Date__c = date.today().addDays(-7),
					pse__End_Date__c = date.today().addDays(1),
					pse__Monday_Hours__c = 8,
					pse__Tuesday_Hours__c = 8,
					pse__Wednesday_Hours__c = 8,
					pse__Thursday_Hours__c = 8,
					pse__Friday_Hours__c = 8
				);
			}
			return schedule;
		} set;
	}
	
}