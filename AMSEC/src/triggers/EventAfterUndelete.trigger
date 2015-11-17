trigger EventAfterUndelete on Event (after undelete) {
	Set<Id> taskIds = new Set<Id>();
	for(Event e : trigger.new) {
		if(e.Call_Sync_Id__c != null) {
			taskIds.add(e.Call_Sync_Id__c);
		}
	}
	
	try {
		List<Task> tasks = [SELECT Id FROM Task WHERE Id IN :taskIds ALL ROWS];
		
		if(!tasks.isEmpty()) {
			undelete tasks;
		}
	} catch(DmlException e) {
	} catch(QueryException e) {
	}
}