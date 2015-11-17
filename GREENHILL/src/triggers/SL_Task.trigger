trigger SL_Task on Task (after insert, after update) 
{
    
    SL_Task_Handler objTaskHandler = new SL_Task_Handler();
    
    if(trigger.isAfter && trigger.isInsert)
    {
        // calling functions of handler class on after insert of task
        objTaskHandler.onAfterInsert(Trigger.newMap);
    }
     
    if(trigger.isAfter && trigger.isUpdate)
    {
        // calling functions of handler class on after insert of task
        objTaskHandler.onAfterUpdate(Trigger.oldMap,Trigger.newMap); 
    } 
}