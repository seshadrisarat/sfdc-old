trigger TaskTrigger on Task (before insert, before update, after insert, after update) {
    LastNextActivityTask UpdateTools = new LastNextActivityTask();
    list<task> TasksListed = trigger.new;
    if (Trigger.isBefore) { 
        //Adds concatinated field
        updateTools.CalendarConcatTasks(TasksListed);
        //Drops phone calls
        set<id> deleteCallCenterids = new set<id>();
        for (task t: TasksListed){
            if (t.callobject != null || t.CallType != null || t.status == 'Complete'){
            //if (t.subject == 'pasta'){
                //deleteCallCenterids.add(t.id);
				t.addError('Call center tasks are being supressed');
            }
        }
        //delete [select id from task where id in :deleteCallCenterids];
    }
    else {
        UpdateTools.LastTasksUpdate(TasksListed);
        //Pipeline update
        set<id> listPL = new set<id>();
        for (task t: TasksListed){
            if (t.WhatId != null){
                listPL.add(t.WhatId);
            }
        }
        UpdateTools.NextPipelineUpdate(listPL);
    }
}