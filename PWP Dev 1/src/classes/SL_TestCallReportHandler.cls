/**
* \arg ClassName      : SL_TestCallReportHandler
* \arg JIRATicket     : PWP-17, PWP-88
* \arg CreatedOn      : 6/JAN/2015
* \arg LastModifiedOn : 08/AUG/2015
* \arg CreatededBy    : Pradeep
* \arg ModifiedBy     : Lodhi
* \arg Description    : This is the Test class for SL_CallReportHandler Trigger.
*/
@isTest
private class SL_TestCallReportHandler 
{
	static List<AccountTeamMember> lstAccountTeams;
	static List<Account> lstAccount ;
	static List<Call_Report_Company__c> lstCRC;
	static List<Call_Report__c> lstCR;
	static List<User> lstUser;
	static Dynamic_Date_for_Email__c objDynamicDate;
	static List<Event> lstEvent;
   
    //calling method to prepare data
    private static void createData()
    {
    	Id profileId  = [SELECT Id FROM Profile WHERE Name='PWP Standard User' LIMIT 1].Id;
    	lstUser = new List<User>{
		    new User(Alias = 'User1', Email='user1@user.com', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='usercrh1@usrpwp.com'),
            new User(Alias = 'User2', Email='user2@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='usercrh2@user.com'),
            new User(Alias = 'User3', Email='user3@user.com', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='usercrh3@usrpwp.com'),
            new User(Alias = 'User4', Email='user4@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='usercrh4@user.com'),
            new User(Alias = 'User5', Email='user5@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='usercrh5@user.com')			         
		};
    	insert lstUser;
    	
    	objDynamicDate = new Dynamic_Date_for_Email__c(Name = 'Dynamic Date', Start_Date__c = Date.Today().addDays(-5));
        insert objDynamicDate;
        
    	lstAccount = new List<Account>{
            new Account(Name = 'Account1'),
            new Account(Name = 'Account2')
    	};
    	insert lstAccount;
    	
    	lstAccountTeams = new List<AccountTeamMember>{
            new AccountTeamMember(UserId = lstUser[0].Id, AccountId = lstAccount[0].Id, TeamMemberRole = 'Role-01'),
            new AccountTeamMember(UserId = lstUser[1].Id, AccountId = lstAccount[0].Id, TeamMemberRole = 'Role-02'),
            new AccountTeamMember(UserId = lstUser[2].Id, AccountId = lstAccount[0].Id, TeamMemberRole = 'Role-03'),
            new AccountTeamMember(UserId = lstUser[3].Id, AccountId = lstAccount[1].Id, TeamMemberRole = 'Role-04'),
            new AccountTeamMember(UserId = lstUser[4].Id, AccountId = lstAccount[1].Id, TeamMemberRole = 'Role-05')
        };
        insert lstAccountTeams;
        
        lstEvent = new List<Event>{
            new Event(Subject = 'Call with Sarah', StartDateTime = Date.Today(), EndDateTime = Date.Today().addDays(5), OwnerId = lstUser[0].Id, whatId = lstAccount[0].Id),
            new Event(Subject = 'Call', StartDateTime = Date.Today(), EndDateTime = Date.Today().addDays(5), OwnerId = lstUser[0].Id, whatId = lstAccount[0].Id),
            new Event(Subject = 'Call with Bryan', StartDateTime = Datetime.now().addDays(-4), EndDateTime = Datetime.now().addDays(-3), OwnerId = lstUser[0].Id, whatId = lstAccount[0].Id)
        };
    	insert lstEvent;
    	
    	lstCR = new List<Call_Report__c>{
			new Call_Report__c(Name = 'Call with Bryan', Call_Report_Date__c = Date.Today().addDays(-4), OwnerId = lstUser[0].Id, Reference_Account__c = lstAccount[0].Id),
 			new Call_Report__c(Name = 'Call with Sarah', Call_Report_Date__c = Date.newInstance(2015,5,5), Reference_Account__c = lstAccount[1].Id)
		};
    	insert lstCR;
    	
    	lstCRC = new List<Call_Report_Company__c>{
    	    new Call_Report_Company__c(Relevant_Company__c = lstCR[1].Reference_Account__c, Call_Report__c = lstCR[1].Id)
    	};
    	insert lstCRC;
    }
    private static testMethod void Test_CallReportHandler()
	{
		createData();
		
		system.assertEquals([SELECT Id FROM Call_Report__Share WHERE ParentId =: lstCR[0].Id AND RowCause = 'Manual'].size(), 2);
		system.assertEquals([SELECT Id FROM Call_Report__Share WHERE ParentId =: lstCR[1].Id AND RowCause = 'Manual'].size(), 2);
		system.assertEquals([SELECT Id from Call_Report__c WHERE Reference_Account__c =: lstAccount[0].Id].size(), 1);
		system.assertEquals([SELECT Id from Call_Report_Company__c WHERE Relevant_Company__c =: lstAccount[0].Id AND Call_Report__c=:lstCR[0].Id ].size(), 1);
		
		List<Call_Report__c> lstCRToUpdate = new List<Call_Report__c>{
			new Call_Report__c(Id=lstCR[0].Id, Reference_Account__c = lstAccount[1].Id),
			new Call_Report__c(Id=lstCR[1].Id, OwnerId = lstUser[2].Id)
		};
    	update lstCRToUpdate;
    	
    	delete lstCRToUpdate[0];
		system.assertEquals([SELECT Id from Call_Report__c WHERE Reference_Account__c =: lstAccount[1].Id].size(), 1);
	}
}