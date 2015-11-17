global class SL_RelockTimeRecordsBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	String query;
	
	global SL_RelockTimeRecordsBatch() {
		
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
		//AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email  FROM AsyncApexJob WHERE Id = :BC.getJobId()];
		//then use the active job id and abort it
		//System.abortJob(a.id);
	}
	
}