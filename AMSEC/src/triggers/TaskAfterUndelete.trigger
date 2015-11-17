trigger TaskAfterUndelete on Task (after undelete) {
	Set<Id> eventIds = new Set<Id>();
	for(Task t : trigger.new) {
		if(t.Call_Sync_Id__c != null) {
			eventIds.add(t.Call_Sync_Id__c);
		}
	}
	
	try {
		List<Event> events = [SELECT Id FROM Event WHERE Id IN :eventIds ALL ROWS];
		
		if(!events.isEmpty()) {
			undelete events;
		}
	} catch(DmlException e) {
	} catch(QueryException e) {
	}
}