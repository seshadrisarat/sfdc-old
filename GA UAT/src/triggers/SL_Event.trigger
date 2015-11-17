/**
*  Trigger Name   : SL_Event
*  CreatedOn      : 10/DEC/2014
*  ModifiedBy     : Hemant Shukla
*  Description    : This is the Event trigger
*/
trigger SL_Event on Event (after insert, after update, after delete) {

    SL_EventHandler objEventHandler = new SL_EventHandler();    //Creating an Object of Handler class.
    
    if(trigger.isAfter && trigger.isInsert){
    
        // method will be called on after insert of Event record
        objEventHandler.onAfterInsert(trigger.newMap);
    }
    
    if(trigger.isAfter && trigger.isUpdate){
    
        // method will be called on after insert of Event record
        objEventHandler.onAfterUpdate(trigger.oldMap,trigger.newMap);
    }
    
    if(trigger.isAfter && trigger.isDelete){
    
        // method will be called on after insert of Event record
        objEventHandler.onAfterDelete(trigger.oldMap); 
    }

}