/**
* \arg ClassName      : SL_Event
* \arg JIRATicket     : STARGAS-6
* \arg CreatedOn      : 15/05/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This trigger is used to update the corresponding Opportunity record with most recently inserted record
*/
trigger SL_Event on Event (before update, after delete, after insert, after update, before insert) 
{
	SL_EventHandler objSL_EventHandler = new SL_EventHandler();
	
	if(Trigger.isAfter)
	{
		if(Trigger.isInsert)
			objSL_EventHandler.onAfterInsert(Trigger.newMap);//Calling on after insert method
		
		if(Trigger.isDelete)
			objSL_EventHandler.onAfterDelete(Trigger.old);//Calling on after delete method
			
		if(Trigger.isUpdate)
			objSL_EventHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);//Calling on after update method
	} else if (Trigger.isBefore) {
		if(Trigger.isUpdate) {
			objSL_EventHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
		}
		
		if(Trigger.isInsert)
			objSL_EventHandler.onBeforeInsert(Trigger.new);
	}
}