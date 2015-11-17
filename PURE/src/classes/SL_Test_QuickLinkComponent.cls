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
private class SL_Test_QuickLinkComponent {

    static testMethod void SL_QuickLinksComponentController() {
    	
    	RecordType objRecordType = [Select Id from RecordType where Name='Member' AND SobjectType ='Account' limit 1];
    	
    	Account objAccount = new Account(Name='TestSandeep', RecordTypeId = objRecordtype.Id, OwnerId = [Select Id from User where UserRoleId != null limit 1].Id);
	    insert objAccount;
    	
    	Contact objContact = new Contact();
    	objContact.LastName = 'TestCOntact';
    	objContact.AccountId = objAccount.Id;
    	insert objContact;
    	
    	
    	Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Pure Customer Community Login User'];
    	
    	User objHpdProviderUser = new User(Alias = 'HPD3', Email='standarduser3@testorg.com', 
                                             EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
                                             LocaleSidKey='en_US', ProfileId = objCommunityUserProfile.Id, 
                                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser3@testorg.com' , ContactID = objContact.Id);              
                             
        insert objHpdProviderUser;
    	
    		RecordType objRecordtypePolicy = [Select Id from RecordType where SobjectType =:'Policy__c' AND Name='Auto' limit 1];
	    	
	    	Policy__c objPolicy = new Policy__c(Risk_State__c = 'TT', Member__c = objAccount.Id, Policy_Number__c = '12345', RecordTypeId = objRecordtypePolicy.Id, Effective_Date__c = date.today(),
	    										Policy_Status__c = 'In-Force',Expiration_Date__c = date.today()+1);
	    	
	    	RecordType objRecordtypePolicyHome = [Select Id from RecordType where SobjectType =:'Policy__c' AND Name='Homeowners' limit 1];
	    	
	    	Policy__c objPolicyHome = new Policy__c(Risk_State__c = 'SS', Member__c = objAccount.Id, Policy_Number__c = '123452', RecordTypeId = objRecordtypePolicy.Id, Effective_Date__c = date.today(),
	    										Policy_Status__c = 'In-Force',Expiration_Date__c = date.today()+1);
	    	
	    	insert objPolicyHome;
	    	
	    	insert objPolicy;
	    	
	    	Claim__c objClaim = new Claim__c(Policy__c = '12345', Member__c = objAccount.Id);
	    	
	    	insert objClaim;
    		PortalURLMap__c oPayMyBillLink = new PortalURLMap__c(Name='PayBill', URL__c='sasas');
    		insert oPayMyBillLink;
    		
    		
    		Transactions__c objTran = new Transactions__c(	Policy__c = objPolicy.Id, Type__c = 'NEW', 	Process_Date__c = date.today(), Description__c = 'ss');
    		insert objTran;
    		
    		Property__c objProperty = new Property__c(	Policy__c = objPolicyHome.Id, Street__c = 'sas', City__c = 'Ajmer');
    		insert objProperty;
    		
    		Vehicle__c objVehicle = new Vehicle__c(	VIN__c = '123456', Year__c = 2014, Policy__c = objPolicy.Id, 	Make__c='2221221212', Can_Download__c = true, 	Model__c = 'sasass');
    		insert objVehicle;
    		
    		System.runAs(objHpdProviderUser) 
           {
	    		SL_QuickLinksComponentController objSL_QuickLinksComponentController = new SL_QuickLinksComponentController();
           }
    	
    	
    	
        // TO DO: implement unit test
    }
}