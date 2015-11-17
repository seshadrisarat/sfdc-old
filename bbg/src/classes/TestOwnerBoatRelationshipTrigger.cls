public class TestOwnerBoatRelationshipTrigger {

	
	static final List<String> BRAND_CODES = new List<String>{'TR','BL','MX', 'AB'} ;
	static final List<String> BRAND_INACTIVE_CODES  = new List<String>{'YP'};
	
	// If we have an existing relationship that was created from registration and create a new relationship the new one should be active
	// and the old one inactive
	public static testMethod void afterInsertNewRelationshipIsActiveAndOldRelationshipInactive() {
		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;	
		
		// Create the boat and initial boat relationship
		list<Boat__c> boats = TestServices.createBoats(1, false);
		boats[0].Brand_del__c = 'BL';
		insert boats;
		
		// Create a new owner account
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, false);
		insert owners;
		
		// Create new relationship
		list<Owner_Boat_Relationship__c> rels = TestServices.createOwnerBoatRelationships(owners, boats, false);
		
		Test.startTest();
			insert rels;
		Test.stopTest();
		
		rels = [select Id, Status__c from Owner_Boat_Relationship__c order by CreatedDate asc];
		system.assertEquals(2, rels.size(), 'There should be 2 relationships');
		system.assertEquals('Inactive', rels[0].Status__c, 'The status should be Inactive');
		system.assertEquals('Active', rels[1].Status__c, 'The status should be Active');
	}
	
	// If we have an existing relationship that is SROC and create a new relationship that is not SROC then the new one 
	// will be inactive and the old one will be Active, since it is SROC
	public static testMethod void afterInsertNewRelationshipIsInActiveWhenOldWasSROC() {
		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;	
		
		// Create the boat and initial boat relationship
		list<Boat__c> boats = TestServices.createBoats(1, false);
		boats[0].Brand_del__c = 'BL';
		insert boats;
		
		// Update the existing relationship source to SROC
		list<Owner_Boat_Relationship__c> rels = [select Id, Entry_Source__c from Owner_Boat_Relationship__c];
		rels[0].Entry_Source__c = BoatServices.ENTRY_SOURCE_SROC;
		update rels;
		
		
		// Create a new owner account
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, false);
		insert owners;
		
		// Create new relationship
		rels = TestServices.createOwnerBoatRelationships(owners, boats, false);
		
		Test.startTest();
			insert rels;
		Test.stopTest();
		
		rels = [select Id, Status__c from Owner_Boat_Relationship__c order by CreatedDate asc];
		system.assertEquals(2, rels.size(), 'There should be 2 relationships');
		system.assertEquals('Active', rels[0].Status__c, 'The status should be Active');
		system.assertEquals('Inactive', rels[1].Status__c, 'The status should be InActive');
	}
	
	// If we have two relationships and the original one is active and the new one active, and we update the source to 
	// SROC on the original one, then this one would become active, since it is SROC and the other one is not
	public static testMethod void afterInsertOfAnotherActiveRelationshipButOriginalIsSROCThenOriginalRemainsActive() {
		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;	
		
		// Create the boat and initial boat relationship
		list<Boat__c> boats = TestServices.createBoats(1, false);
		boats[0].Brand_del__c = 'BL';
		insert boats;
		
		list<Owner_Boat_Relationship__c> rels = [select Id, Entry_Source__c from Owner_Boat_Relationship__c order by CreatedDate asc];
		rels[0].Entry_Source__c = BoatServices.ENTRY_SOURCE_SROC;
		update rels[0];
		
		// Create a new owner account
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, false);
		insert owners;
		
		Test.startTest();
			// Create new relationship
			rels = TestServices.createOwnerBoatRelationships(owners, boats, false);
			insert rels;
		Test.stopTest();
		
		rels = [select Id, Status__c from Owner_Boat_Relationship__c order by CreatedDate asc];
		system.assertEquals(2, rels.size(), 'There should be 2 relationships');
		system.assertEquals('Active', rels[0].Status__c, 'The status should be Active');
		system.assertEquals('Inactive', rels[1].Status__c, 'The status should be InActive');
	}
	
	
	// If we set an existing active relationship to inactive then it stays that way
	public static testMethod void afterUpdateOfExistingRelationshipToInactiveItStaysInactiveAndOwnerBrandRelationshipIsUpdated() {
		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;	
		
		// Create the boat and initial boat relationship
		list<Boat__c> boats = TestServices.createBoats(1, false);
		boats[0].Brand_del__c = 'BL';
		insert boats;
		
		list<Owner_Boat_Relationship__c> rels = [select Id, Status__c from Owner_Boat_Relationship__c order by CreatedDate asc];
		system.assertEquals(1, rels.size(), 'There should be one relationship');
		system.assertEquals('Active', rels[0].Status__c, 'The status should be Active');
		
		list<Account> owners = [select Id, Brand_Relationships__c from Account];
		system.assertEquals(1, owners.size(), 'One owner should have been created');
		system.assertEquals('BL', owners[0].Brand_Relationships__c, 'The brand relationship should have been set');
		
		// Update the relationship to inactive
		
		Test.startTest();
			rels[0].Status__c = 'Inactive';
			update rels;
		Test.stopTest();
		
		rels = [select Id, Status__c from Owner_Boat_Relationship__c order by CreatedDate asc];
		system.assertEquals(1, rels.size(), 'There should be one relationship');
		system.assertEquals('Inactive', rels[0].Status__c, 'The status should be InActive');
		
		owners = [select Id, Brand_Relationships__c from Account];
		system.assertEquals(1, owners.size(), 'There should be one owner');
		system.assertEquals(null, owners[0].Brand_Relationships__c, 'There should be no relationship');
	}
	
	// If we delete a relationship the the brand relationship on the owner should be removed
	public static testMethod void afterDeleteBrandRelationshipIsRemoved() {
		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;	
		
		// Create the boat and initial boat relationship
		list<Boat__c> boats = TestServices.createBoats(1, false);
		boats[0].Brand_del__c = 'BL';
		insert boats;
		
		// Get the relationship
		list<Owner_Boat_Relationship__c> rels = [Select Id from Owner_Boat_Relationship__c];
		system.assertEquals(1, rels.size(), 'We should have one relationship');
		
		// Make sure the owner brand relationship is as we expect it
		list<Account> owners = [select Id, Brand_Relationships__c from Account];
		system.assertEquals(1, owners.size(), 'We should have one owner');
		system.assertEquals('BL', owners[0].Brand_Relationships__c, 'The brand should be set on the relationship');
		
		// Now delete the relationship and the brand should be removed
		Test.startTest();
			delete rels;
		Test.stopTest();
		
		rels = [select Id from Owner_Boat_Relationship__c];
		system.assertEquals(0, rels.size(), 'There should be no relationships');
		
		owners = [select Id, Brand_Relationships__c from Account];
		system.assertEquals(1, owners.size(), 'We should have one owner');
		system.assertEquals(null, owners[0].Brand_Relationships__c, 'The brand relationship should have been removed');
	}
	
	/*public static testMethod void testBoatInsert(){
		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;
		
		UnitTest.addData(TestServices.createBoats(9, false)).tag('Active Boats').tag('Boats').property('Brand_del__c').assignFrom(BRAND_CODES);
		UnitTest.addData(TestServices.createBoats(1, false)).tag('Inactive Boats').tag('Boats').property('Brand_del__c').assignFrom(BRAND_INACTIVE_CODES);
		UnitTest.get('Boats').insertAll();
		
		UnitTest.addData(TestUtilities.createTestOwnerAccounts(10, true)).tag('Accounts');
		
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Inactive Boats').getList(), false)).tag('Inactive Juntion objects').tag('Junction Objects');
		UnitTest.get('Inactive Juntion objects').property('Status__c').assign('Inactive');
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Active Boats').getList(), false)).tag('Active Juntion objects').tag('Junction Objects');
	
		
		Test.startTest();
			UnitTest.get(Owner_Boat_Relationship__c.SObjectType).insertAll();
		Test.stopTest();
		
		List<Account> actualAccounts = [Select Id, Brand_Relationships__c From Account Where Id in :UnitTest.getIds('Accounts')];

		for (Account acc : actualAccounts){
			for (String bcode : BRAND_CODES){
				System.assert(acc.Brand_Relationships__c.contains(bcode), 'We expect to get back the correct brand codes for each account');
			}
		}
	}
	
	public static testMethod void testBoatUpdateOnJunctionObjects(){
		
		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;
		
		UnitTest.addData(TestServices.createBoats(9, false)).tag('Active Boats').tag('Boats')
						.property('Brand_del__c').assignFrom(BRAND_CODES);
						
		UnitTest.addData(TestServices.createBoats(1, false)).tag('Inactive Boats').tag('Boats')
						.property('Brand_del__c').assignFrom(BRAND_INACTIVE_CODES);
		UnitTest.get('Boats').insertAll();
		
		UnitTest.addData(TestUtilities.createTestOwnerAccounts(10, true)).tag('Accounts');
		
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Inactive Boats').getList(), false)).tag('Inactive Juntion objects').tag('Junction Objects');
		UnitTest.get('Inactive Juntion objects').property('Status__c').assign('Inactive');
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Active Boats').getList(), false)).tag('Active Juntion objects').tag('Junction Objects');
		UnitTest.get(Owner_Boat_Relationship__c.SObjectType).insertAll();
		
		UnitTest.get('Inactive Juntion objects').property('Status__c').assign('Active');
		
		Test.startTest();
			UnitTest.get(Owner_Boat_Relationship__c.SObjectType).updateAll();
		Test.stopTest();
		
		List<String> expectedBrandCodes = BRAND_INACTIVE_CODES;
		expectedBrandCodes.addAll(BRAND_INACTIVE_CODES);
		
		List<Account> actualAccounts = [Select Id, Brand_Relationships__c From Account Where Id in :UnitTest.getIds('Accounts')];

		for (Account acc : actualAccounts){
			for (String bcode : expectedBrandCodes){
				System.assert(acc.Brand_Relationships__c.contains(bcode), 'We expect to get back the correct brand codes for each account');
			}
		}
		
	}
	
	public static testMethod void testBoatUpdate(){
		
		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;
		
		UnitTest.addData(TestServices.createBoats(9, false)).tag('Active Boats').tag('Boats')
						.property('Brand_del__c').assignFrom(BRAND_CODES);
						
		UnitTest.addData(TestServices.createBoats(1, false)).tag('Inactive Boats').tag('Boats')
						.property('Brand_del__c').assignFrom(BRAND_INACTIVE_CODES);
		UnitTest.get('Boats').insertAll();
		
		UnitTest.addData(TestUtilities.createTestOwnerAccounts(10, true)).tag('Accounts');
		
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Inactive Boats').getList(), false)).tag('Inactive Juntion objects').tag('Junction Objects');
		UnitTest.get('Inactive Juntion objects').property('Status__c').assign('Inactive');
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Active Boats').getList(), false)).tag('Active Juntion objects').tag('Junction Objects');
		UnitTest.get(Owner_Boat_Relationship__c.SObjectType).insertAll();
		
		UnitTest.get('Inactive Boats').property('Brand_del__c').assignFrom(BRAND_CODES);
		
		Test.startTest();
			UnitTest.get('Boats').updateAll();
		Test.stopTest();
		
		List<Account> actualAccounts = [Select Id, Brand_Relationships__c From Account Where Id in :UnitTest.getIds('Accounts')];

		for (Account acc : actualAccounts){
			for (String bcode : BRAND_INACTIVE_CODES){
				System.assert(!acc.Brand_Relationships__c.contains(bcode), 'We do not expect to get back an inactive brand code for each account');
			}
		}
		
	}*/
	
	public static testMethod void testBoatDeleteOnJunctionObjects(){
		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;
		
		UnitTest.addData(TestServices.createBoats(9, false)).tag('Active Boats').tag('Boats')
						.property('Brand_del__c').assignFrom(BRAND_CODES);
						
		UnitTest.addData(TestServices.createBoats(1, false)).tag('Inactive Boats').tag('Boats')
						.property('Brand_del__c').assignFrom(BRAND_INACTIVE_CODES);
		UnitTest.get('Boats').insertAll();
		
		UnitTest.addData(TestUtilities.createTestOwnerAccounts(10, true)).tag('Accounts');
		
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Inactive Boats').getList(), false)).tag('Inactive Juntion objects').tag('Junction Objects');
		UnitTest.get('Inactive Juntion objects').property('Status__c').assign('Inactive');
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Active Boats').getList(), false)).tag('Active Juntion objects').tag('Junction Objects');
		UnitTest.get(Owner_Boat_Relationship__c.SObjectType).insertAll();
		
		
		Test.startTest();
			UnitTest.get(Owner_Boat_Relationship__c.SObjectType).deleteAll();
		Test.stopTest();
		
		List<String> expectedBrandCodes = BRAND_INACTIVE_CODES;
		expectedBrandCodes.addAll(BRAND_INACTIVE_CODES);
		
		List<Account> actualAccounts = [Select Id, Brand_Relationships__c From Account Where Id in :UnitTest.getIds('Accounts')];

		for (Account acc : actualAccounts){
			System.assert(String.isBlank(acc.Brand_Relationships__c), 'We expect to get back the correct brand codes for each account.');
		}
	}
	
	/*public static testMethod void testBoatDelete(){
		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;
		
		UnitTest.addData(TestServices.createBoats(9, false)).tag('Boats')
						.property('Brand_del__c').assignFrom(BRAND_INACTIVE_CODES);
						
		UnitTest.addData(TestServices.createBoats(1, false)).tag('Boat to be Deleted').tag('Boats')
						.property('Brand_del__c').assignFrom(BRAND_CODES);
						
		UnitTest.get('Boats').insertAll();
		
		UnitTest.addData(TestUtilities.createTestOwnerAccounts(10, true)).tag('Accounts');
		
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Boats').getList(), false)).tag('Inactive Juntion objects').tag('Junction Objects');
		UnitTest.get('Inactive Juntion objects').property('Status__c').assign('Inactive');
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Boat to be Deleted').getList(), false)).tag('Active Juntion objects').tag('Junction Objects');
		UnitTest.get(Owner_Boat_Relationship__c.SObjectType).insertAll();
		
		
		Test.startTest();
			UnitTest.get('Boat to be Deleted').deleteAll();
		Test.stopTest();
		
		List<Account> actualAccounts = [Select Id, Brand_Relationships__c From Account Where Id in :UnitTest.getIds('Accounts')];

		for (Account acc : actualAccounts){
			System.assert(String.isBlank(acc.Brand_Relationships__c), 'We expect to get back the correct brand codes for each account.');
		}
	}*/
	
	
	
	
	
	public static testMethod void testDealerBrandInsert(){
		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;
		
		UnitTest.addData(TestUtilities.createTestDealerAccounts(9, true)).tag('Accounts');
		
		for (String activeBrand : BRAND_CODES){
			UnitTest.addData(TestServices.createDealerBrandRelationships(UnitTest.get('Accounts').getList(), activeBrand, false)).tag('Active Juntion objects').tag('Junction Objects');
		}
		for (String inactiveBrand : BRAND_INACTIVE_CODES){
			UnitTest.addData(TestServices.createDealerBrandRelationships(UnitTest.get('Accounts').getList(), inactiveBrand, false)).tag('Inactive Juntion objects').tag('Junction Objects');
		}
		UnitTest.get('Inactive Juntion objects').property('Status__c').assign('Inactive');
		
		Test.startTest();
			UnitTest.get(Dealer_Brand__c.SObjectType).insertAll();
		Test.stopTest();
		
		List<Account> actualAccounts = [Select Id, Brand_Relationships__c From Account Where Id in :UnitTest.getIds('Accounts')];

		for (Account acc : actualAccounts){
			for (String bcode : BRAND_CODES){
				System.assert(acc.Brand_Relationships__c.contains(bcode), 'We expect to get back the correct brand codes for each account');
			}
		}
	}
	public static testMethod void testDealerBrandUpdate(){
		
		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;
		
		UnitTest.addData(TestUtilities.createTestDealerAccounts(9, true)).tag('Accounts');
		
		for (String activeBrand : BRAND_CODES){
			UnitTest.addData(TestServices.createDealerBrandRelationships(UnitTest.get('Accounts').getList(), activeBrand, false)).tag('Active Juntion objects').tag('Junction Objects');
		}
		for (String inactiveBrand : BRAND_INACTIVE_CODES){
			UnitTest.addData(TestServices.createDealerBrandRelationships(UnitTest.get('Accounts').getList(), inactiveBrand, false)).tag('Inactive Juntion objects').tag('Junction Objects');
		}
		UnitTest.get('Inactive Juntion objects').property('Status__c').assign('Inactive');
		UnitTest.get(Dealer_Brand__c.SObjectType).insertAll();
		
		UnitTest.get('Inactive Juntion objects').property('Status__c').assign('Active');
		
		
		Test.startTest();
			UnitTest.get(Dealer_Brand__c.SObjectType).updateAll();
		Test.stopTest();
		
		List<String> expectedBrandCodes = BRAND_INACTIVE_CODES;
		expectedBrandCodes.addAll(BRAND_INACTIVE_CODES);
		
		List<Account> actualAccounts = [Select Id, Brand_Relationships__c From Account Where Id in :UnitTest.getIds('Accounts')];

		for (Account acc : actualAccounts){
			for (String bcode : expectedBrandCodes){
				System.assert(acc.Brand_Relationships__c.contains(bcode), 'We expect to get back the correct brand codes for each account');
			}
		}
		
	}
	public static testMethod void testDealerBrandDelete(){
		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;
		
		UnitTest.addData(TestUtilities.createTestDealerAccounts(9, true)).tag('Accounts');
		
		for (String activeBrand : BRAND_CODES){
			UnitTest.addData(TestServices.createDealerBrandRelationships(UnitTest.get('Accounts').getList(), activeBrand, false)).tag('Active Juntion objects').tag('Junction Objects');
		}
		for (String inactiveBrand : BRAND_INACTIVE_CODES){
			UnitTest.addData(TestServices.createDealerBrandRelationships(UnitTest.get('Accounts').getList(), inactiveBrand, false)).tag('Inactive Juntion objects').tag('Junction Objects');
		}
		UnitTest.get('Inactive Juntion objects').property('Status__c').assign('Inactive');
		UnitTest.get(Dealer_Brand__c.SObjectType).insertAll();
		
		Test.startTest();
			UnitTest.get(Dealer_Brand__c.SObjectType).deleteAll();
		Test.stopTest();
		
		List<Account> actualAccounts = [Select Id, Brand_Relationships__c From Account Where Id in :UnitTest.getIds('Accounts')];

		for (Account acc : actualAccounts){
			System.assert(String.isBlank(acc.Brand_Relationships__c), 'We expect to get back the correct brand codes for each account');
		}
	}
	
	/*
	public static testMethod void testBoatBrandUpdate(){
		
		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;
		
		UnitTest.addData(TestServices.createBoats(9, false)).tag('Active Boats').tag('Boats')
						.property('Brand_del__c').assignFrom(BRAND_CODES);
						
		UnitTest.addData(TestServices.createBoats(1, false)).tag('Inactive Boats').tag('Boats')
						.property('Brand_del__c').assignFrom(BRAND_INACTIVE_CODES);
		UnitTest.get('Boats').insertAll();
		
		UnitTest.addData(TestUtilities.createTestOwnerAccounts(10, true)).tag('Accounts');
		
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Inactive Boats').getList(), false)).tag('Inactive Juntion objects').tag('Junction Objects');
		UnitTest.get('Inactive Juntion objects').property('Status__c').assign('Inactive');
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Active Boats').getList(), false)).tag('Active Juntion objects').tag('Junction Objects');
		UnitTest.get(Owner_Boat_Relationship__c.SObjectType).insertAll();
		
		UnitTest.get('Inactive Boats').property('Brand_del__c').assignFrom(BRAND_CODES);
		
		Test.startTest();
			UnitTest.get('Boats').updateAll();
		Test.stopTest();
		
		List<String> expectedBrandCodes = BRAND_INACTIVE_CODES;
		expectedBrandCodes.addAll(BRAND_INACTIVE_CODES);
		
		List<Account> actualAccounts = [Select Id, Brand_Relationships__c From Account Where Id in :UnitTest.getIds('Accounts')];

		for (Account acc : actualAccounts){
			for (String bcode : BRAND_INACTIVE_CODES){
				System.assert(!acc.Brand_Relationships__c.contains(bcode), 'We do not expect to get back an inactive brand code for each account');
			}
		}
		
	}*/
	
	

}