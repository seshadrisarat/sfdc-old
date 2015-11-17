/**
*  Trigger Name   : SL_ContactRoleTrigger
*  JIRATicket     : THOR-21
*  CreatedOn      : 13/AUG/2014
*  ModifiedBy     : Pradeep
*  Description    : Trigger to update  associated Person account when ContactRole is inserted or updated.
*/

trigger SL_ContactRoleTrigger on Contact_Role__c (after insert, after update)  
{
	SL_ContactRoleTriggerHandler objCRHandler = new SL_ContactRoleTriggerHandler();
	
	if(trigger.isAfter && trigger.isInsert)
	{
		objCRHandler.onAfterInsert(trigger.new);
	}
	
	if(trigger.isAfter && trigger.isUpdate)
	{
		objCRHandler.onAfterUpdate(trigger.new);
	}
}