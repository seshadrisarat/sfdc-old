global class SL_Batch_ServiceRequestLease implements Database.Batchable<sObject> {
	
	String query;
	
	global SL_Batch_ServiceRequestLease() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}