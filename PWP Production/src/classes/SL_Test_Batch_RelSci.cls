/**
* \arg TriggerName    : SL_Test_Batch_RelSci
* \arg JIRATicket     : PWP-8
* \arg CreatedOn      : 22/JAN/2014
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class is used to check functionality of rel sci batch processes for creating and deleting the relationships. 
*/
@isTest
private class SL_Test_Batch_RelSci 
{
    static List<Account> lstAccount;
    static List<Contact> lstContact;
    static List<Relationship__c> lstRelationship;
    static List<User> lstUser;
    static RelSciIntegration__c objRelSciIntegration;
    //Method to prepare test data
    static void createData()
    {
    	Profile objProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
    	
    	lstUser = new List<User>{
	    						new User(Alias = 'User1', Email='user1@user.com', EmailEncodingKey='UTF-8', LastName='Testing', 
	    								 LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = objProfile.Id, 
	    								 TimeZoneSidKey='America/Los_Angeles', UserName='user211.79874@user.com'),
	    						new User(Alias = 'User2', Email='user3424@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', 
	    								 LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = objProfile.Id, 
	    								 TimeZoneSidKey='America/Los_Angeles', UserName='user5461.79874@user.com')
    							};		 
        insert lstUser;
    	
    	lstAccount = new List<Account>{
    										new Account(Name = 'Test Account 1'),
    										new Account(Name = 'Test Account 2')
    								  };
    	insert lstAccount;
    	
    	lstContact = new List<Contact>{
    										new Contact(FirstName = 'Test', LastName = 'Test Contact 1', AccountId = lstAccount[0].Id),
    										new Contact(FirstName = 'Test', LastName = 'Test Contact 2', AccountId = lstAccount[0].Id),
    										new Contact(FirstName = 'Test', LastName = 'Test Contact 3', AccountId = lstAccount[1].Id),
    										new Contact(FirstName = 'Test', LastName = 'Test Contact 4', AccountId = lstAccount[1].Id)
    								  };
    	insert lstContact;
    	
    	
    	lstRelationship = new List<Relationship__c>{
    													new Relationship__c(External_Contact__c = lstContact[0].Id, PWP_Employee__c = lstUser[0].Id),
    													new Relationship__c(External_Contact__c = lstContact[1].Id, PWP_Employee__c = lstUser[1].Id),
    													new Relationship__c(External_Contact__c = lstContact[2].Id, Account__c = lstAccount[0].Id, PWP_Employee__c = lstUser[0].Id, Relsci_Status__c = 'Uploaded', RelSci_SyncId__c = '2'),
    													new Relationship__c(Account__c = lstAccount[0].Id, PWP_Employee__c = lstUser[1].Id, RelSci_EntityId__c = '12345',  Relsci_Status__c = 'Processed', RelSci_SyncId__c = '232'),
    													new Relationship__c(Account__c = lstAccount[0].Id, External_Contact__c = lstContact[3].Id)
    											   };
    	insert lstRelationship;
    	
    	objRelSciIntegration = new RelSciIntegration__c(API_Password__c = 'pwprelsci909', API_URL__c = 'https://sandbox.relsci.com/v1/', 
    													API_Username__c = 'PWPApiUser', Enabled__c=true, Relationship_Strength__c = 'Average' );
    	insert objRelSciIntegration;
    }
    
    static testMethod void checkForEstablishRelSci() 
    {
        createData();
        
        Test.startTest();
        Database.executeBatch(new SL_Batch_Establish_RelSci_Relationship('SELECT Id, PWP_Employee__r.username, External_Contact__r.FirstName, External_Contact__r.Lastname, External_Contact__r.Email FROM Relationship__C WHERE Relsci_Status__c = null and External_Contact__r.FirstName != null and External_Contact__r.LastName != null' ), 33);
        Test.stopTest();
        
        System.assertEquals([SELECT Relsci_Status__c FROM Relationship__c WHERE Id=:lstRelationship[0].Id].RelSci_Status__c, 'Uploaded');
        System.assertEquals([SELECT Relsci_Status__c FROM Relationship__c WHERE Id=:lstRelationship[4].Id].RelSci_Status__c, 'Invalid');
    }
    
    static testMethod void checkForRelationshipCreate()
    {
    	createData();
    	
    	Test.startTest();
    	Database.executeBatch(new SL_Batch_ProcessContactUpload_RelSci('SELECT Id, RelSci_SyncId__c, PWP_Employee__r.username FROM Relationship__C WHERE Relsci_Status__c = \'Uploaded\' and RelSci_SyncId__c != null'), 49);
    	Test.stopTest();
    	
    	System.assertEquals([SELECT Relsci_Status__c FROM Relationship__c WHERE Id=:lstRelationship[2].Id].RelSci_Status__c, 'Processed');
    	System.assertEquals([SELECT RelSci_EntityId__c FROM Relationship__c WHERE Id=:lstRelationship[2].Id].RelSci_EntityId__c, '73631');
    }
    
    static testMethod void checkForDeleteRecSciProcessing()
    {
    	createData();
    	delete lstRelationship[3];
    	Test.startTest();
    	Database.executeBatch(new SL_Batch_ProcessAlteredRel_RelSci('SELECT Id, RelSci_EntityId__c,RelSci_User_Identifier__c FROM RelSci_Processing__c' ));
    	Test.stopTest();
    }
    
    static testMethod void coverageForSchedulers()
    {
    	 createData();
    	 
    	 Test.startTest();
		 System.schedule('Upload New Relationships to RelSci', '0 0 0/1 1/1 * ?', new SL_BatchScheduler_Establish_RelSci());
		 System.schedule('Process Uploaded Relationships from RelSci', '0 5 0/1 1/1 * ?', new SL_BatchScheduler_ProcessConUpl_RelSci());
		 System.schedule('Process Altered Relationships for RelSci', '0 30 0/1 1/1 * ?', new SL_BatchScheduler_ProcAlteredRel_RelSci());
    	 Test.stopTest();
    }
}