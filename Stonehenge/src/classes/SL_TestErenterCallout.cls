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
private class SL_TestErenterCallout {

    static testMethod void testErenter() 
    {
        Account acc = new Account();
		acc.LastName = 'Test';
		acc.RecordTypeId = [Select Id From RecordType Where Name = 'Client/Tenant Account' And SobjectType='Account'].Id;
		acc.FirstName ='First';
		acc.DOB__c = date.today();
		acc.Tax_ID__c = '000000000';
		acc.Country__c = 'Austria';
		insert acc;
		
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.NAme = 'testOpp';
		opp.CloseDate = date.today();
		opp.StageName = 'Open';
		insert opp;
		
		Contact_Role__c cr = new Contact_Role__c();
		cr.Contact__c = acc.Id;
		cr.Opportunity__c = opp.Id;
		insert cr;
		
		eRenterCustomSetting__c eRenter1 = new eRenterCustomSetting__c();
		eRenter1.username__c = 'testuser';
		eRenter1.password__c = 'testpwd';
		eRenter1.product_ID__c = '46';
		eRenter1.endpoint__c = 'testEP';
		eRenter1.Name = 'test1';
		insert eRenter1;
		
		eRenterCustomSetting__c eRenter2 = new eRenterCustomSetting__c();
		eRenter2.username__c = 'testuser1';
		eRenter2.password__c = 'testpwd1';
		eRenter2.product_ID__c = '60';
		eRenter2.endpoint__c = 'testEP1';
		eRenter2.Name = 'test2';
		insert eRenter2;
		
		eRenterCustomSetting__c eRenter3 = new eRenterCustomSetting__c();
		eRenter3.username__c = 'testuser2';
		eRenter3.password__c = 'testpwd2';
		eRenter3.product_ID__c = '61';
		eRenter3.endpoint__c = 'testEP2';
		eRenter3.Name = 'test3';
		insert eRenter3;
		
		SL_ErenterCallout.sendErenterRequest(cr.id);
    }
}