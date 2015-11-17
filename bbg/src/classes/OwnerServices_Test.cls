/*
* Tests the OwnerServices class
*
* @author Mike Regan
*/
@isTest
private class OwnerServices_Test {
	private static Id DEALER_RECORD_TYPE = [Select Id from RecordType where SobjectType='Account' and Name='Dealer' limit 1].Id;
	static final Decimal TEST_LONGITUDE_FOR_DEALER_1 = -121.894;
    static final Decimal TEST_LATITUDE_FOR_DEALER_1 = 37.4352;
     static final string TEST_DNS_FORM_NAME = 'TestForm';
     
	@istest
	static void writeNewOwnerAccountsToPardotObjectChangeLog_HandlesNullList() {
		Test.startTest();
		OwnerServices.writeNewOwnerAccountsToPardotObjectChangeLog(null);
		Test.stopTest();	
	}
	
	@istest
	static void writeNewOwnerAccountsToPardotObjectChangeLog_LogsAreCreatedForOwnersWithAnEmailThatHasBeenVerified() {
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, false);
		owners[0].PersonEmail = 'test@test.com';
		owners[0].Email_Verified__pc = 'Yes';
		
		// Disable the triggers and pardot log on the insert
		AccountServices.disableTriggerProcessing = true;
		OwnerServices.disablePardotLogCheck = true;
		insert owners;
		OwnerServices.disablePardotLogCheck = false;
		
		owners = [select Id, PersonEmail, Email_Verified__pc, RecordTypeId, PersonContactId from Account where Id=:owners[0].Id];
		
		Test.startTest();
		OwnerServices.writeNewOwnerAccountsToPardotObjectChangeLog(owners);
		Test.stopTest();
		
		list<pi__ObjectChangeLog__c> changeLogs = [select Id, bbg_ObjectParentFId__c, pi__ObjectState__c, pi__ObjectType__c, pi__ObjectEmail__c, pi__ObjectFid__c from pi__ObjectChangeLog__c];
		system.assertEquals(1, changeLogs.size());
		system.assertEquals(owners[0].Id, changeLogs[0].bbg_ObjectParentFId__c);
		system.assertEquals(1, changeLogs[0].pi__ObjectState__c);
		system.assertEquals(owners[0].PersonEmail, changeLogs[0].pi__ObjectEmail__c);
		system.assertEquals(owners[0].PersonContactId, changeLogs[0].pi__ObjectFid__c);
		system.assertEquals(1, changeLogs[0].pi__ObjectType__c);	
	}
	
	@istest
	static void writeNewOwnerAccountsToPardotObjectChangeLog_LogsAreNotCreatedForOwnersWithAnUnverifiedEmail() {
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, false);
		owners[0].PersonEmail = 'test@test.com';
		
		// Disable the triggers and pardot log on the insert
		AccountServices.disableTriggerProcessing = true;
		OwnerServices.disablePardotLogCheck = true;
		insert owners;
		OwnerServices.disablePardotLogCheck = false;
		
		owners = [select Id, PersonEmail, Email_Verified__pc, RecordTypeId, PersonContactId from Account where Id=:owners[0].Id];
		
		Test.startTest();
		OwnerServices.writeNewOwnerAccountsToPardotObjectChangeLog(owners);
		Test.stopTest();
		
		list<pi__ObjectChangeLog__c> changeLogs = [select Id, bbg_ObjectParentFId__c, pi__ObjectState__c, pi__ObjectType__c, pi__ObjectEmail__c, pi__ObjectFid__c from pi__ObjectChangeLog__c];
		system.assertEquals(0, changeLogs.size());
	}
	
	@istest
	static void writeUpdatedOwnerAccountsToPardotObjectChangeLog_HandlesNullList() {
		Test.startTest();
		OwnerServices.writeUpdatedOwnerAccountsToPardotObjectChangeLog(null);
		Test.stopTest();	
	}
	
	@istest
	static void writeUpdatedOwnerAccountsToPardotObjectChangeLog_LogsAreCreatedForOwnersNotAlreadyInPardotWithAnEmailThatHasBeenVerified() {
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, false);
		owners[0].PersonEmail = 'test@test.com';
		owners[0].Email_Verified__pc = 'Yes';
		
		// Disable the triggers and pardot log on the insert
		AccountServices.disableTriggerProcessing = true;
		OwnerServices.disablePardotLogCheck = true;
		insert owners;
		OwnerServices.disablePardotLogCheck = false;
		
		owners = [select Id, PersonEmail, Email_Verified__pc, pi__url__pc, RecordTypeId, PersonContactId from Account where Id=:owners[0].Id];
		
		Test.startTest();
		OwnerServices.writeUpdatedOwnerAccountsToPardotObjectChangeLog(owners);
		Test.stopTest();
		
		list<pi__ObjectChangeLog__c> changeLogs = [select Id, bbg_ObjectParentFId__c, pi__ObjectState__c, pi__ObjectType__c, pi__ObjectEmail__c, pi__ObjectFid__c from pi__ObjectChangeLog__c];
		system.assertEquals(1, changeLogs.size());
		system.assertEquals(owners[0].Id, changeLogs[0].bbg_ObjectParentFId__c);
		system.assertEquals(1, changeLogs[0].pi__ObjectState__c);
		system.assertEquals(owners[0].PersonEmail, changeLogs[0].pi__ObjectEmail__c);
		system.assertEquals(owners[0].PersonContactId, changeLogs[0].pi__ObjectFid__c);
		system.assertEquals(1, changeLogs[0].pi__ObjectType__c);	
	}
	
	@istest
	static void writeUpdatedOwnerAccountsToPardotObjectChangeLog_LogsAreNotCreatedForOwnersAlreadyInPardot() {
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, false);
		owners[0].PersonEmail = 'test@test.com';
		owners[0].Email_Verified__pc = 'Yes';
		owners[0].pi__url__pc = 'www.pardot.com';
		
		// Disable the triggers and pardot log on the insert
		AccountServices.disableTriggerProcessing = true;
		OwnerServices.disablePardotLogCheck = true;
		insert owners;
		OwnerServices.disablePardotLogCheck = false;
		
		owners = [select Id, PersonEmail, Email_Verified__pc, pi__url__pc, RecordTypeId, PersonContactId from Account where Id=:owners[0].Id];
		
		Test.startTest();
		OwnerServices.writeUpdatedOwnerAccountsToPardotObjectChangeLog(owners);
		Test.stopTest();
		
		list<pi__ObjectChangeLog__c> changeLogs = [select Id, bbg_ObjectParentFId__c, pi__ObjectState__c, pi__ObjectType__c, pi__ObjectEmail__c, pi__ObjectFid__c from pi__ObjectChangeLog__c];
		system.assertEquals(0, changeLogs.size());
	}
	
	@istest
	static void writeUpdatedOwnerAccountsToPardotObjectChangeLog_LogsAreNotCreatedForOwnersWithUnverifiedEmail() {
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, false);
		owners[0].PersonEmail = 'test@test.com';
		owners[0].Email_Verified__pc = 'No';
		
		// Disable the triggers and pardot log on the insert
		AccountServices.disableTriggerProcessing = true;
		OwnerServices.disablePardotLogCheck = true;
		insert owners;
		OwnerServices.disablePardotLogCheck = false;
		
		owners = [select Id, PersonEmail, Email_Verified__pc, pi__url__pc, RecordTypeId, PersonContactId from Account where Id=:owners[0].Id];
		
		Test.startTest();
		OwnerServices.writeUpdatedOwnerAccountsToPardotObjectChangeLog(owners);
		Test.stopTest();
		
		list<pi__ObjectChangeLog__c> changeLogs = [select Id, bbg_ObjectParentFId__c, pi__ObjectState__c, pi__ObjectType__c, pi__ObjectEmail__c, pi__ObjectFid__c from pi__ObjectChangeLog__c];
		system.assertEquals(0, changeLogs.size());
	}
	
	@istest
	static void writeUpdatedOwnerAccountsToPardotObjectChangeLog_LogsAreNotCreatedForOwnersWithNoEmail() {
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, false);
		owners[0].PersonEmail = '';
		owners[0].Email_Verified__pc = 'Yes';
		
		// Disable the triggers and pardot log on the insert
		AccountServices.disableTriggerProcessing = true;
		OwnerServices.disablePardotLogCheck = true;
		insert owners;
		OwnerServices.disablePardotLogCheck = false;
		
		owners = [select Id, PersonEmail, Email_Verified__pc, pi__url__pc, RecordTypeId, PersonContactId from Account where Id=:owners[0].Id];
		
		Test.startTest();
		OwnerServices.writeUpdatedOwnerAccountsToPardotObjectChangeLog(owners);
		Test.stopTest();
		
		list<pi__ObjectChangeLog__c> changeLogs = [select Id, bbg_ObjectParentFId__c, pi__ObjectState__c, pi__ObjectType__c, pi__ObjectEmail__c, pi__ObjectFid__c from pi__ObjectChangeLog__c];
		system.assertEquals(0, changeLogs.size());
	}

	@istest
	static void writeDeletedOwnerAccountsToPardotObjectChangeLog_LogsAreCreatedForOwnersWithAnEmailThatExistsInPardot() {
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, false);
		owners[0].PersonEmail = 'test@test.com';
		owners[0].pi__url__pc = 'www.pardot.com';
		
		// Disable the triggers and pardot log on the insert
		AccountServices.disableTriggerProcessing = true;
		OwnerServices.disablePardotLogCheck = true;
		insert owners;
		OwnerServices.disablePardotLogCheck = false;
		
		owners = [select Id, PersonEmail, Email_Verified__pc, pi__url__pc, RecordTypeId, PersonContactId from Account where Id=:owners[0].Id];
		
		Test.startTest();
		OwnerServices.writeDeletedOwnerAccountsToPardotObjectChangeLog(owners);
		Test.stopTest();
		
		list<pi__ObjectChangeLog__c> changeLogs = [select Id, bbg_ObjectParentFId__c, pi__ObjectState__c, pi__ObjectType__c, pi__ObjectEmail__c, pi__ObjectFid__c from pi__ObjectChangeLog__c];
		system.assertEquals(1, changeLogs.size());
		system.assertEquals(owners[0].Id, changeLogs[0].bbg_ObjectParentFId__c);
		system.assertEquals(2, changeLogs[0].pi__ObjectState__c);
		system.assertEquals(owners[0].PersonEmail, changeLogs[0].pi__ObjectEmail__c);
		system.assertEquals(owners[0].PersonContactId, changeLogs[0].pi__ObjectFid__c);
		system.assertEquals(1, changeLogs[0].pi__ObjectType__c);	
	}
	
	@istest
	static void writeDeletedOwnerAccountsToPardotObjectChangeLog_LogsAreNotCreatedForOwnersWithoutAnEmail() {
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, false);
		owners[0].PersonEmail = '';
		owners[0].pi__url__pc = 'www.pardot.com';
		
		// Disable the triggers and pardot log on the insert
		AccountServices.disableTriggerProcessing = true;
		OwnerServices.disablePardotLogCheck = true;
		insert owners;
		OwnerServices.disablePardotLogCheck = false;
		
		owners = [select Id, PersonEmail, Email_Verified__pc, pi__url__pc, RecordTypeId, PersonContactId from Account where Id=:owners[0].Id];
		
		Test.startTest();
		OwnerServices.writeDeletedOwnerAccountsToPardotObjectChangeLog(owners);
		Test.stopTest();
		
		list<pi__ObjectChangeLog__c> changeLogs = [select Id, bbg_ObjectParentFId__c, pi__ObjectState__c, pi__ObjectType__c, pi__ObjectEmail__c, pi__ObjectFid__c from pi__ObjectChangeLog__c];
		system.assertEquals(0, changeLogs.size());
	}
	
	@istest
	static void writeDeletedOwnerAccountsToPardotObjectChangeLog_LogsAreNotCreatedForOwnersThatDoNotExistInPardot() {
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, false);
		owners[0].PersonEmail = 'test@test.com';
		owners[0].pi__url__pc = '';
		
		// Disable the triggers and pardot log on the insert
		AccountServices.disableTriggerProcessing = true;
		OwnerServices.disablePardotLogCheck = true;
		insert owners;
		OwnerServices.disablePardotLogCheck = false;
		
		owners = [select Id, PersonEmail, Email_Verified__pc, pi__url__pc, RecordTypeId, PersonContactId from Account where Id=:owners[0].Id];
		
		Test.startTest();
		OwnerServices.writeDeletedOwnerAccountsToPardotObjectChangeLog(owners);
		Test.stopTest();
		
		list<pi__ObjectChangeLog__c> changeLogs = [select Id, bbg_ObjectParentFId__c, pi__ObjectState__c, pi__ObjectType__c, pi__ObjectEmail__c, pi__ObjectFid__c from pi__ObjectChangeLog__c];
		system.assertEquals(0, changeLogs.size());
	}
	
	@istest
	static void writeDeletedOwnerAccountsToPardotObjectChangeLog_HandlesNullList() {
		Test.startTest();
		OwnerServices.writeDeletedOwnerAccountsToPardotObjectChangeLog(null);
		Test.stopTest();	
	}
	
	@istest
	static void writeUnDeletedOwnerAccountsToPardotObjectChangeLog_HandlesNullList() {
		Test.startTest();
		OwnerServices.writeUnDeletedOwnerAccountsToPardotObjectChangeLog(null);
		Test.stopTest();	
	}
	
	@istest
	static void writeUnDeletedOwnerAccountsToPardotObjectChangeLog_LogsAreCreatedForOwnersWithAnEmailThatIsVerified() {
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, false);
		owners[0].PersonEmail = 'test@test.com';
		owners[0].Email_Verified__pc = 'Yes';
		
		// Disable the triggers and pardot log on the insert
		AccountServices.disableTriggerProcessing = true;
		OwnerServices.disablePardotLogCheck = true;
		insert owners;
		OwnerServices.disablePardotLogCheck = false;
		
		owners = [select Id, PersonEmail, Email_Verified__pc, pi__url__pc, RecordTypeId, PersonContactId from Account where Id=:owners[0].Id];
		
		Test.startTest();
		OwnerServices.writeUnDeletedOwnerAccountsToPardotObjectChangeLog(owners);
		Test.stopTest();
		
		list<pi__ObjectChangeLog__c> changeLogs = [select Id, bbg_ObjectParentFId__c, pi__ObjectState__c, pi__ObjectType__c, pi__ObjectEmail__c, pi__ObjectFid__c from pi__ObjectChangeLog__c];
		system.assertEquals(1, changeLogs.size());
		system.assertEquals(owners[0].Id, changeLogs[0].bbg_ObjectParentFId__c);
		system.assertEquals(3, changeLogs[0].pi__ObjectState__c);
		system.assertEquals(owners[0].PersonEmail, changeLogs[0].pi__ObjectEmail__c);
		system.assertEquals(owners[0].PersonContactId, changeLogs[0].pi__ObjectFid__c);
		system.assertEquals(1, changeLogs[0].pi__ObjectType__c);	
	}
	
	@istest
	static void writeUnDeletedOwnerAccountsToPardotObjectChangeLog_LogsAreNotCreatedForOwnersWithoutAnEmail() {
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, false);
		owners[0].PersonEmail = '';
		owners[0].Email_Verified__pc = 'Yes';
		
		// Disable the triggers and pardot log on the insert
		AccountServices.disableTriggerProcessing = true;
		OwnerServices.disablePardotLogCheck = true;
		insert owners;
		OwnerServices.disablePardotLogCheck = false;
		
		owners = [select Id, PersonEmail, Email_Verified__pc, pi__url__pc, RecordTypeId, PersonContactId from Account where Id=:owners[0].Id];
		
		Test.startTest();
		OwnerServices.writeUnDeletedOwnerAccountsToPardotObjectChangeLog(owners);
		Test.stopTest();
		
		list<pi__ObjectChangeLog__c> changeLogs = [select Id, bbg_ObjectParentFId__c, pi__ObjectState__c, pi__ObjectType__c, pi__ObjectEmail__c, pi__ObjectFid__c from pi__ObjectChangeLog__c];
		system.assertEquals(0, changeLogs.size());
	}
	
	@istest
	static void writeUnDeletedOwnerAccountsToPardotObjectChangeLog_LogsAreNotCreatedForOwnersWithoutAVerifiedEmail() {
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, false);
		owners[0].PersonEmail = 'test@test.com';
		owners[0].Email_Verified__pc = 'No';
		
		// Disable the triggers and pardot log on the insert
		AccountServices.disableTriggerProcessing = true;
		OwnerServices.disablePardotLogCheck = true;
		insert owners;
		OwnerServices.disablePardotLogCheck = false;
		
		owners = [select Id, PersonEmail, Email_Verified__pc, pi__url__pc, RecordTypeId, PersonContactId from Account where Id=:owners[0].Id];
		
		Test.startTest();
		OwnerServices.writeUnDeletedOwnerAccountsToPardotObjectChangeLog(owners);
		Test.stopTest();
		
		list<pi__ObjectChangeLog__c> changeLogs = [select Id, bbg_ObjectParentFId__c, pi__ObjectState__c, pi__ObjectType__c, pi__ObjectEmail__c, pi__ObjectFid__c from pi__ObjectChangeLog__c];
		system.assertEquals(0, changeLogs.size());
	}
	
	static testMethod void assignDealersToOwnersIfNotGeocodingButAssignmentDataHasChanged_ownersNotAssignedIfNothingChanges() {
    	list<Account> oldOwners= setupOwnersDealersAndRoutingRules();
    	oldOwners = getOwner(oldOwners[0].Id);
    	
    	list<Account> newOwners = getOwner(oldOwners[0].Id);
    	map<Id, Account> oldOwnersMap = new map<Id, Account>();
    	map<Id, Account> newOwnersMap = new map<Id, Account>();
    	
    	oldOwnersMap.put(oldOwners[0].Id, oldOwners[0]);
    	newOwnersMap.put(newOwners[0].Id, newOwners[0]);
    	
    	Test.startTest();
    	OwnerServices.assignDealersToOwnersIfNotGeocodingButAssignmentDataOrScoreHasChanged(oldOwnersMap, newOwnersMap);
    	Test.stopTest();
    	
    	list<Assigned_Dealer__c> assignedDealers = [select Id from Assigned_Dealer__c where Owner__c=:newOwners[0].Id];
    	system.assertEquals(0, assignedDealers.size());
    }
    
    static testMethod void assignDealersToOwnersIfNotGeocodingButAssignmentDataHasChanged_ownersAssignedIfProductCategoryChanges() {
    	list<Account> oldOwners = setupOwnersDealersAndRoutingRules();

		disableTriggers();
    	list<Account> newOwners = getOwner(oldOwners[0].Id);
    	newOwners[0].Boat_Category_of_Interest__pc = 'Yacht';
    	update newOwners;
    	
    	map<Id, Account> oldOwnersMap = new map<Id, Account>();
    	map<Id, Account> newOwnersMap = new map<Id, Account>();
    	oldOwnersMap.put(oldOwners[0].Id, oldOwners[0]);
    	newOwnersMap.put(newOwners[0].Id, newOwners[0]);
    	
    	Test.startTest();
    	OwnerServices.assignDealersToOwnersIfNotGeocodingButAssignmentDataOrScoreHasChanged(oldOwnersMap, newOwnersMap);
    	Test.stopTest();
    	
    	list<Assigned_Dealer__c> assignedDealers = [select Id from Assigned_Dealer__c where Owner__c=:newOwners[0].Id];
    	system.assertEquals(1, assignedDealers.size());
    }
    
    static testMethod void assignDealersToOwnersIfNotGeocodingButAssignmentDataHasChanged_ownersNotAssignedIfGeocoding() {
    	list<Account> oldOwners = setupOwnersDealersAndRoutingRules();

    	list<Account> newOwners = getOwner(oldOwners[0].Id);
    	newOwners[0].Geonames_Retry__c = true;
    	update newOwners;
    	
    	map<Id, Account> oldOwnersMap = new map<Id, Account>();
    	map<Id, Account> newOwnersMap = new map<Id, Account>();
    	oldOwnersMap.put(oldOwners[0].Id, oldOwners[0]);
    	newOwnersMap.put(newOwners[0].Id, newOwners[0]);
    	
    	Test.startTest();
    	OwnerServices.assignDealersToOwnersIfNotGeocodingButAssignmentDataOrScoreHasChanged(oldOwnersMap, newOwnersMap);
    	Test.stopTest();
    	
    	list<Assigned_Dealer__c> assignedDealers = [select Id from Assigned_Dealer__c where Owner__c=:newOwners[0].Id];
    	system.assertEquals(0, assignedDealers.size());
    }
    
    static testMethod void assignDealersToOwnersIfNotGeocodingButAssignmentDataHasChanged_ownersNotAssignedIfAddressChanged() {
    	list<Account> oldOwners = setupOwnersDealersAndRoutingRules();

    	list<Account> newOwners = getOwner(oldOwners[0].Id);
    	newOwners[0].PersonMailingPostalCode = '91790';
    	update newOwners;
    	
    	map<Id, Account> oldOwnersMap = new map<Id, Account>();
    	map<Id, Account> newOwnersMap = new map<Id, Account>();
    	oldOwnersMap.put(oldOwners[0].Id, oldOwners[0]);
    	newOwnersMap.put(newOwners[0].Id, newOwners[0]);
    	
    	Test.startTest();
    	OwnerServices.assignDealersToOwnersIfNotGeocodingButAssignmentDataOrScoreHasChanged(oldOwnersMap, newOwnersMap);
    	Test.stopTest();
    	
    	list<Assigned_Dealer__c> assignedDealers = [select Id from Assigned_Dealer__c where Owner__c=:newOwners[0].Id];
    	system.assertEquals(0, assignedDealers.size());
    }
    
    static testMethod void assignDealersToOwnersIfNotGeocodingButAssignmentDataHasChanged_ownersAssignedIfScoreChanged() {
    	list<Account> oldOwners = setupOwnersDealersAndRoutingRules();

    	list<Account> newOwners = getOwner(oldOwners[0].Id);
    	newOwners[0].pi__score__pc = newOwners[0].pi__score__pc + DealerRouter.SCORE_THRESHOLD;
    	update newOwners;
    	
    	map<Id, Account> oldOwnersMap = new map<Id, Account>();
    	map<Id, Account> newOwnersMap = new map<Id, Account>();
    	oldOwnersMap.put(oldOwners[0].Id, oldOwners[0]);
    	newOwnersMap.put(newOwners[0].Id, newOwners[0]);
    	
    	Test.startTest();
    	OwnerServices.assignDealersToOwnersIfNotGeocodingButAssignmentDataOrScoreHasChanged(oldOwnersMap, newOwnersMap);
    	Test.stopTest();
    	
    	list<Assigned_Dealer__c> assignedDealers = [select Id from Assigned_Dealer__c where Owner__c=:newOwners[0].Id];
    	system.assertEquals(1, assignedDealers.size());
    }
	
    static list<Account> setupOwnersDealersAndRoutingRules() {
    	disableTriggers();
    	createLeadRoutingDoNotSend();
    	createDealerRoutingTestMode();
    	createZipRoutingRule();
    	
    	Account dealer = createDealer();
		dealer.Longitude__c = TEST_LONGITUDE_FOR_DEALER_1;
    	dealer.Latitude__c = TEST_LATITUDE_FOR_DEALER_1;
		dealer.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
        dealer.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
		insert dealer;
		
		Dealer_Brand__c db = createDealerBrand(dealer, 'SR');
		insert db;
		Territory__c t = createTerritory(db);
		t.Zipcode_Postal_Code__c = dealer.ShippingPostalCode;
		insert t;
    	
    	disableTriggers();
    	list<Account> owners = createOwners(1);
    	disableTriggers();
    	return owners;
    }
    
    static list<Account> createOwners(integer numberOfOwners) {
    	list<Account> owners = TestUtilities.createTestOwnerAccounts(numberOfOwners, false);
    	
    	for (integer i=0; i<numberOfOwners; i++) {
    		owners[i].PersonMailingStreet ='111 Street';
     		owners[i].PersonMailingCity = 'Knoxville';
     		owners[i].PersonMailingState ='TN';
     		owners[i].County__c ='Knox';
     		owners[i].PersonMailingPostalCode = '37929';
     		owners[i].Home_Address_ISO_Code__c = 'US';
     		owners[i].pi__score__pc = 50;
     		owners[i].Brand__c = 'SR';
     		owners[i].GeoLocation__Latitude__s = TEST_LATITUDE_FOR_DEALER_1;
     		owners[i].GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_DEALER_1;
     		owners[i].latitude__c = TEST_LATITUDE_FOR_DEALER_1;
     		owners[i].longitude__c = TEST_LONGITUDE_FOR_DEALER_1;
    	}
    	
    	insert owners;
    	
    	return owners;
    }
    
    static list<Account> getOwner(Id ownerId) {
    	set<Id> ownerIds = new set<Id>();
    	ownerIds.add(ownerId);
    	
    	return OwnerServices.getOwnerAccountsForRouting(ownerIds);
    }
    
    private static Account createDealer() {
		Account dealer = new Account();
		
		system.debug('Dealer Record Type Id = ' + DEALER_RECORD_TYPE);
		
		dealer.RecordTypeId = DEALER_RECORD_TYPE;
		dealer.Name = 'Test Dealer';
		dealer.Dealer_Number__c = '00000.000';
		dealer.ShippingStreet = '800 South Gay Street';
		dealer.ShippingCity = 'Knoxville';
		dealer.ShippingState = 'TN';
		dealer.ShippingPostalCode = '37929';
		dealer.ShippingCountry = 'US';
		dealer.Country_ISO_Code__c = 'US';
		dealer.County__c = 'Knox';
		
		return dealer;
	}
	
	private static Dealer_Brand__c createDealerBrand(Account dealer, string brand) {
		Dealer_Brand__c dealerBrand = new Dealer_Brand__c();
		dealerBrand.Name = 'dealerBrand-' + brand;
		dealerBrand.Status__c = 'Active';
		dealerBrand.Dealer__c = dealer.Id;	
		dealerBrand.Dealer_Primary_Email__c = 'test@test.com';
		dealerBrand.Brand__c = brand;
		
		return dealerBrand;
	}
	
	private static Territory__c createTerritory(Dealer_Brand__c dealerBrand) {
		Territory__c territory = new Territory__c();
		territory.Brand__c = dealerBrand.Brand__c;
		territory.Dealer_Brand__c = dealerBrand.Id;	
		
		return territory;
	}
	
	private static void createZipRoutingRule() {
		Owner_Routing_Rule__c rule = new Owner_Routing_Rule__c();
		rule.Name = 'Zip';
		rule.Country_Code__c = 'US';
		rule.Brand_Code__c = 'SR';
		rule.Routing_Attempt_1_Type__c = 'Zip/Postal Code with or without Product Category';
		rule.Number_of_Owners_1__c = '10';
		
		insert rule;
	}
    
    private static Id getIntegrationUserId() {
		User[] users = [select Id from User where Name='Integration User'];
		return users[0].Id;
	}
    
    private static void disableTriggers() {
    	AccountServices.disableDealerBrandTriggerProcessing = true;
		LeadServices.disableTriggerProcessing = true;
		OwnerServices.isApexTest = true;
		DealerRouter.doNotSendEmail = true;
		AccountServices.disableTriggerProcessing = true;
		DBMServices.disableTriggerProcessing = true;
		TerritoryServices.disableTriggerProcessing = true;
		OwnerServices.populateOwnerGeoFieldsIsRunning = true;
	}
	
	
	private static void createLeadRoutingDoNotSend() {
		Lead_Routing_Do_Not_Send__c dns = new Lead_Routing_Do_Not_Send__c(Name='Test', Brand_Code__c='SR', Lead_Form_Name__c=TEST_DNS_FORM_NAME);
	   	insert dns;
	}
	
	private static void createDealerRoutingTestMode() {
		Dealer_Routing_Test_Mode__c tm = new Dealer_Routing_Test_Mode__c(Name='Owner', Test_Mode__c=true, Process_Footsteps__c=true);
		insert tm;
	}
	
}