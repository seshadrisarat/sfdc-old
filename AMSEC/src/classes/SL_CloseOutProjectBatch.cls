global class SL_CloseOutProjectBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	String query;
	
	global SL_CloseOutProjectBatch() {
		
	}
	
	global Iterable<sObject> start(Database.BatchableContext BC) {
		Date closeDate = Date.today();
		LIST<AS_Project__c> closingProjects = [SELECT ID,Active__c,Close_Date__c FROM AS_Project__c WHERE Active__c=true AND Close_Date__c!=null AND Close_Date__c<=:closeDate];
		return closingProjects;
	}

  	global void execute(Database.BatchableContext BC, List<AS_Project__c> scope) {
		for(AS_Project__c proj:scope)
		{
			proj.Active__c = false;
		}
		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}