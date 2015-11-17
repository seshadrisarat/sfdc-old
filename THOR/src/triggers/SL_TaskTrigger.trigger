/**
*  Trigger Name   : SL_TaskTrigger
*  JIRATicket     : THOR-26
*  CreatedOn      : 28/AUG/2014
*  ModifiedBy     : Sanath Kumar
*  Description    : Trigger to rollup the Task dates based on type to the Lead and Opportunity
*/
trigger SL_TaskTrigger on Task (after delete, after insert, after undelete, after update) 
{
    SL_TaskHandler objTaskHandler = new SL_TaskHandler();
    
    if(trigger.isAfter)
    {
        ///Call onAfterInsert method after a Task record is inserted
        if(trigger.isInsert)
        {
            objTaskHandler.onAfterInsert(trigger.new);
        }
        
        ///Call onAfterUpdate method after a Task record is updated
        if(trigger.isUpdate)
        {
            objTaskHandler.onAfterUpdate(trigger.oldMap, trigger.newMap);
        }
        
        ///Call onAfterDelete method after a Task record is deleted
        if(trigger.isDelete)
        {
            objTaskHandler.onAfterDelete(trigger.old);
        }
        
        ///Call onAfterUnDelete method after a Task record is undeleted
        if(trigger.isUnDelete)
        {
            objTaskHandler.onAfterUnDelete(trigger.new);
        }
    }
}