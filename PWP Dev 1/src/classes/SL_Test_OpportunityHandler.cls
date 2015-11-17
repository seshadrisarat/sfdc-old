/**
* \arg ClassName        : SL_Test_OpportunityHandler
* \arg JIRATicket     	: PWP-77, PWP-88
* \arg CreatedOn      	: 23/JULY/2015
* \arg LastModifiedOn	: 28/JULY/2015
* \arg CreatededBy    	: Lodhi 
* \arg ModifiedBy     	: Lodhi
* \arg Description      : Test class for SL_Opportunity and SL_Project_Coverage_Team_Member__c triggers and SL_OpportunityHandler, 
*                         SL_ManageAccountTeamMembers and SL_Project_Coverage_Team_Member__cHandler classes
*/
@isTest
private class SL_Test_OpportunityHandler 
{
    static List<Account> lstAccount;
    static List<Opportunity> lstOpportunity;
    static List<Business_Unit__c> lstBusinessUnit;
    static List<AccountTeamMember> lstAccountTeams;
    static List<Project_Coverage_Team_Member__c> lstOpportunityTeams;
    static List<Call_Report__c> lstCallReport;
    static List<User> lstUser;
    
    private static void createData()
    {
		Id profileId  = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id;
		lstUser = new List<User>{
		    new User(Alias = 'User1', Email='user1@user.com', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userpwp1245@usrpwp.com'),
            new User(Alias = 'User2', Email='user2@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='user121jkj.464.2@user.com'),
            new User(Alias = 'User3', Email='user3@user.com', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userpwp1245_@usrpwp.com'),
            new User(Alias = 'User4', Email='user4@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='user_.464.2@user.com'),
            new User(Alias = 'User5', Email='user5@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='user_.464_4578@user.com')			         
		};
    	insert lstUser;
        
        lstBusinessUnit = new List<Business_Unit__c>{
            new Business_Unit__c(Name = 'Test BU-01'),
            new Business_Unit__c(Name = 'Test BU-02'),
            new Business_Unit__c(Name = 'Test BU-03'),
            new Business_Unit__c(Name = 'Test BU-04')
        };
        insert lstBusinessUnit;
        
        lstAccount = new List<Account>{
            new Account(Name = 'Test Account-01'),
            new Account(Name = 'Test Account-02'),
            new Account(Name = 'Test Account-03'),
            new Account(Name = 'Test Account-04')
        };
        insert lstAccount;
        
        lstAccountTeams = new List<AccountTeamMember>{
            new AccountTeamMember(UserId = lstUser[0].Id, AccountId = lstAccount[0].Id, TeamMemberRole = 'Role-01'),
            new AccountTeamMember(UserId = lstUser[1].Id, AccountId = lstAccount[0].Id, TeamMemberRole = 'Role-01')
        };
        insert lstAccountTeams;
         
        lstCallReport = new List<Call_Report__c>{
            new Call_Report__c(Name = 'Test CR-01', Call_Report_Date__c = Date.Today(), Reference_Account__c = lstAccount[0].Id),    
            new Call_Report__c(Name = 'Test CR-02', Call_Report_Date__c = Date.Today(), Reference_Account__c = lstAccount[1].Id)
        };
        insert lstCallReport;
        
        lstOpportunity = new List<Opportunity>{
            new Opportunity(Name = 'TestOpp-01', StageName = 'Active Mandate', AccountId = lstAccount[0].Id, 
                            CloseDate = date.today(), Business_Group__c = lstBusinessUnit[0].Id),
            new Opportunity(Name = 'TestOpp-02', StageName = 'Prospective Mandate', AccountId = lstAccount[0].Id, 
                            CloseDate = date.today(), Business_Group__c = lstBusinessUnit[1].Id),
            new Opportunity(Name = 'TestOpp-03', StageName = 'Previous Mandate', AccountId = lstAccount[0].Id, 
                            CloseDate = date.today(), Business_Group__c = lstBusinessUnit[2].Id),
            new Opportunity(Name = 'TestOpp-04', StageName = 'Lost/Cancelled', AccountId = lstAccount[0].Id, 
                            CloseDate = date.today(), Business_Group__c = lstBusinessUnit[3].Id),
            
            new Opportunity(Name = 'TestOpp-05', StageName = 'Prospective Mandate', AccountId = lstAccount[1].Id, 
                            CloseDate = date.today(), Business_Group__c = lstBusinessUnit[0].Id),
            new Opportunity(Name = 'TestOpp-06', StageName = 'Previous Mandate', AccountId = lstAccount[1].Id, 
                            CloseDate = date.today(), Business_Group__c = lstBusinessUnit[1].Id),
            new Opportunity(Name = 'TestOpp-07', StageName = 'Lost/Cancelled', AccountId = lstAccount[1].Id, 
                            CloseDate = date.today(), Business_Group__c = lstBusinessUnit[2].Id),                            
                            
            new Opportunity(Name = 'TestOpp-08', StageName = 'Previous Mandate', AccountId = lstAccount[2].Id, 
                            CloseDate = date.today(), Business_Group__c = lstBusinessUnit[2].Id),
            new Opportunity(Name = 'TestOpp-09', StageName = 'Lost/Cancelled', AccountId = lstAccount[2].Id, 
                            CloseDate = date.today(), Business_Group__c = lstBusinessUnit[3].Id),
                            
            new Opportunity(Name = 'TestOpp-10', StageName = 'Lost/Cancelled', AccountId = lstAccount[3].Id, 
                            CloseDate = date.today(), Business_Group__c = lstBusinessUnit[3].Id)                           
        };
        insert lstOpportunity;
        
        lstOpportunityTeams = new List<Project_Coverage_Team_Member__c>{
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[0].Id, User__c = lstUser[0].Id),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[0].Id, User__c = lstUser[1].Id),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[0].Id, User__c = lstUser[2].Id),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[0].Id, User__c = lstUser[3].Id),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[0].Id, User__c = lstUser[4].Id)
        };
        insert lstOpportunityTeams;
    }
    
	private static testMethod void Test_OpportunityHandler() 
	{
        createData();
        System.assertEquals([SELECT Id FROM Call_Report__Share WHERE ParentId =: lstCallReport[0].Id AND RowCause = 'Manual'].size(), 5);
        system.assertEquals([SELECT Id FROM AccountTeamMember WHERE AccountId =: lstAccount[0].Id].size(), 5);
        System.assertEquals([SELECT Id FROM EntitySubscription WHERE ParentId =: lstAccount[0].Id].size(), 3);
        
        system.assertEquals([SELECT Status__c FROM Account WHERE Id =: lstAccount[0].Id].Status__c, 'Active Client');
        system.assertEquals([SELECT Project_Business_Group__c FROM Account WHERE Id =: lstAccount[0].Id].Project_Business_Group__c, 'Test BU-01');
        system.assertEquals([SELECT Status__c FROM Account WHERE Id =: lstAccount[1].Id].Status__c, 'Prospective Client');
        system.assertEquals([SELECT Status__c FROM Account WHERE Id =: lstAccount[2].Id].Status__c, 'Past Mandate');
        system.assertEquals([SELECT Status__c FROM Account WHERE Id =: lstAccount[3].Id].Status__c, 'Lost Mandate');
        
        lstOpportunity[0].StageName = 'Previous Mandate';
        lstOpportunity[1].StageName = 'Lost/Cancelled';
        lstOpportunity[4].StageName = 'Previous Mandate';
        
        update lstOpportunity;
        
        System.assertEquals([SELECT Id FROM Call_Report__Share WHERE ParentId =: lstCallReport[0].Id AND RowCause = 'Manual'].size(), 5);
        system.assertEquals([SELECT Id FROM AccountTeamMember WHERE AccountId =: lstAccount[0].Id].size(), 5);
        System.assertEquals([SELECT Id FROM EntitySubscription WHERE ParentId =: lstAccount[0].Id].size(), 3);
        
        system.assertEquals([SELECT Status__c FROM Account WHERE Id =: lstAccount[0].Id].Status__c, 'Past Mandate');
        system.assertEquals([SELECT Status__c FROM Account WHERE Id =: lstAccount[1].Id].Status__c, 'Past Mandate');
        
        delete lstOpportunity[9];
        
        system.assertEquals([SELECT Status__c FROM Account WHERE Id =: lstAccount[3].Id].Status__c, null);
        system.assertEquals([SELECT Project_Business_Group__c FROM Account WHERE Id =: lstAccount[3].Id].Project_Business_Group__c, null); 
        
        lstOpportunity[7].AccountId = lstAccount[3].Id;
        
        update lstOpportunity[7];
        
        system.assertEquals([SELECT Status__c FROM Account WHERE Id =: lstAccount[3].Id].Status__c, 'Past Mandate');
        system.assertEquals([SELECT Project_Business_Group__c FROM Account WHERE Id =: lstAccount[3].Id].Project_Business_Group__c, 'Test BU-03');
        
        delete lstOpportunityTeams[0];
         
        System.assertEquals([SELECT Id FROM Call_Report__Share WHERE ParentId =: lstCallReport[0].Id AND RowCause = 'Manual'].size(), 4);
        system.assertEquals([SELECT Id FROM AccountTeamMember WHERE AccountId =: lstAccount[0].Id].size(), 4);
        System.assertEquals([SELECT Id FROM EntitySubscription WHERE ParentId =: lstAccount[0].Id].size(), 3);
	}
}