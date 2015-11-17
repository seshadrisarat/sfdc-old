trigger SL_Assumption on Assumption__c (before insert, before update) 
{
	// Handler class for calling functions based on event
	SL_Assumption_Handler objAssumptionHandler = new SL_Assumption_Handler();
	
	if(trigger.isBefore && trigger.isInsert)
	{
		// calling functions of handler class on after update of contact
		objAssumptionHandler.onBeforeInsert(Trigger.new);
	}
	
	if(trigger.isBefore && trigger.isUpdate)
	{
		// calling functions of handler class on before delete of contact
		objAssumptionHandler.onBeforeUpdate(Trigger.new);
	}
}