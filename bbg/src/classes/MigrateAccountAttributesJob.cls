global class MigrateAccountAttributesJob implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
	private static final string QUERY = 'select Id, Email_Opt_in_Date__c, BEST_PHONE__C, BEST_TIME_TO_CONTACT__c, BIRTHDAY__C, BOAT_CATEGORY_OF_INTEREST__C, BUYING_HORIZON__C,COMMENTS__C, ' +
										'DEALER_NUMBER__C, EVENT_NAME__C, HULL_IDENTIFICATION_NUMBER_HIN__C, NOTES__C,PREFERENCE_FOR_NEW_OR_USED__C,PREVIOUS_OWNER_NAME__C,' +
										'PREVIOUSLY_OWNED_BOAT_BRAND__C, PURCHASE_DATE__C, PURCHASED_BOAT_FROM__C, TRADE_IN_COMMENTS__C, TRADE_IN_MODEL__C, TRADE_IN_YEAR__C, WORK_PHONE__C, ' +
										'Email_Opt_in_Date__pc, Best_Phone__pc, Best_Time_to_Contact__pc, Birthday__pc, Boat_Category_of_Interest__pc, Buying_horizon__pc, comments__pc, dealer_number__pc, event_name__pc,' +
										'hull_Identification_Number_HIN__pc, notes__pc, PREFERENCE_FOR_NEW_OR_USED__pc, PREVIOUS_OWNER_NAME__pc, PREVIOUSLY_OWNED_BOAT_BRAND__pc, PURCHASE_DATE__pc, PURCHASED_BOAT_FROM__pc,' +
										'TRADE_IN_COMMENTS__pc, TRADE_IN_MODEL__pc, TRADE_IN_YEAR__pc, WORK_PHONE__pc ' +
										'from Account where IsPersonAccount=true and Brand__c <> null'; 
	
	global void execute( SchedulableContext sc ) {
		MigrateAccountAttributesJob batch = new MigrateAccountAttributesJob();
		Database.executeBatch(batch);
	}
	
	global Database.QueryLocator start( Database.BatchableContext BC ) {
		return Database.getQueryLocator( query );
	}
	
	global void execute( Database.BatchableContext BC, list<sObject> scope) {
		list<Account> accounts = (list<Account>)scope;
		migrateAccountAttributes(accounts);
	}
	
	global void finish(Database.BatchableContext BC) {
	}
	
	private void migrateAccountAttributes(list<Account> accounts) {
		for (Account account : accounts) {
			migrateAccountAttributes(account);	
		}	
		
		AccountServices.disablePardotLogCheck = true;
		OwnerServices.disablePardotLogCheck = true;
		AccountServices.disableTriggerProcessing = true;
		update accounts;
	}
	
	private void migrateAccountAttributes(Account account) {
		account.Email_Opt_in_Date__pc = account.Email_Opt_in_Date__c;
		account.Best_Phone__pc = account.BEST_PHONE__C;
		account.Best_Time_to_Contact__pc = account.BEST_TIME_TO_CONTACT__c;	
		account.Birthday__pc = account.BIRTHDAY__C;
		account.Boat_Model_Interest__pc = account.Boat_Model_Interest__pc;
		account.Boat_Category_of_Interest__pc = account.BOAT_CATEGORY_OF_INTEREST__C;
		account.Buying_horizon__pc = account.BUYING_HORIZON__C;
		account.comments__pc = account.COMMENTS__C;
		account.dealer_number__pc = account.DEALER_NUMBER__C;
		account.event_name__pc = account.EVENT_NAME__C;
		account.hull_Identification_Number_HIN__pc = account.HULL_IDENTIFICATION_NUMBER_HIN__C;
		account.notes__pc = account.NOTES__C;
		account.PREFERENCE_FOR_NEW_OR_USED__pc = account.PREFERENCE_FOR_NEW_OR_USED__C;
		account.PREVIOUS_OWNER_NAME__pc = account.PREVIOUS_OWNER_NAME__C;
		account.PREVIOUSLY_OWNED_BOAT_BRAND__pc = account.PREVIOUSLY_OWNED_BOAT_BRAND__C;
		account.PURCHASE_DATE__pc = account.PURCHASE_DATE__C;
		account.PURCHASED_BOAT_FROM__pc = account.PURCHASED_BOAT_FROM__C;
		account.TRADE_IN_COMMENTS__pc = account.TRADE_IN_COMMENTS__C;
		account.TRADE_IN_MODEL__pc = account.TRADE_IN_MODEL__C;
		account.TRADE_IN_YEAR__pc = account.TRADE_IN_YEAR__C;
		account.WORK_PHONE__pc = account.WORK_PHONE__C;
	}
}