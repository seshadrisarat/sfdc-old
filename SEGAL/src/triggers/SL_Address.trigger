/**
*  Trigger Name   : SL_Address
*  JIRATicket     : SEGAL-6
*  CreatedOn      : 20/JAN/2015
*  ModifiedBy     : Pradeep
*  Description    : This is the trigger on Address object to ensure If an Address is changed, all Contacts that have that Address as their Primary address should be updated.
*/

trigger SL_Address on Address__c (after insert,after update,before delete) 
{
	// Creating object for handler class
	SL_AddressHandler objAddressHandler = new SL_AddressHandler();
	
	// Calling handler class method on after insert of Address record 
	if(trigger.isAfter && trigger.isInsert)
	{
		objAddressHandler.onAfterInsert(trigger.newMap);
	}
	
	// Calling handler class method on after update of Address record 
	if(trigger.isAfter && trigger.isUpdate)
	{
		objAddressHandler.onAfterUpdate(trigger.oldMap, trigger.newMap);
	}
	
	// Calling handler class method on before Delete of Address record 
	if(trigger.isBefore && trigger.isDelete)
	{
		objAddressHandler.onBeforeDelete(trigger.oldMap);
	}
}