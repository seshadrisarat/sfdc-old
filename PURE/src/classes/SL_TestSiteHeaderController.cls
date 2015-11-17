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
private class SL_TestSiteHeaderController {

    static testMethod void SL_SiteHeaderComponentController() {
    	RecordType objRecordType = [Select Id from RecordType where Name='Member' AND SobjectType ='Account' limit 1];
    	
    	Account objAccount = new Account(Name='TestSandeep',RecordTypeId = objRecordtype.Id, OwnerId = [Select Id from User where UserRoleId != null limit 1].Id);
	    insert objAccount;
    	
    	Contact objContact = new Contact();
    	objContact.LastName = 'TestCOntact';
    	objContact.AccountId = objAccount.Id;
    	insert objContact;
    	
    	
    	Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Pure Customer Community Login User'];
    	
    	User objHpdProviderUser = new User(Alias = 'HPD', Email='standarduser@testorg.com', 
                                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                             LocaleSidKey='en_US', ProfileId = objCommunityUserProfile.Id, 
                                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com' , ContactID = objContact.Id);              
                             
        insert objHpdProviderUser;
        System.runAs(objHpdProviderUser) 
        {
        	//Page.existingPageName = '/ProfileSettingPage';
        	Test.setCurrentPage(new PageReference('/ProfileSettingPage')); 
    		SL_SiteHeaderComponentController objSL_SiteHeaderComponentController = new SL_SiteHeaderComponentController();
    		
    		Test.setCurrentPage(new PageReference('/AllActivePolicies'));
    		SL_SiteHeaderComponentController objSL_SiteHeaderComponentController1 = new SL_SiteHeaderComponentController();
    		
    		Test.setCurrentPage(new PageReference('/PolicyDetailPage')); 
    		SL_SiteHeaderComponentController objSL_SiteHeaderComponentController2 = new SL_SiteHeaderComponentController();
    		
    		Test.setCurrentPage(new PageReference('/BillingSummary')); 
    		SL_SiteHeaderComponentController objSL_SiteHeaderComponentController3 = new SL_SiteHeaderComponentController();
    		
    		Test.setCurrentPage(new PageReference('/claimsList')); 
    		SL_SiteHeaderComponentController objSL_SiteHeaderComponentController4 = new SL_SiteHeaderComponentController();
    		
    		Test.setCurrentPage(new PageReference('/MemberLandingPage')); 
    		SL_SiteHeaderComponentController objSL_SiteHeaderComponentController5 = new SL_SiteHeaderComponentController();
    		
    		Test.setCurrentPage(new PageReference('/Discounts')); 
    		SL_SiteHeaderComponentController objSL_SiteHeaderComponentController6 = new SL_SiteHeaderComponentController();
        }
    	
        // TO DO: implement unit test
    }
}