@isTest
private class ContactOtherActiveBrandsUpdateJobTest {

	private static Id dealerRecordTypeId = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Dealer'].Id;
	
    static testMethod void test() {
        AccountServices.disableTriggerProcessing = true;
        
        Test.startTest();
        
        Account srOnlyDealer = insertAccount(dealerRecordTypeId, '999.00', 'SR');
        Account srMdDealer = insertAccount(dealerRecordTypeId, '999.01', 'SR;MD');
        Account srMDCLDealer = insertAccount(dealerRecordTypeId, '999.02', 'SR;MD;CL');
        
        Contact srContact = insertContact('test.contact@aol.com', srOnlyDealer);
        Contact srMDContact = insertContact('test.contact@aol.com', srMDDealer);
        Contact srMDCLContact = insertContact('test.contact@aol.com', srMDCLDealer);
        
        Id batchJobId = Database.executeBatch(new ContactOtherActiveBrandsUpdateJob(), 10);
        system.debug('****************************** Job id: ' + batchJobId);
        
        Test.stopTest();
        
        srContact = readContact(srContact.Id);
        srMDContact = readContact(srMDContact.Id);
        srMDCLContact = readContact(srMDCLContact.Id);
        
        system.debug('****************************** srContact other active brands: ' + srContact.Other_Active_Brands__c);
        system.debug('****************************** srMDContact other active brands: ' + srMDContact.Other_Active_Brands__c);
        system.debug('****************************** srMDCLContact other active brands: ' + srMDCLContact.Other_Active_Brands__c);
        
        system.assert(!String.isBlank(srContact.Other_Active_Brands__c), 'Expecting SR contact to have other active brands');
        system.assert(!String.isBlank(srMDContact.Other_Active_Brands__c), 'Expecting SRMD contact to have other active brands');
        system.assert(String.isBlank(srMDCLContact.Other_Active_Brands__c), 'Expecting contact to have no other active brands');
        
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