trigger EventAfterDelete on Event (after delete) {
	if(CallSyncUtility.DoNotProcessEventDelete) {
		return;
	}
	
	Set<Id> taskIds = new Set<Id>();
	
	for(Event e : trigger.old) {
		if(e.Call_Sync_Id__c != null) {
			taskIds.add(e.Call_Sync_Id__c);
		}
	}
	
	if(!taskIds.isEmpty()) {
		List<Task> tasks = [SELECT Id FROM Task WHERE Id IN :taskIds];
		CallSyncUtility.DoNotProcessTaskDelete = true;
		delete tasks;
		CallSyncUtility.DoNotProcessTaskDelete = false;
	}
}