/**
*  Trigger Name   : SL_ActivityTrigger
*  JIRATicket     : HEART-6
*  CreatedOn      : 06/NOV/2013
*  ModifiedBy     : Sandeep
*  Description    : trigger to call handler class method on required events.
*/
trigger SL_ActivityTrigger on Task (after insert, after update) 
{
	SL_ActivityTriggerHandler handler = new SL_ActivityTriggerHandler();// Creating instance of handler class.
	
	//Calling handler method if trigger is on after insert
	if(Trigger.isAfter && Trigger.isInsert)
	{
		handler.onAfterInsert(trigger.newMap);
	}
	
	//Calling handler method if trigger is on after update
	if(Trigger.isAfter && Trigger.isUpdate)
	{
		handler.onAfterUpdate(trigger.newMap,trigger.oldMap );
	} 
}