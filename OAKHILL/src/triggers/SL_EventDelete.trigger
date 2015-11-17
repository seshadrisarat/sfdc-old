/*
    Trigger on    : Event
    Trigger Name  : SL_EventDelete 
    JIRA Ticket   : LIB-184
    Created on    : May-19-2014
    Created by    : Praful
    Description   : After delete event trigger.   
*/
trigger SL_EventDelete on Event (after delete) {
    
    SL_ActivityHandler objActivityHandler = new SL_ActivityHandler();

    if(trigger.isDelete && trigger.isAfter) {

        objActivityHandler.OnAfterDelete(trigger.old);
    }
}