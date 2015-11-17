/**
* \arg ClassName        : SL_Test_ProjectAndTeamsInlineVF
* \arg JIRATicket     	: PWP-114
* \arg CreatedOn      	: 07/AUG/2015
* \arg LastModifiedOn	: 07/AUG/2015
* \arg CreatededBy    	: Lodhi 
* \arg ModifiedBy     	: Lodhi
* \arg Description      : Test class for SL_ProjectAndTeamsInlineVF class
*/
@isTest
private class SL_Test_ProjectAndTeamsInlineVF 
{
    static List<Opportunity> lstOpportunity;
    static List<Business_Unit__c> lstBusinessUnit;
    static List<Project_Coverage_Team_Member__c> lstOpportunityTeams;
    static List<User> lstUser;
    static Account objAccount;
    
    private static void createData()
    { 
        Id profileId  = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id;
		lstUser = new List<User>{
		    new User(Alias = 'User1', Email='user1@user.com', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userptivf-01@usrpwp.com'),
            new User(Alias = 'User2', Email='user2@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userptivf-02@user.com'),
            new User(Alias = 'User3', Email='user3@user.com', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userptivf-03@usrpwp.com'),
            new User(Alias = 'User4', Email='user4@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userptivf-04@user.com'),
            new User(Alias = 'User5', Email='user5@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userptivf-05@user.com')			         
		};
    	insert lstUser;
        
        lstBusinessUnit = new List<Business_Unit__c>{
            new Business_Unit__c(Name = 'Test BU-01'),
            new Business_Unit__c(Name = 'Test BU-02'),
            new Business_Unit__c(Name = 'Test BU-03'),
            new Business_Unit__c(Name = 'Test BU-04')
        };
        insert lstBusinessUnit;
        
        objAccount = new Account(Name = 'Test Account-01'); 
        insert objAccount;
        
        lstOpportunity = new List<Opportunity>{
            new Opportunity(Name = 'TestOpp-01', StageName = 'Active Mandate', AccountId = objAccount.Id, 
                            CloseDate = date.today(), Business_Group__c = lstBusinessUnit[0].Id),
            new Opportunity(Name = 'TestOpp-02', StageName = 'Prospective Mandate', AccountId = objAccount.Id, 
                            CloseDate = date.today(), Business_Group__c = lstBusinessUnit[1].Id),
            new Opportunity(Name = 'TestOpp-03', StageName = 'Previous Mandate', AccountId = objAccount.Id, 
                            CloseDate = date.today(), Business_Group__c = lstBusinessUnit[2].Id),
            new Opportunity(Name = 'TestOpp-04', StageName = 'Lost/Cancelled', AccountId = objAccount.Id, 
                            CloseDate = date.today(), Business_Group__c = lstBusinessUnit[3].Id)
        };
        insert lstOpportunity;
        
        lstOpportunityTeams = new List<Project_Coverage_Team_Member__c>{
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[0].Id, User__c = lstUser[0].Id),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[0].Id, User__c = lstUser[1].Id),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[0].Id, User__c = lstUser[3].Id),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[1].Id, User__c = lstUser[2].Id),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[1].Id, User__c = lstUser[3].Id),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[2].Id, User__c = lstUser[4].Id),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[2].Id, User__c = lstUser[0].Id),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[3].Id, User__c = lstUser[1].Id),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[3].Id, User__c = lstUser[2].Id),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[2].Id, User__c = lstUser[4].Id)
        };
        insert lstOpportunityTeams;
    }
    private static testMethod void Test_ProjectAndTeamsInlineVF()
    {
        createData();
        ApexPages.StandardController std = new ApexPages.StandardController(objAccount);
        SL_ProjectAndTeamsInlineVF objPTInline = new SL_ProjectAndTeamsInlineVF(std);
    }
}