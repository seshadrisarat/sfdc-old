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
public with sharing class SL_Test_SuccessController 
{
    
   private static final Id CUSTOMER_ID = [SELECT Id FROM RecordType WHERE DeveloperName =: 'PersonAccount' LIMIT 1].Id;
    
	static testMethod void testSuccessController()
	{
		Account objAccount = new Account(LastName = 'Test Account - sndApp-1',RecordTypeId=CUSTOMER_ID,PersonEmail = 'test@test1.com');
	    insert objAccount;
	    
	    Opportunity objOpportunity = new Opportunity(Name='Test Opportunity',AccountId = objAccount.Id,
	                                                 CloseDate = Date.today(),StageName='Prospecting');
	    insert objOpportunity;    
	    
	    Contact_Role__c objContactRole = new Contact_Role__c(Person_Account__c = objAccount.Id,
	                                                        Opportunity__c = objOpportunity.Id,Role__c = 'Tenant',Email__c = 'test@test1.com', e_Renter__c = 'abc',
	                                                         Current_Address_Country__c = 'United States', SSN_C__c = '000000000');
	                                                         
	    insert objContactRole; // Inserting Contact Role record
	    
	    SL_ERenterCustomSetting__c objSLERenterCustomSetting = new SL_ERenterCustomSetting__c(Name = 'test1', endpoint__c = 'https://commercial.e-renter.com/soap_server.php?wsdl',
	                                                                                         password__c = 'Th0r3qu1t13s' , product_ID__c = '46', username__c = 'thorequities');
	    insert objSLERenterCustomSetting;
	    
	    System.currentPageReference().getParameters().put('cid',objContactRole.Id);
		System.currentPageReference().getParameters().put('ptId',null);
		SL_Success_Controller objSuccessController = new SL_Success_Controller();
		objSuccessController.validateFromERenter();
	}
}