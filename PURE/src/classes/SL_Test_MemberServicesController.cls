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
public class SL_Test_MemberServicesController 
{
	static testMethod void SL_TestMemServicesControl()
	{
		RecordType objRecordtype = [Select Id from RecordType where SobjectType =:'Account' AND Name='Member' limit 1];
    	
    	Account objAccount = new Account(Name='TestSandeep',Member_Key_EDW__c = '12345', RecordTypeId = objRecordtype.Id, OwnerId = [Select Id from User where UserRoleId != null limit 1].Id);
	    insert objAccount;
    	
    	Contact objContact = new Contact();
    	objContact.LastName = 'TestCOntact';
    	objContact.AccountId = objAccount.Id;
    	insert objContact;
    	
    	
    	Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Pure Customer Community Login User'];
    	
    	User objHpdProviderUser = new User(Alias = 'HPD12', Email='standarduser12@testorg.com', 
                                             EmailEncodingKey='UTF-8', LastName='Testing12', LanguageLocaleKey='en_US', 
                                             LocaleSidKey='en_US', ProfileId = objCommunityUserProfile.Id, 
                                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser12@testorg.com' , ContactID = objContact.Id);              
                             
        insert objHpdProviderUser;
        
    	System.runAs(objHpdProviderUser) 
        {
        	SL_MemberServicesController objMemServcontrol = new SL_MemberServicesController();
        }
	}

}