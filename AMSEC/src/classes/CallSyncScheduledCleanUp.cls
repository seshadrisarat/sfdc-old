global class CallSyncScheduledCleanUp implements Schedulable {
	//System.Schedule('Task & Event CleanUp', '0 0 23 * * ?', new CallSyncScheduledCleanUp());
	
	global void execute(SchedulableContext SC){
		General_Settings__c settings = General_Settings__c.getOrgDefaults();
		Integer hours = settings != null && settings.Activity_Retention_Hrs__c != null ? settings.Activity_Retention_Hrs__c.intValue() : 48;
		DateTime maxDateTime = System.now().addHours(-1 * hours);
		
		if(CallSyncUtility.ScheduledCleanUpDebugMode == true){
			maxDateTime = datetime.now();
		}
		
		List<Task> taskDel = [SELECT Id FROM Task WHERE CallObject != null AND Type = 'Call' AND CreatedDate <= :maxDateTime AND CALENDAR_YEAR(CreatedDate) >= 2012 LIMIT 4000];
		if(!taskDel.isEmpty()) {
			CallSyncUtility.DoNotProcessTaskDelete= true;
			delete taskDel;
			CallSyncUtility.DoNotProcessTaskDelete= false;
		}
		
		Map<Id, User> excludeUserMap = new Map<Id, User>([SELECT Id FROM User WHERE Exclude_Call_Cleanup__c = true]);
		
		List<Event> eventDel = [SELECT Id FROM Event WHERE Event_Type__c = 'Phone Call' AND Call_Sync_Id__c != null AND CreatedDate < :maxDateTime AND CALENDAR_YEAR(CreatedDate) >= 2012 AND Event_Status__c != 'Complete' AND Desc_Summary__c in ('', '...') AND OwnerId NOT IN :excludeUserMap.keySet() LIMIT 4000];
		if(!eventDel.isEmpty()) {
			delete eventDel;
		}

		List<Event> eventUpdate = [SELECT Id, Event_Status__c FROM Event WHERE Event_Type__c = 'Phone Call' AND Call_Sync_Id__c != null AND CreatedDate < :maxDateTime AND CALENDAR_YEAR(CreatedDate) >= 2012 AND Event_Status__c != 'Complete' AND Desc_Summary__c NOT in ('', '...') LIMIT 1500];
		for(Event evt: eventUpdate){
			evt.Event_Status__c = 'Complete';
		}
		
		if(!eventUpdate.isEmpty()) {
			update eventUpdate;
		}
	}
}