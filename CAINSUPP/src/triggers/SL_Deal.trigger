/**
* \arg ClassName      : SL_Deal
* \arg JIRATicket     : CAINSUPP-5
* \arg CreatedOn      : 09/12/2013
* \arg CreatededBy    : Praful
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : -
*/
trigger SL_Deal on Deal__c (after insert, after update, before delete) 
{   
	//Instantiating the Handler class.
	SL_DealHandler objSL_DealHandler = new SL_DealHandler();
	
	if(Trigger.isAfter && Trigger.isInsert)
	{
		objSL_DealHandler.onAfterInsert(Trigger.newMap);//Calling onAfterInsert method of Handler.  
	}
	
	if(Trigger.isAfter && Trigger.isUpdate)
	{
		objSL_DealHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);//Calling onAfterUpdate method of Handler.
	}
	
	if(Trigger.isBefore && Trigger.isDelete)
	{
		objSL_DealHandler.onBeforeDelete(Trigger.oldMap);//Calling onBeforeDelete method of Handler
	}
}