@isTest
private class SL_test_VendorHeaderComponentController {
	
	@isTest static void SL_ctrl_VendorHeaderComponent() {

		RecordType objRecordType = [Select Id from RecordType where Name='Vendor Division' AND SobjectType ='Account' limit 1];
    	
    	Account objAccount = new Account(Name='TestJared',RecordTypeId = objRecordtype.Id, OwnerId = [Select Id from User where Name = 'Peter Dwyer' limit 1].Id);
	    insert objAccount;
    	
    	Contact objContact = new Contact();
    	objContact.LastName = 'TestContact';
    	objContact.AccountId = objAccount.Id;
    	insert objContact;
    	    	
        Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Vendor - External' OR Name='Partner Community User' LIMIT 1];

    	User objUser = new User(Email='standarduser@testorg.com', LastName='Testing',
    							 UserName='jaredTest@jaredTestOrg.com' , ContactID = objContact.Id,
    							 Alias = 'testu', ProfileId = objCommunityUserProfile.Id, EmailEncodingKey='UTF-8',
    							 LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles');              
                             
        insert objUser;

        Portal_Branding__c objBranding = new Portal_Branding__c(
            Name = 'TestBranding', 
            Unique_Id__c = 'test', 
            Font__c = 'Arial', 
            Schedule_Listview__c = 'FAEF Vendor Schedule Listview', 
            Opportunity_Listview__c = 'FAEF Vendor Opportunity Listview');
        insert objBranding;

		Account_Portal__c objAcctPortal = new Account_Portal__c(Portal__c = objBranding.Id, Account_Portal__c = objAccount.Id);
        insert objAcctPortal;

        Portal_Message__c objMessageCurrent = new Portal_Message__c(Portal__c = objBranding.Id, Publish_Date__c = Date.today(), End_Publish_Date__c = Date.today().addDays(1), Message__c = 'test current') ;
		Portal_Message__c objMessageOld = new Portal_Message__c(Portal__c = objBranding.Id, Publish_Date__c = Date.today().addDays(-2), End_Publish_Date__c = Date.today().addDays(-1), Message__c = 'test old');
		insert objMessageCurrent;
		insert objMessageOld;

        Portal_Contact__c objPContatct1 = new Portal_Contact__c(Portal_Branding__c = objBranding.Id, Active__c = true, User__c = [Select Id from User where Name = 'Peter Dwyer' limit 1].Id, Order__c = 1);
		Portal_Contact__c objPContatct2 = new Portal_Contact__c(Portal_Branding__c = objBranding.Id, Active__c = true, User__c = [Select Id from User where Name = 'Peter Dwyer' limit 1].Id, Order__c = 2);
        Portal_Contact__c objPContatct3 = new Portal_Contact__c(Portal_Branding__c = objBranding.Id, Active__c = true, User__c = [Select Id from User where Name = 'Peter Dwyer' limit 1].Id, Order__c = 3);
		Portal_Contact__c objPContatct4 = new Portal_Contact__c(Portal_Branding__c = objBranding.Id, Active__c = false, User__c = [Select Id from User where Name = 'Peter Dwyer' limit 1].Id, Order__c = 1);
		insert objPContatct1;
		insert objPContatct2;
		insert objPContatct3;
		insert objPContatct4;

		System.runAs(objUser) 
        {
			SL_ctrl_VendorHeaderComponent page = new SL_ctrl_VendorHeaderComponent();
        	System.assertEquals(page.brandingId, objBranding.Unique_Id__c);
    	}
	}
	
}