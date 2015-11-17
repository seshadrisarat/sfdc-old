/**
* \arg ClassName      : SL_TestCoverage_Team_MembersHandler
* \arg JIRATicket     : PWP-11
* \arg CreatedOn      : 18/DEC/2014
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This is the Test class for SL_Coverage_Team_Members Trigger.
*/
@isTest
private class SL_TestCoverage_Team_MembersHandler 
{
	static List<Coverage_Team_Members__c> lstCoverageTeamMembers ;
	static List<Account> lstAccount ;
	static List<Relationship__c> lstRelationship ;
	
	//calling method to prepare data
	private static void createData()
	{
		List<User> lstUser;
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		lstUser = new List<User> {
									new User(Alias = 'User1', Email='user1@user.com', 
			                                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
			                                LocaleSidKey='en_US', ProfileId = p.Id, 
			                                TimeZoneSidKey='America/Los_Angeles', UserName='user1kjkj.212@user.com'),
									new User(Alias = 'User2', Email='user2@user.com', 
			                                EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			                                LocaleSidKey='en_US', ProfileId = p.Id, 
			                                TimeZoneSidKey='America/Los_Angeles', UserName='userjkj.464.2@user.com')

								};
    	insert lstUser;

    	lstAccount = new List<Account>{
	    								new Account(Name = 'Account1'),
	    								new Account(Name = 'Account2')
    								  };
    	insert lstAccount;
    	
    	lstRelationship = new List<Relationship__c>{
    													new Relationship__c(Account__c = lstAccount[0].Id, PWP_Employee__c = lstUser[0].Id),
    													new Relationship__c(Account__c = lstAccount[0].Id, PWP_Employee__c = lstUser[1].Id)
    											   };
    	insert lstRelationship;

    	lstCoverageTeamMembers = new List<Coverage_Team_Members__c>
    							{
	    								new Coverage_Team_Members__c(Company__c = lstAccount[0].Id, PWP_Employee__c = lstUser[0].Id),
	    								new Coverage_Team_Members__c(Company__c = lstAccount[0].Id, PWP_Employee__c = lstUser[1].Id),
	    								new Coverage_Team_Members__c(Company__c = lstAccount[1].Id, PWP_Employee__c = lstUser[0].Id),
	    								new Coverage_Team_Members__c(Company__c = lstAccount[1].Id, PWP_Employee__c = lstUser[1].Id)
    							};
    	insert lstCoverageTeamMembers;
	}

	private static testMethod void test()
	{
	    createData();
		system.assertEquals(4,[SELECT Id FROM EntitySubscription].size());
		
		List<Coverage_Team_Members__c> lstCoverageTeamMembersToDelete = new List<Coverage_Team_Members__c>{
	    								new Coverage_Team_Members__c(Id = lstCoverageTeamMembers[0].Id),
	    								new Coverage_Team_Members__c(Id = lstCoverageTeamMembers[1].Id),
	    								new Coverage_Team_Members__c(Id = lstCoverageTeamMembers[2].Id)
    							};
    	// delete 3 records
    	delete lstCoverageTeamMembersToDelete;
    	List<EntitySubscription> lstES = [SELECT Id, ParentId, SubscriberId FROM EntitySubscription];
    	
    	system.assertEquals(3, lstES.size());

    	// undelete 3 records
    	undelete lstCoverageTeamMembersToDelete;
    	system.assertEquals(4, [SELECT Id FROM Coverage_Team_Members__c].size());
    	system.assertEquals(4, [SELECT Id FROM EntitySubscription].size());

    	List<Coverage_Team_Members__c> lstCoverageTeamMembersToUpdate = new List<Coverage_Team_Members__c>{
	    								new Coverage_Team_Members__c(Id = lstCoverageTeamMembers[0].Id, Company__c = lstAccount[1].Id, PWP_Employee__c = lstCoverageTeamMembers[0].PWP_Employee__c)};
    	
    	update lstCoverageTeamMembersToUpdate;
    	
    	lstES = [SELECT Id, ParentId, SubscriberId 
    			   FROM EntitySubscription 
    			  WHERE ParentId = :lstCoverageTeamMembersToUpdate[0].Company__c 
    			    AND SubscriberId = :lstCoverageTeamMembersToUpdate[0].PWP_Employee__c];
    	system.assertEquals(false, lstES.isEmpty());
	}
}