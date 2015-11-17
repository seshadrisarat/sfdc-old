trigger TaskBeforeInsertBeforeUpdate on Task (before insert, before update) {
	if(Trigger.isUpdate && CallSyncUtility.DoNotProcessTaskUpdate) {
		return;
	}
	
	List<Task> callTasks = new List<Task>();
	
	for(Task t : trigger.new) {
		if(t.CallObject != null) {
			callTasks.add(t);
		}
	}
	
	if(!callTasks.isEmpty()) {
		CallSyncUtility.syncEventsFromTasks(callTasks);
	}
}