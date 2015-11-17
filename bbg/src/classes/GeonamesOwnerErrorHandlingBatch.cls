global class GeonamesOwnerErrorHandlingBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {

	global final String query;
	global final Id ownerRecordTypeId = OwnerServices.getOwnerRecordTypeId();
	
	global GeonamesOwnerErrorHandlingBatch() {
		query = 'SELECT Id, Geonames_Retry__c FROM Account WHERE Geonames_Retry__c = true and recordTypeId=:ownerRecordTypeId';	
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		Set<Id> ownerIds = new Set<Id>();

		for(sObject obj : scope){
			ownerIds.add(obj.Id);
		}

		OwnerServices.populateOwnerGeoFields(ownerIds);
	}
	
	//Schedulable function
	global void execute(SchedulableContext sc){
		GeonamesOwnerErrorHandlingBatch batch= new GeonamesOwnerErrorHandlingBatch();
		Database.executeBatch(batch, 9);
		
	}

	global void finish(Database.BatchableContext BC){

	}
}