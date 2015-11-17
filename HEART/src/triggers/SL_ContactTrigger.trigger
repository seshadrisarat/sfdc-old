/**
*  Trigger Name   : SL_ContactTrigger
*  JIRATicket     : HEART-7
*  CreatedOn      : 06/NOV/2013
*  ModifiedBy     : Sandeep
*  Description    : trigger to call handler class method to update 'upcoming meeting material date.
*/
trigger SL_ContactTrigger on Contact (after update) 
{
	SL_ContactTriggerHandler objSL_ContactTriggerHandler = new SL_ContactTriggerHandler();//Creating instance of handler class.
	
	//If trigger is after update
	if(trigger.isAfter && trigger.isUpdate)
	{
		objSL_ContactTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap); 
	}
}