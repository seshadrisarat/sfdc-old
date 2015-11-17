/*
ClassName 		: SL_Test_SyncContactController
JIRA Ticket 	: AMSEC-578
CreatedOn 		: 22/Sept/15
LastModifiedOn  : 22/Sept/15
CreatededBy 	: Praful Gadge
ModifiedBy 		: Praful Gadge
Description 	: Unit Test code for functionality that add Sync Contact button on contact detail page
*/
@isTest
private class SL_Test_SyncContactController {

	static ApexPages.StandardController objStandarController;
    
    static testMethod void testSyncContactMethod() {

        //Creating New Contact
        Contact objContact1 = new Contact(LastName = 'TestContact1', Salesforce_User__c = UserInfo.getUserId());
        insert objContact1;

        Contact objContact2 = new Contact(LastName = 'TestContact2');
        insert objContact2;

        //Creating New Outlook Sync
        Outlook_Sync__c objOutlookSync = new Outlook_Sync__c(Contact__c = objContact1.Id, AS_Person__c = objContact2.Id);
        insert objOutlookSync;
        
        objStandarController = new ApexPages.standardController(objContact1);

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

        User u = new User(Alias = 'standt', Email='testSU@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testSU@testorg.com', Contact_ID__c = objContact2.Id);

        System.runAs(u) {
            
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());             

            SL_SyncContactController objExtension = new SL_SyncContactController(objStandarController);
    		objExtension.syncContact();
        }

        SL_SyncContactController objExtension = new SL_SyncContactController(objStandarController);
        objExtension.getIsSyncContact();
    	objExtension.syncContact();
    }
}