/**
* \arg TriggerName    : SL_Test_RelationshipHandler
* \arg JIRATicket     : PWP-5,PWP-8
* \arg CreatedOn      : 11/DEC/2014
* \arg LastModifiedOn : 17/MAR/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as test class for relationship trigger to test the functionality. 
*/
@isTest
private class SL_Test_RelationshipHandler 
{
    static List<Account> lstAccount;
    static List<Contact> lstContact;
    static List<Relationship__c> lstRelationship;
    static List<Coverage_Team_Members__c> lstCTM;
    static List<User> lstUser;
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
    										new Contact(LastName = 'Test Contact 1', AccountId = lstAccount[0].Id),
    										new Contact(LastName = 'Test Contact 2', AccountId = lstAccount[0].Id),
    										new Contact(LastName = 'Test Contact 3', AccountId = lstAccount[1].Id),
    										new Contact(LastName = 'Test Contact 4', AccountId = lstAccount[1].Id)
    								  };
    	insert lstContact;
    	
    	lstCTM = new List<Coverage_Team_Members__c>{
    												new Coverage_Team_Members__c(PWP_Employee__c = lstUser[0].Id, Company__c = lstAccount[0].Id),		
    												new Coverage_Team_Members__c(PWP_Employee__c = lstUser[0].Id, Company__c = lstAccount[0].Id)
    												};
    	insert lstCTM;
    	
    	lstRelationship = new List<Relationship__c>{
    													new Relationship__c(External_Contact__c = lstContact[0].Id, PWP_Employee__c = lstUser[0].Id),
    													new Relationship__c(Account__c = lstAccount[0].Id, PWP_Employee__c = lstUser[0].Id),
    													new Relationship__c(Account__c = lstAccount[0].Id, PWP_Employee__c = lstUser[1].Id)
    											   };
    	insert lstRelationship;
    }
    
    //test method to check funtionality for insert
    static testMethod void checkForInsert() 
    {
        createData();
        System.assertEquals([SELECT Account__c FROM Relationship__c WHERE Id=:lstRelationship[0].Id].Account__c, lstAccount[0].Id);
        //List<EntitySubscription> lstER = [SELECT Id FROM EntitySubscription];
        //System.assertEquals(lstER.size(), 2);
    }
    
    //test method to check functionality for update
    static testMethod void checkForUpdate()
    {
    	createData();
    	
    	lstRelationship[0].External_Contact__c = lstContact[2].Id;
    	Test.startTest();
    	update lstRelationship[0];
    	Test.stopTest();
    	
    	System.assertEquals([SELECT Account__c FROM Relationship__c WHERE Id=:lstRelationship[0].Id].Account__c, lstAccount[1].Id);
    	//List<EntitySubscription> lstER1 = [SELECT Id FROM EntitySubscription];
        //System.assertEquals(lstER1.size(), 3);
    }
    
    //test method to check functionality for delete
    static testMethod void checkForDelete()
    {
    	createData();
    	Test.startTest();
    	delete lstRelationship[2];
    	Test.stopTest();
    	
    	//List<EntitySubscription> lstER2 = [SELECT Id FROM EntitySubscription];
       // System.assertEquals(lstER2.size(), 1);
    }
    
    //test method to check functionality for undelete
    static testMethod void checkForUnDelete()
    {
    	createData();
    	Test.startTest();
    	delete lstRelationship[0];
    	undelete lstRelationship[0];
    	Test.stopTest();
    	
    	//List<EntitySubscription> lstER3 = [SELECT Id FROM EntitySubscription];
        //System.assertEquals(lstER3.size(), 2);
    }

    static void hydrateRelSciFieldsForRelationship(String status, String entityID){
        lstRelationship[0].RelSci_Status__c = status;
        lstRelationship[0].RelSci_EntityId__c = entityID;
    }

    //test method to check functionality for update
    static testMethod void checkForAfterUpdateContactAndUserNotChanged_RelSciValuesNotReset()
    {
        createData();

        String expectedStatus = 'Processed';
        String expectedEntityId = '1';

        hydrateRelSciFieldsForRelationship(expectedStatus, expectedEntityId);

        String currentRelSciStatus = lstRelationship[0].RelSci_Status__c;
        String currentRelSciEntityId = lstRelationship[0].RelSci_EntityId__c;

        if (String.isEmpty(lstRelationship[0].External_Contact__c )){
            lstRelationship[0].Account__c = lstAccount[0].id;    
        }
        else if (lstRelationship[0].Account__c == lstAccount[0].id){
            lstRelationship[0].Account__c = lstAccount[1].id;    
        }
        else if (lstRelationship[0].Account__c == lstAccount[1].id){
            lstRelationship[0].Account__c = lstAccount[0].id;    
        }
        
        Test.startTest();
        update lstRelationship[0];
        Test.stopTest();
        
        List<Relationship__c> expectedRelationships = [SELECT RelSci_Status__c, RelSci_EntityId__c FROM Relationship__c WHERE Id=:lstRelationship[0].id];
        System.assertEquals(expectedRelationships[0].RelSci_Status__c, expectedStatus);
        System.assertEquals(expectedRelationships[0].RelSci_EntityId__c, expectedEntityId);
        List<RelSci_Processing__c> expectedProcessingRecords = [SELECT Id FROM RelSci_Processing__c];
        System.assertEquals(expectedProcessingRecords.size(), 0);
    }

static Id GetOtherContact(Id originalID){

    if (lstContact[0].id != originalID)
    {
        return lstContact[0].id;
    }
    else    
    {
        return lstContact[1].id;
    }
    
}

static Id GetOtherUser(Id originalID){

    if (lstUser[0].id != originalID)
    {
        return lstUser[0].id;
    }
    else    
    {
        return lstUser[1].id;
    }
    
}

        //test method to check functionality for update
    static testMethod void checkForAfterUpdateContactChanged_RelSciValuesReset()
    {
          createData();

        String expectedStatus = '';
        String expectedEntityId = '';

        hydrateRelSciFieldsForRelationship('Processed', '1');

        String currentRelSciEntityId;

        String currentPWPEmployeeID;

        Relationship__c targetRelationship;
        if (String.isEmpty(lstRelationship[0].External_Contact__c )){
            if (String.isEmpty(lstRelationship[1].External_Contact__c )){
                if (String.isEmpty(lstRelationship[2].External_Contact__c )){
                    targetRelationship = lstRelationship[2];
                }                
            }
            else    
            {
               targetRelationship = lstRelationship[1];
            }
        }
        else
        {
            targetRelationship = lstRelationship[0];
        }

     
        currentRelSciEntityId = targetRelationship.RelSci_EntityId__c;
        currentPWPEmployeeID = targetRelationship.PWP_Employee__r.UserName;
        //set external contact        
        targetRelationship.External_Contact__c = GetOtherContact(targetRelationship.External_Contact__c);
        

        Test.startTest();
        update targetRelationship;
        Test.stopTest();
        
        List<Relationship__c> expectedRelationships = [SELECT RelSci_Status__c, RelSci_EntityId__c FROM Relationship__c WHERE Id=:targetRelationship.id];
        System.assertEquals(expectedRelationships[0].RelSci_Status__c, null);
        System.assertEquals(expectedRelationships[0].RelSci_EntityId__c, null);
        List<RelSci_Processing__c> expectedProcessingRecords = [SELECT Id, RelSci_EntityId__c, RelSci_User_Identifier__c FROM RelSci_Processing__c];
        //RelSci_Processing__c.RelSci_EntityId__c
        //RelSci_Processing__c.RelSci_User_Identifier__c
        System.assertEquals(expectedProcessingRecords.size(), 1);
        System.assertEquals(expectedProcessingRecords[0].RelSci_EntityId__c, currentRelSciEntityId);
        //System.assertEquals(expectedProcessingRecords[0].RelSci_User_Identifier__c, currentPWPEmployeeID);
        
        
    }

    //test method to check functionality for update
    static testMethod void checkForAfterUpdateUserChanged_RelSciValuesReset()
    {
        createData();

        String expectedStatus = '';
        String expectedEntityId = '';

        hydrateRelSciFieldsForRelationship('Processed', '1');

        String currentRelSciEntityId;

        String currentPWPEmployeeID;

        Relationship__c targetRelationship;
        if (String.isEmpty(lstRelationship[0].PWP_Employee__c )){
            if (String.isEmpty(lstRelationship[1].PWP_Employee__c )){
                if (String.isEmpty(lstRelationship[2].PWP_Employee__c )){
                    targetRelationship = lstRelationship[2];
                }                
            }
            else    
            {
               targetRelationship = lstRelationship[1];
            }
        }
        else
        {
            targetRelationship = lstRelationship[0];
        }

     
        currentRelSciEntityId = targetRelationship.RelSci_EntityId__c;
        currentPWPEmployeeID = targetRelationship.PWP_Employee__r.UserName;
        //set external contact        
        targetRelationship.PWP_Employee__c = GetOtherUser(targetRelationship.PWP_Employee__c);
        

        Test.startTest();
        update targetRelationship;
        Test.stopTest();
        
        List<Relationship__c> expectedRelationships = [SELECT RelSci_Status__c, RelSci_EntityId__c FROM Relationship__c WHERE Id=:targetRelationship.id];
        System.assertEquals(expectedRelationships[0].RelSci_Status__c, null);
        System.assertEquals(expectedRelationships[0].RelSci_EntityId__c, null);
        List<RelSci_Processing__c> expectedProcessingRecords = [SELECT Id, RelSci_EntityId__c, RelSci_User_Identifier__c FROM RelSci_Processing__c];
        //RelSci_Processing__c.RelSci_EntityId__c
        //RelSci_Processing__c.RelSci_User_Identifier__c
        System.assertEquals(expectedProcessingRecords.size(), 1);
        System.assertEquals(expectedProcessingRecords[0].RelSci_EntityId__c, currentRelSciEntityId);
        //System.assertEquals(expectedProcessingRecords[0].RelSci_User_Identifier__c, currentPWPEmployeeID);        
    }
}