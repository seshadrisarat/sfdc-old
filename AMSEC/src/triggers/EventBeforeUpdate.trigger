trigger EventBeforeUpdate on Event (before update) {
	List<Event> updateEvents = new List<Event>();
	Map<Id, Event> callEventMap = new Map<Id, Event>();
	
	for(Event e : trigger.new) {
		Event old = trigger.oldMap.get(e.Id);
		
		if(e.Ind_Grp_Coverage_ID1__c == null || e.WhoId != old.WhoId || e.OwnerId != old.OwnerId) {
			updateEvents.add(e);
		}
		
		if(e.Call_Sync_Id__c != null) {
			callEventMap.put(e.Id, e);
		}
	}
	
	if(!updateEvents.isEmpty()) {
		ActivityUtils.updateIndustryGroupCoverages(updateEvents);
	}
	
	if(!callEventMap.isEmpty() && !CallSyncUtility.DoNotProcessEventUpdate) {
		CallSyncUtility.syncTasksFromEvents(callEventMap);
	}	
}