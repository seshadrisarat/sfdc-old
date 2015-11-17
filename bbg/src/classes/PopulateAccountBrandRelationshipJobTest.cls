@isTest
private class PopulateAccountBrandRelationshipJobTest {

	private static Id dealerRecordTypeId = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Dealer'].Id;
	
    static testMethod void test() {
        AccountServices.disableTriggerProcessing = true;
        
        Test.startTest();
        
        Account srDealer = insertAccount(dealerRecordTypeId, '999.00');
        Account srMdDealer = insertAccount(dealerRecordTypeId, '999.01');
        Account srMDCLDealer = insertAccount(dealerRecordTypeId, '999.02');
        
        insertDealerBrand(srDealer, 'SR');
        insertDealerBrand(srMdDealer, 'SR');
        insertDealerBrand(srMdDealer, 'MD');
        insertDealerBrand(srMDCLDealer, 'SR');
        insertDealerBrand(srMDCLDealer, 'MD');
        insertDealerBrand(srMDCLDealer, 'CL');
        
        Contact srContact = insertContact('test.contact@aol.com', srDealer);
        Contact srMDContact = insertContact('test.contact@aol.com', srMDDealer);
        Contact srMDCLContact = insertContact('test.contact@aol.com', srMDCLDealer);
        
        Id batchJobId = Database.executeBatch(new PopulateAccountBrandRelationshipJob(), 10);
        system.debug('****************************** Job id: ' + batchJobId);
        
        Test.stopTest();
        
        srDealer = readAccount(srDealer.Id);
        srMdDealer = readAccount(srMdDealer.Id);
        srMDCLDealer = readAccount(srMDCLDealer.Id);
        
        system.debug('****************************** srDealer brand relationships: ' + srDealer.Brand_Relationships__c);
        system.debug('****************************** srMdDealer brand relationships: ' + srMdDealer.Brand_Relationships__c);
        system.debug('****************************** srMDCLDealer brand relationships: ' + srMDCLDealer.Brand_Relationships__c);
        
        system.assert(!String.isBlank(srDealer.Brand_Relationships__c), 'Expecting SR account to have brand relationship data');
        system.assert(!String.isBlank(srMdDealer.Brand_Relationships__c), 'Expecting SRMD account to have brand relationship data');
        system.assert(!String.isBlank(srMDCLDealer.Brand_Relationships__c), 'Expecting SRMDCL account to have brand relationship data');
        
        srContact = readContact(srContact.Id);
        srMDContact = readContact(srMDContact.Id);
        srMDCLContact = readContact(srMDCLContact.Id);
        
        system.debug('****************************** srContact active brands: ' + srContact.Active_Brands__c);
        system.debug('****************************** srMDContact active brands: ' + srMDContact.Active_Brands__c);
        system.debug('****************************** srMDCLContact active brands: ' + srMDCLContact.Active_Brands__c);
        
        system.assert(!String.isBlank(srContact.Active_Brands__c), 'Expecting SR contact to have active brand data');
        system.assert(!String.isBlank(srMDContact.Active_Brands__c), 'Expecting SRMD contact to have active brand data');
        system.assert(!String.isBlank(srMDCLContact.Active_Brands__c), 'Expecting SRMDCL contact to have active brand data');
        
    }
    
	private static Account insertAccount(Id accountRecordTypeId, String dealerNumber) {
		Account account = new Account(Name = 'TestDealer' + dealerNumber, Dealer_Number__c = dealerNumber, RecordTypeId = dealerRecordTypeId, ShippingCity = 'Test', ShippingState = 'TN');
        insert account;
        system.debug('****************************** Account id: ' + account.Id);
        return account;
	}
	
	private static Account readAccount(Id accountId) {
		Account account = [Select Id, Name, Dealer_Number__c, RecordTypeId, Brand_Relationships__c, ShippingCity, ShippingState From Account Where Id = :accountId];
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
	
	private static Dealer_Brand__c insertDealerBrand(Account dealer, String brand) {
		Dealer_Brand__c dealerBrand = new Dealer_Brand__c(Dealer__c = dealer.Id, Brand__c = brand, Status__c = 'Active', Name = brand + ' ' + dealer.Id);
		insert dealerBrand;
		system.debug('****************************** Dealer brand id: ' + dealerBrand.Id);
        return dealerBrand;
	}

}