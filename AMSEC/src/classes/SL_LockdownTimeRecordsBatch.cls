global class SL_LockdownTimeRecordsBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	String query;
	
	global SL_LockdownTimeRecordsBatch() {
		
	}
	
	global Iterable<sObject> start(Database.BatchableContext BC) {
		Date today = Date.today();
		Date prevMonth = today.addMonths(-1);
		Date prevMonthStart = prevMonth.toStartOfMonth();
		Date prevMonthEnd = (prevMonthStart + Date.daysInMonth(prevMonth.year(), prevMonth.month()))-1;
		List<Project_Time_Tracking__c> timeEntries = [SELECT ID,Date__c,Locked__c FROM Project_Time_Tracking__c WHERE Date__c<=:prevMonthEnd AND Locked__c = false];
		return timeEntries;
	}

   	global void execute(Database.BatchableContext BC, List<Project_Time_Tracking__c> scope) {
		for(Project_Time_Tracking__c entry: scope)
		{
			entry.Locked__c = true;
		}
		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}