/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SL_TestActivityMilestoneBatch 
{
	///Test code for Opportunity batch
    static testMethod void testOpportunity() 
    {
    	List<Event> lstEvents = new List<Event>();///List to hold the event records created
    	List<Task> lstTasks = new List<Task>();///List to hold the task records created
    	
    	///Create account record
    	Account objAccount = new Account
    	(
    		Name = 'Test Account 1'
    	);
    	
    	///Insert account record
    	insert objAccount;
    	
    	///Create a list of Opportunity records
    	List<Opportunity> lstOpportunity = new List<Opportunity>
    	{
    		new Opportunity
    		(
    			Name = 'Test Opportunity 1',
    			AccountId = objAccount.Id,
    			CloseDate = Date.today(),
    			StageName = 'Qualification'
    		),
    		new Opportunity
    		(
    			Name = 'Test Opportunity 2',
    			AccountId = objAccount.Id,
    			CloseDate = Date.today(),
    			StageName = 'Qualification'
    		)
    	};
    	
    	///Insert Opportunity records 
    	insert lstOpportunity;
    	
    	///Create event and task records
    	lstEvents = createEvents(lstOpportunity,new List<Lead>());
    	lstTasks = createTasks(lstOpportunity,new List<Lead>());
    	
    	///Run batch on Opportunity
    	test.StartTest();
	    SL_ActivityMilestoneBatch objActivityMilestoneBatch = new SL_ActivityMilestoneBatch('SELECT Id FROM Opportunity');
	    database.executeBatch(objActivityMilestoneBatch,10);
	    test.StopTest();
	    
	    ///Query inserted Opportunity records
	    List<Opportunity> lstOpportunityInserted = [SELECT First_Call_Date__c,First_Email_Date__c,First_Appointment_Date__c FROM Opportunity];
	    
	    ///Check if First_Call_Date__c field on Opportunity is updated correctly                                      
    	system.assertEquals(lstOpportunityInserted[0].First_Call_Date__c,lstEvents[1].StartDateTime);
    	
    	///Check if First_Email_Date__c field on Opportunity is updated correctly                                      
    	system.assertEquals(lstOpportunityInserted[1].First_Email_Date__c,lstEvents[2].StartDateTime);
    	
    	///Check if First_Appointment_Date__c field on Opportunity is updated correctly                                      
    	system.assertEquals(lstOpportunityInserted[1].First_Appointment_Date__c,lstEvents[3].StartDateTime);
    	
    }
    
    ///Test code for Lead batch
    static testMethod void testLead() 
    {
    	List<Event> lstEvents = new List<Event>();///List to hold the event records created
    	List<Task> lstTasks = new List<Task>();///List to hold the task records created
    	
    	///Create account record
    	Account objAccount = new Account
    	(
    		Name = 'Test Account 1'
    	);
    	
    	///Insert account record
    	insert objAccount;
    	
    	///Create a list of lead records
    	List<Lead> lstLead = new List<Lead>
    	{
    		new Lead
    		(
    			LastName = 'Test Lead 1',
    			Email = 'testLead1@test.com',
    			Status = 'Open'
    		),
    		new Lead
    		(
    			LastName = 'Test Lead 2',
    			Email = 'testLead2@test.com',
    			Status = 'Open'
    		)
    	};
    	
    	///Insert lead records
    	insert lstLead;
    	
    	///Create event and task records
    	lstEvents = createEvents(new List<Opportunity>(),lstLead);
    	lstTasks = createTasks(new List<Opportunity>(),lstLead);
    	
    	///Run batch on Lead
    	test.StartTest();
	    SL_ActivityMilestoneBatch objActivityMilestoneBatch = new SL_ActivityMilestoneBatch('SELECT Id FROM Lead');
	    database.executeBatch(objActivityMilestoneBatch,10);
	    test.StopTest();
	    
	    ///Query inserted Lead records
	    List<Lead> lstLeadInserted = [SELECT First_Call_Date__c,First_Email_Date__c,First_Appointment_Date__c FROM Lead];
	    
	    ///Check if First_Call_Date__c field on Lead is updated correctly                                      
    	system.assertEquals(lstLeadInserted[0].First_Call_Date__c,lstEvents[1].StartDateTime);
    	
    	///Check if First_Email_Date__c field on Lead is updated correctly                                      
    	system.assertEquals(lstLeadInserted[1].First_Email_Date__c,lstEvents[2].StartDateTime);
    	
    	///Check if First_Appointment_Date__c field on Lead is updated correctly                                      
    	system.assertEquals(lstLeadInserted[1].First_Appointment_Date__c,lstEvents[3].StartDateTime);
    }
    
    
    ///Method to create event test records
    static List<Event> createEvents(List<Opportunity> lstOpportunity, List<Lead> lstLead)
    {
    	///Create list of events
    	List<Event> lstEvent = new List<Event>
    	{
    		new Event
    		(
    			Subject = 'Call',
    			Type = 'Call',
    			StartDateTime = Datetime.newInstance(2014, 1, 1, 0, 0, 0),
    			EndDateTime = Datetime.newInstance(2014, 1, 1, 0, 0, 0)
    		),
    		new Event
    		(
    			Subject = 'Call',
    			Type = 'Call',
    			StartDateTime = Datetime.newInstance(2013, 12, 31, 0, 0, 0),
    			EndDateTime = Datetime.newInstance(2013, 12, 31, 0, 0, 0)
    		),
    		new Event
    		(
    			Subject = 'Email',
    			Type = 'Email',
    			StartDateTime = Datetime.newInstance(2014, 1, 1, 0, 0, 0),
    			EndDateTime = Datetime.newInstance(2014, 1, 1, 0, 0, 0)
    		),
    		new Event
    		(
    			Subject = 'Appointment',
    			Type = 'Appointment',
    			StartDateTime = Datetime.newInstance(2013, 1, 1, 0, 0, 0),
    			EndDateTime = Datetime.newInstance(2013, 1, 1, 0, 0, 0)
    		)
    	};
    	
    	///Check if it is a Opportunity batch run
    	if(!lstOpportunity.isEmpty())
    	{
    		lstEvent[0].WhatId = lstOpportunity[0].Id;
    		lstEvent[1].WhatId = lstOpportunity[0].Id;
    		lstEvent[2].WhatId = lstOpportunity[1].Id;
    		lstEvent[3].WhatId = lstOpportunity[1].Id;
    	}
    	///Check if it is a lead batch run
    	else if(!lstLead.isEmpty())
    	{
    		lstEvent[0].WhoId = lstLead[0].Id;
    		lstEvent[1].WhoId = lstLead[0].Id;
    		lstEvent[2].WhoId = lstLead[1].Id;
    		lstEvent[3].WhoId = lstLead[1].Id;
    	}
    	
    	insert lstEvent;
    	
    	return lstEvent;
    }
    
     ///Method to create task test records
    static List<Task> createTasks(List<Opportunity> lstOpportunity, List<Lead> lstLead)
    {
    	///Create list of Task
    	List<Task> lstTask = new List<Task>
    	{
    		new Task
    		(
    			Subject = 'Call',
    			Type = 'Call',
    			ActivityDate = Date.newInstance(2015, 1, 1),
    			Status = 'Completed'
    		),
    		new Task
    		(
    			Subject = 'Email',
    			Type = 'Email',
    			ActivityDate = Date.newInstance(2015, 1, 1),
    			Status = 'Completed'
    		),
    		new Task
    		(
    			Subject = 'Appointment',
    			Type = 'Appointment',
    			ActivityDate = Date.newInstance(2015, 1, 1),
    			Status = 'Completed'
    		)
    	};
    	
    	///Check if it is a Opportunity batch run
    	if(!lstOpportunity.isEmpty())
    	{
    		lstTask[0].WhatId = lstOpportunity[0].Id;
    		lstTask[1].WhatId = lstOpportunity[0].Id;
    		lstTask[2].WhatId = lstOpportunity[1].Id;
    	}
    	///Check if it is a lead batch run
    	else if(!lstLead.isEmpty())
    	{
    		lstTask[0].WhoId = lstLead[0].Id;
    		lstTask[1].WhoId = lstLead[0].Id;
    		lstTask[2].WhoId = lstLead[1].Id;
    	}
    	
    	insert lstTask;
    	
    	return lstTask;
    }
}