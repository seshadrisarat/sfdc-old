/**
    @Trigger Name  : SL_TimeTracking
    @JIRA Ticket   : CAINSUPP-13
    @Created on    : 6/11/15
    @Modified by   : Sanath Kumar
    @Description   : Trigger on insert, update of Time_Tracking__c object to Update Employee__c field
*/
trigger SL_TimeTracking on Time_Tracking__c (before insert , before update) 
{
    SL_TimeTrackerHandler objHandler = new SL_TimeTrackerHandler();
    
    if(trigger.isInsert && trigger.isBefore)
    {
        objHandler.onBeforeInsert(trigger.new);
    }
    
    if(trigger.isUpdate && trigger.isBefore)
    {
        objHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
    }
}