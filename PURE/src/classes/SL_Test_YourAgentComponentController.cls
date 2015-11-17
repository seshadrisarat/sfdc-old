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
private class SL_Test_YourAgentComponentController {

    static testMethod void  SL_YourAgentComponentController()
    {
    	RecordType objRecordtype = [Select Id from RecordType where SobjectType =:'Account' AND Name='Member' limit 1];
    	RecordType objRecordtype1 = [Select Id from RecordType where SobjectType =:'Account' AND Name='Broker' limit 1];
    	
    	Account objAccount1 = new Account(Name='TestSandeep1', RecordTypeId = objRecordtype1.Id, OwnerId = [Select Id from User where UserRoleId != null limit 1].Id);
	    insert objAccount1;
    	
    	Account objAccount = new Account(Name='TestSandeep', Broker__c=objAccount1.Id, RecordTypeId = objRecordtype.Id, OwnerId = [Select Id from User where UserRoleId != null limit 1].Id);
	    insert objAccount;
    	
    	Contact objContact = new Contact();
    	objContact.LastName = 'TestCOntact';
    	objContact.AccountId = objAccount.Id;
    	insert objContact;
    	
    	Portal_Image__c objPI = new Portal_Image__c(Broker__c = objAccount1.Id, Use_Photo_Field__c = true);
    	insert objPI;
    	
    	Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Customer Community Login User'];
    	
    	User objHpdProviderUser = new User(Alias = 'HPD', Email='standarduser@testorg.com', 
                                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                             LocaleSidKey='en_US', ProfileId = objCommunityUserProfile.Id, 
                                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com' , ContactID = objContact.Id);              
                             
        insert objHpdProviderUser;
    	
		RecordType objRecordtypePolicy = [Select Id from RecordType where SobjectType =:'Policy__c' AND Name='Auto' limit 1];
    	
    	Policy__c objPolicy = new Policy__c(Member__c = objAccount.Id, Policy_Number__c = '12345', RecordTypeId = objRecordtypePolicy.Id, Effective_Date__c = date.today(),
    										Policy_Status__c = 'Open',Expiration_Date__c = date.today()+1);
    	
    	RecordType objRecordtypePolicyHome = [Select Id from RecordType where SobjectType =:'Policy__c' AND Name='Homeowners' limit 1];
    	
    	Policy__c objPolicyHome = new Policy__c(Member__c = objAccount.Id, Policy_Number__c = '123452', RecordTypeId = objRecordtypePolicy.Id, Effective_Date__c = date.today(),
    										Policy_Status__c = 'Open',Expiration_Date__c = date.today()+1);
    	
    	insert objPolicyHome;
    	
    	insert objPolicy;
    	
    	PortalURLMap__c oFAQ1 = new PortalURLMap__c(Name='FAQ', URL__c= 'ggg');
    	PortalURLMap__c oFAQ2 = new PortalURLMap__c(Name='PrivacyPolicy', URL__c= 'ggg');
    	PortalURLMap__c oFAQ3 = new PortalURLMap__c(Name='ShareYourStory', URL__c= 'ggg');
    	PortalURLMap__c oFAQ4 = new PortalURLMap__c(Name='pureInsurance.com', URL__c= 'ggg');
    	
    	List<PortalURLMap__c> lstPUM = new List<PortalURLMap__c>();
    	lstPUM.add(oFAQ1);
    	lstPUM.add(oFAQ2);
    	lstPUM.add(oFAQ3);
    	lstPUM.add(oFAQ4);
    	
    	insert lstPUM;
    	
    	
    	List<Claim__c> lstClaim = new List<Claim__c>{new Claim__c(CanShowDetails__c=false,Member__c = objAccount.Id, Claim_Number__c = '1234',Claim_Status__c = 'in progress',Adjustor__c = objHpdProviderUser.Id,Member_Advocate__c = objHpdProviderUser.Id),
        											 new Claim__c(CanShowDetails__c=true,Member__c = objAccount.Id, Claim_Number__c = '12345678',Claim_Status__c = 'in progress',Claim_Mem_Advocate_Email__c = 'test@test.com',Claim_Adjustor_Email__c='test@test.com'),
        											 new Claim__c(CanShowDetails__c=true,Member__c = objAccount.Id, Claim_Number__c = '12345',Claim_Status__c = 'in progress',Member_Advocate__c = objHpdProviderUser.Id,Adjustor__c = objHpdProviderUser.Id)        	
        											};
        insert lstClaim;
        
        
    	
        Portal_Image__c objPI1 = new Portal_Image__c(Broker__c = objAccount1.Id, Use_Photo_Field__c = true,User__c = objHpdProviderUser.id,Image__c=null);
    	insert objPI1;
    	
    	Portal_Image__c objPI2 = new Portal_Image__c(Broker__c = objAccount1.Id, Use_Photo_Field__c = false,User__c = objHpdProviderUser.id,Image__c='sass');
    	insert objPI2;
    	
        Portal_Image__c objPI3 = new Portal_Image__c(Broker__c = objAccount1.Id, Use_Photo_Field__c = false,User__c = objHpdProviderUser.id,Image__c=null);
    	insert objPI3;
    	
    	Agency_Contact__c objAgencyContact = new Agency_Contact__c(Agency__c =objAccount.Id,Contact__c = objContact.Id,User_Status__c = 'Active');
		insert objAgencyContact;
        
    	System.runAs(objHpdProviderUser) 
        {
        	   SL_YourAgentComponentController objYourAgent = new SL_YourAgentComponentController();
        	   objYourAgent.sendEmailToMemberServices();
        	   objYourAgent.sendEmailToMemberAdvocate();
        	   objYourAgent.sendEmailToClaims();
        	   objYourAgent.pageAction();
        	   
        	   Apexpages.currentPage().getParameters().put('mId', objAccount.Id);
        	   Apexpages.currentPage().getParameters().put('claimNumber', '121212');
        	  	
        	   Apexpages.currentPage().getParameters().put('aId', objAccount.Id);
        	   Apexpages.currentPage().getParameters().put('cId', objContact.Id);
        	   Apexpages.currentPage().getParameters().put('pId', objPolicy.Id);
        	   Apexpages.currentPage().getParameters().put('url', '1234');
        	   
        	   SL_YourAgentComponentController objYourAgent2 = new SL_YourAgentComponentController();
        	   objYourAgent2.pageAction();
        	   
        	   Test.setCurrentPage(new PageReference('/ContactUsPage'));
        	   SL_YourAgentComponentController objYourAgent7 = new SL_YourAgentComponentController();
        }
    	
        // TO DO: implement unit test
    }
}