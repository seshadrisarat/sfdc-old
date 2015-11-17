/**
*  Trigger Name   : SL_LeadTrigger
*  JIRATicket     : THOR-17
*  CreatedOn      : 5/AUG/2014
*  ModifiedBy     : Rahul Majumder
*  Description    : Trigger to create Contact role records when a lead is converted
*/
trigger SL_LeadTrigger on Lead (after update) 
{
	///Create an instance of the Handler class	
	SL_LeadHandler objLeadHandler = new SL_LeadHandler();
	
	///Call onAfterUpdate method after a Lead record is updated
	if(trigger.isAfter && trigger.isUpdate)
	{
		objLeadHandler.onAfterUpdate(trigger.newMap);
	}
}