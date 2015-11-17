@isTest
public class DealerServicesTest {
	
	static String TEST_DEALER_NUMBER = '444.22';
	static String TEST_DEALER_NUMBER_2 = '333.22';
	
	
	public static testMethod void testFieldHasChanged_nochange(){
		
		Set<String> dealerConsolidationFields = new Set<String>{'Consolidated_To_Dealer_Datetime__c', 'Consolidated_To_Dealer_Number__c'};
		
		Date testDatetime = Date.today();
		Account acc = new Account(Consolidated_To_Dealer_Datetime__c = testDatetime, Consolidated_To_Dealer_Number__c=TEST_DEALER_NUMBER);
		Account oldAcct =  new Account(Consolidated_To_Dealer_Datetime__c = testDatetime, Consolidated_To_Dealer_Number__c=TEST_DEALER_NUMBER);
		
		Test.startTest();
			Boolean result = DealerServices.fieldHasChanged(acc, oldAcct, dealerConsolidationFields);
		Test.stopTest();
		
		System.assertEquals(false, result, 'We expect to get back no change');
		
	}
	
	public static testMethod void testFieldHasChanged_onefieldChange(){
		
		Set<String> dealerConsolidationFields = new Set<String>{'Consolidated_To_Dealer_Datetime__c', 'Consolidated_To_Dealer_Number__c'};
		
		Date testDatetime = Date.today();
		Account acc = new Account(Consolidated_To_Dealer_Datetime__c = testDatetime, Consolidated_To_Dealer_Number__c=TEST_DEALER_NUMBER);
		Account oldAcct =  new Account(Consolidated_To_Dealer_Datetime__c = testDatetime, Consolidated_To_Dealer_Number__c=TEST_DEALER_NUMBER_2);
		
		Test.startTest();
			Boolean result = DealerServices.fieldHasChanged(acc, oldAcct, dealerConsolidationFields);
		Test.stopTest();
		
		System.assertEquals(true, result, 'We expect to get back a field change');
		
	}
	
	public static testMethod void testFieldHasChanged_bothfieldsChange(){
		
		Set<String> dealerConsolidationFields = new Set<String>{'Consolidated_To_Dealer_Datetime__c', 'Consolidated_To_Dealer_Number__c'};
		
		Date testDatetime = Date.today();
		Account acc = new Account(Consolidated_To_Dealer_Datetime__c = testDatetime, Consolidated_To_Dealer_Number__c=TEST_DEALER_NUMBER);
		Account oldAcct =  new Account(Consolidated_To_Dealer_Datetime__c = testDatetime+3, Consolidated_To_Dealer_Number__c=TEST_DEALER_NUMBER_2);
		
		Test.startTest();
			Boolean result = DealerServices.fieldHasChanged(acc, oldAcct, dealerConsolidationFields);
		Test.stopTest();
		
		System.assertEquals(true, result, 'We expect to get back a field change');
		
	}
	
	
	
	public static testMethod void testFieldIsBlank_notBlank(){
		
		Set<String> dealerConsolidationFields = new Set<String>{'Consolidated_To_Dealer_Datetime__c', 'Consolidated_To_Dealer_Number__c'};
		
		Date testDatetime = Date.today();
		Account acc = new Account(Consolidated_To_Dealer_Datetime__c = testDatetime, Consolidated_To_Dealer_Number__c=TEST_DEALER_NUMBER);
		
		Test.startTest();
			Boolean result = DealerServices.fieldIsBlank(acc, dealerConsolidationFields);
		Test.stopTest();
		
		System.assertEquals(false, result, 'We expect to get back field is not blank');
		
	}
	
	public static testMethod void testFieldIsBlank_isBlank(){
		
		Set<String> dealerConsolidationFields = new Set<String>{'Consolidated_To_Dealer_Datetime__c', 'Consolidated_To_Dealer_Number__c'};
		
		Date testDatetime = Date.today();
		Account acc = new Account(Consolidated_To_Dealer_Number__c=TEST_DEALER_NUMBER);
		
		Test.startTest();
			Boolean result = DealerServices.fieldIsBlank(acc, dealerConsolidationFields);
		Test.stopTest();
		
		System.assertEquals(true, result, 'We expect to get back field is blank');
		
	}
	
	
	public static testMethod void testFilterDealersToBeConsilidated(){
		
		List<Account> testAccounts = TestUtilities.createTestDealerAccounts(200, false);
		TestUtilities.dummyInsert(testAccounts);
		
		UnitTest.addData(testAccounts).tag('Accounts');
		UnitTest.get('Accounts')
			.divide(4)
			.part('Accounts with no changes')
			.part('Accounts with wrong record type')
			.part('Accounts with one field change')
			.part('Accounts with all field change');
		
		UnitTest.get('Accounts with one field change').tag('Filtered Accounts');
		UnitTest.get('Accounts with all field change').tag('Filtered Accounts');
			
		UnitTest.get('Accounts with one field change')
			.property('Consolidated_To_Dealer_Number__c').assign(TEST_DEALER_NUMBER)
			.property('Consolidated_To_Dealer_Datetime__c').assign(Date.today());
			
		UnitTest.get('Accounts with all field change')
			.property('Consolidated_To_Dealer_Datetime__c').assign(Date.today())
			.property('Consolidated_To_Dealer_Number__c').assign(TEST_DEALER_NUMBER);
			
		UnitTest.get('Accounts with wrong record type')
			.property('Consolidated_To_Dealer_Datetime__c').assign(Date.today())
			.property('Consolidated_To_Dealer_Number__c').assign(TEST_DEALER_NUMBER);
		
		Map<Id, Account> oldMapClone = new Map<Id, Account>((List<Account>)UnitTest.get('Accounts').getList().deepClone(true));
		
		UnitTest.get('Accounts with one field change')
			.property('Consolidated_To_Dealer_Number__c').assign(TEST_DEALER_NUMBER)
			.property('Consolidated_To_Dealer_Datetime__c').assign(Date.today()+9);
			
		UnitTest.get('Accounts with all field change')
			.property('Consolidated_To_Dealer_Datetime__c').assign(Date.today()-2)
			.property('Consolidated_To_Dealer_Number__c').assign(TEST_DEALER_NUMBER_2);
			
		UnitTest.get('Accounts with wrong record type')
			.property('RecordTypeId').assign(TestUtilities.RECORD_TYPES.get(TestUtilities.OWNER_ACCOUNT))
			.property('Consolidated_To_Dealer_Datetime__c').assign(Date.today()-2)
			.property('Consolidated_To_Dealer_Number__c').assign(TEST_DEALER_NUMBER_2);
			
		
		Test.startTest();
			List<Account> filteredAccounts = DealerServices.filterDealersToBeConsilidated((List<Account>)UnitTest.get('Accounts').getList(), oldMapClone);
		Test.stopTest();
		
		UnitTest.analyze('Filtered Accounts').assertEquivalence(filteredAccounts, 
			'We expect to filter the accounts that are dealer record type and have a field change');
		
	}


	public static testMethod void testGetSObjectsRelatedToAccounts(){
		AccountServices.disableTriggerProcessing = true;
		BoatServices.disableTriggerProcessing = true;
		
		User boatOwner = TestServices.getUser('insertNewBoat@test.com');
		insert boatOwner;
		
		Configuration__c config = new Configuration__c(Name='BoatOwner',RecordId__c=boatOwner.Id);
		insert config;
		
		String TEST_DEALER_NUMBER_A = '1342.33';
		String TEST_DEALER_NUMBER_B = '2342.33';
		String TEST_DEALER_NUMBER_C = '3342.33';
		
		List<Account> testAccounts = TestUtilities.createTestDealerAccounts(3, false);
		testAccounts[0].Dealer_Number__c = TEST_DEALER_NUMBER_A;
		testAccounts[1].Dealer_Number__c = TEST_DEALER_NUMBER_B;
		testAccounts[2].Dealer_Number__c = TEST_DEALER_NUMBER_C;
		insert testAccounts;
		
		List<Boat__c> testBoats = TestServices.createBoats(10, false);
		
		UnitTest.addData(testBoats).tag('Boats');
		UnitTest.get('Boats')
			.divide(3)
			.part('Boats attached to Account A')
			.part('Boats attached to Account B')
			.part('Boats attached to Account C');
		
		UnitTest.get('Boats attached to Account A')
			.property('DealerNumLoc__c').assign(testAccounts[0].Dealer_Number__c)
			.property('Dealer__c').assign(testAccounts[0].Id);
		UnitTest.get('Boats attached to Account B')
			.property('DealerNumLoc__c').assign(testAccounts[1].Dealer_Number__c)
			.property('Dealer__c').assign(testAccounts[1].Id);
		UnitTest.get('Boats attached to Account C')
			.property('DealerNumLoc__c').assign(testAccounts[2].Dealer_Number__c)
			.property('Dealer__c').assign(testAccounts[2].Id);
		
		UnitTest.get('Boats').insertAll();
		
		UnitTest.get('Boats attached to Account B').tag('Expected Boats');
		UnitTest.get('Boats attached to Account A').tag('Expected Boats');
		
		AccountServices.disableTriggerProcessing = false;
		BoatServices.disableTriggerProcessing = false;
		
		Set<Id> testAccountIds = new Set<Id>{testAccounts[0].Id, testAccounts[1].Id};
	
		Test.startTest();
			List<SObject> filteredBoats = DealerServices.getSObjectsRelatedToAccounts('Boat__c', testAccountIds, 'Dealer__c');
		Test.stopTest();
		
		UnitTest.analyze('Expected Boats').assertEquivalence(filteredBoats, 
			'We expect to filter the boats that are associated to account A and B');
		
		for (SObject sobj : filteredBoats){
			System.assert(testAccountIds.contains((Id)sobj.get('Dealer__c')), 'We expect the dealer to be either account A or B');
		}
		
	}
	
	
	public static testMethod void testGetSObjectsRelatedToAccounts_whereClause(){
		AccountServices.disableTriggerProcessing = true;
		BoatServices.disableTriggerProcessing = true;
		
		User boatOwner = TestServices.getUser('insertNewBoat@test.com');
		insert boatOwner;
		
		Configuration__c config = new Configuration__c(Name='BoatOwner',RecordId__c=boatOwner.Id);
		insert config;
		
		String TEST_DEALER_NUMBER_A = '1342.33';
		String TEST_DEALER_NUMBER_B = '2342.33';
		String TEST_DEALER_NUMBER_C = '3342.33';
		String TEST_BRAND = 'SeaRay';
		
		List<Account> testAccounts = TestUtilities.createTestDealerAccounts(3, false);
		testAccounts[0].Dealer_Number__c = TEST_DEALER_NUMBER_A;
		testAccounts[1].Dealer_Number__c = TEST_DEALER_NUMBER_B;
		testAccounts[2].Dealer_Number__c = TEST_DEALER_NUMBER_C;
		
		insert testAccounts;
		
		List<Boat__c> testBoats = TestServices.createBoats(10, false);
		
		UnitTest.addData(testBoats).tag('Boats');
		UnitTest.get('Boats')
			.divide(3)
			.part('Boats attached to Account A')
			.part('Boats attached to Account B')
			.part('Boats attached to Account C');
		
		UnitTest.get('Boats attached to Account A')
			.property('DealerNumLoc__c').assign(testAccounts[0].Dealer_Number__c)
			.property('Dealer__c').assign(testAccounts[0].Id);
		UnitTest.get('Boats attached to Account B')
			.property('DealerNumLoc__c').assign(testAccounts[1].Dealer_Number__c)
			.property('Dealer__c').assign(testAccounts[1].Id);
		UnitTest.get('Boats attached to Account C')
			.property('DealerNumLoc__c').assign(testAccounts[2].Dealer_Number__c)
			.property('Dealer__c').assign(testAccounts[2].Id)
			.property('Brand_del__c').assign(TEST_BRAND);
		
		UnitTest.get('Boats').insertAll();
		
		UnitTest.get('Boats attached to Account C').tag('Expected Boats');
		
		AccountServices.disableTriggerProcessing = false;
		BoatServices.disableTriggerProcessing = false;
		
		Set<Id> testAccountIds = Pluck.ids(testAccounts);
	
		Test.startTest();
			List<SObject> filteredBoats = DealerServices.getSObjectsRelatedToAccounts('Boat__c', testAccountIds, 'Dealer__c', 
																						'Brand_del__c = \'' + TEST_BRAND + '\'' );
		Test.stopTest();
		
		UnitTest.analyze('Expected Boats').assertEquivalence(filteredBoats, 
			'We expect to filter the boats that are associated to account C');
			
		for (SObject sobj : filteredBoats){
			System.assert(testAccountIds.contains((Id)sobj.get('Dealer__c')), 'We expect the dealer to be either account C');
		}
		
	}
	
	public static testMethod void test_reparentObjects()
	{
		List<Account> testAccounts = TestUtilities.createTestDealerAccounts(4, false);
		TestUtilities.dummyInsert(testAccounts);
		
		// Create Accounts, split them and create a Map to point from old account to new account for reparenting 
		UnitTest.addData(testAccounts).tag('Accounts');
		UnitTest.get('Accounts')
			.divide(2)
			.part('Original Parents')
			.part('New Parents');
		
		List<sObject> oldParents = UnitTest.get('Original Parents').getList();
		List<sObject> newParents = UnitTest.get('New Parents').getList();
		System.assertEquals( oldParents.size(), newParents.size(), 'We expect the Old Parent and New Parent Lists to be have a 1 to 1 relationship' );
		
		Map<Id, Id> oldAccountToNewAccount = new Map<Id, Id>();
		for( Integer i = 0; i < UnitTest.get('Original Parents').getList().size(); i++ )
		{
			oldAccountToNewAccount.put(oldParents.get(i).Id, newParents.get(i).Id );
		}

		// Create boats that will be reparented 
		List<Boat__c> testBoats = TestServices.createBoats(100, false);
		UnitTest.addData(testBoats).tag('Boats');
		UnitTest.get('Boats')
			.divide(2)
			.part('Boats attached to Account 0')
			.part('Boats attached to Account 1');
		
		String boatParentField = DealerServices.SOBJECT_TYPE_TO_ACCOUNT_FIELD.get(Boat__c.getSObjectType());
		UnitTest.get('Boats attached to Account 0')
			.property(boatParentField).assign(oldParents[0].Id);
		UnitTest.get('Boats attached to Account 1')
			.property(boatParentField).assign(oldParents[1].Id);
			
		// Create Contacts that will be reparented 
		List<Contact> testContacts = TestUtilities.createContacts(100, false);
		UnitTest.addData(testContacts).tag('Contacts');
		UnitTest.get('Contacts')
			.divide(2)
			.part('Contacts attached to Account 0')
			.part('Contacts attached to Account 1');
			
		String contactParentField = DealerServices.SOBJECT_TYPE_TO_ACCOUNT_FIELD.get(Contact.getSObjectType());
		UnitTest.get('Contacts attached to Account 0')
			.property(contactParentField).assign(oldParents[0].Id);
		UnitTest.get('Contacts attached to Account 1')
			.property(contactParentField).assign(oldParents[1].Id);
			
		
		Test.startTest();
			List<SObject> sObjList = new List<SObject>();
			sObjList.addAll(UnitTest.get( 'Boats' ).getList());
			sObjList.addAll(UnitTest.get( 'Contacts' ).getList());
			
			DealerServices.reparentObjects( sObjList, oldAccountToNewAccount );
		Test.stopTest();
		
		for( sObject sObj : UnitTest.get('Boats attached to Account 0').getList() )
		{
			System.assertEquals(newParents[0].Id, sObj.get(boatParentField), 'We expect the boat to be repopulated.');
		}
		
		for( sObject sObj : UnitTest.get('Contacts attached to Account 0').getList() )
		{
			System.assertEquals(newParents[0].Id, sObj.get(contactParentField), 'We expect the boat to be repopulated.');
		}

		for( sObject sObj : UnitTest.get('Boats attached to Account 1').getList() )
		{
			System.assertEquals(newParents[1].Id, sObj.get(boatParentField), 'We expect the boat to be repopulated.');
		}
		
		for( sObject sObj : UnitTest.get('Contacts attached to Account 1').getList() )
		{
			System.assertEquals(newParents[1].Id, sObj.get(contactParentField), 'We expect the boat to be repopulated.');
		}
	}
	
	
	public static testMethod void testDealerReparent_trigger(){
		AccountServices.disableTriggerProcessing = true;
		BoatServices.disableTriggerProcessing = true;
		
		User boatOwner = TestServices.getUser('insertNewBoat@test.com');
		insert boatOwner;
		
		Configuration__c config = new Configuration__c(Name='BoatOwner',RecordId__c=boatOwner.Id);
		insert config;
		
		List<Account> testAccounts = TestUtilities.createTestDealerAccounts(2, false);
		
		// Create Accounts, split them and create a Map to point from old account to new account for reparenting 
		UnitTest.addData(testAccounts).tag('Accounts');
		UnitTest.get('Accounts')
			.divide(2)
			.part('Account to ReParent')
			.part('New Parent');
			
		UnitTest.get('Account to ReParent')
			.property('Dealer_Number__c').assign(TEST_DEALER_NUMBER);
			
		UnitTest.get('New Parent')
			.property('Dealer_Number__c').assign(TEST_DEALER_NUMBER_2);
			
		UnitTest.get('Accounts').insertAll();
		
		// Create boats that will be reparented 
		List<Boat__c> testBoats = TestServices.createBoats(100, false);
		UnitTest.addData(testBoats).tag('Boats attached to Old Parent');
		
		String boatParentField = DealerServices.SOBJECT_TYPE_TO_ACCOUNT_FIELD.get(Boat__c.getSObjectType());
		UnitTest.get('Boats attached to Old Parent')
			.property('DealerNumLoc__c').assign(TEST_DEALER_NUMBER)
			.property('Dealer__c').assign(UnitTest.get('Account to ReParent').getList()[0].Id);
			
		// Create Contacts that will be reparented 
		List<Contact> testContacts = TestUtilities.createContacts(100, false);
		UnitTest.addData(testContacts).tag('Contacts attached to Old Parent');
			
		String contactParentField = DealerServices.SOBJECT_TYPE_TO_ACCOUNT_FIELD.get(Contact.getSObjectType());
		UnitTest.get('Contacts attached to Old Parent')
			.property(contactParentField).assign(UnitTest.get('Account to ReParent').getList()[0].Id);
	
			
		UnitTest.get('Boats attached to Old Parent').insertAll();
		UnitTest.get('Contacts attached to Old Parent').insertAll();
		
		AccountServices.disableTriggerProcessing = false;
		BoatServices.disableTriggerProcessing = false;
			
		Test.startTest();
			DealerServices.ACCOUNTS_TO_REPROCESS = true;
			
			UnitTest.get('Account to ReParent')
				.property('Consolidated_To_Dealer_Number__c').assign(TEST_DEALER_NUMBER_2)
				.property('Consolidated_To_Dealer_Datetime__c').assign(Date.today());
			
			UnitTest.get('Account to ReParent').updateAll();
			
		Test.stopTest();
		
		testAccounts = [Select Id, Consolidated_To_Dealer__c From Account where Id in :UnitTest.get('Account to ReParent').getList() ];
		for (Account acc : testAccounts){
			system.debug('*************** Test account consolidated to dealer: ' + acc.Consolidated_To_Dealer__c);
			System.assert(UnitTest.getIds('New Parent').contains(acc.Consolidated_To_Dealer__c), 
				'We expect the Consolidated_To_Dealer__c field to be populated with the new parent id');
		}
		
		List<Boat__c> boatsAttachedToOldAccount = [ Select Id from Boat__c Where Dealer__c in :UnitTest.get('Account to ReParent').getList() ];
		List<Boat__c> boatsAttachedToNewAccount = [ Select Id from Boat__c Where Dealer__c in :UnitTest.get('New Parent').getList() ];
		
		List<Contact> contactsAttachedToOldAccount = [ Select Id from Contact Where AccountId in :UnitTest.get('Account to ReParent').getList() ];
		List<Contact> contactsAttachedToNewAccount = [ Select Id from Contact Where AccountId in :UnitTest.get('New Parent').getList() ];
		
		System.assert(boatsAttachedToOldAccount.isEmpty(), 'We expect no boats to be on the old parent.');
		System.assert(contactsAttachedToOldAccount.isEmpty(), 'We expect no contacts to be on the old parent.');
		
		System.assertEquals(testBoats.size(), boatsAttachedToNewAccount.size(), 'We expect boats to be on the new parent.');
		System.assertEquals(testContacts.size(), contactsAttachedToNewAccount.size(), 'We expect contacts to be on the new parent.');
		

	}
	
}