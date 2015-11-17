global class SL_LockdownStatusRecordsBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	String query;
	
	global SL_LockdownStatusRecordsBatch() {
		
	}
	
	global Iterable<sObject> start(Database.BatchableContext BC) {
		Date today = Date.today();
		Date prevMonth = today.addMonths(-1);
		Date prevMonthStart = prevMonth.toStartOfMonth();
		Date prevMonthEnd = prevMonthStart + Date.daysInMonth(prevMonth.year(), prevMonth.month())-1;
		List<AS_Project_Status__c> timeEntries = [SELECT ID,Month_Ending__c,Locked__c FROM AS_Project_Status__c WHERE Month_Ending__c<=:prevMonthEnd AND Locked__c = false];
		return timeEntries;
	}

   	global void execute(Database.BatchableContext BC, List<AS_Project_Status__c> scope) {
		for(AS_Project_Status__c entry: scope)
		{
			entry.Locked__c = true;
		}
		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}