@isTest
public class MigrateAccountAttributesJob_Test {
	
	@istest
	static void testMigrateAccountAttributes() {
		AccountServices.disablePardotLogCheck = true;
		OwnerServices.disablePardotLogCheck = true;
		AccountServices.disableTriggerProcessing = true;
		
		list<Account> owners  = TestUtilities.createTestOwnerAccounts(10, false);
		integer i = 0;
		for (Account owner : owners) {
			owner.BEST_PHONE__C = '111-111-1111';
			owner.BEST_TIME_TO_CONTACT__c = 'test';	
			owner.Email_Opt_in_Date__c = Date.newInstance(2015, 1, 29);
			owner.BIRTHDAY__C = Date.newInstance(2015, 1, 29);
			owner.BOAT_CATEGORY_OF_INTEREST__C = 'Dauntless';
			owner.BUYING_HORIZON__C = '0-1 Month';
			owner.COMMENTS__C = 'test';
			owner.DEALER_NUMBER__C = '555.00' + i++;
			owner.EVENT_NAME__C = 'test';
			owner.HULL_IDENTIFICATION_NUMBER_HIN__C = 'test';
			owner.NOTES__C = 'test';
			owner.PREFERENCE_FOR_NEW_OR_USED__C = 'New';
			owner.PREVIOUS_OWNER_NAME__C = 'test';
			owner.PREVIOUSLY_OWNED_BOAT_BRAND__C = 'Sea Ray';
			owner.PURCHASE_DATE__C = Date.newInstance(2015, 1, 29);
			owner.PURCHASED_BOAT_FROM__C = 'test';
			owner.TRADE_IN_COMMENTS__C = 'test';
			owner.TRADE_IN_MODEL__C = 'test';
			owner.TRADE_IN_YEAR__C = '2001';
			owner.WORK_PHONE__C = '111-111-1111';
		}
		
		insert owners;
		
		Test.startTest();
		MigrateAccountAttributesJob batch = new MigrateAccountAttributesJob();
		Id batchId = Database.executeBatch(batch);
		Test.stopTest();
		
		owners = [select Id, Email_Opt_in_Date__c,BEST_PHONE__C, BEST_TIME_TO_CONTACT__c, BIRTHDAY__C, BOAT_CATEGORY_OF_INTEREST__C, BUYING_HORIZON__C,COMMENTS__C, 
				  	DEALER_NUMBER__C, EVENT_NAME__C, HULL_IDENTIFICATION_NUMBER_HIN__C, NOTES__C,PREFERENCE_FOR_NEW_OR_USED__C,PREVIOUS_OWNER_NAME__C, 
				  	PREVIOUSLY_OWNED_BOAT_BRAND__C, PURCHASE_DATE__C, PURCHASED_BOAT_FROM__C, TRADE_IN_COMMENTS__C, TRADE_IN_MODEL__C, TRADE_IN_YEAR__C, WORK_PHONE__C, 
					Email_Opt_in_Date__pc,Best_Phone__pc, Birthday__pc, best_Time_to_Contact__pc, Boat_Category_of_Interest__pc, Buying_horizon__pc, comments__pc, dealer_number__pc, event_name__pc,
					hull_Identification_Number_HIN__pc, notes__pc, PREFERENCE_FOR_NEW_OR_USED__pc, PREVIOUS_OWNER_NAME__pc, PREVIOUSLY_OWNED_BOAT_BRAND__pc, PURCHASE_DATE__pc, PURCHASED_BOAT_FROM__pc,
					TRADE_IN_COMMENTS__pc, TRADE_IN_MODEL__pc, TRADE_IN_YEAR__pc, WORK_PHONE__pc from Account where IsPersonAccount=true];
		for (Account owner : owners) {
			system.assertEquals(owner.Email_Opt_in_Date__c, owner.Email_Opt_in_Date__pc);
			system.assertEquals(owner.BEST_PHONE__C, owner.BEST_PHONE__PC);
			system.assertEquals(owner.BEST_TIME_TO_CONTACT__c, owner.BEST_TIME_TO_CONTACT__pc);
			system.assertEquals(owner.BIRTHDAY__C, owner.BIRTHDAY__pc);
			system.assertEquals(owner.BUYING_HORIZON__C, owner.BUYING_HORIZON__pc);
			system.assertEquals(owner.COMMENTS__C, owner.COMMENTS__pc);
			system.assertEquals(owner.DEALER_NUMBER__C, owner.DEALER_NUMBER__pc);
			system.assertEquals(owner.EVENT_NAME__C, owner.EVENT_NAME__pc);
			system.assertEquals(owner.HULL_IDENTIFICATION_NUMBER_HIN__C, owner.HULL_IDENTIFICATION_NUMBER_HIN__pc);
			system.assertEquals(owner.NOTES__C, owner.NOTES__pc);
			system.assertEquals(owner.PREFERENCE_FOR_NEW_OR_USED__C, owner.PREFERENCE_FOR_NEW_OR_USED__pc);
			system.assertEquals(owner.PREVIOUS_OWNER_NAME__C, owner.PREVIOUS_OWNER_NAME__pc);
			system.assertEquals(owner.PREVIOUSLY_OWNED_BOAT_BRAND__C, owner.PREVIOUSLY_OWNED_BOAT_BRAND__pc);
			system.assertEquals(owner.PURCHASE_DATE__C, owner.PURCHASE_DATE__pc);
			system.assertEquals(owner.PURCHASED_BOAT_FROM__C, owner.PURCHASED_BOAT_FROM__pc);
			system.assertEquals(owner.TRADE_IN_COMMENTS__C, owner.TRADE_IN_COMMENTS__pc);
			system.assertEquals(owner.TRADE_IN_MODEL__C, owner.TRADE_IN_MODEL__pc);
			system.assertEquals(owner.TRADE_IN_YEAR__C, owner.TRADE_IN_YEAR__pc);
			system.assertEquals(owner.WORK_PHONE__C, owner.WORK_PHONE__pc);
		}
	}
}