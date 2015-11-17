@isTest 
private class TestBoatServices {
	
	static testmethod void updatingBoatWithNoOwnerMatchButExistingSROCRelationshipDoesNotSetSROCToInactive() {
		User boatOwner = TestServices.getUser('insertNewBoat@test.com');
		insert boatOwner;
		Configuration__c config = new Configuration__c(Name='BoatOwner',RecordId__c=boatOwner.Id);
		insert config;
		
		list<Boat__c> boats = TestServices.createBoats(1, false);
		boats[0].Owner_FirstName__c = 'NonSROC';
		boats[0].Owner_LastName__c = 'LastName';
		
		BoatServices.disableTriggerProcessing = true;
		insert boats;
		BoatServices.disableTriggerProcessing = false;
		
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, true);
		
		Test.startTest();
		list<Owner_Boat_Relationship__c> ownerRels = TestServices.createOwnerBoatRelationships(owners, boats, false);
		ownerRels[0].Entry_Source__c = BoatServices.ENTRY_SOURCE_SROC;
		insert ownerRels;
		Test.stopTest();
		
		ownerRels = [select Id, Status__c, Entry_Source__c from Owner_Boat_Relationship__c order by CreatedDate asc];
		system.assertEquals(2, ownerRels.size(), 'There should be two owner relationships created');
		
		system.assertEquals('Active', ownerRels[0].Status__c, 'The SROC relationship should be active');
		system.assertEquals('Inactive', ownerRels[1].Status__c, 'The non SROC relationship should be inactive');
	}
	
	static testmethod void updatingBoatWithNoOwnerMatchButNonSROCRelationshipSetsOldToInactive() {
		User boatOwner = TestServices.getUser('insertNewBoat@test.com');
		insert boatOwner;
		Configuration__c config = new Configuration__c(Name='BoatOwner',RecordId__c=boatOwner.Id);
		insert config;
		
		list<Boat__c> boats = TestServices.createBoats(1, false);
		boats[0].Owner_FirstName__c = 'Original';
		boats[0].Owner_LastName__c = 'Owner';
		
		BoatServices.disableTriggerProcessing = true;
		insert boats;
		BoatServices.disableTriggerProcessing = false;
		
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, true);
		
		Test.startTest();
		list<Owner_Boat_Relationship__c> ownerRels = TestServices.createOwnerBoatRelationships(owners, boats, true);
		Test.stopTest();
		
		ownerRels = [select Id, Status__c, Entry_Source__c from Owner_Boat_Relationship__c order by CreatedDate asc];
		system.assertEquals(2, ownerRels.size(), 'There should be two owner relationships created');
		
		system.assertEquals('Inactive', ownerRels[0].Status__c, 'The first relationship should be inactive');
		system.assertEquals('Active', ownerRels[1].Status__c, 'The original boat owner relationship should be active');
	}
	
	static testmethod void updatingBoatWithPriorOwnerWithSROCRelationshipSetsSROCToActive() {
		User boatOwner = TestServices.getUser('insertNewBoat@test.com');
		insert boatOwner;
		Configuration__c config = new Configuration__c(Name='BoatOwner',RecordId__c=boatOwner.Id);
		insert config;
		
		list<Boat__c> boats = TestServices.createBoats(1, false);
		boats[0].Owner_FirstName__c = 'NonSROC';
		boats[0].Owner_LastName__c = 'LastName';
		insert boats;
		
		BoatServices.disableTriggerProcessing = false;
		BoatTriggerHandler.disableBoatTrigger = false;
		BoatServices.isWorkFlowRunning = false;
		list<Owner_Boat_Relationship__c> ownerRels = [select Id, Status__c, Entry_Source__c from Owner_Boat_Relationship__c order by CreatedDate asc];
		system.assertEquals(1, ownerRels.size(), 'There should be one owner relationships created');
		system.assertEquals('Active', ownerRels[0].Status__c, 'The relationship status should be active');
		
		list<Account> owners = TestUtilities.createTestOwnerAccounts(1, true);
		
		Test.startTest();
		BoatServices.disableTriggerProcessing = false;
		BoatTriggerHandler.disableBoatTrigger = false;
		BoatServices.isWorkFlowRunning = false;
		ownerRels = TestServices.createOwnerBoatRelationships(owners, boats, false);
		ownerRels[0].Entry_Source__c = BoatServices.ENTRY_SOURCE_SROC;
		insert ownerRels;
		Test.stopTest();
		
		ownerRels = [select Id, Status__c, Entry_Source__c from Owner_Boat_Relationship__c order by CreatedDate asc];
		system.assertEquals(2, ownerRels.size(), 'There should be two owner relationships created');
		
		system.assertEquals('Inactive', ownerRels[0].Status__c, 'The non SROC relationship should be inactive');
		system.assertEquals('Active', ownerRels[1].Status__c, 'The SROC relationship should be active');
	}

    static testMethod void TestFilterBoatsNoDealerBrand() {
    	
    	// Sets up the boats, dealer, and establishes a dealer brand on the dealer.
    	List<Boat__c> boats = TestServices.createBoats(30, false);
    	Account dealer = TestUtilities.createTestDealerAccounts(1, true)[0];
    	Dealer_Brand__c dealerBrand = TestServices.createDealerBrandRelationship(dealer.Id, 'Crestliner', true);
    	
    	// Splits the boat data into 2 groups, with Dealer Brand and Without Dealer Brand.
    	UnitTest.addData(boats).tag('All Boats').divide(2).part('With Dealer Brand').part('Without Dealer Brand');
    	UnitTest.get('With Dealer Brand').property('Dealer_Brand_Lookup__c').assign(dealerBrand.Id);
    	UnitTest.get('All Boats').dummyInsert();
    	
    	// Establishes our expected list of boats.
    	List<Boat__c> expectedBoats = UnitTest.get('Without Dealer Brand').getList();
    	
    	// Calls method and saves to actual list of boats.
    	Test.StartTest();
    		List<Boat__c> actualBoats = BoatServices.filterBoatsNoDealerBrand(boats);
    	Test.StopTest();
    	
    	System.assert(!actualBoats.isEmpty(), 'We expect the list of boats to not be empty.');
    	System.assertEquals(expectedBoats, actualBoats, 'We expect to get back a list of boats that do not have a dealer brand.');
        
    }
    
    static testMethod void TestFindPossibleDealerBrand() {
    	
    	// Config stuff.
    	User boatOwner = TestServices.getUser('insertNewBoat@test.com');
    	insert boatOwner;
    	Configuration__c config = new Configuration__c(Name='BoatOwner',RecordId__c=boatOwner.Id);
		insert config;
    	
    	// Creates 3 dealers.    	
    	Account dealer1 = TestUtilities.createTestDealerAccounts(1, false)[0];
    	Account dealer2 = TestUtilities.createTestDealerAccounts(1, false)[0];
    	Account dealer3 = TestUtilities.createTestDealerAccounts(1, false)[0];
    	insert new List<Account>{ dealer1, dealer2, dealer3 };
    	
    	Set<Id> dealerSet = new Set<Id>{ dealer1.Id, dealer2.Id, dealer3.Id };
    	    	
    	// Creates 3 dearlers brands and spreads them through the dealers.
    	List<Dealer_Brand__c> brands1 = TestServices.createDealerBrandRelationships(new List<Account>{dealer1, dealer2, dealer3}, 'NS', true);
    	List<Dealer_Brand__c> brands2 = TestServices.createDealerBrandRelationships(new List<Account>{dealer1, dealer2}, 'KS', true);
    	Dealer_Brand__c brand3 = TestServices.createDealerBrandRelationship(dealer1.Id, 'SB', true);
    	    	
    	// Creates 3 boats and assigns each a dealer.
    	List<Boat__c> boats = TestServices.createBoats(3, false);
    	UnitTest.addData(boats).tag('All Boats').divide(3).part('Boat for Dealer 1').part('Boat for Dealer 2').part('Boat for Dealer 3');
    	UnitTest.get('Boat for Dealer 1').property('Dealer__c').assign(dealer1.Id);
    	UnitTest.get('Boat for Dealer 2').property('Dealer__c').assign(dealer2.Id);
    	UnitTest.get('Boat for Dealer 3').property('Dealer__c').assign(dealer3.Id);
    	//insert boats;
    	UnitTest.get('All Boats').dummyInsert();
    	
    	// Query the Dealers (Account) for Dealer_Brand_Info.
    	List<Account> dealerList = [SELECT Id, (SELECT Dealer_Brand__c.Id, Dealer_Brand__c.Name, Dealer_Brand__c.Brand__c FROM Dealer_Brands__r) FROM Account WHERE Id =: dealerSet];

		// Update Dealers.
		for(Account acc : dealerList)
		{
			if(acc.Id == dealer1.Id)
				dealer1 = acc;
			else if(acc.Id == dealer2.Id)
				dealer2 = acc;
			else if(acc.Id == dealer3.Id)
				dealer3 = acc;
		}
		
		// Creates a map of the expected output.
    	Map<Id, List<Dealer_Brand__c>> expectedMap = new Map<Id, List<Dealer_Brand__c>>();
    	expectedMap.put(dealer1.Id, dealer1.Dealer_Brands__r);
    	expectedMap.put(dealer2.Id, dealer2.Dealer_Brands__r);
    	expectedMap.put(dealer3.Id, dealer3.Dealer_Brands__r);
    	
    	Test.StartTest();
    		Map<Id, List<Dealer_Brand__c>> actualMap = BoatServices.findPossibleDealerBrand(boats);
    	Test.StopTest();
    	
    	System.assert(!actualMap.isEmpty(), 'We expect the returned map to not be empty.');
    	System.assertEquals(expectedMap.keySet(), actualMap.keySet(), 'We expect to get back a map of Account IDs to list of dealer brands');
    	
    	for(Id dealerId : actualMap.keySet())
    	{
    		System.assertEquals(Pluck.ids(expectedMap.get(dealerId)), Pluck.ids(actualMap.get(dealerId)), 
    			'We expect the returned results to contain an accurate map of boats to dealer brands.');
    	}
    	
    }
    
    static testMethod void TestStampBoatDealerBrand() {
    	
    	// Config Stuff.
    	User boatOwner = TestServices.getUser('insertNewBoat@test.com');
    	insert boatOwner;
    	Configuration__c config = new Configuration__c(Name='BoatOwner',RecordId__c=boatOwner.Id);
		insert config;
    	
    	// Creates 3 boats and assigns them a brand.
    	List<Boat__c> boats = TestServices.createBoats(3, false);
    	UnitTest.addData(boats).tag('All Boats')
    		.divide(3)
    		.part('BL')
    		.part('MX')
    		.part('TR');
    	UnitTest.get('BL').property('Brand_del__c').assign('BL');
    	UnitTest.get('MX').property('Brand_del__c').assign('MX');
    	UnitTest.get('TR').property('Brand_del__c').assign('TR');    	
    	
    	//insert boats;
    	UnitTest.get('All Boats').dummyInsert();
    	
    	// Creates the dealer and attaches 3 dealer brands to it.
    	Account dealer = TestUtilities.createTestDealerAccounts(1, true)[0];
    	
    	UnitTest.get('All Boats').property('Dealer__c').assign(dealer.Id);
    	
    	Map<String, Dealer_Brand__c> dbrands = new Map<String, Dealer_Brand__c>();
    	dbrands.put('BL', TestServices.createDealerBrandRelationship(dealer.Id, 'BL', false)); // Bayliner
    	dbrands.put('MX', TestServices.createDealerBrandRelationship(dealer.Id, 'MX', false)); // Maxum
    	dbrands.put('TR', TestServices.createDealerBrandRelationship(dealer.Id, 'TR', false)); // Trophy Sportfishing Boats
    	
    	insert dbrands.values();
    	
    	// Creates map to pass into function.
    	Map<Id, List<Dealer_Brand__c>> mapping = new Map<Id, List<Dealer_Brand__c>>();
    	mapping.put(dealer.Id, dbrands.values());
    	
    	Test.StartTest();
    		BoatServices.stampBoatDealerBrand(boats, mapping);
    	Test.StopTest();
    	
    	// Adds Name of Dealer Brand to Set.
    	for(Boat__c boat : boats)
    	{
    		System.assert( dbrands.containsKey( boat.Brand_del__c ), 'We expect the boat to be populated with the brand.' );
    		System.assertEquals( dbrands.get(boat.Brand_del__c).Id, boat.Dealer_Brand_Lookup__c , 'We expect the boat to be populated with the correct brand lookup.' );
    		
    	}
    	
    }
    
        
    static testMethod void TestCreateSalespersonContact() {
    	
    	// Config Stuff.
    	User boatOwner = TestServices.getUser('insertNewBoat@test.com');
    	insert boatOwner;
    	Configuration__c config = new Configuration__c(Name='BoatOwner',RecordId__c=boatOwner.Id);
		insert config;
		
		Id dealerRecTypeId = TestUtilities.getRecordTypesMap().get('Dealer');
		Account dealer = new Account(Name='Dealer',
			recordTypeId = dealerRecTypeId,
			Dealer_Number__c = '00555.001',
			Country_ISO_Code__c = 'US',
			ShippingPostalCode = '90210',
			Brand__c = 'SR');
		insert dealer;
		system.debug('Test dealer id: ' + dealer.id);
		
		Boat__c boat= new Boat__c(Name='TestHin', Owner_LastName__c='TestOwnerLastName',
			DealerNumLoc__c = '00555.001',
			Dealer_Salesperson_First_Name__c = 'SP_first',
			Dealer_Salesperson_Last_Name__c = 'SP_last',
			Brand_del__c = 'SR');
			
		Boat__c boat2= new Boat__c(Name='TestHin2', Owner_LastName__c='TestOwnerLastName',
			DealerNumLoc__c = '00555.001',
			Dealer_Salesperson_First_Name__c = 'SP_first',
			Dealer_Salesperson_Last_Name__c = 'SP_last',
			Brand_del__c = 'SR');
			
		Test.startTest();
		insert boat;
		insert boat2;
		Test.stopTest();
		
		
		List<Contact> salesPersons = [select id, firstname, AccountId from Contact where AccountId = :dealer.id];
		for (Contact c: salesPersons) {
			system.debug('salespersons first name: ' + c.firstname + ' account id: ' + c.accountId);
		}
		System.assertEquals(1, salesPersons.size(), 'Expected as salesperson to exist');
    	
    	
    }
    
}