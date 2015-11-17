@IsTest
public with sharing class OwnerResplitJob_Test {

	static testmethod void test() {
		RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Owner' and SObjectType = 'Account'];
		
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		AccountServices.disableTriggerProcessing = true;
		
		//create some boat and owner relationships to test with
		Account juannaSingleOwner = new Account(
			FirstName='Junna',
			LastName='Mann',
			PersonEmail='Juanna.Mann@example.com',
			RecordType=personAccountRecordType,
			Brand__c = 'SR'
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
			Brand__c = 'SR'
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
			Brand__c = 'SR'
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
		Id batchJobId = Database.executeBatch(new OwnerResplitJob(100));
		Test.stopTest();
		
		// single owner test assertions
		juannaSingleOwner = [select Active_Owner_Boat_Relationship_Summary__c, brand__c from Account where PersonEmail='Juanna.Mann@example.com'];	
		System.assertEquals(1, juannaSingleOwner.Active_Owner_Boat_Relationship_Summary__c, 'Boat assignment not correct');
		System.assertEquals('SR', juannaSingleOwner.brand__c, 'Owner account brand not updated for single owner');
		Id singleOwnerId = [select Id from Account where PersonEmail='Juanna.Mann@example.com' and brand__c = 'SR'].id;
		Integer singleOwnerSize = [select count() from Owner_Boat_Relationship__c where owner__r.id = :singleOwnerId];
		System.assertEquals(1, singleOwnerSize, 'Should have one obr for single owner.');
		
		// multiple brand owner assertions
		Integer bigOwnerAccountsSize= [select count() from Account where PersonEmail='Juanna.Mann2@example.com'];
		System.assertEquals(3, bigOwnerAccountsSize, 'Three accounts should now exist for the big owner');
		Integer srBigOwnerSize = [select count() from Account where PersonEmail='Juanna.Mann2@example.com' and brand__c = 'SR'];
		System.assertEquals(1, srBigOwnerSize, 'Should have one owner account for big owner SR');
		Integer mxBigOwnerSize = [select count() from Account where PersonEmail='Juanna.Mann2@example.com' and brand__c = 'MX'];
		System.assertEquals(1, mxBigOwnerSize, 'Should have one owner account for big owner MX');
		Integer blBigOwnerSize = [select count() from Account where PersonEmail='Juanna.Mann2@example.com' and brand__c = 'TR'];
		System.assertEquals(1, blBigOwnerSize, 'Should have one owner account for big owner TR');
		
		// check the OBRs were updated on the big owner
		Id srBigOwnerId = [select Id from Account where PersonEmail='Juanna.Mann2@example.com' and brand__c = 'SR'].id;
		system.debug('SR big owner id: ' + srBigOwnerId);
		Integer srObrSize = [select count() from Owner_Boat_Relationship__c where owner__r.id = :srBigOwnerId];
		
		Id mxBigOwnerId = [select Id from Account where PersonEmail='Juanna.Mann2@example.com' and brand__c = 'MX'].id;
		system.debug('MX big owner id: ' + mxBigOwnerId);
		Integer mxObrSize = [select count() from Owner_Boat_Relationship__c where owner__r.id = :mxBigOwnerId];
		
		Id trBigOwnerId = [select Id from Account where PersonEmail='Juanna.Mann2@example.com' and brand__c = 'TR'].id;
		system.debug('TR big owner id: ' + trBigOwnerId);
		Integer trObrSize = [select count() from Owner_Boat_Relationship__c where owner__r.id = :trBigOwnerId];
		
		System.assertEquals(1, trObrSize, 'Should have one obr for big owner TR clone');
		System.assertEquals(1, srObrSize, 'Should have one obr for big owner SR clone');
		System.assertEquals(1, mxObrSize, 'Should have one obr for big owner MX clone');
		
		// check brand loyal owner
		Integer loyalOwnerAccountsSize= [select count() from Account where PersonEmail='Juanna.Mann3@example.com'];
		System.assertEquals(1, loyalOwnerAccountsSize);
		String loyalOwnerBrand = [select Brand__c from Account where PersonEmail='Juanna.Mann3@example.com'].brand__c;
		System.assertEquals('SR', loyalOwnerBrand);
		
		Id loyalId = [select Id from Account where PersonEmail='Juanna.Mann3@example.com' and brand__c = 'SR'].id;
		Integer loyalSize = [select count() from Owner_Boat_Relationship__c where owner__r.id = :loyalId];
		System.assertEquals(2, loyalSize, 'Should have two obr for loyal owner');
		
		
		
		
	}
}