/*
    Trigger on    : Event
    Trigger Name  : SL_EventDelete 
    JIRA Ticket   : LIB-184
    Created on    : May-19-2014
    Created by    : Praful
    Description   : After delete event trigger.   
*/
trigger SL_EventDelete on Event (after delete, after update, before insert) {
    
    SL_ActivityHandler objActivityHandler = new SL_ActivityHandler();

    if(trigger.isDelete && trigger.isAfter) {

        objActivityHandler.OnAfterDelete(trigger.old);
    }

    if(trigger.isUpdate && trigger.isAfter && SL_ActivityHandler.runOnce()) {

        objActivityHandler.OnAfterUpdate(trigger.newMap, trigger.oldMap);
    }
    
    if(trigger.isInsert && trigger.isBefore)
    {
        objActivityHandler.onBeforeInsert(trigger.new);
    }
}