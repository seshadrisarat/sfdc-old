/**
* \arg ClassName      : SL_Test_Batch_SendEmailReminder
* \arg JIRATicket     : PWP-18
* \arg CreatedOn      : 6/APR/2015
* \arg LastModifiedOn : 17/AUG/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Lodhi
* \arg Description    : This class serves as the test class for testing the functionality of sending email reminders to those activity owners for which the call report has not been created yet. 
*/
@isTest
private class SL_Test_Batch_SendEmailReminder 
{
    static List<Event> lstEvent;
    static User objUser;
    static List<Call_Report__c> lstCallReport;
    static List<Account> lstAccount ;
    static Dynamic_Date_for_Email__c objDynamicDate;
    //calling method to prepare data
    private static void createData()
    {
    	Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
    	
    	objUser = new User(Alias = 'User1', Email='use22r122@user.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='userTBSER-01@user.com', Send_Call_Report_Reminder__c=true);
        insert objUser;
        
        objDynamicDate = new Dynamic_Date_for_Email__c(Name = 'Dynamic Date', Start_Date__c = Date.Today().addDays(-5));
        insert objDynamicDate;
        
        lstAccount = new List<Account>{
	    								new Account(Name = 'Account1'),
	    								new Account(Name = 'Account2')
    								  };
    	insert lstAccount;
        
        lstEvent = new List<Event>{
							         new Event(Subject = 'Call with Sarah',
						         				StartDateTime = Date.Today(), EndDateTime = Date.Today().addDays(5), OwnerId = objUser.Id, whatId = lstAccount[0].Id),
							         new Event(Subject = 'Call', 
						         			   StartDateTime = Date.Today(), EndDateTime = Date.Today().addDays(5), OwnerId = objUser.Id, whatId = lstAccount[0].Id),
						         	 new Event(Subject = 'Call with Bryan', 
						         			   StartDateTime = Date.Today().addDays(-4), EndDateTime = Date.Today().addDays(5), OwnerId = objUser.Id, whatId = lstAccount[0].Id)
         						  };
    	insert lstEvent;
    	
    	lstCallReport = new List<Call_Report__c>{
    												new Call_Report__c(Name = 'Call with Bryan', Call_Report_Date__c = Date.newInstance(2015,5,5), OwnerId = objUser.Id, Reference_Account__c = lstAccount[0].Id),
    												new Call_Report__c(Name = 'Call', Call_Report_Date__c = Date.Today(), OwnerId = objUser.Id, Reference_Account__c = lstAccount[0].Id)
    											};
    	insert lstCallReport;
    }
    
    static testMethod void checkForBatchFunctionality() 
    {
        createData();
        
        Test.startTest();
        Database.executeBatch(new SL_Batch_SendEmailReminder(),100);
        Test.stopTest();
    }
    
    static testMethod void coverageForScheduler() 
    {
        createData();
		Test.startTest();
		System.schedule('Test','0 0 * * * ?', new SL_BatchSchedule_SendEmailReminder());
		Test.stopTest();
    }
}