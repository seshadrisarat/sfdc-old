/**
*  Trigger Name   : SL_AccountTrigger
*  JIRATicket     : HEART-7
*  CreatedOn      : 06/NOV/2013
*  ModifiedBy     : Sandeep
*  Description    : trigger to call handler class method to update 'upcoming meeting material date.
*/
trigger SL_AccountTrigger on Account (after update) 
{
    SL_AccountTriggerHandler objSL_AccountTriggerHandler = new SL_AccountTriggerHandler();//Creating instance of handler class.
    
    //If trigger is after update
    if(trigger.isAfter && trigger.isUpdate)
    {
        objSL_AccountTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap); 
    }
}