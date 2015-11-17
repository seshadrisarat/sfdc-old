@isTest
private class SL_Test_ForgotAgentUsernameController {

    static testMethod void myUnitTest() 
    {
        
        Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='PURE Broker View Partner Login User'];
        
        RecordType objMemberRecordtype = [Select Id from RecordType where SobjectType =:'Account' AND Name='Member'];
        RecordType objBrokerRecordtype = [Select Id from RecordType where SobjectType =:'Account' AND Name='Broker'];
        
        Account objAccount = new Account(Name = 'Test Account', RecordTypeId = objBrokerRecordtype.Id, Billing_Document_Delivery_Method__c = 'Electronic');
        insert objAccount;
        
        Account objAccount1 = new Account(Name = 'Test Account 1', RecordTypeId = objMemberRecordtype.Id, Billing_Document_Delivery_Method__c = 'Paper',Broker_ID__c = '12345',Broker__c = objAccount.Id,Status__c = 'Active');
        insert objAccount1;
        
        List<Contact> lstContact = new List<Contact>{new Contact(LastName = 'Test Contact', AccountId = objAccount.Id),
        											 new Contact(LastName = 'Test Contact 1', AccountId = objAccount.Id)
        											};
        insert lstContact;
        
        User objCommunityUser = new User(Alias = 'HPD4', Email='standarduser4@testorg.com', 
                                             EmailEncodingKey='UTF-8', LastName='Testing4', LanguageLocaleKey='en_US', 
                                             LocaleSidKey='en_US', ProfileId = objCommunityUserProfile.Id, 
                                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser4.testorg.com@brokerview.pureinsurance.com' , ContactID = lstContact[0].Id);              
                             
        insert objCommunityUser;
        
        Agency_Contact__c objAgencyContact = new Agency_Contact__c(Contact__c = lstContact[0].Id,Agency__c = objAccount1.Id,User_Status__c = 'Active',DragonID__c = 'Test Dragon');
        insert objAgencyContact;
        
        System.runAs(objCommunityUser)
        {
			SL_ForgotAgentUsernameController objForgorUName = new SL_ForgotAgentUsernameController();
        	objForgorUName.brokerId = '12345';
        	objForgorUName.dragonUsername = 'Test Dragon'; 
        	objForgorUName.forgotUser();
        	objForgorUName.redirectToLoginPage();    	
        }
    }
}