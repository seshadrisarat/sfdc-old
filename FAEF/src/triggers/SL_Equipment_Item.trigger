trigger SL_Equipment_Item on Equipment_Item__c (after insert, after update)
{
	SL_Equipment_Item_Handler handler = new SL_Equipment_Item_Handler();

	if(trigger.isAfter && trigger.isInsert)
    {
        handler.onAfterInsert(Trigger.newMap); 
    } 
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        handler.onAfterUpdate(Trigger.oldMap, Trigger.newMap); 
    }
}