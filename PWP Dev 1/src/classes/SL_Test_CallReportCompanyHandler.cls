/**
* \arg ClassName      : SL_Test_CallReportCompanyHandler
* \arg JIRATicket     : PWP-9,PWP-19,PWP-88
* \arg CreatedOn      : 7/JAN/2015
* \arg LastModifiedOn : 8/AUG/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Lodhi
* \arg Description    : This is the Test class for SL_CallReportCompanyHandler
*/
@isTest
private class SL_Test_CallReportCompanyHandler 
{
	static List<AccountTeamMember> lstAccountTeams;
	static List<Account> lstAccount;
	static List<Call_Report_Company__c> lstCRC;
	static List<Call_Report__c> lstCR;
	static List<User> lstUser;
    //calling method to prepare data
    private static void createData() 
    {
        Id profileId  = [SELECT Id FROM Profile WHERE Name='PWP Standard User' LIMIT 1].Id;
    	lstUser = new List<User>{
		    new User(Alias = 'User1', Email='user1@user.com', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='usercrch1@usrpwp.com'),
            new User(Alias = 'User2', Email='user2@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='usercrch2@user.com'),
            new User(Alias = 'User3', Email='user3@user.com', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='usercrch3@usrpwp.com'),
            new User(Alias = 'User4', Email='user4@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='usercrch4@user.com'),
            new User(Alias = 'User5', Email='user5@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='usercrch5@user.com')			         
		};
    	insert lstUser;
    	
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
    	
    	lstCR = new List<Call_Report__c>{
            new Call_Report__c(Name = 'Test Call Report1', Reference_Account__c = lstAccount[0].Id),
            new Call_Report__c(Name = 'Test Call Report2', Reference_Account__c = lstAccount[1].Id)
        };
    	insert lstCR;
    	
    	lstCRC = new List<Call_Report_Company__c>{
            new Call_Report_Company__c(Call_Report__c = lstCR[0].Id, Relevant_Company__c = lstAccount[1].Id),
            new Call_Report_Company__c(Call_Report__c = lstCR[1].Id, Relevant_Company__c = lstAccount[0].Id)
        };
    }
    
    static testmethod void checkForInsert()
    {
    	createData();
    	system.assertEquals([SELECT Id FROM Call_Report__Share WHERE ParentId =: lstCR[0].Id AND RowCause = 'Manual'].size(), 3);
    	system.assertEquals([SELECT Id FROM Call_Report__Share WHERE ParentId =: lstCR[1].Id AND RowCause = 'Manual'].size(), 2);
    	
    	Test.startTest();
    	insert lstCRC;
    	Test.stopTest();
        system.assertEquals([SELECT Id FROM Call_Report__Share WHERE ParentId =: lstCR[0].Id AND RowCause = 'Manual'].size(), 5);
    	system.assertEquals([SELECT Id FROM Call_Report__Share WHERE ParentId =: lstCR[1].Id AND RowCause = 'Manual'].size(), 5);
    }
    
    static testMethod void checkForUpdate()
    {
    	createData();
    	system.assertEquals([SELECT Id FROM Call_Report__Share WHERE ParentId =: lstCR[0].Id AND RowCause = 'Manual'].size(), 3);
    	system.assertEquals([SELECT Id FROM Call_Report__Share WHERE ParentId =: lstCR[1].Id AND RowCause = 'Manual'].size(), 2);
    	
    	Test.startTest();
    	insert lstCRC;
    	lstCRC[0].Relevant_Company__c = lstAccount[0].Id;
    	update lstCRC[0];
    	Test.stopTest();
    	system.assertEquals([SELECT Id FROM Call_Report__Share WHERE ParentId =: lstCR[0].Id AND RowCause = 'Manual'].size(), 3);
    }
    
    static testMethod void checkForDelete()
    {
    	createData();
    	
    	Test.startTest();
    	insert lstCRC;
    	delete lstCRC[0];
    	Test.stopTest();
    	system.assertEquals([SELECT Id FROM Call_Report__Share WHERE ParentId =: lstCR[0].Id AND RowCause = 'Manual'].size(), 3);
    }
    
    static testmethod void checkForUndelete()
    {
    	createData();
    	insert lstCRC;
    	delete lstCRC[0];
    	system.assertEquals([SELECT Id FROM Call_Report__Share WHERE ParentId =: lstCR[0].Id AND RowCause = 'Manual'].size(), 3);
    	
    	Test.startTest();
    	undelete lstCRC[0];
    	Test.stopTest();
    	system.assertEquals([SELECT Id FROM Call_Report__Share WHERE ParentId =: lstCR[0].Id AND RowCause = 'Manual'].size(), 5);
    }
    
    static testMethod void checkForOwnerChange()
    {
    	createData();
    	
    	lstCR[1].OwnerId = lstUser[2].Id;
    	Test.startTest();
    	update lstCR[1];
    	Test.stopTest();
    	System.assertEquals([select count() from Call_Report__Share where ParentId =:lstCR[1].Id AND RowCause ='Manual'], 2);
    }
}