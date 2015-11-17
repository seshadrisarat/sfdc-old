trigger SL_Event on Event (after insert, after update) 
{
    SL_Event_Handler objEventHandler = new SL_Event_Handler();
    
    if(trigger.isAfter && trigger.isInsert)
    {
        // calling functions of handler class on after insert of task
        objEventHandler.onAfterInsert(Trigger.newMap);
    }
     
    if(trigger.isAfter && trigger.isUpdate)
    {
        // calling functions of handler class on after insert of task
        objEventHandler.onAfterUpdate(Trigger.oldMap,Trigger.newMap);
    } 
}