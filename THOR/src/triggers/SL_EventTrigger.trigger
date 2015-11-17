/**
*  Trigger Name   : SL_EventTrigger
*  JIRATicket     : THOR-26
*  CreatedOn      : 26/AUG/2014
*  ModifiedBy     : Sanath Kumar
*  Description    : Trigger to rollup the event dates based on type to the Lead and Opportunity
*/
trigger SL_EventTrigger on Event (after delete, after insert, after undelete, after update) 
{
    ///Create an object of handler class
    SL_EventHandler objEventHandler = new SL_EventHandler();
    
    if(trigger.isAfter)
    {
        ///Call onAfterInsert method after an event record is inserted
        if(trigger.isInsert)
        {
            objEventHandler.onAfterInsert(trigger.new);
        }
        
        ///Call onAfterUpdate method after an event record is updated
        if(trigger.isUpdate)
        {
            objEventHandler.onAfterUpdate(trigger.oldMap, trigger.newMap);
        }
        
        ///Call onAfterDelete method after an event record is deleted
        if(trigger.isDelete)
        {
            objEventHandler.onAfterDelete(trigger.old);
        }
        
        ///Call onAfterUnDelete method after an event record is undeleted
        if(trigger.isUnDelete)
        {
            objEventHandler.onAfterUnDelete(trigger.new);
        }
    }
    
}