/**
* \arg TriggerName    : SL_Contact
* \arg JIRATicket     : PWP-6
* \arg CreatedOn      : 8/DEC/2014
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This trigger on contact object 
*/
trigger SL_Contact on Contact (after update) 
{
	// initialize the handler class SL_ContactHandler
	SL_ContactHandler handler = new SL_ContactHandler();
	
	//will be called on after event
	if(Trigger.isAfter)
	{
		//update of Contact object.
		if(Trigger.isUpdate)
		{
			// call the handler method
			handler.onAfterUpdate(Trigger.NewMap, Trigger.OldMap);
		}
	}
}