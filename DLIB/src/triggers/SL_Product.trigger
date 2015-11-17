/**
* @Trigger	 		: SL_Product
* @JIRATicket   	: SILVERLINE-145
* @CreatedOn    	: 3/JAN/2013
* @ModifiedBy   	: Rehan
* @Description 	 	: This is the trigger on Product2 Object
*/
trigger SL_Product on Product2 (after insert, after update)
{
	SL_Product_Handler handler = new SL_Product_Handler(Trigger.isExecuting, Trigger.size);

	if(trigger.IsInsert)
	{
		if(trigger.IsBefore)
		{
		  	//handler.OnBeforeInsert(Trigger.new);
		}
		else
		{
			handler.OnAfterInsert(trigger.oldMap, trigger.newMap);
		}
	}

	else if(trigger.IsUpdate)
	{
		if(trigger.IsBefore)
		{
		   	//handler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap);
		}
		else
		{
			handler.OnAfterUpdate(trigger.oldMap,trigger.newMap);
		}
	 }
}