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
private class SL_Test_BusinessAddrAssociationControler {

    static testMethod void myUnitTest() 
    {
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
        
        list<Contact_Address__c> lstConAddrs = new list<Contact_Address__c>{new Contact_Address__c(Address__c = lstEntityAddresses[0].Id,Contact__c = objContact.Id,Default_Contact_Address__c = true),
        																	new Contact_Address__c(Address__c = lstEntityAddresses[1].Id,Contact__c = objContact.Id,Default_Contact_Address__c = false)};
        insert lstConAddrs;
        
        Contact objUpdatedContact = [Select Name,MailingCity
        							 from Contact where Id=:objContact.Id];
        
        // Checking whether Contact MailingAddress is updated with primary contact Address or not
        system.assertEquals(objUpdatedContact.MailingCity,lstEntityAddresses[0].City__c);
        
        SL_RecursionHelper.setisAfterInsert(true);
        
        // Updating address for primary contact address
        lstConAddrs[0].Address__c = lstEntityAddresses[0].Id;
        update lstConAddrs[0];
        
        Contact objUpdatedContact1 = [Select Name,MailingCity
        							 from Contact where Id=:objContact.Id];
        
        // Checking whether Contact MailingAddress is updated with updated primary contact address
        system.assertEquals(objUpdatedContact1.MailingCity,lstEntityAddresses[1].City__c);
        
        SL_RecursionHelper.setisAfterUpdate(true);
        
        lstConAddrs[0].Default_Contact_Address__c = true;
        lstConAddrs[1].Default_Contact_Address__c = true;
        update lstConAddrs;
        
        SL_RecursionHelper.setisAfterUpdate(true);
        
        lstConAddrs[0].Default_Contact_Address__c = false;
        lstConAddrs[1].Default_Contact_Address__c = false;
        update lstConAddrs;
        
        Contact objUpdatedContact2 = [Select Name,MailingCity
        							 from Contact where Id=:objUpdatedContact1.Id];
        
        // Checking whether contact Mailing address is made blank when there is primary contact address for contact.
        system.assertEquals(objUpdatedContact2.MailingCity,null);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(objContact);
        SL_BusinessAddressAssociationController objBusinessAddr = new SL_BusinessAddressAssociationController(controller);
        
        // Verifying expected results
        system.assertEquals(objBusinessAddr.strEntityId,objAccount1.Id);
        system.assertEquals(objBusinessAddr.lstContactAddrAssociatedWithContact.size(),2);
        system.assertEquals(objBusinessAddr.lstBusinessAddrAssociatedWithContactEntity.size(),6);
        
        objBusinessAddr.nextPage();
        objBusinessAddr.previousPage();

        objBusinessAddr.lstBusinessAddrAssociatedWithContactEntity[0].isSelected = true;
        objBusinessAddr.createContactAddressAssociation();
        
        // Verifying whether new Contact Address is created or not
        system.assertEquals(objBusinessAddr.lstContactAddrAssociatedWithContact.size(),3);
        
        objBusinessAddr.strEntityId = objAccount2.Id;
        objBusinessAddr.searchAddresses();
        
        // Verfying search results based on selected Entity
        system.assertEquals(objBusinessAddr.lstBusinessAddrAssociatedWithContactEntity.size(),0);
        
        objBusinessAddr.saveAddress();
        
        // Checking whether new contact Address is created or not.
        system.assertEquals(objBusinessAddr.lstContactAddrAssociatedWithContact.size(),4);
        objBusinessAddr.intSaveOrCancelAddressIndex = 1;
        objBusinessAddr.lstContactAddrAssociatedWithContact[0].objAddress.City__c = 'Arrier';
        objBusinessAddr.saveUpdatedAddressRecord();
        
        objBusinessAddr.intSaveOrCancelAddressIndex = 1;
        objBusinessAddr.cancelUpdatedAddressRecord();
        
        objBusinessAddr.strAddressIdToRemove = objBusinessAddr.lstContactAddrAssociatedWithContact[0].objAddress.Id;
        objBusinessAddr.strContactAddressIdToRemove = objBusinessAddr.lstContactAddrAssociatedWithContact[0].idContactAddress;
        
        objBusinessAddr.deleteAddress();
        
        // Checking whether contact Address is deleted or not.
        system.assertEquals(objBusinessAddr.lstContactAddrAssociatedWithContact.size(),3);
        //objBusinessAddr.strUpdatedPrimaryAddressId = objBusinessAddr.lstBusinessAddrAssociatedWithContactEntity[0].Id;
        objBusinessAddr.updatedPrimaryContactAddress();
        
    }
}