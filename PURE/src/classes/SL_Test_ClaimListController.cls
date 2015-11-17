/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SL_Test_ClaimListController 
{
    static testMethod void myUnitTest() 
    {
        Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Customer Community Login User'];
        
        RecordType objRecordtype = [Select Id from RecordType where SobjectType =:'Account' AND Name='Member' limit 1];
        
        List<Account> lstAccount = new List<Account>{new Account(Name = 'Test Account', RecordTypeId = objRecordtype.Id, OwnerId = [Select Id from User where UserRoleId != null limit 1].Id),
        											 new Account(Name = 'Test Account 1', RecordTypeId = objRecordtype.Id, OwnerId = [Select Id from User where UserRoleId != null limit 1].Id)
        											};
        insert lstAccount;
        
        List<Contact> lstContact = new List<Contact>{new Contact(LastName = 'Test Contact', AccountId = lstAccount[0].Id),
        											 new Contact(LastName = 'Test Contact 1', AccountId = lstAccount[1].Id)
        											};
        insert lstContact;
        
        User objHpdProviderUser = new User(Alias = 'HPD9', Email='standarduser9@testorg.com', 
                                             EmailEncodingKey='UTF-8', LastName='Testing9', LanguageLocaleKey='en_US', 
                                             LocaleSidKey='en_US', ProfileId = objCommunityUserProfile.Id, 
                                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser9@testorg.com' , ContactID = lstContact[0].Id);              
                             
        insert objHpdProviderUser;
        
        List<Claim__c> lstClaim = new List<Claim__c>{new Claim__c(Member__c = lstAccount[0].Id, Claim_Number__c = '1234',Claim_Status__c = 'in progress',Adjustor__c = objHpdProviderUser.Id, Portal_Closed_Date__c = date.today()),
        											 new Claim__c(Member__c = lstAccount[0].Id, Claim_Number__c = '12345',Claim_Status__c = 'Closed',Adjustor__c = objHpdProviderUser.Id, Portal_Closed_Date__c = Date.newInstance(2014, 01, 09 )),
        											 new Claim__c(Member__c = lstAccount[0].Id, Claim_Number__c = '12345',Claim_Status__c = 'in subrogation',Member_Advocate__c = objHpdProviderUser.Id, Portal_Closed_Date__c = Date.newInstance(2014, 01 , 09))      	
        											};
        insert lstClaim;
        
        Agency_Contact__c objAgencyContact = new Agency_Contact__c(Agency__c =lstAccount[0].Id,Contact__c = lstContact[0].Id,User_Status__c = 'Active');
		insert objAgencyContact;
		
        System.runAs(objHpdProviderUser)
        {
        	Sl_ClaimsListController objSl_ClaimsListController = new Sl_ClaimsListController();
        	objSl_ClaimsListController.pageAction();
        	
        	apexpages.currentPage().getParameters().put('url','1234');
        	apexpages.currentPage().getParameters().put('mId',lstAccount[0].Id);
        	
        	Sl_ClaimsListController objSl_ClaimsListController1 = new Sl_ClaimsListController();
        	objSl_ClaimsListController1.pageAction();
        }
    }
}