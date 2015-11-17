/**
* \arg ClassName      : SL_Test_Batch_ActivityCount
* \arg JIRATicket     : PWP-7
* \arg CreatedOn      : 26/DEC/2014
* \arg LastModifiedOn : 12/FEB/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pradeep
* \arg Description    : This class serves as test class for updating the relationship records with activity count
*/
@isTest
private class SL_Test_Batch_ActivityCount 
{
	static List<Event> lstEvent;
    static List<Task> lstTask;
    static List<EventRelation> lstEventRelation;
    static List<TaskRelation> lstTaskRelation;
    static List<Relationship__c> lstRelationship;
    static List<Contact> lstContact;
    static List<Call_Report_Attendees__c> lstCallReportAttendees; 
    static User objUser;
    static List<Account> lstAccount;
    static Call_Report__c objCallReport;
    
    //calling method to prepare data
    private static void createData()
    {
    	Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    	objUser = new User(Alias = 'User1', Email='userTBAC-01@user.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='userTBAC-01@user.com');
        insert objUser;
        
    	lstContact = new List<Contact>{
    									new Contact(LastName = 'TestContact0', User__c = objUser.Id),
										new Contact(LastName = 'TestContact1', User__c = objUser.Id),
										new Contact(LastName = 'TestContact2', User__c = objUser.Id)
									  };
		insert lstContact;
    	
    	lstRelationship = new List<Relationship__c>{
    													new Relationship__c(PWP_Employee__c = objUser.Id, External_Contact__c = lstContact[0].Id),
    											   		new Relationship__c(PWP_Employee__c = objUser.Id, External_Contact__c = lstContact[1].Id)
    											   };
    	insert lstRelationship;
    											   
    	lstTask = new List<Task>{
									new Task(Subject = 'test1', WhoId = lstContact[0].Id, OwnerId = objUser.Id ),
									new Task(Subject = 'test2', WhoId = lstContact[1].Id, OwnerId = objUser.Id )
								};
		insert lstTask;
		
		lstTaskRelation = new List<TaskRelation>{
													new TaskRelation(RelationId = lstContact[1].Id , TaskId = lstTask[0].Id )
												};
		insert lstTaskRelation; 
		
		lstEvent = new List<Event>{
							         new Event(Subject = 'Call',
							         				StartDateTime = Date.Today(), EndDateTime = Date.Today().addDays(5), OwnerId = objUser.Id, 
							         				WhoId = lstContact[0].Id),
							         new Event(Subject = 'Call', 
								         			  StartDateTime = Date.Today(), EndDateTime = Date.Today().addDays(5), OwnerId = objUser.Id,
								         			  WhoId = lstContact[1].Id)
         						  };
    	insert lstEvent;
    	
		lstEventRelation = new List<EventRelation>{
													new EventRelation(RelationId = lstContact[1].Id, EventId = lstEvent[0].Id)
												  };
		insert lstEventRelation;
		
		lstAccount = new List<Account>{
    										new Account(Name = 'Test Account133'),
    										new Account(Name = 'Test Account222')
    								  };
    	insert lstAccount;												
		 
		objCallReport = new Call_Report__c(Name = 'Test CR1', Call_Report_Date__c = Date.today(), Reference_Account__c = lstAccount[0].Id); 
		insert objCallReport;
		
		lstCallReportAttendees = new List<Call_Report_Attendees__c>{
																	new Call_Report_Attendees__c(Call_Report__c = objCallReport.Id , Call_Report_Attendee__c = lstContact[0].Id),
			 														new Call_Report_Attendees__c(Call_Report__c = objCallReport.Id , Call_Report_Attendee__c = lstContact[1].Id)
			 													   }; 
		insert lstCallReportAttendees;
																		
	}	
	
	//Function to check for schedule update
	static testMethod void checkForBatch()
	{
		createData();
		
	 	Test.startTest();
	 	Database.executeBatch(new SL_Batch_ActivityCount('Select PWP_Employee__c, External_Contact__c, Event_Count__c, Count_Task__c, Call_Report_Count__c From Relationship__c WHERE PWP_Employee__c!=null AND External_Contact__c!=null'));
	 	Test.stopTest();
	 	
	 	System.assertEquals(1, [SELECT Count_Task__c from Relationship__c where Id =: lstRelationship[0].Id].Count_Task__c);
	 	System.assertEquals(1, [select Event_Count__c from Relationship__c where Id =: lstRelationship[0].Id].Event_Count__c);
	 	System.assertEquals(2, [SELECT Count_Task__c from Relationship__c where Id =: lstRelationship[1].Id].Count_Task__c);
	 	System.assertEquals(2, [select Event_Count__c from Relationship__c where Id =: lstRelationship[1].Id].Event_Count__c);
	}
	
	//coverage for scheduler
	static testMethod void coverageForScheduler()
	{
		createData();
		
		Test.startTest();
		System.schedule('Test','0 0 * * * ?', new SL_BatchScheduler_ActivityCount());
		Test.stopTest();
	}
}