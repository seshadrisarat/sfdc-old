/**
* \arg ClassName        : SL_Test_Batch_CreateSharingRecords
* \arg JIRATicket     	: FBR-2
* \arg CreatedOn      	: 06/April/2015
* \arg LastModifiedOn   : 10/APR/2015
* \arg CreatededBy    	: Nrusingh
* \arg LastModifiedBy	: Pankaj Ganwani
*/
@isTest
private class SL_Test_Batch_CreateSharingRecords 
{
	static final Id employeeRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType =: 'Contact' AND DeveloperName =: 'Employee'].Id;
    static testMethod void SL_Test_Batch_CreateSharingRecords() 
    {
		List<Deals__c> lstDeal;
		List<Deal_Team_Member__c> lstDealTeamMember;
		List<Contact> lstContact;
		List<User> lstUser;
    	
    	// Fetch ProfileId 
    	String profileId = [SELECT Id FROM Profile WHERE Name =:'Standard User' LIMIT 1].Id;
    	
    	// Insert User
    	lstUser = new List<User>{
    								new User(Alias = 'User11', Email='user1122@user.com', 
			                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
			                                LocaleSidKey='en_US', ProfileId = profileId, 
			                                TimeZoneSidKey='America/Los_Angeles', UserName='user1222324@user.com'),
			                        new User(Alias = 'User21', Email='user111122@user.com', 
			                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
			                                LocaleSidKey='en_US', ProfileId = profileId, 
			                                TimeZoneSidKey='America/Los_Angeles', UserName='use1r12324@user.com')
    							};
    	insert lstUser;
    	
    	// Insert Contact
    	lstContact = new List<Contact>{
    										new Contact(LastName = 'Test Contact 1', User__c = lstUser[0].Id, RecordTypeId = employeeRecordTypeId),
    										new Contact(LastName = 'Test Contact 2', User__c = lstUser[1].Id, RecordTypeId = employeeRecordTypeId)
    								  };
    	insert lstContact;
    	
    	// Insert Account
    	Account objAccount  = (new Account (Name = 'TestAccount', Stock_Exchange__c = 'NYSE', Primary_Relationship_Banker__c = lstContact[0].Id, Priority_Ranking__c = 'Not Ranked', Sector__c = 'Insurance'));
        insert objAccount;
    	
    	// Insert Deal
    	lstDeal = new List<Deals__c>{
    									new Deals__c(Name = 'TestDeal', Company__c = objAccount.Id, Lead_Banker__c = lstContact[0].Id, Transaction_Type__c = 'IPO', FBR_Role__c = 'Advisor',
        								  Probability__c = 'Low', Deal_Stage__c = 'Pitch' , Engagement_Status__c = 'Not Engaged'),
    									new Deals__c(Name = 'TestDea2', Company__c = objAccount.Id, Lead_Banker__c = lstContact[1].Id, Transaction_Type__c = 'IPO', FBR_Role__c = 'Advisor',
        								  Probability__c = 'Low', Deal_Stage__c = 'Pitch' , Engagement_Status__c = 'Not Engaged')
    								};
    	insert lstDeal;
    	
    	// Insert Deal Team Member
    	lstDealTeamMember = new List<Deal_Team_Member__c>{
    															new Deal_Team_Member__c(Related_Deal__c = lstDeal[0].Id, FBR_Team_Member__c = lstContact[0].Id, Status__c = 'Active'),
    															new Deal_Team_Member__c(Related_Deal__c = lstDeal[0].Id, FBR_Team_Member__c = lstContact[1].Id, Status__c = 'Active'),
    															new Deal_Team_Member__c(Related_Deal__c = lstDeal[1].Id, FBR_Team_Member__c = lstContact[0].Id, Status__c = 'Active'),
    															new Deal_Team_Member__c(Related_Deal__c = lstDeal[1].Id, FBR_Team_Member__c = lstContact[1].Id, Status__c = 'Active')
    													 };
    	insert lstDealTeamMember;
    	
    	Test.startTest();
    	Database.executeBatch(new SL_Batch_CreateSharingRecords(), 200);
   		Test.stopTest();
   		
   		system.assertEquals([SELECT count() FROM Deal_Team_Member__c WHERE Status__c = 'Active'],6);
    }
}