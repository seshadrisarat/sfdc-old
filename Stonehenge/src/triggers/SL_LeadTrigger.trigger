/**
 
* \see http://silverline.jira.com/browse/STONEPII-17
 
* \brief SL_LeadTrigger trigger : Runs after update of lead.
 
*/
trigger SL_LeadTrigger on Lead (after update) 
{
	// Creating an instance of the Handler class	
	SL_LeadHandler handler = new SL_LeadHandler();
	
	if(trigger.isUpdate)
	{
		if(trigger.isAfter)
		{
			// this method is called on after update of a Lead
			handler.onAfterUpdate(trigger.newMap);
		}
	}
}