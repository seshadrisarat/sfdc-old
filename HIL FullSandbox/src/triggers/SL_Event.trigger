trigger SL_Event on Event (after insert, after undelete, after update) 
{
    // Handler class for calling functions based on Event
    SL_EventHandler objEventHandler = new SL_EventHandler(Trigger.isExecuting, Trigger.size);
    
    if(trigger.isAfter && trigger.isInsert)
    {
        SL_RecursionHelper.isUpdate = false;
        // calling functions of handler class on after insert of Event
        objEventHandler.onAfterInsert(Trigger.newMap); 
    } 
    
    /* Added by vishnu as per clarion-21 on 2/May/2013*/
    if(trigger.isAfter && trigger.isUpdate && SL_RecursionHelper.isUpdate)
    {
        SL_RecursionHelper.isUpdate = false;
        objEventHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
    
    if(trigger.isAfter && trigger.isUndelete)
    {
        SL_RecursionHelper.isUpdate = false;
        objEventHandler.onAfterUndelete(Trigger.newMap);
    }
    /* End */
}