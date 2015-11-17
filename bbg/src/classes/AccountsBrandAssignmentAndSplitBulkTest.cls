@IsTest
public with sharing class AccountsBrandAssignmentAndSplitBulkTest {

	/**
	 * This test requires the Brand_Required_for_Owner_Account validation rule be set not active.
	 *
	 * Tests the bulk job with the following three scenarios
	 * 1. Single boat owner, Should updated the brand of the owner account
	 * 2. Owner with three boat brands, should assign brand to existing contact
	 *    and should create 2 additional contacts for the other two brands
	 * 3. Brand loyal owner, shouldn't create additional contacts only update the Brand of the contact
	 */
	static testmethod void test() {
		RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
		
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		AccountServices.disableTriggerProcessing = true;
		
		//create some boat and owner relationships to test with
		Account juannaSingleOwner = new Account(
			FirstName='Junna',
			LastName='Mann',
			PersonEmail='Juanna.Mann@example.com',
			RecordType=personAccountRecordType,
			Brand__c = 'NA'
		);
		insert juannaSingleOwner;
		Boat__c juannasBoat = new Boat__c(
			Name='FAKEHIN',
			Brand_del__c='SR'
		);
		insert juannasBoat;
		Owner_Boat_Relationship__c juannasBoatRel = new Owner_Boat_Relationship__c(
			HIN_Number__c = juannasBoat.id,
			Owner__c = juannaSingleOwner.id,
			Status__c = 'Active'
		);
		insert juannasBoatRel;
		
		//create some boat and owner with multiple boats of different brands to test with
		Account juannaBigOwner = new Account(
			FirstName='Junna',
			LastName='Mann',
			PersonEmail='Juanna.Mann2@example.com',
			RecordType=personAccountRecordType,
			Brand__c = 'NA'
		);
		insert juannaBigOwner;
		Boat__c juannasBoat1 = new Boat__c(
			Name='FAKEHIN1',
			Brand_del__c='SR'
		);
		insert juannasBoat1;
		Owner_Boat_Relationship__c juannasBoatRel1 = new Owner_Boat_Relationship__c(
			HIN_Number__c = juannasBoat1.id,
			Owner__c = juannaBigOwner.id,
			Status__c = 'Active'
		);
		insert juannasBoatRel1;
		Boat__c juannasBoat2 = new Boat__c(
			Name='FAKEHIN2',
			Brand_del__c='MX'
		);
		insert juannasBoat2;
		Owner_Boat_Relationship__c juannasBoatRel2 = new Owner_Boat_Relationship__c(
			HIN_Number__c = juannasBoat2.id,
			Owner__c = juannaBigOwner.id,
			Status__c = 'Active'
		);
		insert juannasBoatRel2;
		Boat__c juannasBoat3 = new Boat__c(
			Name='FAKEHIN3',
			Brand_del__c='TR'
		);
		insert juannasBoat3;
		Owner_Boat_Relationship__c juannasBoatRel3 = new Owner_Boat_Relationship__c(
			HIN_Number__c = juannasBoat3.id,
			Owner__c = juannaBigOwner.id,
			Status__c = 'Active'
		);
		insert juannasBoatRel3;
		
		// create an owner with multiple boat of the same brand
		Account juannaBrandLoyalOwner = new Account(
			FirstName='Junna',
			LastName='Mann',
			PersonEmail='Juanna.Mann3@example.com',
			RecordType=personAccountRecordType,
			Brand__c = 'NA'
		);
		insert juannaBrandLoyalOwner;
		Boat__c juannasBoat4 = new Boat__c(
			Name='FAKEHIN4',
			Brand_del__c='SR'
		);
		insert juannasBoat4;
		Owner_Boat_Relationship__c juannasBoatRel4 = new Owner_Boat_Relationship__c(
			HIN_Number__c = juannasBoat4.id,
			Owner__c = juannaBrandLoyalOwner.id,
			Status__c = 'Active'
		);
		insert juannasBoatRel4;
		Boat__c juannasBoat5 = new Boat__c(
			Name='FAKEHIN5',
			Brand_del__c='SR'
		);
		insert juannasBoat5;
		Owner_Boat_Relationship__c juannasBoatRel5 = new Owner_Boat_Relationship__c(
			HIN_Number__c = juannasBoat5.id,
			Owner__c = juannaBrandLoyalOwner.id,
			Status__c = 'Active'
		);
		insert juannasBoatRel5;
		
		Test.startTest();
		Id batchJobId = Database.executeBatch(new AccountsBrandAssignmentAndSplitBulkJob());
		Test.stopTest();
		
		// single owner test assertions
		juannaSingleOwner = [select Active_Owner_Boat_Relationship_Summary__c, brand__c from Account where PersonEmail='Juanna.Mann@example.com'];	
		System.assertEquals(1, juannaSingleOwner.Active_Owner_Boat_Relationship_Summary__c, 'Boat assignment not correct');
		System.assertEquals('SR', juannaSingleOwner.brand__c, 'Owner account brand not updated for single owner');
		
		// multiple brand owner assertions
		Integer bigOwnerAccountsSize= [select count() from Account where PersonEmail='Juanna.Mann2@example.com'];
		System.assertEquals(3, bigOwnerAccountsSize, 'Three accounts should now exist for the big owner');
		Integer srBigOwnerSize = [select count() from Account where PersonEmail='Juanna.Mann2@example.com' and brand__c = 'SR'];
		System.assertEquals(1, srBigOwnerSize, 'Should have one owner account for big owner SR');
		Integer mxBigOwnerSize = [select count() from Account where PersonEmail='Juanna.Mann2@example.com' and brand__c = 'MX'];
		System.assertEquals(1, mxBigOwnerSize, 'Should have one owner account for big owner MX');
		Integer blBigOwnerSize = [select count() from Account where PersonEmail='Juanna.Mann2@example.com' and brand__c = 'MX'];
		System.assertEquals(1, blBigOwnerSize, 'Should have one owner account for big owner BL');
		
		// check brand loyal owner
		Integer loyalOwnerAccountsSize= [select count() from Account where PersonEmail='Juanna.Mann3@example.com'];
		System.assertEquals(1, loyalOwnerAccountsSize);
		String loyalOwnerBrand = [select Brand__c from Account where PersonEmail='Juanna.Mann3@example.com'].brand__c;
		System.assertEquals('SR', loyalOwnerBrand);
		
	}
}