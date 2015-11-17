/**
 * Tests the DBMServices class
 */
@isTest
private class DBMServicesTest {
	private static Id DEALER_RECORD_TYPE = [Select Id from RecordType Where DeveloperName='DEALER' limit 1].Id;
	private static Id OWNER_RECORD_TYPE_ID = [select Id from recordtype where developerName='Owner' limit 1].Id;
	private static final String BRAND_NON_FW = 'SR';
	private static final String BRAND1 = 'CC';
	private static final string HIN1 = 'SERT8312B606';
	private static final string HIN2 = 'SERT8312B603';
	private static final string DEALER_NUMBER1 = '123456.000';
	private static final string DEALER_NUMBER2 = '123456.001';
	private static final string TEST_OWNER_FIRST_NAME = 'James';
	private static final string TEST_OWNER_MIDDLE_INITIAL = 'T';
	private static final string TEST_OWNER_LAST_NAME = 'Holt';
	private static final string TEST_OWNER_SUFFIX = 'Jr.';
	private static final string TEST_OWNER_STREET = '3218 Beachwater Drive';
	private static final string TEST_OWNER_CITY = 'Katy';
	private static final string TEST_OWNER_STATE = 'TX';
	private static final string TEST_OWNER_ZIP = '77450';
	private static final string TEST_OWNER_EMAIL = 'test@test.com';
	
	static testMethod void sharingRulesAreNotCreatedForInactiveUserOwner() {
		AccountServices.disableDealerBrandTriggerProcessing = true;
		AccountServices.disableTriggerProcessing = true;
		DBMServices.disableTriggerProcessing = true;
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
        createFreshwaterBrandsCustomSetting();
        User owner = createOwner();
        insert owner;
        Account dealer = createDealer(DEALER_NUMBER1);
        insert dealer;
        Dealer_Brand__c db = createDealerBrand(dealer, owner, BRAND1);
        insert db;
        Boat__c boat = createBoat(dealer, db, HIN1);
        insert boat;
        
        owner.IsActive = false;
        update owner;
        
        list<Boat__c> boats = new list<Boat__c>();
        boats.add(boat);
        
        Account boatOwner = createOwnerAccount();
        insert boatOwner;	
        Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(boatOwner, boat);
        insert obr;
        
        Test.startTest();
       	new DBMServices().createApexSharingRules(boats);
        Test.stopTest();
        
        list<Boat__Share> boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(0, boatShares.size(), 'There should be no boat shares');
        
        list<AccountShare> ownerShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:boatOwner.Id and RowCause='Manual'];
        system.assertEquals(0, ownerShares.size(), 'There should not be any owner shares');
	}
	
	static testMethod void updatingMultileBoatsAndTerritories() {
		integer numberOfBoats = 100;
		integer numberOfTerritories = 100;
		AccountServices.disableTriggerProcessing = true;
		DBMServices.disableTriggerProcessing = true;
		BoatServices.disableTriggerProcessing = true;
		TerritoryServices.disableTriggerProcessing = true;
		createConfiguration();
        createFreshwaterBrandsCustomSetting();
        User owner = createOwner();
        insert owner;
        User owner2 = createOwner();
        owner2.Username = 'DBMServicesTest2@test.com';
       	owner2.Alias = 'DBMST2';
        insert owner2;
        Account dealer = createDealer(DEALER_NUMBER1);
        insert dealer;
        Dealer_Brand__c db = createDealerBrand(dealer, owner, BRAND1);
        insert db;
        
        list<Boat__c> boats = createBoats(dealer, db, HIN1, numberOfBoats);
        insert boats;
        
        list<Territory__c> territories = createTerritories(db, numberOfTerritories);
        insert territories;
        
        list<Dealer_Brand__c> dealerBrands = new list<Dealer_Brand__c>();
        dealerBrands.add(db);
        
        new DBMServices().createApexSharingRules(dealerBrands);
        
       	dealerBrands = new list<Dealer_Brand__c>();
       	Dealer_Brand__c updatedDb = [Select Id, Brand__c, Dealer__c, OwnerId from Dealer_Brand__c where Id=:db.Id];
       	updatedDb.OwnerId = owner2.Id;
       	update updatedDb;
       	dealerBrands.add(updatedDb);
       	
        map<Id, Dealer_Brand__c> oldDealerBrandMap = new map<Id, Dealer_Brand__c>();
        oldDealerBrandMap.put(db.Id, db);
        
        Test.startTest();
       	new DBMServices().updateApexSharingRules(dealerBrands, oldDealerBrandMap);
        Test.stopTest();
        
        // We should have 500 sharing rules and the owner of each should be the new owner
        list<Boat__Share> boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(numberOfBoats, boatShares.size());
        for (integer i=0; i<boatShares.size(); i++) {
        	system.assertEquals(owner2.Id, boatShares[i].UserOrGroupId, 'The new owner should own the share');
        }
        
        list<Territory__Share> tShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Territory__Share where RowCause=:Schema.Territory__Share.rowCause.DBM_Territory_Access__c];
        system.assertEquals(numberOfTerritories, tShares.size());
        for (integer i=0; i<tShares.size(); i++) {
        	system.assertEquals(owner2.Id, tShares[i].UserOrGroupId, 'The new owner should own the share');
        }
	}
	static testMethod void sharingRulesAreCreatedForBoatsAndBoatOwnersAndAccessibleToDBM() {
		AccountServices.disableDealerBrandTriggerProcessing = true;
		AccountServices.disableTriggerProcessing = true;
		DBMServices.disableTriggerProcessing = true;
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		createConfiguration();
        createFreshwaterBrandsCustomSetting();
        User owner = createOwner();
        insert owner;
        User owner2 = createOwner();
       	owner2.Username = 'DBMServicesTest2@test.com';
       	owner2.Alias = 'DBMST2';
        insert owner2;
        Account boatOwner = createOwnerAccount();
        insert boatOwner;
        Account boatOwner2 = createOwnerAccount();
        boatOwner2.LastName = TEST_OWNER_LAST_NAME + '2';
        boatOwner2.FirstName = TEST_OWNER_FIRST_NAME + '2';
       	boatOwner2.PersonEmail = '2' + TEST_OWNER_EMAIL;
       	insert boatOwner2;
        Account dealer = createDealer(DEALER_NUMBER1);
        insert dealer;
        Account dealer2 = createDealer(DEALER_NUMBER2);
        insert dealer2;
        Dealer_Brand__c db = createDealerBrand(dealer, owner, BRAND1);
        insert db;
        Dealer_Brand__c db2 = createDealerBrand(dealer2, owner2, BRAND1);
        insert db2;
        Boat__c boat = createBoat(dealer, db, HIN1);
        insert boat;
        Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(boatOwner, boat);
        insert obr;
        Owner_Boat_Relationship__c obr2 = createOwnerBoatRelationship(boatOwner2, boat);
        insert obr2;
        
        list<Boat__Share> boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(0, boatShares.size(), 'There should not be any boat shares');
        
        list<AccountShare> dealerShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer.Id and RowCause='Manual'];
        system.assertEquals(0, dealerShares.size(), 'There should not be any dealer shares');
        
        list<AccountShare> ownerShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:boatOwner.Id and RowCause='Manual'];
        system.assertEquals(0, ownerShares.size(), 'There should not be any owner shares');
        
        list<Boat__c> boats = new list<Boat__c>();
        boats.add(boat);	
        
        // Before we run the sharing rules the DBM should not see anything
        System.runAs(owner) {
        	list<Boat__c> boatsToCheck = [select Id, Name from Boat__c];
        	system.assertEquals(0, boatsToCheck.size());
        	
        	// Can they see the owner
        	list<Account> boatOwners = [select Id from Account where RecordTypeId = :OWNER_RECORD_TYPE_ID];
        	system.assertEquals(0, boatOwners.size());
        	
        	// Can they see the owner boat relationship
        	list<Owner_Boat_Relationship__c> obrs = [select Id from Owner_Boat_Relationship__c];
        	system.assertEquals(0, obrs.size());
        }
        
        Test.startTest();
       	new DBMServices().createApexSharingRules(boats);
        Test.stopTest();
        
        // We should have a single boat share created
        boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(1, boatShares.size(), 'There should be a single boat share');
        system.assertEquals(owner.Id, boatShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of the dealer brand');
        system.assertEquals('Read', boatShares[0].AccessLevel);
        
        // We should have 2 owner shares created
        ownerShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where UserOrGroupId=:owner.Id and RowCause='Manual'];
        system.assertEquals(2, ownerShares.size(), 'There should be a 2 owner share2');
        system.assertEquals('Read', ownerShares[0].AccountAccessLevel);
        
        // Now we should be able to see this dealer and boat when we run as this user
        System.runAs(owner) {
        	// Can they see the boat
        	boats = [select Id, Name from Boat__c];
        	system.assertEquals(1, boats.size());
        	system.assertEquals(boat.Name, boats[0].Name);
        	
        	// Can they see the owner
        	list<Account> boatOwners = [select Id from Account where RecordTypeId = :OWNER_RECORD_TYPE_ID];
        	system.assertEquals(2, boatOwners.size());
        	
        	// Can they see the owner boat relationship
        	list<Owner_Boat_Relationship__c> obrs = [select Id from Owner_Boat_Relationship__c];
        	system.assertEquals(2, obrs.size());
        }
	}
	
    static testMethod void sharingRulesAreCreatedAndAccessibleToDBM() {
    	AccountServices.disableDealerBrandTriggerProcessing = true;
		AccountServices.disableTriggerProcessing = true;
		DBMServices.disableTriggerProcessing = true;
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
        createConfiguration();
        createFreshwaterBrandsCustomSetting();
        User owner = createOwner();
        insert owner;
        Account dealer = createDealer(DEALER_NUMBER1);
        insert dealer;
        Dealer_Brand__c db = createDealerBrand(dealer, owner, BRAND1);
        insert db;
        Boat__c boat = createBoat(dealer, db, HIN1);
        insert boat;
        Territory__c territory = createTerritory(db);
        insert territory;
        list<Dealer_Brand__c> dealerBrands = new list<Dealer_Brand__c>();
        dealerBrands.add(db);
        Account boatOwner = createOwnerAccount();
        insert boatOwner;
        Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(boatOwner, boat);
        insert obr;
        
        Test.startTest();
       	new DBMServices().createApexSharingRules(dealerBrands);
        Test.stopTest();
        
        // We should have a single account share created
        list<AccountShare> accountShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer.Id and RowCause='Manual'];
        system.assertEquals(1, accountShares.size(), 'There should be a single account share');
        system.assertEquals(owner.Id, accountShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of dealer brand');
        system.assertEquals('Read', accountShares[0].AccountAccessLevel);
        
        // We should have a single boat share created
        list<Boat__Share> boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(1, boatShares.size(), 'There should be a single boat share');
        system.assertEquals(owner.Id, boatShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of the dealer brand');
        system.assertEquals('Read', boatShares[0].AccessLevel);
        
        // We should have a single territory share created
        list<Territory__Share> territoryShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Territory__Share where ParentId=:territory.Id and RowCause=:Schema.Territory__Share.rowCause.DBM_Territory_Access__c];
        system.assertEquals(1, territoryShares.size(), 'There should be a single territory share');
        system.assertEquals(owner.Id, territoryShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of the dealer brand');
        system.assertEquals('Read', territoryShares[0].AccessLevel);
        
        // We should have a single boat owner share created
        list<AccountShare> ownerShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:boatOwner.Id and RowCause='Manual'];
        system.assertEquals(1, ownerShares.size(), 'There should be a single owner share');
        system.assertEquals(owner.Id, ownerShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of the dealer brand');
        
        // Now we should be able to see this dealer and boat when we run as this user
        System.runAs(owner) {
        	// Can they see the dealer
        	list<Account> dealers = [select Id, Dealer_Number__c from Account where recordTypeId=:DEALER_RECORD_TYPE];
        	system.assertEquals(1, dealers.size());
        	system.assertEquals(dealer.Dealer_Number__c, dealers[0].Dealer_Number__c);
        	
        	// Can they see the boat
        	list<Boat__c> boats = [select Id, Name from Boat__c];
        	system.assertEquals(1, boats.size());
        	system.assertEquals(boat.Name, boats[0].Name);
        	
        	// Can they see the territory
        	list<Territory__c> territories = [select Id from Territory__c];
        	system.assertEquals(1, territories.size());
        	system.assertEquals(territory.Id, territories[0].Id);
        	
        	// Can they see the boat owner
        	list<Account> boatOwners = [select Id from Account where recordTypeId=:OWNER_RECORD_TYPE_ID];
        	system.assertEquals(1, boatOwners.size());
        	system.assertEquals(boatOwner.Id, boatOwners[0].Id);
        	
        	// Can they see the owner boat relationship
        	list<Owner_Boat_Relationship__c> obrs = [select Id from Owner_Boat_Relationship__c];
        	system.assertEquals(1, obrs.size());
        	system.assertEquals(obr.Id, obrs[0].Id);
        }
    }
    
    
    // Tests that sharing rules are not created for a non FW brand
    static testMethod void sharingRulesAreNotCreatedForNonFWBrand() {
    	AccountServices.disableDealerBrandTriggerProcessing = true;
		AccountServices.disableTriggerProcessing = true;
		DBMServices.disableTriggerProcessing = true;
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
        createConfiguration();
        createFreshwaterBrandsCustomSetting();
        User owner = createOwner();
        insert owner;
        Account dealer = createDealer(DEALER_NUMBER1);
        insert dealer;
        Dealer_Brand__c db = createDealerBrand(dealer, owner, BRAND_NON_FW);
        insert db;
        Boat__c boat = createBoat(dealer, db, HIN1);
        insert boat;
        Territory__c territory = createTerritory(db);
        insert territory;
        list<Dealer_Brand__c> dealerBrands = new list<Dealer_Brand__c>();
        dealerBrands.add(db);
        
        Account boatOwner = createOwnerAccount();
		insert boatOwner;	
		Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(boatOwner, boat);
		insert obr;
        
        Test.startTest();
       	new DBMServices().createApexSharingRules(dealerBrands);
        Test.stopTest();
        
        // We should have no account shares
        list<AccountShare> accountShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer.Id and RowCause='Manual'];
        system.assertEquals(0, accountShares.size(), 'There should be no account shares');
        
        // We should have no boat shares
        list<Boat__Share> boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(0, boatShares.size(), 'There should be no boat shares');
        
        // We should have no territory shares
        list<Territory__Share> territoryShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Territory__Share where ParentId=:territory.Id and RowCause=:Schema.Territory__Share.rowCause.DBM_Territory_Access__c];
        system.assertEquals(0, territoryShares.size(), 'There should be no territory shares');
        
        list<AccountShare> ownerShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:boatOwner.Id and RowCause='Manual'];
        system.assertEquals(0, ownerShares.size(), 'There should not be any owner shares');
        
        // Now we should not be able to see this dealer and boat when we run as this user
        System.runAs(owner) {
        	// Can they see the dealer
        	list<Account> dealers = [select Id, Dealer_Number__c from Account where recordTypeId=:DEALER_RECORD_TYPE];
        	system.assertEquals(0, dealers.size());
        	
        	// Can they see the boat
        	list<Boat__c> boats = [select Id, Name from Boat__c];
        	system.assertEquals(0, boats.size());
        	
        	// Can they see the territory
        	list<Territory__c> territories = [select Id from Territory__c];
        	system.assertEquals(0, territories.size());
        	
        	// Can they see the owner
        	list<Account> boatOwners = [select Id from Account where RecordTypeId = :OWNER_RECORD_TYPE_ID];
        	system.assertEquals(0, boatOwners.size());
        	
        	// Can they see the owner boat relationship
        	list<Owner_Boat_Relationship__c> obrs = [select Id from Owner_Boat_Relationship__c];
        	system.assertEquals(0, obrs.size());
        }
    }
    
    // Tests that sharing rules are created for multiple boats
    static testMethod void sharingRulesAreCreatedAndAccessibleToDBMForMultipleBoatsAndTerritories() {
    	AccountServices.disableDealerBrandTriggerProcessing = true;
		AccountServices.disableTriggerProcessing = true;
		DBMServices.disableTriggerProcessing = true;
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
        createConfiguration();
        createFreshwaterBrandsCustomSetting();
        User owner = createOwner();
        insert owner;
        Account dealer = createDealer(DEALER_NUMBER1);
        insert dealer;
        Dealer_Brand__c db = createDealerBrand(dealer, owner, BRAND1);
        insert db;
        Boat__c boat1 = createBoat(dealer, db, HIN1);
        insert boat1;
        Boat__c boat2 = createBoat(dealer, db, HIN2);
        insert boat2;
        Territory__c t1 = createTerritory(db);
        insert t1;
        Territory__c t2 = createTerritory(db);
        insert t2;
        list<Dealer_Brand__c> dealerBrands = new list<Dealer_Brand__c>();
        dealerBrands.add(db);
        
        Account boatOwner = createOwnerAccount();
		insert boatOwner;	
		Owner_Boat_Relationship__c obr1 = createOwnerBoatRelationship(boatOwner, boat1);
		insert obr1;
		Owner_Boat_Relationship__c obr2 = createOwnerBoatRelationship(boatOwner, boat2);
		insert obr2;
        
        Test.startTest();
       	new DBMServices().createApexSharingRules(dealerBrands);
        Test.stopTest();
        
        // We should have a single account share created
        list<AccountShare> accountShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer.Id and RowCause='Manual'];
        system.assertEquals(1, accountShares.size(), 'There should be a single account share');
        system.assertEquals(owner.Id, accountShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of dealer brand');
        system.assertEquals('Read', accountShares[0].AccountAccessLevel);
        
        // We should have two boat shares created
        list<Boat__Share> boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where UserOrGroupId=:owner.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c order by LastModifiedDate asc];
        system.assertEquals(2, boatShares.size(), 'There should be 2 boat shares');
        system.assertEquals(boat1.Id, boatShares[0].ParentId, 'The ParentId should belong to the boats');
        system.assertEquals(boat2.Id, boatShares[1].ParentId, 'The ParentId should belong to the boats');
        system.assertEquals('Read', boatShares[0].AccessLevel);
        system.assertEquals('Read', boatShares[1].AccessLevel);
        
         // We should have two territory shares created
        list<Territory__Share> tshares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Territory__Share where UserOrGroupId=:owner.Id and RowCause=:Schema.Territory__Share.rowCause.DBM_Territory_Access__c order by LastModifiedDate asc];
        system.assertEquals(2, tshares.size(), 'There should be 2 territory shares');
        system.assertEquals(t1.Id, tshares[0].ParentId, 'The ParentId should belong to the territories');
        system.assertEquals(t2.Id, tshares[1].ParentId, 'The ParentId should belong to the territories');
        system.assertEquals('Read', tshares[0].AccessLevel);
        system.assertEquals('Read', tshares[1].AccessLevel);
        
        list<AccountShare> ownerShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where UserOrGroupId=:owner.Id and RowCause='Manual'];
        system.assertEquals(2, ownerShares.size(), 'There should be a 2 owner share2');
        system.assertEquals('Read', ownerShares[0].AccountAccessLevel);
        
        // Now we should be able to see this dealer and boat when we run as this user
        System.runAs(owner) {
        	// Can they see the dealer
        	list<Account> dealers = [select Id, Dealer_Number__c from Account where recordTypeId=:DEALER_RECORD_TYPE];
        	system.assertEquals(1, dealers.size());
        	system.assertEquals(dealer.Dealer_Number__c, dealers[0].Dealer_Number__c);
        	
        	// Can they see the boats
        	list<Boat__c> boats = [select Id, Name from Boat__c order by CreatedDate asc];
        	system.assertEquals(2, boats.size());
        	system.assertEquals(boat1.Name, boats[0].Name);
        	system.assertEquals(boat2.Name, boats[1].Name);
        	
        	// Can they see the territories
        	list<Territory__c> territories = [select Id from Territory__c order by CreatedDate asc];
        	system.assertEquals(2, territories.size());
        	system.assertEquals(t1.Id, territories[0].Id);
        	system.assertEquals(t2.Id, territories[1].Id);
        	
        	// Can they see the owner
        	list<Account> boatOwners = [select Id from Account where RecordTypeId = :OWNER_RECORD_TYPE_ID];
        	system.assertEquals(1, boatOwners.size());
        	
        	// Can they see the owner boat relationship
        	list<Owner_Boat_Relationship__c> obrs = [select Id from Owner_Boat_Relationship__c];
        	system.assertEquals(2, obrs.size());
        }
    }
    
   	// Tests that when multiple sharing rules are created for different owners that they are accessible only to those owners
	static testMethod void sharingRulesAreCreatedAndAccessibleToCertainDBM() {
		AccountServices.disableDealerBrandTriggerProcessing = true;
		AccountServices.disableTriggerProcessing = true;
		DBMServices.disableTriggerProcessing = true;
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
        createConfiguration();
        createFreshwaterBrandsCustomSetting();
        User owner1 = createOwner();
        insert owner1;
        User owner2 = createOwner();
       	owner2.Username = 'DBMServicesTest2@test.com';
       	owner2.Alias = 'DBMST2';
        insert owner2;
        
        Account dealer1 = createDealer(DEALER_NUMBER1);
        insert dealer1;
        Account dealer2 = createDealer(DEALER_NUMBER2);
        dealer2.Dealer_Number__c = '123456.001';
        insert dealer2;
        
        // Create the dealer brands, including 2 non-fw brands. The non-fw brands should have no effect
        Dealer_Brand__c db1 = createDealerBrand(dealer1, owner1, BRAND1);
        insert db1;
        Dealer_Brand__c db1a = createDealerBrand(dealer1, owner1, BRAND_NON_FW);
        insert db1a;
        Dealer_Brand__c db2 = createDealerBrand(dealer2, owner2, BRAND1);
        insert db2;
        Dealer_Brand__c db2a = createDealerBrand(dealer2, owner2, BRAND_NON_FW);
        insert db2a;
       
        Boat__c boat1 = createBoat(dealer1, db1, HIN1);
        insert boat1;
        Boat__c boat1a = createBoat(dealer1, db1a, HIN1);
        insert boat1a;
        Boat__c boat2 = createBoat(dealer2, db2, HIN2);
        insert boat2;
        Boat__c boat2a = createBoat(dealer2, db2a, HIN2);
        insert boat2a;
        
        Territory__c t1 = createTerritory(db1);
        insert t1;
        Territory__c t2 = createTerritory(db2);
        insert t2;
        
        list<Dealer_Brand__c> dealerBrands = new list<Dealer_Brand__c>();
        dealerBrands.add(db1);
        dealerBrands.add(db1a);
        dealerBrands.add(db2);
        dealerBrands.add(db2a);
        
        Test.startTest();
       	new DBMServices().createApexSharingRules(dealerBrands);
        Test.stopTest();
      
        // We should have a single account share created
        list<AccountShare> accountShares1 = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer1.Id and RowCause='Manual'];
        system.assertEquals(1, accountShares1.size(), 'There should be a single account share');
        system.assertEquals(owner1.Id, accountShares1[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of dealer brand');
        system.assertEquals('Read', accountShares1[0].AccountAccessLevel);
        
        list<AccountShare> accountShares2 = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer2.Id and RowCause='Manual'];
        system.assertEquals(1, accountShares2.size(), 'There should be a single account share');
        system.assertEquals(owner2.Id, accountShares2[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of dealer brand');
        system.assertEquals('Read', accountShares2[0].AccountAccessLevel);
        
        // We should have a single boat share created
        list<Boat__Share> boatShares1 = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat1.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(1, boatShares1.size(), 'There should be a single boat share');
        system.assertEquals(owner1.Id, boatShares1[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of the dealer brand');
        system.assertEquals('Read', boatShares1[0].AccessLevel);
        
        list<Boat__Share> boatShares2 = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat2.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(1, boatShares2.size(), 'There should be a single boat share');
        system.assertEquals(owner2.Id, boatShares2[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of the dealer brand');
        system.assertEquals('Read', boatShares2[0].AccessLevel);
        
        // We should have a single territory share created
        list<Territory__Share> tshare1 = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Territory__Share where ParentId=:t1.Id and RowCause=:Schema.Territory__Share.rowCause.DBM_Territory_Access__c];
        system.assertEquals(1, tshare1.size(), 'There should be a single territory share');
        system.assertEquals(owner1.Id, tshare1[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of the dealer brand');
        system.assertEquals('Read', tshare1[0].AccessLevel);
        
        list<Territory__Share> tshare2 = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Territory__Share where ParentId=:t2.Id and RowCause=:Schema.Territory__Share.rowCause.DBM_Territory_Access__c];
        system.assertEquals(1, tshare2.size(), 'There should be a single territory share');
        system.assertEquals(owner2.Id, tshare2[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of the dealer brand');
        system.assertEquals('Read', tshare2[0].AccessLevel);
        
        // Now we should be able to see this dealer and boat when we run as this user
        System.runAs(owner1) {
        	// Can they see the dealer
        	list<Account> dealers1 = [select Id, Dealer_Number__c from Account where recordTypeId=:DEALER_RECORD_TYPE];
        	system.assertEquals(1, dealers1.size());
        	system.assertEquals(dealer1.Dealer_Number__c, dealers1[0].Dealer_Number__c);
        	
        	// Can they see the boat
        	list<Boat__c> boats1 = [select Id, Name from Boat__c];
        	system.assertEquals(1, boats1.size());
        	system.assertEquals(boat1.Name, boats1[0].Name);
        	
        	// Can they see the territory
        	list<Territory__c> territories1 = [select Id from Territory__c];
        	system.assertEquals(1, territories1.size());
        	system.assertEquals(t1.Id, territories1[0].Id);
        	
        	// They should not be able to see the other boat
        	list<Boat__c> boats1b = [select Id, Name from Boat__c where Id=:boat2.Id];
        	system.assertEquals(0, boats1b.size());
        	
        	// They should not be able to see the other territory
        	list<Territory__c> territories2 = [select Id from Territory__c where Id=:t2.Id];
        	system.assertEquals(0, territories2.size());
        	
        	// They should not be able to see the boat with the non-fw brand
        	list<Boat__c> boats1a = [select Id, Name from Boat__c where Id=:boat1a.Id];
        	system.assertEquals(0, boats1a.size());
        }
        
        System.runAs(owner2) {
        	// Can they see the dealer
        	list<Account> dealers2 = [select Id, Dealer_Number__c from Account where recordTypeId=:DEALER_RECORD_TYPE];
        	system.assertEquals(1, dealers2.size());
        	system.assertEquals(dealer2.Dealer_Number__c, dealers2[0].Dealer_Number__c);
        	
        	// Can they see the boat
        	list<Boat__c> boats2 = [select Id, Name from Boat__c];
        	system.assertEquals(1, boats2.size());
        	system.assertEquals(boat2.Name, boats2[0].Name);
        	
        	// Can they see the territory
        	list<Territory__c> territories2 = [select Id from Territory__c];
        	system.assertEquals(1, territories2.size());
        	system.assertEquals(t2.Id, territories2[0].Id);
        	
        	// They should not be able to see the other boat
        	list<Boat__c> boats2b = [select Id, Name from Boat__c where Id=:boat1.Id];
        	system.assertEquals(0, boats2b.size());
        	
        	// They should not be able to see the other territory
        	list<Territory__c> territories1 = [select Id from Territory__c where Id=:t1.Id];
        	system.assertEquals(0, territories1.size());
        	
        	// They should not be able to see the boat with the non-fw brand
        	list<Boat__c> boats2a = [select Id, Name from Boat__c where Id=:boat2a.Id];
        	system.assertEquals(0, boats2a.size());
        }
    }
    
    // Tests that updated sharing rules delete the old relationships and add the new ones
    static testMethod void updatedSharingRules() {
    	AccountServices.disableDealerBrandTriggerProcessing = true;
		AccountServices.disableTriggerProcessing = true;
		DBMServices.disableTriggerProcessing = true;
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
        createConfiguration();
        createFreshwaterBrandsCustomSetting();
       
        User owner1 = createOwner();
        insert owner1;
        User owner2 = createOwner();
       	owner2.Username = 'DBMServicesTest2@test.com';
       	owner2.Alias = 'DBMST2';
        insert owner2;
        
        Account dealer = createDealer(DEALER_NUMBER1);
        insert dealer;
        
        Dealer_Brand__c db = createDealerBrand(dealer, owner1, BRAND1);
        insert db;
        
        Boat__c boat = createBoat(dealer, db, HIN1);
        insert boat;
        
        Territory__c t = createTerritory(db);
        insert t;
        
        Account boatOwner = createOwnerAccount();
        insert boatOwner;
        
        Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(boatOwner, boat);
        insert obr;
        
        list<Dealer_Brand__c> dealerBrands = new list<Dealer_Brand__c>();
        dealerBrands.add(db);
        
        // Create the sharing rules
       	DBMServices services = new DBMServices();
       	services.createApexSharingRules(dealerBrands);
       	
       	// We should have a single account share created
        list<AccountShare> accountShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer.Id and RowCause='Manual'];
        system.assertEquals(1, accountShares.size(), 'There should be a single account share');
        
        // We should have a single boat share created
        list<Boat__Share> boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(1, boatShares.size(), 'There should be a single boat share');
        
         // We should have a single territory share created
        list<Territory__Share> tshares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Territory__Share where ParentId=:t.Id and RowCause=:Schema.Territory__Share.rowCause.DBM_Territory_Access__c];
        system.assertEquals(1, tshares.size(), 'There should be a single territory share');
        
        list<AccountShare> ownerShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:boatOwner.Id and RowCause='Manual'];
        system.assertEquals(1, ownerShares.size(), 'There should be a single owner share');
       	
       	// Now update the owner of the dealer brand and test the update
       	Dealer_Brand__c updatedDb = [Select Id, Brand__c, Dealer__c, OwnerId from Dealer_Brand__c where Id=:db.Id];
       	updatedDb.OwnerId = owner2.Id;
       	update updatedDb;
       	
       	dealerBrands = new list<Dealer_Brand__c>();
        dealerBrands.add(updatedDb);
        
        map<Id, Dealer_Brand__c> oldDealerBrandMap = new map<Id, Dealer_Brand__c>();
        oldDealerBrandMap.put(db.Id, db);
        
        Test.startTest();
       	services.updateApexSharingRules(dealerBrands, oldDealerBrandMap);
        Test.stopTest();
        
        // We should have a single account share created
        accountShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer.Id and RowCause='Manual'];
        system.assertEquals(1, accountShares.size(), 'There should be a single account share');
        system.assertEquals(owner2.Id, accountShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of dealer brand');
        system.assertEquals('Read', accountShares[0].AccountAccessLevel);
        
        // We should have a single boat share created
        boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(1, boatShares.size(), 'There should be a single boat share');
        system.assertEquals(owner2.Id, boatShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of the dealer brand');
        system.assertEquals('Read', boatShares[0].AccessLevel);
        
         // We should have a single territory share created
        tshares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Territory__Share where ParentId=:t.Id and RowCause=:Schema.Territory__Share.rowCause.DBM_Territory_Access__c];
        system.assertEquals(1, tshares.size(), 'There should be a single territory share');
        system.assertEquals(owner2.Id, tshares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of the dealer brand');
        system.assertEquals('Read', tshares[0].AccessLevel);
        
        ownerShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:boatOwner.Id and RowCause='Manual'];
        system.assertEquals(1, ownerShares.size(), 'There should be a single owner shares');
        system.assertEquals(owner2.Id, ownerShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of dealer brand');
        system.assertEquals('Read', ownerShares[0].AccountAccessLevel);
        
        // Now we should be able to see this dealer and boat when we run as this user
        System.runAs(owner2) {
        	// Can they see the dealer
        	list<Account> dealers = [select Id, Dealer_Number__c from Account where recordTypeId=:DEALER_RECORD_TYPE];
        	system.assertEquals(1, dealers.size());
        	system.assertEquals(dealer.Dealer_Number__c, dealers[0].Dealer_Number__c);
        	
        	// Can they see the boat
        	list<Boat__c> boats = [select Id, Name from Boat__c];
        	system.assertEquals(1, boats.size());
        	system.assertEquals(boat.Name, boats[0].Name);
        	
        	// Can they see the territories
        	list<Territory__c> territories = [select Id from Territory__c];
        	system.assertEquals(1, territories.size());
        	system.assertEquals(t.Id, territories[0].Id);
        	
        	// Can they see the owner
        	list<Account> boatOwners = [select Id from Account where RecordTypeId = :OWNER_RECORD_TYPE_ID];
        	system.assertEquals(1, boatOwners.size());
        	
        	// Can they see the owner boat relationship
        	list<Owner_Boat_Relationship__c> obrs = [select Id from Owner_Boat_Relationship__c];
        	system.assertEquals(1, obrs.size());
        }
        
        // We should no longer be able to see this dealer and boat when we run as this user
        System.runAs(owner1) {
        	// Can they see the dealer
        	list<Account> dealers = [select Id, Dealer_Number__c from Account where recordTypeId=:DEALER_RECORD_TYPE];
        	system.assertEquals(0, dealers.size());
        	
        	// Can they see the boat
        	list<Boat__c> boats = [select Id, Name from Boat__c];
        	system.assertEquals(0, boats.size());
        	
        	// Can they see the territory
        	list<Territory__c> territories = [select Id from Territory__c];
        	system.assertEquals(0, territories.size());
        	
        	// Can they see the owner
        	list<Account> boatOwners = [select Id from Account where RecordTypeId = :OWNER_RECORD_TYPE_ID];
        	system.assertEquals(0, boatOwners.size());
        	
        	// Can they see the owner boat relationship
        	list<Owner_Boat_Relationship__c> obrs = [select Id from Owner_Boat_Relationship__c];
        	system.assertEquals(0, obrs.size());
        }
    }
    
    // Tests that sharing rules are removed
    static testMethod void sharingRulesAreRemoved() {
    	AccountServices.disableDealerBrandTriggerProcessing = true;
		AccountServices.disableTriggerProcessing = true;
		DBMServices.disableTriggerProcessing = true;
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
        createConfiguration();
        createFreshwaterBrandsCustomSetting();
        User owner = createOwner();
        insert owner;
        
        Account dealer = createDealer(DEALER_NUMBER1);
        insert dealer;
        
        Dealer_Brand__c db = createDealerBrand(dealer, owner, BRAND1);
        insert db;
        
        Boat__c boat = createBoat(dealer, db, HIN1);
        insert boat;
        
        Territory__c t = createTerritory(db);
        insert t;
        
        Account boatOwner = createOwnerAccount();
        insert boatOwner;
        
        Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(boatOwner, boat);
        insert obr;
        
        list<Dealer_Brand__c> dealerBrands = new list<Dealer_Brand__c>();
        dealerBrands.add(db);
        
        // Create the sharing rules
       	DBMServices services = new DBMServices();
       	services.createApexSharingRules(dealerBrands);
       	
       	// We should have a single account share created
        list<AccountShare> accountShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer.Id and RowCause='Manual'];
        system.assertEquals(1, accountShares.size(), 'There should be a single account share');
        
        // We should have a single boat share created
        list<Boat__Share> boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(1, boatShares.size(), 'There should be a single boat share');
        
        // We should have a single territory share created
        list<Territory__Share> territoryShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Territory__Share where ParentId=:t.Id and RowCause=:Schema.Territory__Share.rowCause.DBM_Territory_Access__c];
        system.assertEquals(1, territoryShares.size(), 'There should be a single territory share');
        
        list<AccountShare> ownerShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:boatOwner.Id and RowCause='Manual'];
        system.assertEquals(1, ownerShares.size(), 'There should be a single owner shares');
       	
       	// Now remove the sharing rules
        Test.startTest();
       	services.removeSharingRules(dealerBrands);
        Test.stopTest();
        
        // We should have no account shares
        accountShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer.Id and RowCause='Manual'];
        system.assertEquals(0, accountShares.size(), 'There should not be any account shares');
        
        // We should have not boat shares
        boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(0, boatShares.size(), 'There should be no boat shares');
        
        // We should have no territory shares
        territoryShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Territory__Share where ParentId=:t.Id and RowCause=:Schema.Territory__Share.rowCause.DBM_Territory_Access__c];
        system.assertEquals(0, territoryShares.size(), 'There should be no territory shares');
        
        ownerShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:boatOwner.Id and RowCause='Manual'];
        system.assertEquals(0, ownerShares.size(), 'There should not be any owner shares');
        
        // Now we should not be able to see this dealer and boat when we run as this user
        System.runAs(owner) {
        	// Can they see the dealer
        	list<Account> dealers = [select Id, Dealer_Number__c from Account where recordTypeId=:DEALER_RECORD_TYPE];
        	system.assertEquals(0, dealers.size());
        	
        	// Can they see the boat
        	list<Boat__c> boats = [select Id, Name from Boat__c];
        	system.assertEquals(0, boats.size());
        	
        	// Can they see the territory
        	list<Territory__c> territories = [select Id from Territory__c];
        	system.assertEquals(0, territories.size());
        	
        	// Can they see the owner
        	list<Account> boatOwners = [select Id from Account where RecordTypeId = :OWNER_RECORD_TYPE_ID];
        	system.assertEquals(0, boatOwners.size());
        	
        	// Can they see the owner boat relationship
        	list<Owner_Boat_Relationship__c> obrs = [select Id from Owner_Boat_Relationship__c];
        	system.assertEquals(0, obrs.size());
        }
    }
    
    // Tests that updated sharing rules delete the old relationships and add the new ones
    static testMethod void updatedSharingRulesNonFWBrands() {
    	AccountServices.disableDealerBrandTriggerProcessing = true;
		AccountServices.disableTriggerProcessing = true;
		DBMServices.disableTriggerProcessing = true;
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
        createConfiguration();
        createFreshwaterBrandsCustomSetting();
        User owner1 = createOwner();
        insert owner1;
        User owner2 = createOwner();
       	owner2.Username = 'DBMServicesTest2@test.com';
       	owner2.Alias = 'DBMST2';
        insert owner2;
        
        Account dealer = createDealer(DEALER_NUMBER1);
        insert dealer;
        
        Dealer_Brand__c db = createDealerBrand(dealer, owner1, BRAND1);
        insert db;
        
        Dealer_Brand__c db2 = createDealerBrand(dealer, owner1, BRAND_NON_FW);
        insert db2;
        
        Boat__c boat = createBoat(dealer, db, HIN1);
        insert boat;
        
        Boat__c boat2 = createBoat(dealer, db2, HIN2);
        insert boat2; 
        
        Account boatOwner = createOwnerAccount();
		insert boatOwner;	
		
		Account boatOwner2 = createOwnerAccount();
        boatOwner2.LastName = TEST_OWNER_LAST_NAME + '2';
        boatOwner2.FirstName = TEST_OWNER_FIRST_NAME + '2';
       	boatOwner2.PersonEmail = '2' + TEST_OWNER_EMAIL;
       	insert boatOwner2;
       	
		Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(boatOwner, boat);
		insert obr;
		
		Owner_Boat_Relationship__c obr2 = createOwnerBoatRelationship(boatOwner2, boat2);
		insert obr2;
        
        list<Dealer_Brand__c> dealerBrands = new list<Dealer_Brand__c>();
        dealerBrands.add(db);
        dealerBrands.add(db2);
        
        // Create the sharing rules
       	DBMServices services = new DBMServices();
       	services.createApexSharingRules(dealerBrands);
       	
       	// We should have a single account share created
        list<AccountShare> accountShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer.Id and RowCause='Manual'];
        system.assertEquals(1, accountShares.size(), 'There should be a single account share');
        
        // We should have a single boat share created
        list<Boat__Share> boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(1, boatShares.size(), 'There should be a single boat share');
        
        list<AccountShare> ownerShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:boatOwner.Id and RowCause='Manual'];
        system.assertEquals(1, ownerShares.size(), 'There should be a single owner shares');
       	
       	// Now update the owner of the dealer brand and test the update
       	dealerBrands = new list<Dealer_Brand__c>();
       	Dealer_Brand__c updatedDb = [Select Id, Brand__c, Dealer__c, OwnerId from Dealer_Brand__c where Id=:db.Id];
       	updatedDb.OwnerId = owner2.Id;
       	update updatedDb;
       	dealerBrands.add(updatedDb);
       	
       	Dealer_Brand__c updatedDb2 = [Select Id, Brand__c, Dealer__c, OwnerId from Dealer_Brand__c where Id=:db2.Id];
       	updatedDb2.OwnerId = owner2.Id;
       	update updatedDb2;
       	dealerBrands.add(updatedDb2);
       	
        
        map<Id, Dealer_Brand__c> oldDealerBrandMap = new map<Id, Dealer_Brand__c>();
        oldDealerBrandMap.put(db.Id, db);
        oldDealerBrandMap.put(db2.Id, db2);
        
        Test.startTest();
       	services.updateApexSharingRules(dealerBrands, oldDealerBrandMap);
        Test.stopTest();
        
        // We should have a single account share created
        accountShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer.Id and RowCause='Manual'];
        system.assertEquals(1, accountShares.size(), 'There should be a single account share');
        system.assertEquals(owner2.Id, accountShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of dealer brand');
        system.assertEquals('Read', accountShares[0].AccountAccessLevel);
        
        // We should have a single boat share created
        boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(1, boatShares.size(), 'There should be a single boat share');
        system.assertEquals(owner2.Id, boatShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of the dealer brand');
        system.assertEquals('Read', boatShares[0].AccessLevel);
        
       	ownerShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:boatOwner.Id and RowCause='Manual'];
        system.assertEquals(1, ownerShares.size(), 'There should be a single owner shares');
        
        // Now we should be able to see this dealer and boat when we run as this user
        System.runAs(owner2) {
        	// Can they see the dealer
        	list<Account> dealers = [select Id, Dealer_Number__c from Account where recordTypeId=:DEALER_RECORD_TYPE];
        	system.assertEquals(1, dealers.size());
        	system.assertEquals(dealer.Dealer_Number__c, dealers[0].Dealer_Number__c);
        	
        	// Can they see the boat
        	list<Boat__c> boats = [select Id, Name from Boat__c];
        	system.assertEquals(1, boats.size());
        	system.assertEquals(boat.Name, boats[0].Name);
        	
        	// Can they see the owner
        	list<Account> boatOwners = [select Id from Account where RecordTypeId = :OWNER_RECORD_TYPE_ID];
        	system.assertEquals(1, boatOwners.size());
        	
        	// Can they see the owner boat relationship
        	list<Owner_Boat_Relationship__c> obrs = [select Id from Owner_Boat_Relationship__c];
        	system.assertEquals(1, obrs.size());
        }
        
        // We should no longer be able to see this dealer and boat when we run as this user
        System.runAs(owner1) {
        	// Can they see the dealer
        	list<Account> dealers = [select Id, Dealer_Number__c from Account where recordTypeId=:DEALER_RECORD_TYPE];
        	system.assertEquals(0, dealers.size());
        	
        	// Can they see the boat
        	list<Boat__c> boats = [select Id, Name from Boat__c];
        	system.assertEquals(0, boats.size());
        	
        	// Can they see the owner
        	list<Account> boatOwners = [select Id from Account where RecordTypeId = :OWNER_RECORD_TYPE_ID];
        	system.assertEquals(0, boatOwners.size());
        	
        	// Can they see the owner boat relationship
        	list<Owner_Boat_Relationship__c> obrs = [select Id from Owner_Boat_Relationship__c];
        	system.assertEquals(0, obrs.size());
        }
    }
    
    // Tests that updated sharing rules deletes only some of the old relationships and add the new ones
    static testMethod void updatedSharingRulesOnlyDeletesSome() {
    	AccountServices.disableDealerBrandTriggerProcessing = true;
		AccountServices.disableTriggerProcessing = true;
		DBMServices.disableTriggerProcessing = true;
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
        createConfiguration();
        createFreshwaterBrandsCustomSetting();
        User owner1 = createOwner();
        insert owner1;
        User owner2 = createOwner();
       	owner2.Username = 'DBMServicesTest2@test.com';
       	owner2.Alias = 'DBMST2';
        insert owner2;
        
        Account dealer1 = createDealer(DEALER_NUMBER1);
        insert dealer1;
        
        Account dealer2 = createDealer(DEALER_NUMBER2);
        insert dealer2;
        
        Dealer_Brand__c db1 = createDealerBrand(dealer1, owner1, BRAND1);
        insert db1;
        
        Dealer_Brand__c db2 = createDealerBrand(dealer2, owner1, BRAND1);
        insert db2;
        
        Boat__c boat1 = createBoat(dealer1, db1, HIN1);
        insert boat1;
        
        Boat__c boat2 = createBoat(dealer2, db2, HIN2);
        insert boat2;
        
        list<Dealer_Brand__c> dealerBrands = new list<Dealer_Brand__c>();
        dealerBrands.add(db1);
        dealerBrands.add(db2);
        
        // Create the sharing rules
       	DBMServices services = new DBMServices();
       	services.createApexSharingRules(dealerBrands);
       	
       	// Now update the owner of the dealer brand and test the update
       	list<Dealer_Brand__c> updatedDbs = [Select Id, Brand__c, Dealer__c, OwnerId from Dealer_Brand__c where Id in :dealerBrands order by CreatedDate asc];
       	updatedDbs[0].OwnerId = owner2.Id;
       	update updatedDbs[0];
        
        map<Id, Dealer_Brand__c> oldDealerBrandMap = new map<Id, Dealer_Brand__c>();
        oldDealerBrandMap.put(db1.Id, db1);
        oldDealerBrandMap.put(db2.Id, db2);
        
        Test.startTest();
       	services.updateApexSharingRules(updatedDbs, oldDealerBrandMap);
        Test.stopTest();
        
        // We should have 1 account shares created for first dealer
        list<AccountShare> accountShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer1.Id and RowCause='Manual'];
        system.assertEquals(1, accountShares.size(), 'There should be a single account share');
        system.assertEquals(owner2.Id, accountShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of dealer brand');
        
        // We should have 1 account shares created for second dealer
        accountShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer2.Id and RowCause='Manual'];
        system.assertEquals(1, accountShares.size(), 'There should be a single account share');
        system.assertEquals(owner1.Id, accountShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of dealer brand');
        
        // We should have a single boat share created
        list<Boat__Share> boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat1.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(1, boatShares.size(), 'There should be a single boat share');
        system.assertEquals(owner2.Id, boatShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of the dealer brand');
        
        boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat2.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(1, boatShares.size(), 'There should be a single boat share');
        system.assertEquals(owner1.Id, boatShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of the dealer brand');
        
        // Now we should be able to see this dealer and boat when we run as this user
        System.runAs(owner2) {
        	// Can they see the dealer
        	list<Account> dealers = [select Id, Dealer_Number__c from Account where recordTypeId=:DEALER_RECORD_TYPE];
        	system.assertEquals(1, dealers.size());
        	system.assertEquals(dealer1.Dealer_Number__c, dealers[0].Dealer_Number__c);
        	
        	// Can they see the boat
        	list<Boat__c> boats = [select Id, Name from Boat__c];
        	system.assertEquals(1, boats.size());
        	system.assertEquals(boat1.Name, boats[0].Name);
        }
        
        // We should no longer be able to see this dealer and boat when we run as this user
        System.runAs(owner1) {
        	// Can they see the dealer
        	list<Account> dealers = [select Id, Dealer_Number__c from Account where recordTypeId=:DEALER_RECORD_TYPE];
        	system.assertEquals(1, dealers.size());
        	system.assertEquals(dealer2.Dealer_Number__c, dealers[0].Dealer_Number__c);
        	
        	// Can they see the boat
        	list<Boat__c> boats = [select Id, Name from Boat__c];
        	system.assertEquals(1, boats.size());
        	system.assertEquals(boat2.Name, boats[0].Name);
        }
    }
    
    private static Id getIntegrationUserId() {
		User[] users = [select Id from User where Name='Integration User'];
		return users[0].Id;
	}
    
    private static void createConfiguration() {
		Configuration__c config = new Configuration__c(Name='BoatOwner',RecordId__c=getIntegrationUserId());
		insert config;
	}
	
	private static void createFreshwaterBrandsCustomSetting() {
		list<Freshwater_Brands__c> fwBrands = new list<Freshwater_Brands__c>();
		
		Freshwater_Brands__c fwb1 = new Freshwater_Brands__c(Name='CC', Brand__c='CC');
		
		fwBrands.add(fwb1);
		
		insert fwBrands;
	}
	
	private static User createOwner() {
		Profile p = [select Id from Profile where name = 'Freshwater DBM User' limit 1];
        return new User(
	      FirstName = 'testFirst'
	      , LastName = 'testLast'
	      , Username = 'DBMServicesTest@test.com'
	      , Email = 'test@test.com'
	      , IsActive = true
	      , Alias = 'DBMST'
	      , TimeZoneSidKey = 'GMT'
	      , LocaleSidKey = 'en_US'
	      , EmailEncodingKey = 'ISO-8859-1'
	      , LanguageLocaleKey = 'en_US'
	      , ProfileId = p.Id);
	}
	
	private static Account createOwnerAccount() {
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
        owner.HIN_Number__c = HIN1;
        owner.Home_Address_ISO_Code__c = 'US';
        owner.Brand_Relationships__c = BRAND1;
        owner.PersonEmail = TEST_OWNER_EMAIL;
        owner.Brand__c = 'SR';
		
		return owner;
	}
	
	private static Group createGroup() {
		return new Group(Name='TestGroup', DeveloperName='testDev');
	}
    
  	private static Account createDealer(string dealerNumber) {
		Account dealer = new Account();
		
		dealer.recordTypeId = DEALER_RECORD_TYPE;
		dealer.Name = 'MarineMax TX-Seabrook';
		dealer.Dealer_Number__c = dealerNumber;
		dealer.ShippingStreet = '112 E. HIGH STREET';
		dealer.ShippingCity = 'HENNEPIN';
		dealer.ShippingState = 'IL';
		dealer.ShippingPostalCode = '61327';
		dealer.ShippingCountry = 'US';
		dealer.Country_ISO_Code__c = 'US';
		
		return dealer;
	}
	
	private static list<Boat__c> createBoats(Account dealer, Dealer_Brand__c db, string hin, integer boatCount) {
		list<Boat__c> boats = new list<Boat__c>();
		
		for (integer i=0; i<boatCount; i++) {
			Boat__c boat = createBoat(dealer, db, hin);
			boats.add(boat);
		}
		
		return boats;	
	}
	
	private static list<Territory__c> createTerritories(Dealer_Brand__c db, integer territoryCount) {
		list<Territory__c> territories = new list<Territory__c>();
		
		for (integer i=0; i<territoryCount; i++) {
			Territory__c territory = createTerritory(db);
			territories.add(territory);
		}
		
		return territories;
	}
    
    private static Dealer_Brand__c createDealerBrand(Account dealer, User owner, string brand) {
    	Dealer_Brand__c db = new Dealer_Brand__c();
    	db.Brand__c = brand;
    	db.Dealer__c = dealer.Id;
    	db.OwnerId = owner.Id;
    	
    	return db;
    }
    
    private static Dealer_Brand__c createDealerBrand(Account dealer, Group owner, string brand) {
    	Dealer_Brand__c db = new Dealer_Brand__c();
    	db.Brand__c = brand;
    	db.Dealer__c = dealer.Id;
    	db.OwnerId = owner.Id;
    	
    	return db;
    }
    
    private static Boat__c createBoat(Account dealer, Dealer_Brand__c db, string hin) {
		Boat__c boat = new Boat__c();
		
		boat.Name = hin;
		boat.External_HIN_Number__c = hin;
		boat.Hin_migration__c = hin;
		boat.Model_Year__c = '2006';
		boat.Boat_Model__c = '320DA';
		boat.Brand_del__c = db.Brand__c;
		
		boat.DealerNumLoc__c = dealer.Dealer_Number__c;
		boat.Dealer__c = dealer.Id;
		boat.Dealer_Brand_Lookup__c = db.Id;
		
		return boat;
	}
	
	private static Owner_Boat_Relationship__c createOwnerBoatRelationship(Account owner, Boat__c boat) {
		Owner_Boat_Relationship__c  boatOwnerShip = new Owner_Boat_Relationship__c();
        boatOwnerShip.HIN_Number__c = boat.Id;
        boatOwnerShip.Owner__c = owner.Id;
        boatOwnerShip.Status__c = 'Active';
        boatOwnerShip.Purchase_Date__c = Date.newInstance(2015, 1, 29);          
        
        return boatOwnerShip;	
	}
	
	private static Territory__c createTerritory(Dealer_Brand__c db) {
		Territory__c t = new Territory__c();
		t.Brand__c = db.Brand__c;
		t.Dealer_Brand__c = db.Id;
		return t;
	}
}