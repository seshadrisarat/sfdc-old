trigger SL_Opportunity on Opportunity (after update) 
{
	SL_Opportunity_Trigger_Handler objHandler = new SL_Opportunity_Trigger_Handler();
	
	if(trigger.isAfter && trigger.isUpdate)
	{
		objHandler.OnAfterUpdate(trigger.oldMap, trigger.newMap);
	}
	
}