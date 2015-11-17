/**
* \arg ClassName      : SL_Test_Batch_CreateRelationships
* \arg JIRATicket     : PWP-5
* \arg CreatedOn      : 5/DEC/2014
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as test class for create relationships batch class
*/
@isTest
private class SL_Test_Batch_CreateRelationships 
{
	static List<Event> lstEvent;
    static List<Task> lstTask;
    static List<Contact> lstContact;
    static User objUser;
    
    //calling method to prepare data
    private static void createData()
    {
    	Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    	objUser = new User(Alias = 'User1', Email='userTBCR-01@user.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='userTBCR-01@user.com');
        insert objUser;
         
        Account objAccount  = new Account(Name = 'Account1');
        insert objAccount;
         
         lstContact = new List<Contact>{
							         	new Contact(LastName = 'Contact1', AccountId = objAccount.Id),
							         	new Contact(LastName = 'Contact2', AccountId = objAccount.Id)
        							   };
         insert lstContact;
         
         lstTask = new List<Task>{
						         	new Task(Subject = 'Call',
						         				Status = 'Open', Priority = 'Normal'),
						         	new Task(Subject = 'Call', 
						         				Status = 'Open', Priority = 'Normal')
         						};
         insert lstTask;
         List<TaskRelation> lstTaskRelation = new List<TaskRelation>{
         																new TaskRelation(TaskId = lstTask[0].Id, RelationId = lstContact[0].Id),
         																new TaskRelation(TaskId = lstTask[0].Id, RelationId = lstContact[1].Id),
         																new TaskRelation(TaskId = lstTask[1].Id, RelationId = lstContact[0].Id),
         																new TaskRelation(TaskId = lstTask[1].Id, RelationId = lstContact[1].Id)
         															};
         insert lstTaskRelation;
        
         lstEvent = new List<Event>{
							         	new Event(Subject = 'Call',
							         				StartDateTime = Date.Today(), EndDateTime = Date.Today().addDays(5),
							         				WhoId = lstContact[0].Id),
							         	new Event(Subject = 'Call', 
							         			  StartDateTime = Date.Today(), EndDateTime = Date.Today().addDays(5),
							         			  WhoId = lstContact[1].Id)
         						  };
         insert lstEvent;
         List<EventRelation> lstEventRelation = new List<EventRelation>{
	         																new EventRelation(EventId = lstEvent[0].Id, RelationId = lstContact[1].Id),
	         																new EventRelation(EventId = lstEvent[1].Id, RelationId = lstContact[0].Id)
         																};
         insert lstEventRelation;
    }
    
	//Function to check for schedule update
	static testMethod void checkForBatch()
	{
		createData();
		
	 	test.startTest();
	 	Database.executeBatch(new SL_Batch_CreateRelationships('SELECT Id, OwnerId, (SELECT RelationId, TaskId FROM TaskRelations) FROM Task WHERE WhoId!=null'));
	 	Database.executeBatch(new SL_Batch_CreateRelationships('SELECT Id, OwnerId, (SELECT RelationId, EventId FROM EventRelations) FROM Event WHERE WhoId!=null'));
	 	test.stopTest();
	}
	
	//coverage for scheduler
	static testMethod void coverageForScheduler()
	{
		createData();
		
		Test.startTest();
		System.schedule('Test','0 0 * * * ?', new SL_BatchScheduler_CreateRelationships());
		Test.stopTest();
	}
}