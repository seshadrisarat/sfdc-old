trigger SL_Note_Joiner on Note_Joiner__c (after insert, after update)
{

    // Handler class for calling functions based on Event
    SL_Note_Joiner_Handler objEventHandler = new SL_Note_Joiner_Handler(Trigger.isExecuting, Trigger.size);
    
    if(trigger.isAfter && trigger.isInsert)
    {
        // calling functions of handler class on after insert of Event
        objEventHandler.onAfterInsert(Trigger.newMap); 
    } 
    
    /* Added by vishnu as per clarion-21 on 2/May/2013*/
    if(trigger.isAfter && trigger.isUpdate)
    {
        objEventHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }
    /* End */
}