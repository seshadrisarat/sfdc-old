trigger SL_Task on Task (after insert, after undelete, after update) 
{
    // Handler class for calling functions based on Task
    SL_TaskHandler objTaskHandler = new SL_TaskHandler(Trigger.isExecuting, Trigger.size);
    
    if(trigger.isAfter && trigger.isInsert)
    {
        // calling functions of handler class on after insert of task
        SL_RecursionHelper.isUpdate = false;
        objTaskHandler.onAfterInsert(Trigger.newMap); 
    } 
    
    if(trigger.isAfter && trigger.isUpdate && SL_RecursionHelper.isUpdate)
    {
        SL_RecursionHelper.isUpdate = false;
        objTaskHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
    
    if(trigger.isAfter && trigger.isUndelete)
    {
        SL_RecursionHelper.isUpdate = false;
        objTaskHandler.onAfterUndelete(Trigger.newMap);
    }
    /* End */
}