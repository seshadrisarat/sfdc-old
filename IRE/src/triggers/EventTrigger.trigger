trigger EventTrigger on Event (before insert, before update, after insert, after update) {
    LastNextActivityTask UpdateTools = new LastNextActivityTask();
    list<Event> EventsListed = trigger.new;
    if (Trigger.isBefore) { 
        updateTools.CalendarConcatEvents(EventsListed);
    }
    else{
        UpdateTools.LastEventsUpdate(EventsListed);
        //Pipeline update
        set<id> listPL = new set<id>();
	    for (Event t: EventsListed){
            if (t.WhatId != null){
                listPL.add(t.WhatId);
            }
    	}
        UpdateTools.NextPipelineUpdate(listPL);
    }
       
}