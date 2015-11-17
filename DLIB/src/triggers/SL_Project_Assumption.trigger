trigger SL_Project_Assumption on Project_Assumption__c (before insert, before update) 
{
	// Handler class for calling functions based on event
	SL_Project_Assumption_Handler objAssumptionHandler = new SL_Project_Assumption_Handler(Trigger.isExecuting, Trigger.size);
	
	if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate))
	{
		// calling functions of handler class on before insert and update
		objAssumptionHandler.onBeforeInsertUpdate(Trigger.new); 
	}
}