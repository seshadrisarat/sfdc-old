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
 
@isTest(seeAllData = true) 
private class SL_Test_ClaimDetailsController 
{
    static testMethod void myUnitTest() 
    {
        Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Pure Customer Community Login User'];
        
        RecordType objRecordtype = [Select Id from RecordType where SobjectType =:'Account' AND Name='Member' limit 1];
        
        List<Account> lstAccount = new List<Account>{new Account(Primary_Email__c ='s@s.com',Name = 'Test Account', Phone='121212',RecordTypeId = objRecordtype.Id, OwnerId = [Select Id from User where UserRoleId != null limit 1].Id),
        											 new Account(Primary_Email__c ='s@ss.com',Name = 'Test Account 1', Phone='212122',RecordTypeId = objRecordtype.Id, OwnerId = [Select Id from User where UserRoleId != null limit 1].Id)
        											};
        insert lstAccount;
        
        List<Contact> lstContact = new List<Contact>{new Contact(LastName = 'Test Contact', AccountId = lstAccount[0].Id),
        											 new Contact(LastName = 'Test Contact 1', AccountId = lstAccount[1].Id)
        											};
        insert lstContact;
        
         User objHpdProviderUser = new User(Alias = 'HPD10', Email='standarduser10@testorg.com', 
                                             EmailEncodingKey='UTF-8', LastName='Testing10', LanguageLocaleKey='en_US', 
                                             LocaleSidKey='en_US', ProfileId = objCommunityUserProfile.Id, 
                                             TimeZoneSidKey='America/Los_Angeles', IsActive=true,UserName='standarduser10@testorg.com' , ContactID = lstContact[0].Id);              
                
                             
        insert objHpdProviderUser;
        
        List<Contact_Info__c> lstContactInfo = new List<Contact_Info__c>{new Contact_Info__c(Phone__c = '304042',Email__c = 'test@silverlinecrm.com',Type__c = 'Email', Account__c = lstAccount[0].Id),
        																 new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm.com',Type__c = 'Phone', Account__c = lstAccount[0].Id)
        																};
        insert lstContactInfo;
        
        List<Claim__c> lstClaim = new List<Claim__c>{new Claim__c(CanShowDetails__c=false,Member__c = lstAccount[0].Id, Claim_Number__c = '1234',Claim_Status__c = 'in progress',Adjustor__c = objHpdProviderUser.Id,Member_Advocate__c = objHpdProviderUser.Id),
        											 new Claim__c(CanShowDetails__c=true,Member__c = lstAccount[0].Id, Claim_Number__c = '12345678',Claim_Status__c = 'in progress',Claim_Mem_Advocate_Email__c = 'test@test.com',Claim_Adjustor_Email__c='test@test.com'),
        											 new Claim__c(CanShowDetails__c=true,Member__c = lstAccount[0].Id, Claim_Number__c = '12345',Claim_Status__c = 'in progress',Member_Advocate__c = objHpdProviderUser.Id,Adjustor__c = objHpdProviderUser.Id)        	
        											};
        insert lstClaim;
        
        List<Vendors_Involved__c> lstVendorsInvolved = new List<Vendors_Involved__c>{new Vendors_Involved__c(Claim__c = lstClaim[0].Id, Role__c = 'Contractor', Company__c = 'Test Company', DoNotShow__c = false, Phone__c = '1234', Email__c = 'test@silverlinecrm.com'),
        																			 new Vendors_Involved__c(Claim__c = lstClaim[0].Id, Role__c = 'Plumber', Company__c = 'Test Company1', DoNotShow__c = false, Phone__c = '12345', Email__c = 'test1@silverlinecrm.com')
        																			};
        insert lstVendorsInvolved;
        
        List<Claim_Activity__c> lstClaimActivity = new List<Claim_Activity__c>{new Claim_Activity__c(Type__c = 'Test Activity', Short_Description__c = 'Test Description', Full_Description__c = 'Test Full Description', Claim__c = lstClaim[0].Id),
        																	   new Claim_Activity__c(Type__c = 'Test Activity', Short_Description__c = 'Test Description', Full_Description__c = 'Test Full Description', Claim__c = lstClaim[0].Id)
        																	   };
        insert lstClaimActivity;
        
        List<Claim_Payment__c> lstClaimPayment = new List<Claim_Payment__c>{new Claim_Payment__c(Claim__c = lstClaim[0].Id, Paid_To__c = 'Test Paid', DoNotShow__c = false),
        																	new Claim_Payment__c(Claim__c = lstClaim[0].Id, Paid_To__c = 'Test Paid', DoNotShow__c = false)
        																	};
        insert lstClaimPayment;
        
        
        Portal_Image__c objPI = new Portal_Image__c(Broker__c = lstAccount[0].Id, Use_Photo_Field__c = true,User__c = objHpdProviderUser.id,Image__c='sass');
    	insert objPI;
    	
        Portal_Image__c objPI1 = new Portal_Image__c(Broker__c = lstAccount[0].Id, Use_Photo_Field__c = true,User__c = objHpdProviderUser.id,Image__c=null);
    	insert objPI1;
    	
    	Portal_Image__c objPI2 = new Portal_Image__c(Broker__c = lstAccount[0].Id, Use_Photo_Field__c = false,User__c = objHpdProviderUser.id,Image__c='sass');
    	insert objPI2;
    	
        Portal_Image__c objPI3 = new Portal_Image__c(Broker__c = lstAccount[0].Id, Use_Photo_Field__c = false,User__c = objHpdProviderUser.id,Image__c=null);
    	insert objPI3;
    	
    	
        System.runAs(objHpdProviderUser)
        {
        	apexpages.currentPage().getParameters().put('url','1234');
        	
        	apexpages.currentPage().getParameters().put('isSuccess','true');
        	SL_ClaimDetailsController objSL_ClaimDetailsController = new SL_ClaimDetailsController();
        	
        	apexpages.currentPage().getParameters().put('url',lstClaim[0].Claim_Number__c);
        	SL_ClaimDetailsController objSL_ClaimDetailsController1 = new SL_ClaimDetailsController();
        	objSL_ClaimDetailsController.isFileSelected = true;
        	
        	objSL_ClaimDetailsController.pageAction();
        	objSL_ClaimDetailsController.strMemAdvOrAdjUser = 'cliamAdjuster';
        	objSL_ClaimDetailsController.submitPreference();
        	objSL_ClaimDetailsController.selectedClaimDetails();
        	objSL_ClaimDetailsController.strMemAdvOrAdjUser = 'cliamMemAdvicer';
        	objSL_ClaimDetailsController.submitPreference();
        	
        	// When there is no adjuster or Member advocate lookup
        	apexpages.currentPage().getParameters().put('url',lstClaim[1].Claim_Number__c);
        	SL_ClaimDetailsController objSL_ClaimDetailsController2 = new SL_ClaimDetailsController();
        	objSL_ClaimDetailsController2.pageAction();
        	objSL_ClaimDetailsController2.strChatterMessage = 'test Question';
        	objSL_ClaimDetailsController2.strMemAdvOrAdjUser = 'cliamAdjuster';
        	objSL_ClaimDetailsController2.submitPreference();
        	
        	objSL_ClaimDetailsController2.strMemAdvOrAdjUser = 'cliamMemAdvicer';
        	objSL_ClaimDetailsController2.submitPreference();
        	
        	
        	apexpages.currentPage().getParameters().put('url','');
        	
        	SL_ClaimDetailsController objSL_ClaimDetailsController3 = new SL_ClaimDetailsController();
        	objSL_ClaimDetailsController3.pageAction();
        	
        	apexpages.currentPage().getParameters().put('url','7892');
        	objSL_ClaimDetailsController3.pageAction();
        	
        }
    }
}