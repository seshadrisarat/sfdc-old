global class SendFootstepsLeadsBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
	
	global final String query;
	
	global SendFootstepsLeadsBatch(){
		query = 'SELECT Id, Footsteps_Retry__c FROM Lead WHERE Footsteps_Retry__c = true';	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		if (scope != null){
			FootStepsService service = new FootStepsService();
			service.footstepsFieldsMakeCallout(Pluck.ids(scope));
		}
	}

	global void finish(Database.BatchableContext BC){

	}
	
	//Schedulable function
	global void execute(SchedulableContext sc){
		SendFootstepsLeadsBatch batch= new SendFootstepsLeadsBatch();
		Database.executeBatch(batch, FootstepsService.MAX_FOOTSTEPS_LEAD_BATCH_SIZE);
	}
}