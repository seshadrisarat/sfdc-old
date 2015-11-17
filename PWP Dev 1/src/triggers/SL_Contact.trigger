/**
* \arg TriggerName    : SL_Contact
* \arg JIRATicket     : PWP-6, PWP-169
* \arg CreatedOn      : 8/DEC/2014
* \arg LastModifiedOn : 20/AUG/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This trigger on contact object 
*/
trigger SL_Contact on Contact (after update, before insert, before update, after insert, after delete, before delete) 
{
	// initialize the handler class SL_ContactHandler
	SL_ContactHandler handler = new SL_ContactHandler();
	
	//will be called on before event
	if(Trigger.isBefore)
	{
		//insert of Contact object.
		if(Trigger.isInsert)
		{
			// call the handler method
			handler.onBeforeInsert(Trigger.new);
		}
		//update of Contact object.
		else if(Trigger.isUpdate)
		{
			// call the handler method
			handler.onBeforeUpdate(Trigger.new, Trigger.OldMap);
		}
		else if(Trigger.isDelete)
		{
			handler.onBeforeDelete(Trigger.oldMap);
		}
	}
	
	//will be called on after event
	if(Trigger.isAfter)
	{
		//update of Contact object.
		if(Trigger.isUpdate)
		{
			// call the handler method
			handler.onAfterUpdate(Trigger.NewMap, Trigger.OldMap);
		}
		else if(Trigger.isInsert)
		{
			handler.onAfterInsert(Trigger.new);
		}
		else if(Trigger.isDelete)
		{
			handler.onAfterDelete();
		}
	}
}