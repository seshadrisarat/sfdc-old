/**
* \arg ClassName        : SL_Test_BatchAddCoverageTeamsToAccTeams
* \arg JIRATicket     	: PWP-88
* \arg CreatedOn      	: 28/JULY/2015
* \arg LastModifiedOn	: 28/JULY/2015
* \arg CreatededBy    	: Lodhi 
* \arg ModifiedBy     	: Lodhi
* \arg Description      : Test class for SL_BatchAddCoverageTeamsToAccountTeams class 
*/
@isTest
private class SL_Test_BatchAddCoverageTeamsToAccTeams 
{
    static List<Account> lstAccount;
    static List<AccountTeamMember> lstAccountTeams;
    static List<User> lstUser;
    static List<Call_Report__c> lstCallReport;
    static List<Coverage_Team_Members__c> lstCoverageTeamMembers;
    
    private static void createData()
    {
        Id profileId  = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id;
		lstUser = new List<User>{
		    new User(Alias = 'User1', Email='user1@user.com', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userTBACTM-01@45usrpwp.com'),
            new User(Alias = 'User2', Email='user2@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userTBACTM-02@32user.com'),
            new User(Alias = 'User3', Email='user3@user.com', EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userTBACTM-03@12pwp.com')			         
		};
    	insert lstUser;
    	
    	lstAccount = new List<Account>{
            new Account(Name = 'Test Account-01'),
            new Account(Name = 'Test Account-02')
        };
        insert lstAccount;
        
        lstAccountTeams = new List<AccountTeamMember>{
            new AccountTeamMember(UserId = lstUser[0].Id, AccountId = lstAccount[0].Id),
            new AccountTeamMember(UserId = lstUser[0].Id, AccountId = lstAccount[1].Id)
        };
        insert lstAccountTeams;
        
        lstCallReport = new List<Call_Report__c>{
            new Call_Report__c(Name = 'Test CR-01', Call_Report_Date__c = Date.Today(), Reference_Account__c = lstAccount[0].Id),    
            new Call_Report__c(Name = 'Test CR-02', Call_Report_Date__c = Date.Today(), Reference_Account__c = lstAccount[1].Id)
        };
        insert lstCallReport;
        
        lstCoverageTeamMembers = new List<Coverage_Team_Members__c>{
            new Coverage_Team_Members__c(Company__c = lstAccount[0].Id, PWP_Employee__c = lstUser[0].Id),
			new Coverage_Team_Members__c(Company__c = lstAccount[0].Id, PWP_Employee__c = lstUser[1].Id),
			new Coverage_Team_Members__c(Company__c = lstAccount[0].Id, PWP_Employee__c = lstUser[2].Id),
			new Coverage_Team_Members__c(Company__c = lstAccount[1].Id, PWP_Employee__c = lstUser[0].Id),
			new Coverage_Team_Members__c(Company__c = lstAccount[1].Id, PWP_Employee__c = lstUser[1].Id),
			new Coverage_Team_Members__c(Company__c = lstAccount[1].Id, PWP_Employee__c = lstUser[2].Id)
        };
    	insert lstCoverageTeamMembers;
    }
    
    static testMethod void Test_BatchAddCoverageTeamsToAccTeams() 
    {
	    createData();
        
        Test.startTest();
        Database.executeBatch(new SL_BatchAddCoverageTeamsToAccountTeams(), 20);
        Test.stopTest();
        
        System.assertEquals([SELECT Id FROM EntitySubscription WHERE ParentId =: lstAccount[0].Id].size(), 2);
        System.assertEquals([SELECT Id FROM EntitySubscription WHERE ParentId =: lstAccount[1].Id].size(), 2);
        System.assertEquals([SELECT Id FROM AccountTeamMember WHERE AccountId =: lstAccount[0].Id].size(), 3);
        System.assertEquals([SELECT Id FROM AccountTeamMember WHERE AccountId =: lstAccount[1].Id].size(), 3);
        System.assertEquals([SELECT Id FROM Call_Report__Share WHERE ParentId =: lstCallReport[0].Id AND RowCause = 'Manual'].size(), 3);
        System.assertEquals([SELECT Id FROM Call_Report__Share WHERE ParentId =: lstCallReport[1].Id AND RowCause = 'Manual'].size(), 3);
    }
}