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
private class SL_Test_ContactTriggerHandler {

    static testMethod void myUnitTest() 
    {
        // TO DO: implement unit test
        
         // Start of preparing test data
		Account objAccount1 = new Account(Name = 'Test Account 1');
		insert objAccount1;
		
		Account objAccount2 = new Account(Name = 'Test Account 2');
		insert objAccount2;
		
        list<Address__c> lstEntityAddresses = new list<Address__c>{ new Address__c(Address_Type__c = 'Entity',Entity__c=objAccount1.Id, Address_1__c = 'Addr1',City__c = 'BallsbridgeCafe',State__c = 'Florida',Zipcode__c = '14563'),
        															new Address__c(Address_Type__c = 'Entity',Entity__c=objAccount1.Id,Address_1__c='Terenes City',City__c = 'BallsbridgeCafe',State__c = 'Florida',Zipcode__c = '25379'),
        															new Address__c(Address_Type__c = 'Entity',Entity__c=objAccount1.Id,Address_1__c='Terenes City-1',City__c = 'BallsbridgeCafe',State__c = 'Florida',Zipcode__c = '25379'),
        															new Address__c(Address_Type__c = 'Entity',Entity__c=objAccount1.Id,Address_1__c='Terenes City-2',City__c = 'BallsbridgeCafe',State__c = 'Florida',Zipcode__c = '25379'),
        															new Address__c(Address_Type__c = 'Entity',Entity__c=objAccount1.Id,Address_1__c='Terenes City-3',City__c = 'BallsbridgeCafe',State__c = 'Florida',Zipcode__c = '25379'),
        															new Address__c(Address_Type__c = 'Entity',Entity__c=objAccount1.Id,Address_1__c='Terenes City-4',City__c = 'BallsbridgeCafe',State__c = 'Florida',Zipcode__c = '25379')};
        insert lstEntityAddresses;
        
        Contact objContact = new Contact(AccountID = objAccount1.Id,LastName = 'Test Contact-01');  
        insert objContact;
        
        Contact objContact1 = new Contact(AccountID = objAccount1.Id,LastName = 'Test Contact-02');  
        insert objContact1;
        
        list<Contact_Address__c> lstConAddrs = new list<Contact_Address__c>{new Contact_Address__c(Address__c = lstEntityAddresses[0].Id,Contact__c = objContact.Id,Default_Contact_Address__c = true),
        																	new Contact_Address__c(Address__c = lstEntityAddresses[1].Id,Contact__c = objContact1.Id,Default_Contact_Address__c = true)};
        insert lstConAddrs;
        
        list<Contact_Address__c> lstConAddrsForCon = [Select Id from Contact_Address__c
        											  where Contact__c =:objContact.Id ];
        
        // Checking no of addresses for master contact before merge Operation
        system.assertEquals(lstConAddrsForCon.size(),1);											  
        
        //Merging Contacts
        test.starttest();
			Database.merge(objContact, objContact1, false);
		test.stoptest();
		
		list<Contact_Address__c> lstConAddrsForMergerdCon = [Select Id from Contact_Address__c
        											  		 where Contact__c =:objContact.Id
        											  		];
        
        // Checking no of contact addresses for master contact after merge Operation.
        system.assertEquals(lstConAddrsForMergerdCon.size(),2);	
        
        list<Contact_Address__c> lstPrimConAddrsForMergerdCon = [Select Id from Contact_Address__c
        											  		     where Contact__c =:objContact.Id and Default_Contact_Address__c = true];
        // Checking no of primary contact addresses for master contact after merge Operation										  		   
        system.assertEquals(lstPrimConAddrsForMergerdCon.size(),1);
                											  		
    }
}