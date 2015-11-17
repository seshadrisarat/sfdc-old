/**
* \arg TriggerName    : SL_Coverage_Team_Members
* \arg JIRATicket     : PWP-11
* \arg CreatedOn      : 18/DEC/2014
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This trigger on Coverage_Team_Members__c object 
*/
trigger SL_Coverage_Team_Members on Coverage_Team_Members__c (after insert, after update, after delete, after undelete) 
{
	// initialize the handler class SL_Coverage_Team_MembersHandler
	SL_Coverage_Team_MembersHandler handler = new SL_Coverage_Team_MembersHandler();
	//will be called on insert event
	
	//will be called on after event
	if(trigger.isAfter)
	{
		//insert of Coverage_Team_Members object. 
		if(trigger.isInsert)
		{
			// call the handler method
			handler.onAfterInsert(trigger.new);
		}
		//update of Coverage_Team_Members object.
		if(trigger.isUpdate)
		{
			// call the handler method
			handler.onAfterUpdate(trigger.NewMap, trigger.OldMap);
		}

		//delete of Coverage_Team_Members object.
		if(trigger.isDelete)
		{
			// call the handler method
			handler.onAfterDelete(trigger.old);
		}

		//undelete of Coverage_Team_Members object.
		if(trigger.isUnDelete)
		{
			// call the handler method
			handler.onAfterUnDelete(trigger.new);
		}

	}

}