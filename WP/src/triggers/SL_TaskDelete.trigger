/*
    Trigger on    : Task
    Trigger Name  : SL_TaskDelete 
    JIRA Ticket   : LIB-184
    Created on    : May-19-2014
    Created by    : Praful
    Description   : After delete task trigger.   
*/
trigger SL_TaskDelete on Task (after delete, after update) { 
    
    SL_ActivityHandler objActivityHandler = new SL_ActivityHandler();

    if(trigger.isDelete && trigger.isAfter) {

        objActivityHandler.OnAfterDelete(trigger.old);
    }

    if(trigger.isUpdate && trigger.isAfter && SL_ActivityHandler.runOnce()) {

        objActivityHandler.OnAfterUpdate(trigger.newMap, trigger.oldMap);
    } 
}