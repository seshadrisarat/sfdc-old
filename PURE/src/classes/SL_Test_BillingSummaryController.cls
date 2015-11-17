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
private class SL_Test_BillingSummaryController 
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
        
        User objHpdProviderUser = new User(Alias = 'HPD11', Email='standarduser11@testorg.com', 
                                             EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
                                             LocaleSidKey='en_US', ProfileId = objCommunityUserProfile.Id, 
                                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser11@testorg.com' , ContactID = lstContact[0].Id);              
                             
        insert objHpdProviderUser;
        
        List<Contact_Info__c> lstContactInfo = new List<Contact_Info__c>{new Contact_Info__c(Phone__c = '304042',Email__c = 'test@silverlinecrm.com',Type__c = 'Email', Account__c = lstAccount[0].Id, Is_Primary__c = true),
        																 new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm.com',Type__c = 'Phone', Account__c = lstAccount[0].Id, Is_Primary__c = true),
        																 new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm.com',Type__c = 'Billing', Account__c = lstAccount[0].Id, Is_Primary__c = true)
        																};
        insert lstContactInfo;
        
        List<Policy__c> lstPolicy = new List<Policy__c>{new Policy__c(Member__c = lstAccount[0].Id,Policy_Status__c='In-Force',User_Description__c = 'Test User Description',Integration_Description__c='Test Integration Description',IsIndividuallyBilled__c=true, Policy_Number__c='1222'),
														new Policy__c(Member__c = lstAccount[0].Id,Policy_Status__c='In-Force',User_Description__c = 'Test User Description',Integration_Description__c='Test Integration Description',IsIndividuallyBilled__c =true, Policy_Number__c='1223'),
														new Policy__c(Member__c = lstAccount[0].Id,Policy_Status__c='In-Force',User_Description__c = 'Test User Description',Integration_Description__c='Test Integration Description',IsIndividuallyBilled__c=false, Policy_Number__c='1224'),
														new Policy__c(Member__c = lstAccount[0].Id,Policy_Status__c='In-Force',User_Description__c = 'Test User Description',Integration_Description__c='Test Integration Description',IsIndividuallyBilled__c=true, Policy_Number__c='1225'),
														new Policy__c(Member__c = lstAccount[0].Id,Policy_Status__c='In-Force',User_Description__c = 'Test User Description',Integration_Description__c='Test Integration Description',IsIndividuallyBilled__c=true, Policy_Number__c='1226')
												  		};
													
		insert lstPolicy;
		
		List<Invoices__c> lstInvoice = new List<Invoices__c>{new Invoices__c(Name = 'Test Invoice', Member__c = lstAccount[0].Id,Is_Consolidated__c = true,Bill_Date__c = Date.Today()),
															 new Invoices__c(Name = 'Test Invoice-1',Member__c = lstAccount[0].Id,Is_Consolidated__c = true,Bill_Date__c = Date.Today()),
															 new Invoices__c(Name = 'Test Invoice-2',Member__c = lstAccount[0].Id,Is_Consolidated__c = false,Policy__c = lstPolicy[0].Id,Bill_Date__c = Date.Today()),
															 new Invoices__c(Name = 'Test Invoice-3',Member__c = lstAccount[0].Id,Is_Consolidated__c = false,Policy__c = lstPolicy[1].Id,Bill_Date__c = Date.Today())
															};
		insert lstInvoice;
		
		List<Future_Payment__c> lstFuturePayment = new List<Future_Payment__c>{new Future_Payment__c(Policy__c = lstPolicy[0].Id, Member__c = lstAccount[0].Id, Minimum_Due__c = 1200, EDW_ID__c = '00393545',Estimated_Date__c =  Date.Today().addDays(2) ),
																			   new Future_Payment__c(Policy__c = lstPolicy[0].Id, Member__c = lstAccount[0].Id, Minimum_Due__c = 1200, EDW_ID__c = '94949445',Estimated_Date__c =  Date.Today().addDays(2))
																			  };
		insert lstFuturePayment;
		
		List<Payment_Credits__c> lstPaymentCredits = new List<Payment_Credits__c>{new Payment_Credits__c(Member__c = lstAccount[0].Id, Policy__c = lstPolicy[0].Id,Hide_Payment_Flag__c = false,Transaction_Date__c = Date.today()),
																				  new Payment_Credits__c(Member__c = lstAccount[0].Id, Policy__c = lstPolicy[0].Id,Hide_Payment_Flag__c = false,Transaction_Date__c = Date.today())
																				 };
		insert lstPaymentCredits;
		
		Agency_Contact__c objAgencyContact = new Agency_Contact__c(Agency__c =lstAccount[0].Id,Contact__c = lstContact[0].Id,User_Status__c = 'Active');
		insert objAgencyContact;
		
		SL_PolicyStatusValues__c objPolicyStatus = new SL_PolicyStatusValues__c(Name='In-Force');
		insert objPolicyStatus;
		
		System.runAs(objHpdProviderUser) 
        {    	
        	SL_BillingSummaryController objSL_BillingSummaryController = new SL_BillingSummaryController();
	    	objSL_BillingSummaryController.pageAction();  	
	    	
	    	Apexpages.currentPage().getParameters().put('mId',lstAccount[0].Id);
	    	
        	SL_BillingSummaryController objSL_BillingSummaryController1 = new SL_BillingSummaryController();
	    	objSL_BillingSummaryController1.pageAction();  
	    	
        	Apexpages.currentPage().getParameters().put('aid',lstAccount[0].Id);
        	
        	SL_BillingSummaryController objSL_BillingSummaryController2 = new SL_BillingSummaryController();
	    	objSL_BillingSummaryController2.pageAction();  
        }
    }
}