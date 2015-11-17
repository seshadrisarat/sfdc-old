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
private class SL_Test_AddressHandler {

    static testMethod void myUnitTest() 
    {
    	String Contact_Address_RECORDTYPE_ID = [Select Id From RecordType Where SobjectType='Address__c' AND DeveloperName = 'Contact_Address'].Id;
        // Start of preparing test data
		Account objAccount1 = new Account(Name = 'Test Account 1');
		insert objAccount1;
		
        Address__c objAddress = new Address__c( Address_Type__c = 'Entity',Address_1__c	= 'Addr1',City__c = 'BallsbridgeCafe',State__c = 'Florida',Zipcode__c = '14563',RecordTypeId = Contact_Address_RECORDTYPE_ID);
        insert objAddress;
        
        Address__c objAddress1 = new Address__c( Address_Type__c = 'Entity',Address_1__c='Terenes City',City__c = 'BallsbridgeCafe',State__c = 'Florida',Zipcode__c = '25379',RecordTypeId = Contact_Address_RECORDTYPE_ID);
        insert objAddress1;
        
        Contact objContact = new Contact(AccountID = objAccount1.Id,LastName = 'Test Contact-01');  
        insert objContact;
        
        Contact_Address__c objCA = new Contact_Address__c(Address__c = objAddress.Id,Contact__c = objContact.Id,Default_Contact_Address__c = true);
        insert objCA;
        
        Contact objContact1 = [Select MailingCity,MailingStreet from Contact where Id=:objContact.id];
        system.assert(objContact1.MailingCity == 'BallsbridgeCafe');
        system.assert(objContact1.MailingStreet == 'Addr1');
        
		// Firing trigger        
        test.startTest();
        	objAddress.City__c = 'Sanores';
        	update objAddress;
        test.stoptest();	
        
        // Querying updated contact
        Contact objContact2 = [Select MailingCity from Contact where Id=:objContact.id];
        
        // Verifying expected results.
        system.assertEquals(objContact2.MailingCity,'Sanores');
        
        delete objAddress;
        
        Contact objContact4 = [Select MailingCity from Contact where Id=:objContact2.id];
        // Verifying expected results.
        system.assertEquals(objContact4.MailingCity,null);
    }
}