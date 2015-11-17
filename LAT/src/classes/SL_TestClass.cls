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
private class SL_TestClass {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        String strAccountRecordTypeId = [Select SobjectType, Id From RecordType where SobjectType ='Account' LIMIT 1].Id;
        Account objAccount = new Account(Name = 'TestAcc-001');
        
        insert objAccount;
        
        Contact objContact = new Contact(LastName='TestC-001', AccountId = objAccount.Id);
		insert objContact;
		
		Case objCase = new Case(AccountId = objAccount.Id, ContactId = objContact.Id, Type = 'Legal', Product_Name__c = '254 Platinum', Manuafacturing_Origin__c = 'Vendor', Application_Type__c = 'Other', Building_Type__c = 'Residential', Finish_Type__c = 'Basalt', Product_Classification__c = 'Grout', Field_Rep__c = 'Archer, Jimmy', Reason = 'Leaking', Substrate__c = 'Brick', Location__c = 'Exterior', Region__c = 'CA', Claim_Disposition__c = 'Unconfirmed');
		insert objCase; 
		
		List<CaseTeamMember> lstCTM  = new List<CaseTeamMember>([select Id, ParentId from CaseTeamMember where ParentId =: objCase.Id]);
		System.AssertEquals(lstCTM.size(),1);
		
    }
}