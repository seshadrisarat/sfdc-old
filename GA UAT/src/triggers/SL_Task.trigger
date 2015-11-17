/**
*  Trigger Name   : SL_Task
*  CreatedOn      : 10/DEC/2014
*  ModifiedBy     : Hemant Shukla 
*  Description    : This is the Task trigger
*/
trigger SL_Task on Task (after insert, after update, after delete, before update,before delete) {
    
    SL_TaskHandler objTaskHandler = new SL_TaskHandler(); //Creating an Object of Handler class. 
    
    if(trigger.isAfter && trigger.isInsert)
    {
        // method will be called on after insert of task record
        objTaskHandler.onAfterInsert(trigger.NewMap);   
    }
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        // method will be called on after update of task record
        objTaskHandler.onAfterUpdate(trigger.oldMap, trigger.NewMap);
    }
    
    if(trigger.isAfter && trigger.isDelete)
    {
        // method will be called on after delete of task record
        objTaskHandler.onAfterDelete(trigger.oldMap);     
    }
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        SL_TaskHandler.onBeforeUpdate(Trigger.oldMap);
    }
    if(Trigger.isDelete && Trigger.isBefore)
    {
       SL_TaskHandler.onBeforeDelete(Trigger.oldMap);
    }
}