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
private class SL_TestActivityHandler 
{
    static testMethod void testActivityHandler() 
    {
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
    	
    	///Create list of events
    	List<Event> lstEvent = new List<Event>
    	{
    		new Event
    		(
    			Subject = 'Call',
    			Type = 'Call',
    			StartDateTime = Datetime.newInstance(2014, 1, 1, 0, 0, 0),
    			EndDateTime = Datetime.newInstance(2014, 1, 1, 0, 0, 0),
    			WhatId  = lstOpportunity[0].Id
    		),
    		new Event
    		(
    			Subject = 'Call',
    			Type = 'Call',
    			StartDateTime = Datetime.newInstance(2013, 12, 31, 0, 0, 0),
    			EndDateTime = Datetime.newInstance(2013, 12, 31, 0, 0, 0),
    			WhatId  = lstOpportunity[0].Id
    		),
    		new Event
    		(
    			Subject = 'Email',
    			Type = 'Email',
    			StartDateTime = Datetime.newInstance(2015, 1, 1, 0, 0, 0),
    			EndDateTime = Datetime.newInstance(2015, 1, 1, 0, 0, 0),
    			WhoId = lstLead[0].Id
    		),
    		new Event
    		(
    			Subject = 'Email',
    			Type = 'Email',
    			StartDateTime = Datetime.newInstance(2014, 12, 31, 0, 0, 0),
    			EndDateTime = Datetime.newInstance(2014, 12, 31, 0, 0, 0),
    			WhoId = lstLead[0].Id
    		),
    		new Event
    		(
    			Subject = 'Appointment',
    			Type = 'Appointment',
    			StartDateTime = Datetime.newInstance(2013, 12, 31, 0, 0, 0),
    			EndDateTime = Datetime.newInstance(2013, 12, 31, 0, 0, 0),
    			WhoId = lstLead[1].Id
    		),
    		new Event
    		(
    			Subject = 'Appointment',
    			Type = 'Appointment',
    			StartDateTime = Datetime.newInstance(2014, 1, 1, 0, 0, 0),
    			EndDateTime = Datetime.newInstance(2014, 1, 1, 0, 0, 0),
    			WhoId = lstLead[1].Id
    		)
    	};
    	
    	///Insert list of events
    	insert lstEvent;
    	
    	///Create list of Task
    	List<Task> lstTask = new List<Task>
    	{
    		new Task
    		(
    			Subject = 'Call',
    			Type = 'Call',
    			ActivityDate = Date.newInstance(2015, 1, 1),
    			WhatId  = lstOpportunity[0].Id,
    			Status = 'Completed'
    		),
    		new Task
    		(
    			Subject = 'Email',
    			Type = 'Email',
    			ActivityDate = Date.newInstance(2015, 1, 1),
    			WhoId = lstLead[0].Id,
    			Status = 'Completed'
    		),
    		new Task
    		(
    			Subject = 'Appointment',
    			Type = 'Appointment',
    			ActivityDate = Date.newInstance(2015, 1, 1),
    			WhoId = lstLead[1].Id,
    			Status = 'Completed'
    		)
    	};
    	
    	///Insert list of task
    	insert lstTask;
    	
    	///Query First Opportunity
    	Opportunity objFirstOpportunityInserted = [SELECT First_Call_Date__c FROM Opportunity WHERE Id =: lstOpportunity[0].Id];
    	                                            
    	///Query First Lead
    	Lead objFirstLeadInserted = [SELECT First_Email_Date__c FROM Lead WHERE Id =: lstLead[0].Id];
    	
    	///Query Second Lead
    	Lead objSecondLeadInserted = [SELECT First_Appointment_Date__c,Last_Appointment_Date__c FROM Lead  WHERE Id =: lstLead[1].Id];
    	
    	///Check if First_Call_Date__c field on Opportunity is updated correctly                                      
    	system.assertEquals(objFirstOpportunityInserted.First_Call_Date__c,lstEvent[1].StartDateTime);
    	
    	///Check if First_Appointment_Date__c field on Lead is updated correctly  
    	system.assertEquals(objSecondLeadInserted.First_Appointment_Date__c,lstEvent[4].StartDateTime);
    	
    	test.StartTest();
    	
    	///Update event records
    	lstEvent[4].StartDateTime = Datetime.newInstance(2013, 12, 20, 0, 0, 0);
    	update lstEvent[4];
    	
    	///Check if First_Appointment_Date__c field on Lead is updated correctly  
    	system.assertEquals([SELECT First_Appointment_Date__c FROM Lead  WHERE Id =: lstLead[1].Id].First_Appointment_Date__c,Datetime.newInstance(2013, 12, 20, 0, 0, 0));
    	
    	Event objEventToDelete = lstEvent[1];
    	
    	///Delete event record
    	delete objEventToDelete;
    	
    	///Check if First_Call_Date__c field on Opportunity is updated correctly                                      
    	system.assertEquals([SELECT First_Call_Date__c FROM Opportunity WHERE Id =: lstOpportunity[0].Id].First_Call_Date__c,lstEvent[0].StartDateTime);
    	
    	
    	
    	///Query deleted event
    	Event objEventToUndelete = [SELECT Id FROM Event WHERE ID =:objEventToDelete.Id ALL ROWS ];
		
		///Undelete event
		undelete objEventToUndelete;                                                                   
		 
		///Check if First_Call_Date__c field on Opportunity is updated correctly                                      
    	system.assertEquals([SELECT First_Call_Date__c FROM Opportunity WHERE Id =: lstOpportunity[0].Id].First_Call_Date__c,lstEvent[1].StartDateTime);                                                                                
    	
    	List<Event> lstEventToDelete = [SELECT Id FROM Event WHERE WhatId =: lstOpportunity[0].Id OR WhoId =: lstLead[0].Id];
    	delete lstEventToDelete;
    	
    	lstTask[0].ActivityDate = Date.newInstance(2015, 2, 1);
    	update lstTask[0];
    	
    	///Delete task records
    	delete lstTask;
    	
    	test.StopTest();
    }
}