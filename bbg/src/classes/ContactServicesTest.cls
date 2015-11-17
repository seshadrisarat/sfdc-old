@isTest
private class ContactServicesTest {

	private static Id dealerRecordTypeId = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Dealer'].Id;
	
    static testMethod void test() {
        AccountServices.disableTriggerProcessing = true;
        Set<Id> accountIds = new Set<Id>();
        
        Test.startTest();
        
        Account srOnlyDealer = insertAccount(dealerRecordTypeId, '999.00', 'SR');
        Account srMdDealer = insertAccount(dealerRecordTypeId, '999.01', 'SR;MD');
        
        accountIds.add(srOnlyDealer.Id);
        
        Contact srContact1 = insertContact('test1.contact@aol.com', srOnlyDealer);
        Contact srContact2 = insertContact('test2.contact@aol.com', srOnlyDealer);
        Contact srContact3 = insertContact('test3.contact@aol.com', srOnlyDealer);
        
        Contact srMDContact = insertContact('test1.contact@aol.com', srMDDealer);

        contactServices.updateContactOtherBrandsByAccount(accountIds);
        
        Test.stopTest();
        
        srContact1 = readContact(srContact1.Id);
        srContact2 = readContact(srContact2.Id);
        srContact3 = readContact(srContact3.Id);
        srMDContact = readContact(srMDContact.Id);
        
        system.debug('****************************** srContact 1 other active brands: ' + srContact1.Other_Active_Brands__c);
        system.debug('****************************** srContact 2 other active brands: ' + srContact2.Other_Active_Brands__c);
        system.debug('****************************** srContact 3 other active brands: ' + srContact3.Other_Active_Brands__c);
        system.debug('****************************** srMDContact other active brands: ' + srMDContact.Other_Active_Brands__c);
        
        system.assert(!String.isBlank(srContact1.Other_Active_Brands__c), 'Expecting SR contact 1 to have other active brands');
        system.assert(String.isBlank(srContact2.Other_Active_Brands__c), 'Expecting SR contact 2 to have no other active brands');
        system.assert(String.isBlank(srContact3.Other_Active_Brands__c), 'Expecting SR contact 3 to have no other active brands');
        
        system.assert(String.isBlank(srMDContact.Other_Active_Brands__c), 'Expecting SRMD contact to have no other active brands');
        
    }
    
	private static Account insertAccount(Id accountRecordTypeId, String dealerNumber, String brandRelationship) {
		Account account = new Account(Name = 'TestDealer' + dealerNumber, Dealer_Number__c = dealerNumber, RecordTypeId = dealerRecordTypeId, Brand_Relationships__c = brandRelationship, ShippingCity = 'Test', ShippingState = 'TN');
        insert account;
        system.debug('****************************** Account id: ' + account.Id);
        return account;
	}
	
	private static Contact insertContact(String emailAddress, Account account) {
		Contact contact = new Contact(Email = emailAddress, FirstName = 'Test', LastName = 'Contact', AccountId = account.Id);
		insert contact;
		system.debug('****************************** Contact id: ' + contact.Id);
        return readContact(contact.Id);
	}
	
	private static Contact readContact(Id contactId) {
		Contact contact = [Select Email, AccountId, FirstName, LastName, Active_Brands__c, Other_Active_Brands__c From Contact Where Id = :contactId];
		return contact;
	}

}