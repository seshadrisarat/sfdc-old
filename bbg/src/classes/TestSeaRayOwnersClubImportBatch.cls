@isTest
private class TestSeaRayOwnersClubImportBatch {
	private static Id DEALER_RECORD_TYPE = [Select Id from RecordType Where DeveloperName='DEALER' limit 1].Id;
	private static Id OWNER_RECORD_TYPE_ID = [select Id from recordtype where developerName='Owner' limit 1].Id;
	private static final string TEST_HIN = 'SERT8312B606';
	private static final string TEST_HIN2 = 'SERT8312B605';
	private static final string TEST_HIN3 = 'BLBX1599G415';
	private static final string TEST_MODEL = '320DA';
	private static final string TEST_MODEL_YEAR = '2006';
	private static final string TEST_BRAND = 'SR';
	private static final string TEST_DEALER_NUMBER = '00433.000';
	private static final string TEST_DEALER_NUMBER_SROC = '433-000';
	private static final string TEST_OWNER_FIRST_NAME = 'James';
	private static final string TEST_OWNER_MIDDLE_INITIAL = 'T';
	private static final string TEST_OWNER_LAST_NAME = 'Holt';
	private static final string TEST_OWNER_SUFFIX = 'Jr.';
	private static final string TEST_OWNER_STREET = '3218 Beachwater Drive';
	private static final string TEST_OWNER_CITY = 'Katy';
	private static final string TEST_OWNER_STATE = 'TX';
	private static final string TEST_OWNER_ZIP = '77450';
	private static final string TEST_OWNER_EMAIL = 'test@test.com';
	private static final Date TEST_OWNER_PURCHASE_DATE = Date.newInstance(2015, 1, 29);
	private static final Date TEST_OWNER_JOIN_DATE = Date.newInstance(2015, 2, 10);
	private static final Date TEST_OWNER_JOIN_DATE2 = Date.newInstance(2015, 2, 11);
	private static final Date TEST_OWNER_MORE_RECENT_PURCHASE_DATE = Date.newInstance(2015, 2, 29);
	
	
	private static Id getIntegrationUserId() {
		User[] users = [select Id from User where Name='Integration User'];
		return users[0].Id;
	}
	
	// Tests that when there is an existing owner and no existing relationship is found on a boat, it will use the existing owner
	static testmethod void testMatchesExistingOwner() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Account owner = createOwner();
		Boat__c boat = createBoat();
		SROC__c ocData = createSROC1();
		update ocData;
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		
		// Make sure there is only 1 owner for the boat
		list<Owner_Boat_Relationship__c> ownerRels = [select Id, Owner__c From Owner_Boat_Relationship__c];
		System.assert(ownerRels.size() == 1);
		BoatServices.disableTriggerProcessing = false;	
	}
	
	// Tests that when there is an existing owner with the middle initial before first name and no existing relationship is found on a boat, it will use the existing owner
	static testmethod void testMatchesExistingOwnerWithMiddleInitial() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Account owner = createOwner();
		owner.FirstName = TEST_OWNER_MIDDLE_INITIAL + '. ' + TEST_OWNER_FIRST_NAME;
		update owner;
		Boat__c boat = createBoat();
		SROC__c ocData = createSROC1();
		update ocData;
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		
		// Make sure there is only 1 owner for the boat
		list<Owner_Boat_Relationship__c> ownerRels = [select Id, Owner__c From Owner_Boat_Relationship__c];
		System.assert(ownerRels.size() == 1);
		BoatServices.disableTriggerProcessing = false;	
	}
	
	// Tests that when there is an existing owner with the suffix after last name and no existing relationship is found on a boat, it will use the existing owner
	static testmethod void testMatchesExistingOwnerWithSuffix() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Account owner = createOwner();
		owner.LastName = TEST_OWNER_LAST_NAME + ' ' + TEST_OWNER_SUFFIX;
		update owner;
		Boat__c boat = createBoat();
		SROC__c ocData = createSROC1();
		update ocData;
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		
		// Make sure there is only 1 owner for the boat
		list<Owner_Boat_Relationship__c> ownerRels = [select Id, Owner__c From Owner_Boat_Relationship__c];
		System.assert(ownerRels.size() == 1);
		BoatServices.disableTriggerProcessing = false;	
	}
	
	static testmethod void testNoBoatFails() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		SROC__c ocData = createSROC1();
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we failed
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == true);
		System.assert(records[0].Is_Processed__c == true);
	}
	
	static testmethod void testImportField() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		SROC__c ocData = createSROC1();
		Boat__c boat = createBoat();
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		
		// Make sure the owner was created and is related to the boat
		Owner_Boat_Relationship__c obr = [Select o.Owner__r.Customer_Wants_Mailings__c, o.Owner__r.Id, o.Owner__r.HIN_Number__c, o.Owner__r.PersonHasOptedOutOfEmail,o.Owner__r.FirstName, o.Owner__r.LastName,  o.Owner__r.PersonMailingStreet,  o.Owner__r.PersonMailingState,  o.Owner__r.PersonMailingCity, 
										   o.Owner__r.PersonMailingCountry, o.Owner__r.Home_Address_ISO_Code__c,  o.Owner__r.PersonMailingPostalCode, o.Owner__r.Work_Phone__pc, 
										   o.Owner__r.Co_Owner__c, o.Owner__r.PersonHomePhone, o.Owner__r.PersonEmail, o.Owner__r.RecordTypeId, o.Owner__r.OwnerId, o.Owner__r.Birthday__pc, o.Owner__r.Comments__pc,o.SROC_Comments__c, o.Owner__r.Brand_Relationships__c, 
										   o.Owner__r.Latitude__c, o.Owner__r.Longitude__c, o.Owner__r.GeoLocation__c, o.Owner__c, o.Purchase_Date__c, o.Status__c,
										   o.Owner__r.Entry_Source__c, o.Entry_Source__c, o.Owner__r.Middle_Initial__c,o.Owner__r.Name_Suffix__c,o.Owner__r.NCOA_Address_Status__c,o.NCOA_Address_Status__c,o.NCOA_Status__c,o.Owner__r.NCOA_Status__c,
										   o.Owner__r.NCOA_Validation_Date__c, o.Customer_Wants_Mailings__c, o.NCOA_Validation_Date__c,o.Owner__r.New_or_Used__c, o.New_or_Used__c, o.Owner__r.SROC_Cancellation_Date__c, o.SROC_Cancellation_Date__c,o.Owner__r.SROC_Enrollment_Level__c, o.SROC_Enrollment_Level__c,o.SROC_Enrollment_Status__c,
										   o.Owner__r.SROC_Enrollment_Status__c, o.Owner__r.SROC_Join_Date__c, o.SROC_Join_Date__c, o.Owner__r.SROC_Member_ID__c, o.SROC_Member_ID__c,o.Owner__r.SROC_Membership_Status__c, 
										   o.SROC_Membership_Status__c,o.Owner__r.SROC_Ownership_Status__c, o.SROC_Ownership_Status__c,o.Owner__r.SROC_Points_Total__c, o.SROC_Points_Total__c,
										   o.Owner__r.SROC_Purchased_Dealer_Name__c, o.SROC_Purchased_Dealer_Name__c, o.Owner__r.SROC_Sales_Total__c, o.SROC_Sales_Total__c,o.Owner__r.SROC_Welcome_Kit_Status__c, o.SROC_Welcome_Kit_Status__c, 
										   o.Email_Opt_In__c, o.Owner__r.SROC_Purchased_Dealer_Number__c, o.SROC_Purchased_Dealer_Number__c, o.Opt_Out_of_Sea_Ray_Living__c From Owner_Boat_Relationship__c o where o.HIN_Number__r.Name=:ocData.HIN__c limit 1];
		System.assert(obr.Owner__r.Id != null);
		
		// Make sure all the relationship fields were set correctly
		System.assert(obr.Purchase_Date__c == ocData.SROC_Purchase_Date__c);
		System.assert(obr.Status__c == ('OWNED'.equalsIgnoreCase(ocData.SROC_Ownership_Status__c) ? 'Active' : 'Inactive'));
		
		// Make sure all the owner fields were set correctly
		System.assert(obr.Owner__r.HIN_Number__c == ocData.HIN__c);
		System.assert(obr.Owner__r.FirstName == ocData.First_Name__c);
		System.assert(obr.Owner__r.LastName == ocData.Last_Name__c);
		System.assert(obr.Owner__r.PersonMailingStreet == ocData.Address__c);
		System.assert(obr.Owner__r.PersonMailingState == ocData.State__c);
		System.assert(obr.Owner__r.PersonMailingCity == ocData.City__c);
		System.assert(obr.Owner__r.PersonMailingCountry == ocData.Country_Name__c);
		System.assert(obr.Owner__r.Home_Address_ISO_Code__c == 'US');
		System.assert(obr.Owner__r.PersonMailingPostalCode == ocData.Zip_Code__c);
		System.assert(obr.Owner__r.PersonHasOptedOutOfEmail == ((ocData.Email_Opt_In__c == 'Y' || ocData.Email_Opt_In__c == 'Yes') ? false : true)); 
		System.assert(obr.Email_Opt_In__c == ((ocData.Email_Opt_In__c == 'Y' || ocData.Email_Opt_In__c == 'Yes') ? 'Yes' : 'No')); 
		//System.assert(obr.Owner__r.Email_Opt_In__c == ((ocData.Email_Opt_In__c == 'Y' || ocData.Email_Opt_In__c == 'Yes') ? 'Yes' : 'No'));
		System.assert(obr.Owner__r.Work_Phone__pc == ocData.Work_Phone__c);
		System.assert(obr.Owner__r.Co_Owner__c == ocData.Co_Owner__c);
		System.assert(obr.Owner__r.PersonHomePhone == ocData.Home_Phone__c);
		System.assert(obr.Owner__r.PersonEmail == ocData.Email__c);
		System.assert(obr.Owner__r.Birthday__pc == ocData.Birth_Date__c);
		System.assert(obr.Owner__r.Comments__pc == ocData.Comments__c);
		System.assert(obr.SROC_Comments__c == ocData.Comments__c);
		System.assert(obr.Owner__r.Brand_Relationships__c == TEST_BRAND);
		//System.assert(obr.Owner__r.OwnerId == getIntegrationUserId());
		System.assert(obr.Owner__r.RecordTypeId == OWNER_RECORD_TYPE_ID);
		System.assert(obr.Owner__r.Customer_Wants_Mailings__c == ((ocData.Customer_Wants_Mailings__c == 'Y' || ocData.Customer_Wants_Mailings__c == 'Yes') ? true : false));
		System.assert(obr.Customer_Wants_Mailings__c == ocData.Customer_Wants_Mailings__c);
		System.assert(obr.Opt_Out_of_Sea_Ray_Living__c == ocData.Opt_Out_of_Sea_Ray_Living__c);
		System.assert(obr.Owner__r.Entry_Source__c	== SeaRayOwnersClubImportService.ENTRY_SOURCE_SROC);
		System.assert(obr.Entry_Source__c == SeaRayOwnersClubImportService.ENTRY_SOURCE_SROC);
		System.assert(obr.Owner__r.Middle_Initial__c == ocData.Middle_Initial__c);
		System.assert(obr.Owner__r.Name_Suffix__c == ocData.Name_Suffix__c);
		System.assert(obr.NCOA_Address_Status__c == ocData.NCOA_Address_Status__c);
		System.assert(obr.Owner__r.NCOA_Address_Status__c == ocData.NCOA_Address_Status__c);
		System.assert(obr.NCOA_Status__c == ocData.NCOA_Status__c);
		System.assert(obr.Owner__r.NCOA_Status__c == ocData.NCOA_Status__c);
		System.assert(obr.NCOA_Validation_Date__c == ocData.NCOA_Validation_Date__c);
		System.assert(obr.Owner__r.NCOA_Validation_Date__c == ocData.NCOA_Validation_Date__c);
		System.assert(obr.New_or_Used__c == ocData.New_or_Used__c);
		System.assert(obr.Owner__r.New_or_Used__c == ocData.New_or_Used__c);
		System.assert(obr.SROC_Cancellation_Date__c == ocData.SROC_Cancellation_Date__c);
		System.assert(obr.Owner__r.SROC_Cancellation_Date__c == ocData.SROC_Cancellation_Date__c);
		System.assert(obr.SROC_Enrollment_Level__c == ocData.SROC_Enrollment_Level__c);
		System.assert(obr.Owner__r.SROC_Enrollment_Level__c == ocData.SROC_Enrollment_Level__c);
		System.assert(obr.SROC_Enrollment_Status__c == ocData.SROC_Enrollment_Status__c);
		System.assert(obr.Owner__r.SROC_Enrollment_Status__c == ocData.SROC_Enrollment_Status__c);
		System.assert(obr.SROC_Join_Date__c == ocData.SROC_Join_Date__c);
		System.assert(obr.Owner__r.SROC_Join_Date__c == ocData.SROC_Join_Date__c);
		System.assert(obr.SROC_Member_ID__c == ocData.SROC_Member_ID__c);
		System.assert(obr.Owner__r.SROC_Member_ID__c == ocData.SROC_Member_ID__c);
		System.assert(obr.SROC_Membership_Status__c == ocData.SROC_Membership_Status__c);
		System.assert(obr.Owner__r.SROC_Membership_Status__c == ocData.SROC_Membership_Status__c);
		System.assert(obr.SROC_Ownership_Status__c == ocData.SROC_Ownership_Status__c);
		System.assert(obr.Owner__r.SROC_Ownership_Status__c == ocData.SROC_Ownership_Status__c);
		System.assert(obr.SROC_Points_Total__c == ocData.SROC_Points_Total__c);
		System.assert(obr.Owner__r.SROC_Points_Total__c == ocData.SROC_Points_Total__c);
		System.assert(obr.SROC_Purchased_Dealer_Name__c == ocData.SROC_Purchased_Dealer_Name__c);
		System.assert(obr.Owner__r.SROC_Purchased_Dealer_Name__c == ocData.SROC_Purchased_Dealer_Name__c);
		System.assert(obr.SROC_Purchased_Dealer_Number__c == ocData.SROC_Purchased_Dealer_Number__c);
		System.assert(obr.Owner__r.SROC_Purchased_Dealer_Number__c == ocData.SROC_Purchased_Dealer_Number__c);
		System.assert(obr.SROC_Sales_Total__c == ocData.SROC_Sales_Total__c);
		System.assert(obr.Owner__r.SROC_Sales_Total__c == ocData.SROC_Sales_Total__c);
		System.assert(obr.SROC_Welcome_Kit_Status__c == ocData.SROC_Welcome_Kit_Status__c);
		System.assert(obr.Owner__r.SROC_Welcome_Kit_Status__c == ocData.SROC_Welcome_Kit_Status__c);
		
		BoatServices.disableTriggerProcessing = false;
		OwnerBoatRelationshipServices.disableTriggerProcessing = false;
	}
	
	// Tests that the SROC data is updated with the more recent data
	static testmethod void testUpdatesSROCWithLatestData() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Account owner = createOwner();
		Boat__c boat = createBoat();
		
		Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(owner, boat);
		SROC__c ocData = createSROC1();
		SROC__c ocData2 = createSROC1();
		ocData2.SROC_Member_ID__c = 'member2';
		ocData2.SROC_Membership_Status__c = 'status2';
		ocData2.SROC_Join_Date__c = Date.newInstance(2015, 2, 12);
		update ocData2;
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		System.assert(records[1].Is_Processing_Error__c == false);
		System.assert(records[1].Is_Processed__c == true);
		
		// Make sure there is only 1 owner for the boat
		list<Owner_Boat_Relationship__c> obrs = [select Id, Owner__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id];
		System.assert(obrs.size() == 1);
		
		// Make sure there is only 1 owner relationship
		obrs = [select Id, Owner__r.SROC_Member_ID__c, Owner__r.SROC_Membership_Status__c, Owner__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id];
		System.assert(obrs.size() == 1);
		
		// Make sure the second SROC data is used for the relationship
		System.assert(obrs[0].Owner__r.SROC_Member_ID__c == ocData2.SROC_Member_ID__c);
		System.assert(obrs[0].Owner__r.SROC_Membership_Status__c == ocData2.SROC_Membership_Status__c);
		
		BoatServices.disableTriggerProcessing = false;	
	}
	
	// Tests that the SROC data is not updated with the more recent data since the prior data is OWNED and the more recent is not
	static testmethod void testKeepsSROCWithPriorOwnedData() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Account owner = createOwner();
		Boat__c boat = createBoat();
		
		Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(owner, boat);
		SROC__c ocData = createSROC1();
		SROC__c ocData2 = createSROC1();
		ocData2.SROC_Ownership_Status__c = 'SOLD';
		ocData2.SROC_Member_ID__c = 'member2';
		ocData2.SROC_Membership_Status__c = 'status2';
		update ocData2;
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch); 
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		System.assert(records[1].Is_Processing_Error__c == false);
		System.assert(records[1].Is_Processed__c == true);
		
		// Make sure there is only 1 owner for the boat
		list<Owner_Boat_Relationship__c> obrs = [select Id, Owner__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id];
		System.assert(obrs.size() == 1);
		
		// Make sure there is only 1 owner relationship
		obrs = [select Id, Owner__r.SROC_Member_ID__c, Owner__r.SROC_Membership_Status__c, Owner__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id];
		System.assert(obrs.size() == 1);
		
		// Make sure the first SROC data is used for the relationship
		System.assert(obrs[0].Owner__r.SROC_Member_ID__c == ocData.SROC_Member_ID__c);
		System.assert(obrs[0].Owner__r.SROC_Membership_Status__c == ocData.SROC_Membership_Status__c);
		
		BoatServices.disableTriggerProcessing = false;	
	}
	
	// Tests that an additional owner will not be created if an existing one already exists for a different boat matched by first, last, and email
	static testmethod void testDoesNotCreateAdditionalOwnerWithDifferntBoat() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Account owner = createOwner();
		Boat__c boat1 = createBoat();
		Boat__c boat = createBoat2();
		update boat;
		Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(owner, boat);
		SROC__c ocData = createSROC1();
		update ocData;
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		
		// Make sure there is only 1 owner for the boat
		list<Owner_Boat_Relationship__c> obrs = [select Id, Owner__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat1.Id];
		System.assert(obrs.size() == 1);
		
		// Make sure there is only 1 owner for the original boat
		obrs = [select Id, Owner__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id];
		System.assert(obrs.size() == 1);
		
		// Make sure there is only 1 owner
		list<Account> owners = [select Id from Account where FirstName=:ocData.First_Name__c and LastName=:ocData.Last_Name__c and PersonEmail=:ocData.Email__c];
		System.assert(owners.size() == 1);
		
		BoatServices.disableTriggerProcessing = false;	
	}
	
	// Tests that a multiple brand relationship is maintained
	static testmethod void testCreatesMultipleBrandRelationship() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Account owner = createOwner();
		Boat__c boat1 = createBoat();
		Boat__c boat = createBoat3();
		
		// Create a relationship to this BL boat
		Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(owner, boat);
		SROC__c ocData = createSROC1();
		update ocData;
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		
		// Make sure there is only 1 owner for the boat
		list<Owner_Boat_Relationship__c> obrs = [select Id, Owner__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat1.Id];
		System.assert(obrs.size() == 1);
		
		// Make sure there is only 1 owner for the BL boat
		obrs = [select Id, Owner__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id];
		System.assert(obrs.size() == 1);
		
		// Make sure there is only 1 owner
		list<Account> owners = [select Id, Brand_Relationships__c from Account where FirstName=:ocData.First_Name__c and LastName=:ocData.Last_Name__c and PersonEmail=:ocData.Email__c];
		System.assert(owners.size() == 1);
		
		owner = owners[0];
		
		// Make sure the brand relationship contains both brands
		System.assert(owner.Brand_Relationships__c != null);
		string[] brands = owner.Brand_Relationships__c.split(';', -2);
		System.assert(brands.size() == 2);
		
		BoatServices.disableTriggerProcessing = false;	
	}
	
	static testmethod void testErrorOnImportWithNoLastName() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Boat__c boat = createBoat();
		SROC__c ocData = createSROC1();
		ocData.Last_Name__c = null;
		update ocData;
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we captured an error
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == true);
		System.assert(records[0].Is_Processed__c == true);
		System.assert(records[0].Processing_Error_Message__c != null);
		BoatServices.disableTriggerProcessing = false;
	}
	
	// Tests that no records are processed when all Is_Processed__c flags are true
	static testmethod void testNoRecordsProcessedWhenAllProcessedFlagsTrue() {
		Boat__c boat = createBoat();
		SROC__c ocData = createSROC1();
		ocData.Is_Processed__c = true;
		update ocData;
		
		test.startTest();
		list<SROC__c> records = Database.query(SeaRayOwnersClubImportBatch.QUERY);
		test.stopTest();
		
		System.assert(records.size() == 0);
	}
	
	// Tests that no records are processed when all Is_Processing_Error__c flags are true
	static testmethod void testNoRecordsProcessedWhenAllProcessedErrorsFlagsTrue() {
		Boat__c boat = createBoat();
		SROC__c ocData = createSROC1();
		ocData.Is_Processing_Error__c = true;
		update ocData;
		
		test.startTest();
		list<SROC__c> records = Database.query(SeaRayOwnersClubImportBatch.QUERY);
		test.stopTest();
		
		System.assert(records.size() == 0);
	}
	
	// Tests that an additional owner will not be created if an existing one already exists matched by first, last
	static testmethod void testDoesNotCreateAdditionalOwner() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Account owner = createOwner();
		Boat__c boat = createBoat();
		Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(owner, boat);
		SROC__c ocData = createSROC1();
		update ocData;
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		
		// Make sure there is only 1 owner for the boat
		list<Owner_Boat_Relationship__c> owners = [select Id, Owner__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id];
		System.assert(owners.size() == 1);
		BoatServices.disableTriggerProcessing = false;	
	}
	
	
	
	// Tests that when there is an existing owner and no existing relationship is found on a boat, it will use the existing owner
	static testmethod void testMatchesExistingOwnerWithoutCase() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Account owner = createOwner();
		Boat__c boat = createBoat();
		owner.FirstName = TEST_OWNER_FIRST_NAME.toLowerCase();
		owner.LastName = TEST_OWNER_LAST_NAME.toLowerCase();
		owner.PersonMailingStreet = TEST_OWNER_STREET.toLowerCase();
		update owner;
		SROC__c ocData = createSROC1();
		update ocData;
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		
		// Make sure there is only 1 owner
		list<Account> owners = [select Id From Account where RecordTypeId=:OWNER_RECORD_TYPE_ID];
		System.assert(owners.size() == 1);
		
		// Make sure there is only 1 owner for the boat
		list<Owner_Boat_Relationship__c> ownerRels = [select Id, Owner__c From Owner_Boat_Relationship__c];
		System.assert(ownerRels.size() == 1);
		BoatServices.disableTriggerProcessing = false;	
	}
	
	// Tests that when there is an existing owner and no existing relationship is found on a boat, it will use the existing owner
	static testmethod void testDoesNotMatchExistingOwnerWithoutCaseWithDifferentFirstname() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Account owner = createOwner();
		Boat__c boat = createBoat();
		owner.FirstName = (TEST_OWNER_FIRST_NAME + '_diff').toLowerCase();
		owner.LastName = TEST_OWNER_LAST_NAME.toLowerCase();
		owner.PersonMailingStreet = TEST_OWNER_STREET.toLowerCase();
		update owner;
		SROC__c ocData = createSROC1();
		update ocData;
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		
		// Make sure there are 2 owners
		list<Account> owners = [select Id From Account where RecordTypeId=:OWNER_RECORD_TYPE_ID];
		System.assert(owners.size() == 2);
		
		// Make sure there is only 1 owner for the boat
		list<Owner_Boat_Relationship__c> ownerRels = [select Id, Owner__c From Owner_Boat_Relationship__c];
		System.assert(ownerRels.size() == 1);
		BoatServices.disableTriggerProcessing = false;	
	}
	
	// Tests that an existing active owner relationship will be set to inactive with a new active owner relationship
	static testmethod void testOldOwnerRelationshipSetToInactive() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Account owner = createOwner();
		owner.LastName = owner.LastName + '-old';
		update owner;
		
		Boat__c boat = createBoat();
		Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(owner, boat);
		SROC__c ocData = createSROC1();
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		
		// Make sure there are 2 owners for the boat
		list<Owner_Boat_Relationship__c> owners = [select Id, Owner__c, Status__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id];
		System.assert(owners.size() == 2);
		
		// Make sure the old owner is inactive
		boolean foundInactive = false;
		for (Owner_Boat_Relationship__c ownerBoat : owners) {
			if (ownerBoat.Owner__c == owner.Id && ownerBoat.Status__c == 'Inactive') {
				foundInactive = true;
				break;
			}
		}
		System.assert(foundInactive == true);
		BoatServices.disableTriggerProcessing = false;		
	}
	
	// Tests that an existing active owner relationship will not be set to inactive if the PurchaseDate > SROC Purchase Date and SROC is not Owned
	static testmethod void testOldOwnerRelationshipNotSetToInactiveWhenMoreRecent() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Account owner = createOwner();
		owner.LastName = owner.LastName + '-old';
		update owner;
		
		Boat__c boat = createBoat();
		Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(owner, boat);
		
		// Update the purchase date to more recent than the SROC
		obr.Purchase_Date__c = TEST_OWNER_MORE_RECENT_PURCHASE_DATE;
		update obr;
		SROC__c ocData = createSROC1();
		ocData.SROC_Ownership_Status__c = 'RESOLD';
		update ocData;
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		
		// Make sure there are 2 owners for the boat
		list<Owner_Boat_Relationship__c> owners = [select Id, Owner__c, Status__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id order by CreatedDate asc];
		System.assert(owners.size() == 2);
		
		// Make sure the old owner is active and the SROC is inactive
		system.assertEquals(owners[0].Status__c, 'Active', 'The old owner should be active');
		system.assertEquals(owners[1].Status__c, 'Inactive', 'The new owner should be inactive');
		
		BoatServices.disableTriggerProcessing = false;		
	}
	
	// Tests that an existing active owner relationship will not be set to inactive if the PurchaseDate > SROC Purchase Date and SROC is not Owned
	static testmethod void testOldOwnerRelationshipNotSetToInactiveWhenMoreRecentAndNoPuchaseDate() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Account owner = createOwner();
		owner.LastName = owner.LastName + '-old';
		update owner;
		
		Boat__c boat = createBoat();
		Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(owner, boat);
		
		// Update the purchase date to more recent than the SROC
		obr.Purchase_Date__c = TEST_OWNER_MORE_RECENT_PURCHASE_DATE;
		update obr;
		
		// update the SROC purchase date to null. This will make the logic use Join Date instead
		SROC__c ocData = createSROC1();
		ocData.SROC_Ownership_Status__c = 'RESOLD';
		ocData.SROC_Purchase_Date__c = null;
		update ocData;
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		
		// Make sure there are 2 owners for the boat
		list<Owner_Boat_Relationship__c> owners = [select Id, Owner__c, Status__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id order by CreatedDate asc];
		System.assert(owners.size() == 2);
		
		// Make sure the old owner is active and the SROC is inactive
		system.assertEquals(owners[0].Status__c, 'Active', 'The old owner should be active');
		system.assertEquals(owners[1].Status__c, 'Inactive', 'The new owner should be inactive');
		
		BoatServices.disableTriggerProcessing = false;		
	}
	
	// Tests that an existing active owner relationship will be set to inactive if the PurchaseDate > SROC Purchase Date but SROC is Owned
	static testmethod void testOldOwnerRelationshipSetToInActiveWhenMoreRecentIsOwned() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Account owner = createOwner();
		owner.LastName = owner.LastName + '-old';
		update owner;
		
		Boat__c boat = createBoat();
		Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(owner, boat);
		
		// Update the purchase date to more recent than the SROC
		obr.Purchase_Date__c = TEST_OWNER_MORE_RECENT_PURCHASE_DATE;
		update obr;
		SROC__c ocData = createSROC1();
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		
		// Make sure there are 2 owners for the boat
		list<Owner_Boat_Relationship__c> owners = [select Id, Owner__c, Status__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id order by CreatedDate asc];
		System.assert(owners.size() == 2);
		
		// Make sure the old owner is active and the SROC is inactive
		system.assertEquals(owners[0].Status__c, 'Inactive', 'The old owner should be inactive');
		system.assertEquals(owners[1].Status__c, 'Active', 'The new owner should be active');
		
		BoatServices.disableTriggerProcessing = false;		
	}
	
	// Tests that an existing owner without an street will still match
	static testmethod void testExistingOwnerWillMatchWithoutStreet() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Account owner = createOwner();
		update owner;
		
		Boat__c boat = createBoat();
		Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(owner, boat);
		SROC__c ocData = createSROC1();
		ocData.Address__c = '';
		update ocData;
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		
		// Make sure there are 1 owners for the boat
		list<Owner_Boat_Relationship__c> owners = [select Id, Owner__c, Status__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id];
		System.assert(owners.size() == 1);
		
		// Make sure the owner is active
		System.assert(owners[0].Status__c == 'Active');
		BoatServices.disableTriggerProcessing = false;		
	}
	
	// Tests that an existing owner will match without regard to case
	static testmethod void testExistingOwnerWillMatchWithoutCase() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Account owner = createOwner();
		owner.FirstName = TEST_OWNER_FIRST_NAME.toLowerCase();
		owner.LastName = TEST_OWNER_LAST_NAME.toLowerCase();
		update owner;
		
		Boat__c boat = createBoat();
		Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(owner, boat);
		SROC__c ocData = createSROC1();
		update ocData;
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		
		// Make sure there are 1 owners for the boat
		list<Owner_Boat_Relationship__c> owners = [select Id, Owner__c, Status__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id];
		System.assert(owners.size() == 1);
		
		// Make sure the owner is active
		System.assert(owners[0].Status__c == 'Active');
		BoatServices.disableTriggerProcessing = false;		
	}
	
	// Tests that the results will be ordered by join date
	static testmethod void testOrderedByJoinDate() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
		Account dealer = createDealer();
		Boat__c boat = createBoat();
		SROC__c ocData = createSROC1();
		update ocData;
		
		// Give the next SROC a join date before
		SROC__c ocData2 = createSROC1();
		ocData2.First_Name__c = 'test2';
		ocData2.Last_Name__c = 'test2';
		ocData2.SROC_Join_Date__c = Date.newInstance(2015, 2, 8);
		update ocData2;
		
		test.startTest();
		SeaRayOwnersClubImportBatch batch = new SeaRayOwnersClubImportBatch();
		Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		// Make sure we were successful
		list<SROC__c> records = [select Id, Is_Processed__c, Is_Processing_Error__c, Processing_Error_Message__c from SROC__c];
		System.assert(records[0].Is_Processing_Error__c == false);
		System.assert(records[0].Is_Processed__c == true);
		
		// Make sure there are 2 owners for the boat
		list<Owner_Boat_Relationship__c> owners = [select Id, Owner__c, Status__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id];
		System.assert(owners[0].Status__c == 'Inactive');
		System.assert(owners[1].Status__c == 'Active');
		BoatServices.disableTriggerProcessing = false;		
	}
	
	private static void createConfiguration() {
		Configuration__c config = new Configuration__c(Name='BoatOwner',RecordId__c=getIntegrationUserId());
		insert config;
	}
	
	
	private static SROC__c createSROC1() {
		SROC__c d = new SROC__c();
		d.Address__c = TEST_OWNER_STREET;
		d.HIN__c = TEST_HIN;
		d.Boat_Model__c = TEST_MODEL;	
		d.Boat_Model_Year__c = TEST_MODEL_YEAR;
		d.Brand__c = TEST_BRAND;
		d.City__c = TEST_OWNER_CITY;
		d.State__c = TEST_OWNER_STATE;
		d.Country__c = 'USA';
		d.Country_Name__c = 'UNITED STATES';
		d.First_Name__c = TEST_OWNER_FIRST_NAME;
		d.Last_Name__c = TEST_OWNER_LAST_NAME;
		d.Middle_Initial__c = TEST_OWNER_MIDDLE_INITIAL;
		d.Name_Suffix__c = TEST_OWNER_SUFFIX;
		d.Email__c = TEST_OWNER_EMAIL;
		
		d.Opt_Out_of_Sea_Ray_Living__c = true;
		d.SROC_Enrollment_Level__c = '0-Basic';
		d.SROC_Points_Total__c = 100;
		d.SROC_Sales_Total__c = 0.01;
		d.SROC_Join_Date__c = TEST_OWNER_JOIN_DATE;
		d.SROC_Membership_Status__c = 'ACTIVE';
		d.SROC_Member_ID__c = '6284851';
		d.SROC_Purchased_Dealer_Name__c = 'MarineMax TX-Seabrook';
		d.SROC_Purchased_Dealer_Number__c = TEST_DEALER_NUMBER_SROC;
		d.NCOA_Address_Status__c = 'CURRENT';
		d.NCOA_Status__c = 'UNKNOWN';
		d.NCOA_Validation_Date__c = Date.newInstance(2014, 11, 20);
		d.Customer_Wants_Mailings__c = 'Y';
		d.Email_Opt_In__c = 'Yes';
		d.Work_Phone__c = '212-692-6506';
		d.Birth_Date__c = Date.newInstance(1950, 10, 4);
		d.New_or_Used__c = 'Used';
		d.Comments__c = 'Previous Email: jonathan@galvestonjustice.com';
		d.SROC_Enrollment_Status__c = 'ENROLLED';
		d.Co_Owner__c = 'Carolyn Holt';
		d.SROC_Welcome_Kit_Status__c = 'ORDERED';
		
		d.Zip_Code__c = TEST_OWNER_ZIP;
		d.SROC_Purchase_Date__c = TEST_OWNER_PURCHASE_DATE;
		d.SROC_Ownership_Status__c = 'OWNED';
		d.Is_Processed__c = false;
		
		insert d;
		
		return d;
	}
	
	private static SROC__c createSROC2() {
		SROC__c d = new SROC__c();
		d.Address__c = TEST_OWNER_STREET;
		d.HIN__c = TEST_HIN2;
		d.Boat_Model__c = TEST_MODEL;	
		d.Boat_Model_Year__c = TEST_MODEL_YEAR;
		d.Brand__c = TEST_BRAND;
		d.City__c = TEST_OWNER_CITY;
		d.State__c = TEST_OWNER_STATE;
		d.Country__c = 'USA';
		d.Country_Name__c = 'UNITED STATES';
		d.First_Name__c = TEST_OWNER_FIRST_NAME;
		d.Last_Name__c = TEST_OWNER_LAST_NAME;
		d.Middle_Initial__c = TEST_OWNER_MIDDLE_INITIAL;
		d.Name_Suffix__c = TEST_OWNER_SUFFIX;
		
		d.Opt_Out_of_Sea_Ray_Living__c = true;
		d.SROC_Enrollment_Level__c = '0-Basic2';
		d.SROC_Points_Total__c = 200;
		d.SROC_Sales_Total__c = 0.02;
		d.SROC_Join_Date__c = TEST_OWNER_JOIN_DATE2;
		d.SROC_Membership_Status__c = 'INACTIVE';
		d.SROC_Member_ID__c = '62848512';
		d.SROC_Purchased_Dealer_Name__c = 'MarineMax TX-Seabrook2';
		d.SROC_Purchased_Dealer_Number__c = TEST_DEALER_NUMBER_SROC;
		d.NCOA_Address_Status__c = 'CURRENT2';
		d.NCOA_Status__c = 'UNKNOWN2';
		d.NCOA_Validation_Date__c = Date.newInstance(2014, 11, 2);
		d.Customer_Wants_Mailings__c = 'N';
		d.Email_Opt_In__c = 'No';
		d.Work_Phone__c = '212-692-6502';
		d.Birth_Date__c = Date.newInstance(1950, 10, 2);
		d.New_or_Used__c = 'Used';
		d.Comments__c = 'Previous Email: jonathan@2galvestonjustice.com';
		d.SROC_Enrollment_Status__c = 'ENROLLED2';
		d.Co_Owner__c = 'Carolyn Holt2';
		d.SROC_Welcome_Kit_Status__c = 'ORDERED2';
		
		d.Zip_Code__c = TEST_OWNER_ZIP;
		d.SROC_Purchase_Date__c = TEST_OWNER_PURCHASE_DATE;
		d.SROC_Ownership_Status__c = 'OWNED';
		d.Is_Processed__c = false;
		
		insert d;
		
		return d;
	}
	
	private static Account createDealer() {
		Account dealer = new Account();
		
		dealer.recordTypeId = DEALER_RECORD_TYPE;
		dealer.Name = 'MarineMax TX-Seabrook';
		dealer.Dealer_Number__c = TEST_DEALER_NUMBER;
		dealer.ShippingStreet = '112 E. HIGH STREET';
		dealer.ShippingCity = 'HENNEPIN';
		dealer.ShippingState = 'IL';
		dealer.ShippingPostalCode = '61327';
		dealer.ShippingCountry = 'US';
		dealer.Country_ISO_Code__c = 'US';
		
		insert dealer;
		
		return dealer;
	}
	
	private static Account createOwner() {
		Account owner = new Account();
		
		owner.RecordTypeId = OWNER_RECORD_TYPE_ID;
        owner.LastName = TEST_OWNER_LAST_NAME;
        owner.FirstName = TEST_OWNER_FIRST_NAME;
        owner.PersonMailingStreet  = TEST_OWNER_STREET;
        owner.PersonMailingState = TEST_OWNER_STATE;
        owner.PersonMailingCity = TEST_OWNER_CITY;
        owner.PersonMailingCountry = 'US';
        owner.PersonMailingPostalCode = TEST_OWNER_ZIP;
        owner.OwnerId = Configuration__c.getInstance('BoatOwner').RecordId__c;
        owner.HIN_Number__c = TEST_HIN;
        owner.Home_Address_ISO_Code__c = 'US';
        owner.Brand_Relationships__c = 'SR';
        owner.PersonEmail = TEST_OWNER_EMAIL;
        owner.Brand__c = 'SR';
		
		insert owner;
		
		return owner;
	}
	
	private static Boat__c createBoat() {
		Boat__c boat = new Boat__c();
		
		boat.Name = TEST_HIN;
		boat.External_HIN_Number__c = TEST_HIN;
		boat.Hin_migration__c = TEST_HIN;
		boat.Model_Year__c = TEST_MODEL_YEAR;
		boat.Boat_Model__c = TEST_MODEL;
		boat.Brand_del__c = TEST_BRAND;
		
		boat.DealerNumLoc__c = TEST_DEALER_NUMBER;
		string dealerId = TEST_DEALER_NUMBER;
		Account[] dealers = [select Id from Account where Dealer_Number__c=:dealerId];
		if (dealers.size() > 0) {
			system.debug('Found matching dealer for ' + dealerId);
			boat.Dealer__c = dealers[0].Id;
		}
		else {
			system.debug('Did not find match for dealer ' + dealerId);
		}
		
		insert boat;
		
		return boat;
	}
	
	private static Boat__c createBoat2() {
		Boat__c boat = new Boat__c();
		
		boat.Name = TEST_HIN2;
		boat.External_HIN_Number__c = TEST_HIN2;
		boat.Hin_migration__c = TEST_HIN2;
		boat.Model_Year__c = TEST_MODEL_YEAR;
		boat.Boat_Model__c = TEST_MODEL;
		boat.Brand_del__c = TEST_BRAND;
		
		boat.DealerNumLoc__c = TEST_DEALER_NUMBER;
		string dealerId = TEST_DEALER_NUMBER;
		Account[] dealers = [select Id from Account where Dealer_Number__c=:dealerId];
		if (dealers.size() > 0) {
			system.debug('Found matching dealer for ' + dealerId);
			boat.Dealer__c = dealers[0].Id;
		}
		else {
			system.debug('Did not find match for dealer ' + dealerId);
		}
		
		insert boat;
		
		return boat;
	}
	
	private static Boat__c createBoat3() {
		Boat__c boat = new Boat__c();
		
		boat.Name = TEST_HIN3;
		boat.External_HIN_Number__c = TEST_HIN3;
		boat.Hin_migration__c = TEST_HIN3;
		boat.Model_Year__c = '2015';
		boat.Boat_Model__c = '190DB';
		boat.Brand_del__c = 'BL';
		
		boat.DealerNumLoc__c = TEST_DEALER_NUMBER;
		string dealerId = TEST_DEALER_NUMBER;
		Account[] dealers = [select Id from Account where Dealer_Number__c=:dealerId];
		if (dealers.size() > 0) {
			system.debug('Found matching dealer for ' + dealerId);
			boat.Dealer__c = dealers[0].Id;
		}
		else {
			system.debug('Did not find match for dealer ' + dealerId);
		}
		
		insert boat;
		
		return boat;
	}
	
	private static Owner_Boat_Relationship__c createOwnerBoatRelationship(Account owner, Boat__c boat) {
		Owner_Boat_Relationship__c  boatOwnerShip = new Owner_Boat_Relationship__c();
        boatOwnerShip.HIN_Number__c = boat.Id;
        boatOwnerShip.Owner__c = owner.Id;
        boatOwnerShip.Status__c = 'Active';
        boatOwnerShip.Purchase_Date__c = TEST_OWNER_PURCHASE_DATE;          
        
        insert boatOwnerShip;  
        
        return boatOwnerShip;	
	}
}