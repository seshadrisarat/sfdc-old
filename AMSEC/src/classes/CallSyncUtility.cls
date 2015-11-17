public with sharing class CallSyncUtility {
	public static Boolean DoNotProcessEventUpdate { get; set; }
	public static Boolean DoNotProcessEventDelete { get; set; }
	public static Boolean DoNotProcessTaskUpdate { get; set; }
	public static Boolean DoNotProcessTaskDelete { get; set; }
	public static Boolean ScheduledCleanUpDebugMode { get; set; }
	
	static {
		DoNotProcessEventUpdate = false;
		DoNotProcessEventDelete = false;
		DoNotProcessTaskUpdate = false;
		DoNotProcessTaskDelete = false;
		ScheduledCleanUpDebugMode = false;
	}
	
	public static void syncEventsFromTasks(List<Task> tasks) {
		Map<Task, Event> newTaskEventMap = new Map<Task, Event>();
		Set<Id> updateEventIds = new Set<Id>();
		List<Task> updateTasks = new List<Task>();
		
		for(Task t : tasks) {
			if(t.CallObject != null) { 
				if(t.Call_Sync_Id__c == null) {
					Event e = new Event();
					syncTaskToEvent(t, e);
					
					if(t.Id != null) {
						e.Call_Sync_Id__c = t.Id;
					}
					
					newTaskEventMap.put(t, e);
				} else {
					updateEventIds.add(t.Call_Sync_Id__c);
					updateTasks.add(t);
				}
			}
		}
		
		if(!newTaskEventMap.isEmpty()) {
			insert newTaskEventMap.values();
			
			for(Task t : newTaskEventMap.keySet()) {
				t.Call_Sync_Id__c = newTaskEventMap.get(t).Id;
			}
		}
		
		if(!updateEventIds.isEmpty()) {
			Map<Id, Event> eventMap = new Map<Id, Event>([SELECT Id, Call_Sync_Id__c, Subject, Description, WhatId, WhoId, StartDateTime, EndDateTime, Last_Sync__c FROM Event WHERE Id IN :updateEventIds]);
			
			for(Task t : updateTasks) {
				Event e = eventMap.get(t.Call_Sync_Id__c);
				syncTaskToEvent(t, e);
			}
			
			DoNotProcessEventUpdate = true;
			update eventMap.values();
			DoNotProcessEventUpdate = false;
		}
	}
	
	public static void syncTasksFromEvents(Map<Id, Event> eventMap) {
		List<Task> tasks = [SELECT Id, Call_Sync_Id__c, Subject, Description, WhatId, WhoId, Last_Sync__c FROM Task WHERE Call_Sync_Id__c IN :eventMap.keySet()];
		
		if(!tasks.isEmpty()) {
			for(Task t : tasks) {
				Event e = eventMap.get(t.Call_Sync_Id__c);
				syncEventToTask(e, t);
			}
			
			DoNotProcessTaskUpdate = true;
			update tasks;
			DoNotProcessTaskUpdate = false;
		}
	}
	
	private static void syncTaskToEvent(Task t, Event e) {
		t.Last_Sync__c = System.now();
		e.Last_Sync__c = t.Last_Sync__c;
		
		e.Subject = t.Subject;
		e.Description = t.Description;
		e.WhatId = t.WhatId;
		e.WhoId = t.WhoId;
		
		if(t.CreatedDate == null) {
			e.EndDateTime = t.Last_Sync__c;
		} else {
			e.EndDateTime = t.CreatedDate;
		}
		
		if(t.CallDurationInSeconds != null) {
			e.StartDateTime = e.EndDateTime.addSeconds(-1 * t.CallDurationInSeconds);
		} else {
			e.StartDateTime = e.EndDateTime;
		}
	}
	
	private static void syncEventToTask(Event e, Task t) {
		e.Last_Sync__c = System.now();
		t.Last_Sync__c = e.Last_Sync__c;
		t.Subject = e.Subject;
		t.Description = e.Description;
		t.WhatId = e.WhatId;
		t.WhoId = e.WhoId;
	}
	
	public static void runCleanupProcess(){
		List<Task> taskDel = [Select Id FROM Task WHERE CallObject <> null AND Type = 'Call' AND CreatedDate <= YESTERDAY AND CALENDAR_YEAR(CreatedDate) >= 2012 AND OwnerId in ('005300000048Y51','005300000048b7a','00530000004MylK') limit 4000];
		if(!taskDel.isEmpty()) {
			CallSyncUtility.DoNotProcessTaskDelete= true;
			delete taskDel;
			CallSyncUtility.DoNotProcessTaskDelete= false;
		}
		
		List<Event> eventDel = [Select Id FROM Event WHERE Event_Type__c = 'Phone Call' AND Call_Sync_Id__c <> null AND CreatedDate < YESTERDAY AND CALENDAR_YEAR(CreatedDate) >= 2012 AND Event_Status__c <> 'Complete' AND Desc_Summary__c in ('', '...') AND OwnerId <> '005300000048b5pAAA' AND OwnerId in ('005300000048Y51','005300000048b7a','00530000004MylK') limit 4000];
		if(!eventDel.isEmpty()) {
			delete eventDel;
		}

		List<Event> eventUpdate = [Select Id, Event_Status__c FROM Event WHERE Event_Type__c = 'Phone Call' AND Call_Sync_Id__c <> null AND CreatedDate < YESTERDAY AND CALENDAR_YEAR(CreatedDate) >= 2012 AND Event_Status__c <> 'Complete' AND Desc_Summary__c NOT in ('', '...') AND OwnerId in ('005300000048Y51','005300000048b7a','00530000004MylK') limit 1000];
		for(Event evt: eventUpdate){
			evt.Event_Status__c = 'Complete';
		}
		
		if(!eventUpdate.isEmpty()) {
			update eventUpdate;
		}
	}
}