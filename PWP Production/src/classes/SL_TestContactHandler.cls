/**
* \arg ClassName      : SL_TestContactHandler
* \arg JIRATicket     : PWP-6
* \arg CreatedOn      : 8/DEC/2014
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This is the Test class for SL_Contact Trigger.
*/
@isTest
private class SL_TestContactHandler 
{
	static List<Account> lstAccount ;
	static List<Contact> lstContact ;
	static List<Relationship__c> lstRelationship ;
	//calling method to prepare data
    private static void createData()
    {
    	Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    	User objUser = new User(Alias = 'User1', Email='user1@user.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='user1434312@user.com');
        insert objUser;
        
    	lstAccount = new List<Account>{
	    								new Account(Name = 'Account1'),
	    								new Account(Name = 'Account2')
    							};
    	insert lstAccount;
    	
    	lstContact = new List<Contact>{
										new Contact(LastName = 'Contact1', AccountId = lstAccount[0].Id),
										new Contact(LastName = 'Contact1', AccountId = lstAccount[1].Id)    	
    							};
    	insert lstContact;
    	
    	lstRelationship = new List<Relationship__c>{
    												new Relationship__c(PWP_Employee__c = objUser.Id, External_Contact__c = lstContact[0].Id,
    																		Account__c = lstAccount[0].Id),
    												new Relationship__c(PWP_Employee__c = objUser.Id, External_Contact__c = lstContact[0].Id,
    																		Account__c = lstAccount[0].Id),
    												new Relationship__c(PWP_Employee__c = objUser.Id, External_Contact__c = lstContact[1].Id,
    																		Account__c = lstAccount[1].Id),
    												new Relationship__c(PWP_Employee__c = objUser.Id, External_Contact__c = lstContact[1].Id,
    																		Account__c = lstAccount[1].Id)
    											};
    	insert lstRelationship;
    }
    
    //Function to check for field update
	private static testMethod void test()
	{
		createData();
		List<Contact> lstContactToUpdate = new List<Contact>{
																new Contact(Id = lstContact[0].Id, AccountId = lstAccount[1].Id),
																new Contact(Id = lstContact[1].Id, AccountId = lstAccount[0].Id)    	
    														};
    	update lstContactToUpdate;
    	system.assertEquals(lstAccount[1].Id,[SELECT Account__c from Relationship__c where Id = : lstRelationship[0].Id].Account__c);
    	system.assertEquals(lstAccount[1].Id,[SELECT Account__c from Relationship__c where Id = : lstRelationship[1].Id].Account__c);
    	system.assertEquals(lstAccount[0].Id,[SELECT Account__c from Relationship__c where Id = : lstRelationship[2].Id].Account__c);
    	system.assertEquals(lstAccount[0].Id,[SELECT Account__c from Relationship__c where Id = : lstRelationship[3].Id].Account__c);
	}
}