trigger TaskAfterDelete on Task (after delete) {
	if(CallSyncUtility.DoNotProcessTaskDelete) {
		return;
	}
	
	Set<Id> eventIds = new Set<Id>();
	
	for(Task t : trigger.old) {
		if(t.Call_Sync_Id__c != null) {
			eventIds.add(t.Call_Sync_Id__c);
		}
	}
	
	if(!eventIds.isEmpty()) {
		List<Event> events = [SELECT Id FROM Event WHERE Id IN :eventIds];
		CallSyncUtility.DoNotProcessEventDelete = true;
		delete events;
		CallSyncUtility.DoNotProcessEventDelete = false;
	}
}