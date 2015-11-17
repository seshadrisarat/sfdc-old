/**
* \arg ClassName      : SL_TestCallReportHandler
* \arg JIRATicket     : PWP-17
* \arg CreatedOn      : 6/JAN/2015
* \arg LastModifiedOn : 07/JULY/2015
* \arg CreatededBy    : Pradeep
* \arg ModifiedBy     : Lodhi
* \arg Description    : This is the Test class for SL_Contact Trigger.
*/
@isTest
private class SL_TestCallReportHandler 
{
	static List<Coverage_Team_Members__c> lstCoverageTeamMembers ;
	static List<Account> lstAccount ;
	static List<Call_Report_Company__c> lstCRC;
	static List<Call_Report__c> lstCR;
	static List<User> lstUser;
	static Dynamic_Date_for_Email__c objDynamicDate;
	static List<Event> lstEvent;
   
    //calling method to prepare data
    private static void createData()
    {
    	Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    	lstUser = new List<User> {
									new User(Alias = 'User1', Email='user1@user.com', 
			                                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
			                                LocaleSidKey='en_US', ProfileId = p.Id, 
			                                TimeZoneSidKey='America/Los_Angeles', UserName='user1kjkj1212.212@user.com'),
									new User(Alias = 'User2', Email='user2@user.com', 
			                                EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			                                LocaleSidKey='en_US', ProfileId = p.Id, 
			                                TimeZoneSidKey='America/Los_Angeles', UserName='userjkj33444.464.2@user.com')
								};
    	insert lstUser;
    	
    	objDynamicDate = new Dynamic_Date_for_Email__c(Name = 'Dynamic Date', Start_Date__c = Date.Today().addDays(-5));
        insert objDynamicDate;
        
    	lstAccount = new List<Account>{
	    								new Account(Name = 'Account1'),
	    								new Account(Name = 'Account2')
    								  };
    	insert lstAccount;
        
        lstEvent = new List<Event>{
							         new Event(Subject = 'Call with Sarah',
						         				StartDateTime = Date.Today(), EndDateTime = Date.Today().addDays(5), OwnerId = lstUser[0].Id, whatId = lstAccount[0].Id),
							         new Event(Subject = 'Call', 
						         			   StartDateTime = Date.Today(), EndDateTime = Date.Today().addDays(5), OwnerId = lstUser[0].Id, whatId = lstAccount[0].Id),
						         	 new Event(Subject = 'Call with Bryan', 
						         			   StartDateTime = Datetime.now().addDays(-4), EndDateTime = Datetime.now().addDays(-3), OwnerId = lstUser[0].Id, whatId = lstAccount[0].Id)
         						  };
    	insert lstEvent;
    	
    	lstCR = new List<Call_Report__c>{
    										new Call_Report__c(Name = 'Call with Bryan', Call_Report_Date__c = Date.Today().addDays(-4), OwnerId = lstUser[0].Id, Reference_Account__c = lstAccount[0].Id),
    		 								new Call_Report__c(Name = 'Call with Sarah', Call_Report_Date__c = Date.newInstance(2015,5,5), OwnerId = lstUser[1].Id, Reference_Account__c = lstAccount[1].Id)
    									};
    	insert lstCR;
    	
    	lstCRC = new List<Call_Report_Company__c>{
    	    new Call_Report_Company__c(Relevant_Company__c = lstCR[1].Reference_Account__c, Call_Report__c = lstCR[1].Id)
    	};
    	insert lstCRC;
    	
    	lstCoverageTeamMembers = new List<Coverage_Team_Members__c>
    							{
	    								new Coverage_Team_Members__c(Company__c = lstAccount[0].Id, PWP_Employee__c = lstUser[0].Id),
	    								new Coverage_Team_Members__c(Company__c = lstAccount[0].Id, PWP_Employee__c = lstUser[1].Id)
    							};
    	insert lstCoverageTeamMembers;
    }
    private static testMethod void test()
	{
		createData();
    	System.runAs(lstUser[0]) 
		{
			system.assertEquals([SELECT Id from Call_Report__c WHERE Reference_Account__c =: lstAccount[0].Id].size(), 1);
			system.assertEquals([SELECT Id from Call_Report_Company__c WHERE Relevant_Company__c =: lstAccount[0].Id AND Call_Report__c=:lstCR[0].Id ].size(), 1);
		}
		List<Call_Report__c> lstCRToUpdate = new List<Call_Report__c>{
	    																new Call_Report__c(Id=lstCR[0].Id, Reference_Account__c = lstAccount[1].Id)
							    									};
    	update lstCRToUpdate;
    	
    	delete lstCRToUpdate;
		System.runAs(lstUser[1]) 
		{
			system.assertEquals([SELECT Id from Call_Report__c WHERE Reference_Account__c =: lstAccount[1].Id].size(), 1);
		}
	}
}