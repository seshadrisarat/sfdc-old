trigger TaskAfterInsert on Task (after insert) {
	Map<Id, Task> eventTaskMap = new Map<Id, Task>();
	for(Task t : trigger.new) {
		if(t.CallObject != null && t.Call_Sync_Id__c != null) {
			eventTaskMap.put(t.Call_Sync_Id__c, t);
		}
	}
	
	List<Event> events = [SELECT Id, Call_Sync_Id__c FROM Event WHERE Id IN :eventTaskMap.keySet()];
	
	if(!events.isEmpty()) {
		for(Event e : events) {
			Task t = eventTaskMap.get(e.Id);
			e.Call_Sync_Id__c = t.Id;
		}
		
		CallSyncUtility.DoNotProcessEventUpdate = true;
		update events;
		CallSyncUtility.DoNotProcessEventUpdate = false;
	}
}