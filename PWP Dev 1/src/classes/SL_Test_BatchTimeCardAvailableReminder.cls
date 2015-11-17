/**
    * \arg ClassName      : SL_Test_Batch_TimeCardReminder
    * \arg JIRATicket     : PWP-215
    * \arg CreatedOn      : 14/Sep/2015
    * \arg LastModifiedOn : 14/Sep/2015
    * \arg CreatededBy    : Lodhi
    * \arg ModifiedBy     : Lodhi
    * \arg Description    : Test class for SL_Batch_TimeCardAvailabilityReminder, SL_Batch_TimeCardReminderUtility classes.
*/
@isTest
private class SL_Test_BatchTimeCardAvailableReminder 
{
    static List<Opportunity> lstOpportunity;
    static List<Time_Card__c> lstTimeCard;
    static List<User> lstUser;
    private static void createData()
    {
        Id profileId  = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id;
		lstUser = new List<User>{
		    new User(Alias = 'User1', Email='user1@user.com', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userTBTCAR-01@pwp.com'),
            new User(Alias = 'User2', Email='user2@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userTBTCAR-02@user.com'),
            new User(Alias = 'User3', Email='user3@user.com', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userTBTCAR-03@usrpwp.com'),
            new User(Alias = 'User4', Email='user4@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userTBTCAR-04@user.com'),
            new User(Alias = 'User5', Email='user5@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userTBTCAR-05@user.com')			         
		};
		insert lstUser;
        
        Date dtWeekStart = Date.today().toStartofWeek();
        Date dtWeekEnd = dtWeekStart.addDays(6);
        lstOpportunity = new List<Opportunity>{
            new Opportunity(StageName = 'Active Mandate', Name = 'Test Opportunity-01', CloseDate = Date.today()),
            new Opportunity(StageName = 'Prospective Mandate', Name = 'Test Opportunity-02', CloseDate = Date.today())
        };
        insert lstOpportunity;
        system.assertEquals(lstOpportunity.size(), 2);
        
        lstTimeCard = new List<Time_Card__c>{
            new Time_Card__c(Project__c = lstOpportunity[0].Id, Resource__c = lstUser[0].Id, Worked_Hours__c = 12, 
                             Percentage_Worked__c = 12, Start_Date__c = dtWeekStart, End_Date__c = dtWeekEnd),
            new Time_Card__c(Project__c = lstOpportunity[0].Id, Resource__c = lstUser[1].Id, Worked_Hours__c = 0, 
                             Percentage_Worked__c = 0, Start_Date__c = dtWeekStart, End_Date__c = dtWeekEnd),
            new Time_Card__c(Project__c = lstOpportunity[1].Id, Resource__c = lstUser[2].Id, Worked_Hours__c = 15, 
                             Percentage_Worked__c = 15, Start_Date__c = dtWeekStart, End_Date__c = dtWeekEnd),
            new Time_Card__c(Project__c = lstOpportunity[1].Id, Resource__c = lstUser[3].Id, Worked_Hours__c = 0, 
                             Percentage_Worked__c = 0, Start_Date__c = dtWeekStart, End_Date__c = dtWeekEnd)                                
        };
        insert lstTimeCard;
        system.assertEquals(lstTimeCard.size(), 4);
    }
    
	private static testMethod void Test_Batch_TimeCardAvailabilityReminder() 
	{
        createData();
        Test.startTest();
        Database.executeBatch(new SL_Batch_TimeCardAvailabilityReminder(DateTime.now().format('EEE'), '2.00', 'test@test.com'), 200);
        Test.stopTest();
	}
	
	static testMethod void Test_Schedule_TimeCardAvailability() 
    {
		Test.startTest();
		System.schedule('Schedule_TimeCardAvailability','0 0 * * * ?', new SL_Schedule_TimeCardAvailability(DateTime.now().format('EEE'), '2.00', 'test@test.com'));
		Test.stopTest(); 
    }
}