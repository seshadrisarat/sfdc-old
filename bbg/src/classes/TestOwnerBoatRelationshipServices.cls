@isTest
private class TestOwnerBoatRelationshipServices {
	
	static final List<String> BRAND_CODES = new List<String>{'TR','BL','MX', 'AB'} ;
	static final List<String> BRAND_INACTIVE_CODES  = new List<String>{'YP'};
	
		static testMethod void testFilterBoats(){
		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;

		UnitTest.addData(TestServices.createBoats(10, false)).tag('Boats')
						.property('Brand_del__c').assignFrom(BRAND_CODES).insertAll();

		Map<Id, Boat__c> oldBoats= new Map<Id, Boat__c>((List<Boat__c>) UnitTest.get('Boats').getList().deepClone(true));

		UnitTest.get('Boats').divide(2).part('Boats updated brand').part('Boats not updated brand');

		UnitTest.get('Boats updated brand').assign('Brand_del__c', BRAND_INACTIVE_CODES[0]);

		Test.startTest();
			List<Boat__c> filteredBoats= OwnerBoatRelationshipServices.filterBoats(UnitTest.get('Boats').getList(), oldBoats);
		Test.stopTest();

		UnitTest.analyze('Boats Updated brand').assertEquivalence(filteredBoats, 'We should only get the boats that changed brand');
	}


	/*static testMethod void testGetParentObjectPersonAccount(){

		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;
		
		UnitTest.addData(TestServices.createBoats(9, false)).tag('Active Boats').tag('Boats')
						.property('Brand_del__c').assignFrom(BRAND_CODES);
						
		UnitTest.addData(TestServices.createBoats(1, false)).tag('Inactive Boats').tag('Boats')
						.property('Brand_del__c').assignFrom(BRAND_INACTIVE_CODES);
		UnitTest.get('Boats').insertAll();
		
		//Boat trigger automatically inserts an account and juncion object
		//Delete them to have more control over the test data
		List<Account> automaticallyAddedAccounts=[SELECT id from Account];
		delete automaticallyAddedAccounts;
		
		UnitTest.addData(TestUtilities.createTestOwnerAccounts(10, true)).tag('Accounts');
		
		
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Inactive Boats').getList(), false)).tag('Inctive Juntion objects');
		UnitTest.get('Inctive Juntion objects').property('Status__c').assign('Inactive').insertAll();
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Active Boats').getList(), true)).tag('Active Juntion objects');

		Test.startTest();
			Map<Id, Set<String>> actualBrandMap = OwnerBoatRelationshipServices.getParentObject((List<Owner_Boat_Relationship__c>)UnitTest.get(Owner_Boat_Relationship__c.SObjectType).getList());
		Test.stopTest();

		System.assertEquals(UnitTest.getIds('Accounts'), actualBrandMap.keySet(), 'There should be a map entry per each account associated with the owner boat relationship objects passed as parameter');
		for(Set<String> brandSet: actualBrandMap.values()){
			System.assertEquals(new Set<String>(BRAND_CODES), brandSet);
		}

	}*/
	
	static testMethod void testGetParentObjectDealerAccount(){
		
		UnitTest.addData(TestUtilities.createTestDealerAccounts(9, true)).tag('Accounts');

		List<Dealer_Brand__c> dealerBrands = new List<Dealer_Brand__c>();

		for(String brand: BRAND_CODES){
			dealerBrands.addAll(TestServices.createDealerBrandRelationships(UnitTest.get('Accounts').getList(),brand, false));

		}

		UnitTest.addData(dealerBrands).tag('Juntion objects');
		UnitTest.addData(TestServices.createDealerBrandRelationships(UnitTest.get('Accounts').getList(), BRAND_INACTIVE_CODES[0], false)).tag('Inactive Juntion objects');
		
		UnitTest.get('Inactive Juntion objects').property('Status__c').assign('Inactive');
		
		UnitTest.get(Dealer_Brand__c.SObjectType).insertAll();
		
		Test.startTest();
			Map<Id, Set<String>> actualBrandMap = OwnerBoatRelationshipServices.getParentObject((List<Dealer_Brand__c>)UnitTest.get('Juntion objects').getList());
		Test.stopTest();

		System.assertEquals(UnitTest.getIds('Accounts'), actualBrandMap.keySet(), 'There should be a map entry per each account associated with the owner boat relationship objects passed as parameter');
		for(Set<String> brandSet: actualBrandMap.values()){
			System.assertEquals(new Set<String>(BRAND_CODES), brandSet);
		}

	}
	
	/*static testMethod void testGetParentObjectBoatAccount(){

		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;
		
		UnitTest.addData(TestServices.createBoats(10, false)).tag('Active Boats').property('Brand_del__c').assignFrom(BRAND_CODES);
						
						
		UnitTest.addData(TestServices.createBoats(1, false)).tag('Inactive Boats')
						.property('Brand_del__c').assignFrom(BRAND_INACTIVE_CODES);					
						
		UnitTest.get('Active Boats').tag('Boats');
		UnitTest.get('Inactive Boats').tag('Boats');
		UnitTest.get('Boats').insertAll();
		
		//Boat trigger automatically inserts an account and juncion object
		//Delete them to have more control over the test data
		list<Owner_Boat_Relationship__c> rels = [select Id from Owner_Boat_Relationship__c];
		delete rels;
		
		List<Account> automaticallyAddedAccounts=[SELECT id from Account];
		delete automaticallyAddedAccounts;
		
		


		UnitTest.addData(TestUtilities.createTestOwnerAccounts(9, true)).tag('Accounts');
		
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Active Boats').getList(), true)).tag('Active Juntion objects');
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Inactive Boats').getList(), false)).tag('Active Juntion objects')
															.assign('Status__c', 'Inactive').insertAll();


		Test.startTest();
			Map<Id, Set<String>> actualBrandMap = OwnerBoatRelationshipServices.getParentObject((List<Boat__c>)UnitTest.get('Boats').getList());
		Test.stopTest();

		System.assertEquals(UnitTest.getIds('Accounts'), actualBrandMap.keySet(), 'There should be a map entry per each account associated with the owner boat relationship objects passed as parameter');
		for(Set<String> brandSet: actualBrandMap.values()){
			System.assertEquals(new Set<String>(BRAND_CODES), brandSet);
		}

	}*/

	static testMethod void testProcessAccountBrands(){
		
		UnitTest.addData(TestUtilities.createTestOwnerAccounts(50, true)).tag('Accounts').divide(3)
											.part('Accounts with no brands')
											.part('Accounts with one brand')
											.part('Accounts with several brands');

		Map<Id, Set<String>> idToBrandsMap = new Map<Id, Set<String>>();
		
		List<String> brandCodes= new List<String>{'TR','BL','MX', 'AB'};

		for(Account a: (List<Account>) UnitTest.get('Accounts').getList()){
			idToBrandsMap.put(a.Id, new Set<String>());
			if(UnitTest.analyze('Accounts with one brand').hasId(a.Id)){
				idToBrandsMap.get(a.Id).add(brandCodes[0]);		
			} else if(UnitTest.analyze('Accounts with several brands').hasId(a.Id)){
				idToBrandsMap.get(a.Id).addAll(brandCodes);
			}
		}

		Test.startTest();
			List<Account> updatedBrandAccounts = OwnerBoatRelationshipServices.processAccountBrands(idToBrandsMap);
		Test.stopTest();

		UnitTest.analyze('Accounts').assertEquivalence(updatedBrandAccounts, 'We should get the same accounts we passed in the map');

		for(Account a: updatedBrandAccounts){
			if(UnitTest.analyze('Accounts with no brands').hasId(a.Id)){
				System.assert(String.isBlank(a.Brand_Relationships__c),'This field should be empty if there is no brands on the account');
			} else if(UnitTest.analyze('Accounts with one brand').hasId(a.Id)){
				System.assertEquals(brandCodes[0], a.Brand_Relationships__c,'This field should be the brand code if there is one brand associated with the account');
			} else if(UnitTest.analyze('Accounts with several brands').hasId(a.Id)){
				for(String brandCode: brandCodes){
					System.assert(a.Brand_Relationships__c.contains(brandCode),'This field should contain all the brand codes of the brands associated with the account');
				}
			}	
		}		
	}

	static testMethod void testLinkParentAndChildAccountsOwner(){
		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;
		
		UnitTest.addData(TestServices.createBoats(10, false)).tag('Boats')
						.property('Brand_del__c').assignFrom(BRAND_CODES).insertAll();
						
		UnitTest.addData(TestUtilities.createTestOwnerAccounts(9, true)).tag('Accounts');
		
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Boats').getList(), true)).tag('Junction');
		
		Test.startTest();
			Map<Id, List<SObject>> accountToBoatsMap = OwnerBoatRelationshipServices.linkParentAndChildAccounts(UnitTest.get('Accounts').getList(), new Map<Id, SObject>(UnitTest.get('Boats').getList()));
			Map<Id, List<SObject>> accountToOwnerBoatsMap = OwnerBoatRelationshipServices.linkParentAndChildAccounts(UnitTest.get('Accounts').getList(), new Map<Id, SObject>(UnitTest.get('Junction').getList()));
		Test.stopTest();

		System.assertEquals(UnitTest.getIds('Accounts'), accountToBoatsMap.keySet(), 'There should be an entry per account');
		System.assertEquals(UnitTest.getIds('Accounts'), accountToOwnerBoatsMap.keySet(), 'There should be an entry per account');

		for(List<SObject> sObjects: accountToBoatsMap.values()){
			UnitTest.analyze('Boats').assertEquivalence(sObjects, 'Should get the boats related with each account');
		}

		for(Id acctId: accountToOwnerBoatsMap.keySet()){
			System.assertEquals(UnitTest.getIds('Boats').size(), accountToOwnerBoatsMap.get(acctId).size(), 'There should be an owner per boat per account');
			for(Owner_Boat_Relationship__c obr: (List<Owner_Boat_Relationship__c>) accountToOwnerBoatsMap.get(acctId)){
				System.assertEquals(acctId, obr.Owner__c, 'Should get the boats owners related with each account');
			}
		}
	}

	static testMethod void testLinkParentAndChildAccountsDealer(){
		
						
		UnitTest.addData(TestUtilities.createTestDealerAccounts(9, true)).tag('Accounts');
		
		List<Dealer_Brand__c> dealerBrands = new List<Dealer_Brand__c>();

		for(String brand: BRAND_CODES){
			dealerBrands.addAll(TestServices.createDealerBrandRelationships(UnitTest.get('Accounts').getList(),brand, false));

		}

		UnitTest.addData(dealerBrands).tag('Junction').insertAll();
		
		Test.startTest();
			Map<Id, List<SObject>> accountToDealersMap = OwnerBoatRelationshipServices.linkParentAndChildAccounts(UnitTest.get('Accounts').getList(), new Map<Id, SObject>(UnitTest.get('Junction').getList()));
		Test.stopTest();

		
		System.assertEquals(UnitTest.getIds('Accounts'), accountToDealersMap.keySet(), 'There should be an entry per account');

		for(Id acctId: accountToDealersMap.keySet()){
			System.assertEquals(BRAND_CODES.size(), accountToDealersMap.get(acctId).size(), 'There should be a dealer per brand per account');
			for(Dealer_Brand__c obr: (List<Dealer_Brand__c>) accountToDealersMap.get(acctId)){
				System.assertEquals(acctId, obr.Dealer__c, 'Should get the dealers related with each account');
			}
		}
	}
	
	static testmethod void testUpdateOwnerSROCDataWhenMoreRecentJoinDate() {
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		
		Configuration__c boatConfig= new Configuration__c(Name='BoatOwner', RecordId__c=TestUtilities.ADMIN_USER.Id);
		insert boatConfig;
		
		UnitTest.addData(TestServices.createBoats(1, false)).tag('Boats').property('Brand_del__c').assignFrom(BRAND_CODES).insertAll();
		UnitTest.addData(TestUtilities.createTestOwnerAccounts(1, true)).tag('Accounts');
		UnitTest.addData(TestServices.createOwnerBoatRelationships(UnitTest.get('Accounts').getList(), UnitTest.get('Boats').getList(), true)).tag('Junction');
		
		// Update the Account with SROC data we want to be changed
		Account owner = (Account)UnitTest.get('Accounts').getList()[0];
		owner.SROC_Join_Date__c = Date.newInstance(2015, 2, 22);
		owner.SROC_Member_ID__c = '62848512';
		owner.SROC_Ownership_Status__c = 'OWNED';
		update owner;
		
		// Update the owner boat relationship to have more recent data
		list<Owner_Boat_Relationship__c> obrs = UnitTest.get('Junction').getList();
		Owner_Boat_Relationship__c obr = obrs[0];
		obr.SROC_Join_Date__c = Date.newInstance(2015, 2, 23);
		obr.SROC_Member_ID__c = '62848513';
		obr.SROC_Ownership_Status__c = 'OWNED';
		update obr;
		
		Test.startTest();
		OwnerBoatRelationshipServices.updateOwnerSROCData(obrs);
		Test.stopTest();
		
		// Make sure the owner was updated with the new data
		Account updatedOwner = [select Id, SROC_Join_Date__c, SROC_Member_ID__c, SROC_Ownership_Status__c from Account where Id=:owner.Id];
		System.assert(updatedOwner.SROC_Member_ID__c == obr.SROC_Member_ID__c);
		System.assert(updatedOwner.SROC_Join_Date__c == obr.SROC_Join_Date__c);
		System.assert(updatedOwner.SROC_Ownership_Status__c == obr.SROC_Ownership_Status__c);
	}

}