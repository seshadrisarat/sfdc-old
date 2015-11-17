@isTest
public class DealerConsolidationBatchTest {
	
	static String TEST_DEALER_NUMBER = '444.22';
	static String TEST_DEALER_NUMBER_2 = '333.22';

	public static testMethod void testDealerReparentBatch(){
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
			.property('RecordTypeId').assign(DealerServices.DEALER_RECORD_TYPE_ID)
			.property('Dealer_Number__c').assign(TEST_DEALER_NUMBER)
			.property('Consolidated_To_Dealer_Number__c').assign(TEST_DEALER_NUMBER_2)
			.property('Consolidated_To_Dealer_Datetime__c').assign(Date.today())
			.property('Re_Process_Consolidation__c').assign(true)
			.property('Brand__c').assign('SR');
			
		UnitTest.get('New Parent')
			.property('RecordTypeId').assign(DealerServices.DEALER_RECORD_TYPE_ID)
			.property('Dealer_Number__c').assign(TEST_DEALER_NUMBER_2)
			.property('Brand__c').assign('SR');
			
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
		
		Test.startTest();
			DealerConsolidationBatch batch = new DealerConsolidationBatch();
			Database.executeBatch( batch );
		Test.stopTest();
		
		testAccounts = [Select Id, Consolidated_To_Dealer__c From Account where Id in :UnitTest.get('Account to ReParent').getList() ];
		for (Account acc : testAccounts){
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
		BoatServices.disableTriggerProcessing = false;
		AccountServices.disableTriggerProcessing = false;
	}
}