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

private class SL_Test_ContactRoleTriggerHandler 
{
	private static final Id CUSTOMER_ID = [SELECT Id FROM RecordType WHERE DeveloperName =: 'PersonAccount' LIMIT 1].Id;
	static testMethod void testCRTrigger() 
    {
        Account objAccount = new Account(LastName = 'Test Account - eRenterBtch',RecordTypeId=CUSTOMER_ID,PersonEmail = 'test@test1.com');
        insert objAccount;
        
        Opportunity objOpportunity = new Opportunity(Name='Test Opportunity',AccountId = objAccount.Id,
                                                     CloseDate = Date.today(),StageName='Prospecting');
        insert objOpportunity;    
        
        Contact_Role__c objContactRole = new Contact_Role__c(Person_Account__c = objAccount.Id,
                                                            Opportunity__c = objOpportunity.Id,Role__c = 'Tenant',Email__c = 'test@test1.com');
                                                             
        insert objContactRole; // Inserting Contact Role record
        
        // Updating ContactRole record
        objContactRole.Email__c = 'test@silverline.com';
        update objContactRole;
        
    }
}