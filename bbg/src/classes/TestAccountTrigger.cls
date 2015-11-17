@isTest
public class TestAccountTrigger {
 	@isTest
	static void dealerAccountsAreMarkedForGeocodingWhenTooMany() {
		// Disable geocoding since we dont want to test this
		AccountServices.ranPopulateAccountGeoFields = true;
		list<Account> dealers = TestUtilities.createTestDealerAccounts((AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE+1), false);
		
		Test.startTest();
		insert dealers;
		Test.stopTest();
		
		dealers = [select Id, Geonames_Retry__c from Account where RecordTypeId=:AccountServices.getDealerRecordType()];
		system.assertEquals((AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE+1), dealers.size());
		
		for (Account dealer : dealers) {
			system.assertEquals(true, dealer.Geonames_Retry__c, 'The dealer should have been marked for geocoding');
		}
	}
	
	@isTest
	static void dealerAccountsAreMarkedForGeocodingWhenUpdatedAndTooMany() {
		// Disable geocoding since we dont want to test this
		AccountServices.ranPopulateAccountGeoFields = true;
		
		// Disable trigger processing for insert so we can test update
		AccountServices.disableTriggerProcessing = true;
		list<Account> dealers = TestUtilities.createTestDealerAccounts((AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE+1), true);
		AccountServices.disableTriggerProcessing = false;
		
		// Update the address
		for (Account dealer : dealers) {
			dealer.ShippingPostalCode = '37922';
		}
		
		Test.startTest();
		update dealers;
		Test.stopTest();
		
		dealers = [select Id, Geonames_Retry__c from Account where RecordTypeId=:AccountServices.getDealerRecordType()];
		system.assertEquals((AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE+1), dealers.size());
		
		for (Account dealer : dealers) {
			system.assertEquals(true, dealer.Geonames_Retry__c, 'The dealer should have been marked for geocoding');
		}
	}
	
	@isTest
	static void ownerAccountsAreMarkedForGeocodingWhenTooMany() {
		// Disable geocoding since we dont want to test this
		OwnerServices.populateOwnerGeoFieldsIsRunning = true;
		list<Account> owners = TestUtilities.createTestOwnerAccounts((AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE+1), false);
		for (Account owner : owners) {
			owner.PersonMailingPostalCode = '37934';
			owner.Home_Address_ISO_Code__c = 'US';
		}
		
		Test.startTest();
		insert owners;
		Test.stopTest();
		
		owners = [select Id, Geonames_Retry__c from Account where RecordTypeId=:OwnerServices.getOwnerRecordTypeId()];
		system.assertEquals((AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE+1), owners.size());
		
		for (Account owner : owners) {
			system.assertEquals(true, owner.Geonames_Retry__c, 'The owner should have been marked for geocoding');
		}
	}
	
	@isTest
	static void ownerAccountsAreMarkedForGeocodingWhenUpdatedAndTooMany() {
		// Disable geocoding since we dont want to test this
		OwnerServices.populateOwnerGeoFieldsIsRunning = true;
		
		// Disable trigger processing for insert so we can test update
		AccountServices.disableTriggerProcessing = true;
		list<Account> owners = TestUtilities.createTestOwnerAccounts((AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE+1), false);
		for (Account owner : owners) {
			owner.PersonMailingPostalCode = '37934';
		}
		insert owners;
		AccountServices.disableTriggerProcessing = false;
		
		// Update the address
		for (Account owner : owners) {
			owner.PersonMailingPostalCode = '37922';
		}
		
		Test.startTest();
		update owners;
		Test.stopTest();
		
		owners = [select Id, Geonames_Retry__c from Account where RecordTypeId=:OwnerServices.getOwnerRecordTypeId()];
		system.assertEquals((AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE+1), owners.size());
		
		for (Account owner : owners) {
			system.assertEquals(true, owner.Geonames_Retry__c, 'The owner should have been marked for geocoding');
		}
	}
	
	@isTest
	static void dealerAccountsAreGeocodedWhenNotTooMany() {
		list<Account> dealers = TestUtilities.createTestDealerAccounts(1, false);
		
		Test.startTest();
		insert dealers;
		Test.stopTest();
		
		dealers = [select Id, longitude__c, latitude__c, Geonames_Retry__c from Account where RecordTypeId=:AccountServices.getDealerRecordType()];
		system.assertEquals(1, dealers.size());
		system.assertEquals(37.4352, dealers[0].latitude__c);
		system.assertEquals(-121.895, dealers[0].longitude__c);
		system.assertEquals(false, dealers[0].Geonames_Retry__c);
	}
	@isTest
	static void ownerAccountsAreGeocodedWhenNotTooMany() {
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, false);
		for (Account owner : owners) {
			owner.PersonMailingPostalCode = '37934';
			owner.Home_Address_ISO_Code__c = 'US';
		}
		
		Test.startTest();
		insert owners;
		Test.stopTest();
		
		owners = [select Id, longitude__c, latitude__c, Geonames_Retry__c from Account where RecordTypeId=:OwnerServices.getOwnerRecordTypeId()];
		system.assertEquals(1, owners.size());
		system.assertEquals(37.4352, owners[0].latitude__c);
		system.assertEquals(-121.895, owners[0].longitude__c);
		system.assertEquals(false, owners[0].Geonames_Retry__c);
	}
	
	
	@isTest
	static void dealerAccountsAreGeocodedWhenTooMany() {
		list<Account> dealers = TestUtilities.createTestDealerAccounts((AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE+1), false);
		
		Test.startTest();
		insert dealers;
		Test.stopTest();
		
		dealers = [select Id, longitude__c, latitude__c, Geonames_Retry__c from Account where RecordTypeId=:AccountServices.getDealerRecordType()];
		system.assertEquals((AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE+1), dealers.size());
		
		for (Account dealer : dealers) {
			system.assertEquals(37.4352, dealer.latitude__c);
			system.assertEquals(-121.895, dealer.longitude__c);
			system.assertEquals(false, dealer.Geonames_Retry__c, 'The dealer should not have been marked for geocoding');
		}
	}
	
	@isTest
	static void ownerAccountsAreGeocodedWhenTooMany() {
		list<Account> owners = TestUtilities.createTestOwnerAccounts((AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE+1), false);
		for (Account owner : owners) {
			owner.PersonMailingPostalCode = '37934';
			owner.Home_Address_ISO_Code__c = 'US';
		}
		
		Test.startTest();
		insert owners;
		Test.stopTest();
		
		owners = [select Id, longitude__c, latitude__c, Geonames_Retry__c from Account where RecordTypeId=:OwnerServices.getOwnerRecordTypeId()];
		system.assertEquals((AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE+1), owners.size());
		
		for (Account owner : owners) {
			system.assertEquals(37.4352, owner.latitude__c);
			system.assertEquals(-121.895, owner.longitude__c);
			system.assertEquals(false, owner.Geonames_Retry__c, 'The owner should not have been marked for geocoding');
		}
	}
}