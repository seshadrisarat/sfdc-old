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
public with sharing class SL_Test_AccountTrigger 
{
	static testMethod void test_AccountTrigger()
    {
    	Id AccountRecordtypeId = [SELECT Id FROM Recordtype WHERE SobjectType='Account' AND IsPersonType=True].Id;
    	Account objAccount = new Account(LastName = 'Test Name', ShippingStreet = '123', ShippingCity = 'Newyork', ShippingState = 'New York',
    	                                 ShippingPostalCode = '233',ShippingCountry = 'United States',PersonEmail = 'test1233@test.com',
    	                                 RecordTypeId = AccountRecordtypeId);
    	insert objAccount;
    	
    	Opportunity objOpportunity = new Opportunity(Name = 'Test Opportunity-01', StageName = 'Qualified Porspect',CloseDate = Date.today(), AccountId  = objAccount.Id);
    	insert objOpportunity;
    	
    	objAccount.ShippingStreet = '';
		objAccount.ShippingCity = '';
		objAccount.ShippingState = '';
		objAccount.ShippingPostalCode = '';
		objAccount.ShippingCountry = '';
		objAccount.PersonEmail = '';
		
		test.startTest();
		update objAccount;
		test.stopTest();
		
		objOpportunity = [SELECT Account_Current_Address__c,Person_Account_Email__c FROM Opportunity WHERE Id =:objOpportunity.Id];
		
		///Check if opporunity fields are updated as per account
		system.assertEquals(objOpportunity.Account_Current_Address__c,null);
		system.assertEquals(objOpportunity.Person_Account_Email__c,null);
    }
}