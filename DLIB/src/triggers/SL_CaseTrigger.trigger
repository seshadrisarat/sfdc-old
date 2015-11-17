/**
* \arg TriggerName    : SL_CaseTrigger
* \arg JIRATicket     : SILVERLINE-189
* \arg CreatedOn      : 30/10/2013
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
*/

trigger SL_CaseTrigger on Case (before insert, before update) 
{
	// Handler class for calling functions based on event
	SL_CaseTriggerHandler objSL_CaseTriggerHandler=new SL_CaseTriggerHandler();
	
    
	if(Trigger.isBefore && Trigger.isInsert)
	{
		objSL_CaseTriggerHandler.onBeforeInsert(Trigger.new);//Calling onBeforeInsert function of handler and passing the record as parameter.
	}
	if(Trigger.isBefore && Trigger.isUpdate)
	{
		objSL_CaseTriggerHandler.onBeforeUpdate(Trigger.oldmap,Trigger.newMap);//Calling onBeforeUpdate function of handler 
																			   //and passing the old record and new record as parameters to compare Subscriber Organization Ids.
	}
}