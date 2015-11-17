/**
* \arg ClassName        : SL_Test_ProjectCoverageTeamsController
* \arg JIRATicket     	: PWP-83
* \arg CreatedOn      	: 29/JULY/2015
* \arg LastModifiedOn	: 29/JULY/2015
* \arg CreatededBy    	: Lodhi 
* \arg ModifiedBy     	: Lodhi
* \arg Description      : Test class for SL_AutoComplete_Controller and SL_ProjectCoverageTeamsController class.
*/
@isTest
private class SL_Test_ProjectCoverageTeamsController 
{
    static List<Account> lstAccount;
    static List<Business_Unit__c> lstBusinessUnit;
    static List<Business_Unit_Members__c> lstBusinessUnitMembers;
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
            new Business_Unit__c(Name = 'Test BU-02')
        };
        insert lstBusinessUnit;
        
        lstBusinessUnitMembers = new List<Business_Unit_Members__c>{
            new Business_Unit_Members__c(PWP_Employee__c = lstUser[0].Id, Business_Unit__c = lstBusinessUnit[0].Id),
            new Business_Unit_Members__c(PWP_Employee__c = lstUser[1].Id, Business_Unit__c = lstBusinessUnit[0].Id),
            new Business_Unit_Members__c(PWP_Employee__c = lstUser[2].Id, Business_Unit__c = lstBusinessUnit[0].Id),
            new Business_Unit_Members__c(PWP_Employee__c = lstUser[3].Id, Business_Unit__c = lstBusinessUnit[1].Id),
            new Business_Unit_Members__c(PWP_Employee__c = lstUser[4].Id, Business_Unit__c = lstBusinessUnit[1].Id),
            new Business_Unit_Members__c(PWP_Employee__c = UserInfo.getUserId(), Business_Unit__c = lstBusinessUnit[1].Id)
        };
        insert lstBusinessUnitMembers;
        
        lstAccount = new List<Account>{
            new Account(Name = 'Test Account-01'),
            new Account(Name = 'Test Account-02')
        };
        insert lstAccount;
    }
    
	private static testMethod void SL_Test_ProjectInsert() 
	{
        createData();
        
        Apexpages.currentPage().getParameters().put('retURL', 'testUrl');
        Apexpages.currentPage().getParameters().put('accId', lstAccount[0].Id);
        Apexpages.StandardController std = new Apexpages.StandardController(new Opportunity());
        SL_ProjectCoverageTeamsController objPCTC = new SL_ProjectCoverageTeamsController(std);
        
        objPCTC.objProject.Business_Group__c = lstBusinessUnit[0].Id;
        objPCTC.bussGroupRelatedCoverageTeamMembers();
        objPCTC.strSelAll = 'AddAll';
        objPCTC.selectAllOrRemoveUsers();
        objPCTC.selectUnselectCoverageTeam();
        objPCTC.otherTeamMembers();
        objPCTC.saveClick();
        
        system.assertEquals([SELECT Id FROM Opportunity].size(), 1);
        system.assertEquals([SELECT Id FROM Project_Coverage_Team_Member__c].size(), 3);
        
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity];
        Apexpages.StandardController std1 = new Apexpages.StandardController(lstOpp[0]);
        SL_ProjectCoverageTeamsController objPCTC1 = new SL_ProjectCoverageTeamsController(std1);
        objPCTC.cancelClick();
	}
	
	private static testMethod void SL_Test_AutoComplete() 
	{
	    createData();
	    String strExistingUser = '['+lstUser[0].Id +','+ lstUser[1].Id +','+ lstUser[2].Id +']';
	    
	    SL_AutoComplete_Controller.findSObjects('User', strExistingUser, lstUser[3].Name);
	}
}