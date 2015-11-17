global class GeonamesErrorHandlingBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {

	global final String query;
	
	global GeonamesErrorHandlingBatch(){
		query = 'SELECT Id, Geonames_Retry__c FROM Lead WHERE Geonames_Retry__c = true';	
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		Set<Id> leadIds = new Set<Id>();

		for(sObject obj : scope){
			leadIds.add(obj.Id);
		}

		LeadServices.geoFieldsMakeCallout(leadIds, false);
	}
	
	//Schedulable function
	global void execute(SchedulableContext sc){
		GeonamesErrorHandlingBatch batch= new GeonamesErrorHandlingBatch();
		Database.executeBatch(batch, 9);
		
	}

	global void finish(Database.BatchableContext BC){

	}
}