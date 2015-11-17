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
private class SL_Test_MemberLandingPage 
{

    static testMethod void Sl_MemberLandingPage() 
    {    	
    	
    	RecordType objRecordtype = [Select Id from RecordType where SobjectType =:'Account' AND Name='Member' limit 1];
    	
    	Account objAccount = new Account(Name='TestSandeep', RecordTypeId = objRecordtype.Id, OwnerId = [Select Id from User where UserRoleId != null limit 1].Id);
	    insert objAccount;
    	
    	Contact objContact = new Contact();
    	objContact.LastName = 'TestCOntact';
    	objContact.AccountId = objAccount.Id;
    	insert objContact;
    	
    	
    	Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Pure Customer Community Login User'];
    	Profile objStandardUserProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    	
    	User objStandardUser = new User(Alias = 'HPD7', Email='standarduser7@testorg.com', 
                                        EmailEncodingKey='UTF-8', LastName='Testing7', LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', ProfileId = objStandardUserProfile.Id, 
                                        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser7@testorg.com');
       // insert objStandardUser;
    	
    	User objHpdProviderUser = new User(Alias = 'HPD8', Email='standarduser8@testorg.com', 
                                             EmailEncodingKey='UTF-8', LastName='Testing8', LanguageLocaleKey='en_US', 
                                             LocaleSidKey='en_US', ProfileId = objCommunityUserProfile.Id, 
                                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser8@testorg.com' , ContactID = objContact.Id);              
                             
        insert objHpdProviderUser;
    	
    	RecordType objRecordtypePolicy = [Select Id from RecordType where SobjectType =:'Policy__c' AND Name='Auto' limit 1];
	    	
	    	
	    	
    	List<Contact_Info__c> lstContactInfo = new List<Contact_Info__c>{new Contact_Info__c(Account__c = objAccount.Id,Is_Primary__c = true,Type__c = 'Mailing',Street__c='Broadway',Street_2__c='Broadway1',City__c= 'New York',State__c='NY',Zip__c='00993'),
    																	 new Contact_Info__c(Account__c = objAccount.Id,Is_Primary__c = true,Type__c = 'Billing',Street__c='Broadway',Street_2__c='Broadway1',City__c= 'New York',State__c='NY',Zip__c='00993'),
    																	 new Contact_Info__c(Account__c = objAccount.Id,Is_Primary__c = true,Type__c = 'Email',Street__c='Broadway',Street_2__c='Broadway1',City__c= 'New York',State__c='NY',Zip__c='00993')
    																	};
    	insert lstContactInfo;
		
		SL_PolicyStatusValues__c objSPS = new SL_PolicyStatusValues__c();
    	objSPS.Name = 'In-Force';
    	insert objSPS;
		
		List<Policy__c> lstPolicy = new List<Policy__c>{new Policy__c(Member__c = objAccount.Id,Policy_Status__c='In-Force',User_Description__c = 'Test User Description',Integration_Description__c='Test Integration Description',IsIndividuallyBilled__c=true, Policy_Number__c='1222'),
														new Policy__c(Member__c = objAccount.Id,Policy_Status__c='In-Force',User_Description__c = 'Test User Description',Integration_Description__c='Test Integration Description',IsIndividuallyBilled__c = true, Policy_Number__c='1223'),
														new Policy__c(Member__c = objAccount.Id,Policy_Status__c='In-Force',User_Description__c = 'Test User Description',Integration_Description__c='Test Integration Description',IsIndividuallyBilled__c=true, Policy_Number__c='1224'),
														new Policy__c(Member__c = objAccount.Id,Policy_Status__c='In-Force',User_Description__c = 'Test User Description',Integration_Description__c='Test Integration Description',IsIndividuallyBilled__c=true, Policy_Number__c='1225'),
														new Policy__c(Member__c = objAccount.Id,Policy_Status__c='In-Force',User_Description__c = 'Test User Description',Integration_Description__c='Test Integration Description',IsIndividuallyBilled__c=true, Policy_Number__c='1226')
													  };
														
		insert lstPolicy; 							
		
		List<Claim__c> lstClaim = new List<Claim__c>{new Claim__c(Claim_Status__c = 'In Progress', Member__c = objAccount.Id),
													 new Claim__c(Claim_Status__c = 'In Progress', Member__c = objAccount.Id),
													 new Claim__c(Claim_Status__c = 'In Progress', Member__c = objAccount.Id)
													};
		insert lstClaim;
    		
		System.runAs(objHpdProviderUser) 
        {
	    	SL_MemberLandingPageController objMLPController = new SL_MemberLandingPageController();
	    	objMLPController.pageAction();
	    	
	    	ApexPages.CurrentPage().getParameters().put('policyDescription', 'Test new');
	    	ApexPages.CurrentPage().getParameters().put('policyId', lstPolicy[0].Id);
	    	SL_MemberLandingPageController.updatePolicyDescription(lstPolicy[0].Id, 'Test Policy Description');	
	    	SL_MemberLandingPageController.updatePolicyDescription(lstPolicy[1].Id, '');	    	 	
       }
       
      // System.runAS(objStandardUser)
       {
       		ApexPages.currentPage().getParameters().put('cid',objContact.Id);
       		SL_MemberLandingPageController objMLPController = new SL_MemberLandingPageController();
       }
    }
}