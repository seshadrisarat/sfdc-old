@isTest
public class SL_TestAgentRegister {

	/*

	Test cases: 
	1) Successfully register an agent (Broker Id on Account, Dragon ID on Agency_Contact, and Email on Contact all match)
	2) Failure, Broker ID doesn't match
	3) Failure, Dragon ID doesn't match
	4) Failure, Email doesn't match
	5) Failure, User already exists with username matching email
	6) Failure, User already exists with ContactId matching contact with email address but username doesn't match email
	7) Failure, Misc. other user error (community nickname matches)
	*/

	public static testMethod void SL_TestAgentRegister() {
		RecordType objRecordtype = [Select Id from RecordType where SobjectType =:'Account' AND Name='Broker' limit 1];
        
        Account objAccount1 = new Account(Name='TestAcct1', RecordTypeId = objRecordtype.Id, 
                                          Broker_Id__c = '12345', Broker_Status__c='Active', Date_of_Appointment__c= Date.today());
        insert objAccount1;
        
        //Account objAccount2 = new Account(Name='TestAcct2', RecordTypeId = objRecordtype.Id, Broker_Id__c = '54321');
        //insert objAccount2;
        
        //Account objAccount3 = new Account(Name='TestAcct3', RecordTypeId = objRecordtype.Id,
        //                                  Member_Key_EDW__c = null,BillingPostalCode = '50506');
        //insert objAccount3;
        
        Contact objContact = new Contact();
        objContact.LastName = 'TestContact1Last';
        objContact.FirstName = 'TestContact1First';
        objContact.AccountId = objAccount1.Id;
        objContact.Email = 'testemail@test.com';
        insert objContact;
        
        Contact contactWithUser = new Contact();
        contactWithUser.LastName = 'TestContact2Last';
        contactWithUser.FirstName = 'TestContact2First';
        contactWithUser.AccountId = objAccount1.Id;
        contactWithUser.Email = 'testemail2@test.com';
        insert contactWithUser;

        Contact contactWithUser2 = new Contact();
        contactWithUser2.LastName = 'TestContact3Last';
        contactWithUser2.FirstName = 'TestContact3First';
        contactWithUser2.AccountId = objAccount1.Id;
        contactWithUser2.Email = 'testemail3@test.com';
        insert contactWithUser2;

        Contact throwawayContact = new Contact();
        throwawayContact.LastName = 'TestContact4Last';
        throwawayContact.FirstName = 'TestContact4First';
        throwawayContact.AccountId = objAccount1.Id;
        throwawayContact.Email = 'testemail4@test.com';
        insert throwawayContact;

        Agency_Contact__c agencyContact1 = new Agency_Contact__c(Contact__c = objContact.Id, Agency__c = objAccount1.Id, 
        														 DragonID__c = '12345', User_Status__c = 'Active');
        insert agencyContact1;

        Agency_Contact__c agencyContact2 = new Agency_Contact__c(Contact__c = contactWithUser.Id, Agency__c = objAccount1.Id, 
        														 DragonID__c = '54321', User_Status__c = 'Active');
        insert agencyContact2;

        Agency_Contact__c agencyContact3 = new Agency_Contact__c(Contact__c = contactWithUser2.Id, Agency__c = objAccount1.Id, 
        														 DragonID__c = '98765', User_Status__c = 'Active');
        insert agencyContact3;

        Agency_Contact__c agencyContact4 = new Agency_Contact__c(Contact__c = throwawayContact.Id, Agency__c = objAccount1.Id, 
        														 DragonID__c = '102030', User_Status__c = 'Active');
        insert agencyContact4;

        Agency_Contact__c agencyContact5= new Agency_Contact__c(Contact__c = objContact.Id, Agency__c = objAccount1.Id, 
        														 DragonID__c = '00000', User_Status__c = 'Active');
        insert agencyContact5;

        
        Profile agentUserProfile = [SELECT Id FROM Profile WHERE Name = 'Pure Customer Community Login User'];
        
        User agentUser1 = new User(Alias = 'Test2', Email='testemail2@test.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = agentUserProfile.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testemail222.test.com@brokerview.pureinsurance.com', 
                                 ContactID = contactWithUser.Id);              
        insert agentUser1;

        User agentUser2 = new User(Alias = 'Test3', Email='anotheremail@test.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = agentUserProfile.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='anotheremail.test.com@brokerview.pureinsurance.com' , 
                                 ContactID = contactWithUser2.Id);              
        insert agentUser2;
        
        User agentUser3 = new User(Alias = 'Test4', Email='blahblah@email.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing4', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = agentUserProfile.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='blahblah.email.com@brokerview.pureinsurance.com' , 
                                 ContactID = throwawayContact.Id, CommunityNickname = 'TestC00000');              
        insert agentUser3;

        // Case 2

        SL_PortalRegisterAgentController agentRegCtrl2 = new SL_PortalRegisterAgentController();
        agentRegCtrl2.brokerId = '99999';         
        agentRegCtrl2.dragonUserId = '12345';
        agentRegCtrl2.email = 'testemail@test.com';
        
        System.assertEquals(agentRegCtrl2.register(), null);

        // Case 3

        SL_PortalRegisterAgentController agentRegCtrl3 = new SL_PortalRegisterAgentController();
        agentRegCtrl3.brokerId = '12345';         
        agentRegCtrl3.dragonUserId = '99999';
        agentRegCtrl3.email = 'testemail@test.com';
        
        System.assertEquals(agentRegCtrl3.register(), null);

        // Case 4

        SL_PortalRegisterAgentController agentRegCtrl4 = new SL_PortalRegisterAgentController();
        agentRegCtrl4.brokerId = '12345';         
        agentRegCtrl4.dragonUserId = '12345';
        agentRegCtrl4.email = 'nomatch@email.com';
        
        System.assertEquals(agentRegCtrl4.register(), null);

        // Case 5

        SL_PortalRegisterAgentController agentRegCtrl5 = new SL_PortalRegisterAgentController();
        agentRegCtrl5.brokerId = '12345';         
        agentRegCtrl5.dragonUserId = '54321';
        agentRegCtrl5.email = 'testemail2@test.com';
        
        System.assertEquals(agentRegCtrl5.register(), null);

        // Case 6

        SL_PortalRegisterAgentController agentRegCtrl6 = new SL_PortalRegisterAgentController();
        agentRegCtrl6.brokerId = '12345';         
        agentRegCtrl6.dragonUserId = '98765';
        agentRegCtrl6.email = 'testemail3@test.com';
        
        System.assertEquals(agentRegCtrl6.register(), null);

        // Case 7

        SL_PortalRegisterAgentController agentRegCtrl7 = new SL_PortalRegisterAgentController();
        agentRegCtrl7.brokerId = '12345';         
        agentRegCtrl7.dragonUserId = '00000';
        agentRegCtrl7.email = 'testemail@test.com';
        
        System.assertEquals(agentRegCtrl7.register(), null);

        //  Case 1 - Doing this last so the inserted user doesn't conflict with other tests

        SL_PortalRegisterAgentController agentRegCtrl1 = new SL_PortalRegisterAgentController();
        agentRegCtrl1.brokerId = '12345';         
        agentRegCtrl1.dragonUserId = '12345';
        agentRegCtrl1.email = 'testemail@test.com';
        
        System.assertEquals(agentRegCtrl1.register(), null);
	}
}