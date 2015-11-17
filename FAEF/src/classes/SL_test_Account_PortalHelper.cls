/*
 * Runs test for SL_Account_PortalHelper, SL_UserHelper, and SL_Portal_Contact_Helper
 */

@isTest
public without sharing class SL_test_Account_PortalHelper {
	
	@isTest static void test_Account_PortalHelper(){
		RecordType objRecordType = [Select Id from RecordType where Name='Vendor Division' AND SobjectType ='Account' limit 1];
        
		Profile internalCommunityProfile = [SELECT Id FROM Profile WHERE Name='Sales - RVP - Vendor' LIMIT 1];
        Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Partner Community User' LIMIT 1];
		UserRole internalCommunityRole = [SELECT Id FROM UserRole WHERE Name='Sales- Vendor' LIMIT 1];

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
			Vendor_Community_Name__c communityName = new Vendor_Community_Name__c();
			communityName.Name = 'Vendor Community';
			communityName.Community_Name__c = 'FAEF Vendor Community';
			insert communityName;

			Account objAccount;
			List<User> internalCommunityUsers;

			internalCommunityUsers = new List<User>();
	        internalCommunityUsers.add(new User(Email='standarduser1@testorg.com', LastName='Testing1', UserName='jaredTest1@jaredTestOrg.com',
	                                 Alias = 'testu', ProfileId = internalCommunityProfile.Id, EmailEncodingKey='UTF-8', UserRoleId = internalCommunityRole.Id,
	                                 LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles'));           
	        internalCommunityUsers.add(new User(Email='standarduser2@testorg.com', LastName='Testing2', UserName='jaredTest2@jaredTestOrg.com',
	                                 Alias = 'testu', ProfileId = internalCommunityProfile.Id, EmailEncodingKey='UTF-8', UserRoleId = null,
	                                 LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles'));
		    internalCommunityUsers.add(new User(Email='standarduser3@testorg.com', LastName='Testing3', UserName='jaredTest3@jaredTestOrg.com',
	                                 Alias = 'testu', ProfileId = internalCommunityProfile.Id, EmailEncodingKey='UTF-8', UserRoleId = null,
	                                 LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles'));
	        internalCommunityUsers.add(new User(Email='standarduser4@testorg.com', LastName='Testing4', UserName='jaredTest4@jaredTestOrg.com',
	                                 Alias = 'testu', ProfileId = internalCommunityProfile.Id, EmailEncodingKey='UTF-8', UserRoleId = null,
	                                 LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles'));              
	                             
	        insert internalCommunityUsers;

        	objAccount = new Account(Name='TestJared',RecordTypeId = objRecordtype.Id, OwnerId = internalCommunityUsers.get(0).Id);
        	insert objAccount;

	        Contact objContact = new Contact();
	        objContact.LastName = 'TestContact';
	        objContact.AccountId = objAccount.Id;
	        insert objContact;
	                

	        User communityUser = new User(Email='standarduser@testorg.com', LastName='Testing',
                                 UserName='jaredTest@jaredTestOrg.com' , ContactID = objContact.Id, UserRoleId = null,
                                 Alias = 'testu', ProfileId = objCommunityUserProfile.Id, EmailEncodingKey='UTF-8',
                                 LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles');              
            insert communityUser;
	    
	        Portal_Branding__c objBranding = new Portal_Branding__c(
	            Name = 'TestBranding', 
	            Unique_Id__c = 'test', 
	            Font__c = 'Arial', 
	            Schedule_Listview__c = 'FAEF Vendor Schedule Listview', 
	            Opportunity_Listview__c = 'FAEF Vendor Opportunity Listview');
        	insert objBranding;

	        List<Portal_Contact__c> contacts = new List<Portal_Contact__c>();
			contacts.add(new Portal_Contact__c(Portal_Branding__c = objBranding.Id, Active__c = true, User__c = internalCommunityUsers.get(1).Id, Order__c = 1, Is_Chatter__c = true));
	        contacts.add(new Portal_Contact__c(Portal_Branding__c = objBranding.Id, Active__c = true, User__c = internalCommunityUsers.get(2).Id, Order__c = 2, Is_Chatter__c = true));
	        contacts.add(new Portal_Contact__c(Portal_Branding__c = objBranding.Id, Active__c = true, User__c = internalCommunityUsers.get(3).Id, Order__c = 3, Is_Chatter__c = false));
	        insert contacts;
        
	        Account_Portal__c objAcctPortal = new Account_Portal__c(Portal__c = objBranding.Id, Account_Portal__c = objAccount.Id);
	        Test.startTest();
	    		insert objAcctPortal;

					Account_Portal__c newAcctPortal = [SELECT Id, Chatter_Group_Id__c FROM Account_Portal__c WHERE Id =: objAcctPortal.Id];

	        System.assertNotEquals(newAcctPortal.Chatter_Group_Id__c, null);
	        CollaborationGroup cGroup = [SELECT MemberCount, Id FROM CollaborationGroup WHERE Id =: newAcctPortal.Chatter_Group_Id__c];
	        System.assertNotEquals(cGroup, null);
	        List<CollaborationGroupMember> cGroupMembers = [SELECT MemberId, Id FROM CollaborationGroupMember WHERE CollaborationGroupId =: cGroup.Id];
	        System.assertEquals(cGroupMembers.size(), 4);
	        Portal_Contact__c updatedContact = [SELECT Id, Community_Email_Frequency__c FROM Portal_Contact__c WHERE Id = : contacts.get(0).Id AND  Is_Chatter__c = true LIMIT 1];
	        System.assertNotEquals(updatedContact.Community_Email_Frequency__c, null);
		    	User updatedUser = [SELECT Id, Community_Email_Frequency__c FROM User WHERE Id =: communityUser.Id];
	        System.assertNotEquals(updatedUser.Community_Email_Frequency__c, null);

	        delete newAcctPortal;

	        List<CollaborationGroup> newCGroup = [SELECT MemberCount, Id FROM CollaborationGroup WHERE Id =: newAcctPortal.Chatter_Group_Id__c];

	        System.assertEquals(newCGroup.size(), 0);

	        Test.stopTest();
		}

	}

	@isTest static void test_Portal_ContactHelper(){
		RecordType objRecordType = [Select Id from RecordType where Name='Vendor Division' AND SobjectType ='Account' limit 1];
        
		Profile internalCommunityProfile = [SELECT Id FROM Profile WHERE Name='Sales - RVP - Vendor' LIMIT 1];
        Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Partner Community User' LIMIT 1];
		UserRole internalCommunityRole = [SELECT Id FROM UserRole WHERE Name='Sales- Vendor' LIMIT 1];

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
			Vendor_Community_Name__c communityName = new Vendor_Community_Name__c();
			communityName.Name = 'Vendor Community';
			communityName.Community_Name__c = 'FAEF Vendor Community';
			insert communityName;

			Account objAccount;
			List<User> internalCommunityUsers;

			internalCommunityUsers = new List<User>();
	        internalCommunityUsers.add(new User(Email='standarduser1@testorg.com', LastName='Testing1', UserName='jaredTest1@jaredTestOrg.com',
	                                 Alias = 'testu', ProfileId = internalCommunityProfile.Id, EmailEncodingKey='UTF-8', UserRoleId = internalCommunityRole.Id,
	                                 LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles'));           
	        internalCommunityUsers.add(new User(Email='standarduser2@testorg.com', LastName='Testing2', UserName='jaredTest2@jaredTestOrg.com',
	                                 Alias = 'testu', ProfileId = internalCommunityProfile.Id, EmailEncodingKey='UTF-8', UserRoleId = null,
	                                 LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles'));
		    internalCommunityUsers.add(new User(Email='standarduser3@testorg.com', LastName='Testing3', UserName='jaredTest3@jaredTestOrg.com',
	                                 Alias = 'testu', ProfileId = internalCommunityProfile.Id, EmailEncodingKey='UTF-8', UserRoleId = null,
	                                 LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles'));
	        internalCommunityUsers.add(new User(Email='standarduser4@testorg.com', LastName='Testing4', UserName='jaredTest4@jaredTestOrg.com',
	                                 Alias = 'testu', ProfileId = internalCommunityProfile.Id, EmailEncodingKey='UTF-8', UserRoleId = null,
	                                 LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles'));              
	                             
	        insert internalCommunityUsers;

        	objAccount = new Account(Name='TestJared',RecordTypeId = objRecordtype.Id, OwnerId = internalCommunityUsers.get(0).Id);
        	insert objAccount;

	        Contact objContact = new Contact();
	        objContact.LastName = 'TestContact';
	        objContact.AccountId = objAccount.Id;
	        insert objContact;
	                

	        User communityUser = new User(Email='standarduser@testorg.com', LastName='Testing',
                                 UserName='jaredTest@jaredTestOrg.com' , ContactID = objContact.Id, UserRoleId = null,
                                 Alias = 'testu', ProfileId = objCommunityUserProfile.Id, EmailEncodingKey='UTF-8',
                                 LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles');              
            insert communityUser;
	    
	        Portal_Branding__c objBranding = new Portal_Branding__c(
	            Name = 'TestBranding', 
	            Unique_Id__c = 'test', 
	            Font__c = 'Arial', 
	            Schedule_Listview__c = 'FAEF Vendor Schedule Listview', 
	            Opportunity_Listview__c = 'FAEF Vendor Opportunity Listview');
	        insert objBranding;

	        List<Portal_Contact__c> contacts = new List<Portal_Contact__c>();
			contacts.add(new Portal_Contact__c(Portal_Branding__c = objBranding.Id, Active__c = true, User__c = internalCommunityUsers.get(1).Id, Order__c = 1, Is_Chatter__c = true));
	        contacts.add(new Portal_Contact__c(Portal_Branding__c = objBranding.Id, Active__c = true, User__c = internalCommunityUsers.get(2).Id, Order__c = 2, Is_Chatter__c = true));
	        contacts.add(new Portal_Contact__c(Portal_Branding__c = objBranding.Id, Active__c = true, User__c = internalCommunityUsers.get(3).Id, Order__c = 3, Is_Chatter__c = false));
	        insert contacts;
        
	        Account_Portal__c objAcctPortal = new Account_Portal__c(Portal__c = objBranding.Id, Account_Portal__c = objAccount.Id);
	        Test.startTest();
	        System.debug(LoggingLevel.ERROR, 'test 2: inserting account portal');
	    	insert objAcctPortal;

	        User communityUser2;
	        Contact objContact2;

	        objContact2 = new Contact();
	        objContact2.LastName = 'TestContact2';
	        objContact2.AccountId = objAccount.Id;
	        insert objContact2;
	               
	        communityUser2 = new User(Email='standarduser5@testorg.com', LastName='Testing5', UserRoleId = null,
	                                 UserName='jaredTest5@jaredTestOrg.com' , ContactID = objContact2.Id,
	                                 Alias = 'testu', ProfileId = objCommunityUserProfile.Id, EmailEncodingKey='UTF-8',
	                                 LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles');  
	        System.debug(LoggingLevel.ERROR, 'test 2: inserting new user');
		    insert communityUser2;

	        System.debug(LoggingLevel.ERROR, 'test 2: updating new user');
			communityUser2.Community_Email_Frequency__c = 'Daily';
	        update communityUser2;


	        delete contacts.get(1);
	        Portal_Contact__c newContact = new Portal_Contact__c(Portal_Branding__c = objBranding.Id, Active__c = true, User__c = internalCommunityUsers.get(2).Id, Order__c = 2, Is_Chatter__c = true);
	        System.debug(LoggingLevel.ERROR, 'test 2: inserting portal contact');
	        insert newContact;
	        newContact.Active__c = false;
	        System.debug(LoggingLevel.ERROR, 'test 2: updating portal contact');
	        update newContact;
	        update objAcctPortal;

			
			Account_Portal__c newAcctPortal = [SELECT Id, Chatter_Group_Id__c FROM Account_Portal__c WHERE Id =: objAcctPortal.Id];
	        CollaborationGroup cGroup = [SELECT MemberCount, Id FROM CollaborationGroup WHERE Id =: newAcctPortal.Chatter_Group_Id__c];
	        List<CollaborationGroupMember> cGroupMembers = [SELECT MemberId, Id FROM CollaborationGroupMember WHERE CollaborationGroupId =: cGroup.Id];

	        System.assertEquals(cGroupMembers.size(), 5);
	        CollaborationGroupMember cGroupMember = [SELECT NotificationFrequency FROM CollaborationGroupMember WHERE CollaborationGroupId =: cGroup.Id AND MemberId =: communityUser2.Id];
	        System.assertEquals(cGroupMember.NotificationFrequency, 'P');
        Test.stopTest();
		}
	}
}