global class GeonamesDealerErrorHandlingBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {

	global final String query;
	global final Id dealerRecordTypeId = AccountServices.getDealerRecordType();
	
	global GeonamesDealerErrorHandlingBatch() {
		query = 'SELECT Id, Geonames_Retry__c FROM Account WHERE Geonames_Retry__c = true and recordTypeId=:dealerRecordTypeId';	
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		Set<Id> dealerIds = new Set<Id>();

		for(sObject obj : scope){
			dealerIds.add(obj.Id);
		}
		
		AccountServices.populateAccountGeoFields(dealerIds);
	}
	
	//Schedulable function
	global void execute(SchedulableContext sc){
		GeonamesDealerErrorHandlingBatch batch= new GeonamesDealerErrorHandlingBatch();
		
		if (Test.isRunningTest()) {
			system.debug('executing test batch');
			Database.executeBatch(batch, 100);
		}
		else {
			system.debug('executing batch');
			Database.executeBatch(batch, 9);
		}
		
	}

	global void finish(Database.BatchableContext BC){

	}
}