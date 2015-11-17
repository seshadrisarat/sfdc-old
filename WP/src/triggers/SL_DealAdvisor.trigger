trigger SL_DealAdvisor on Deal_Advisor__c (after delete, after insert, after update) 
{
	SL_handler_DealAdvisor handler = new  SL_handler_DealAdvisor(Trigger.isExecuting, Trigger.size);
     
    if(trigger.IsInsert)
    {
        if(trigger.IsBefore)	{}
        else	handler.OnAfterInsert(Trigger.newMap); 
    }
    else if(trigger.IsUpdate)
    {
        if(trigger.IsBefore)	{}
        else	handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap);
    } 
    else if(trigger.IsDelete)
    {
        if(trigger.IsBefore)	{}
        else	handler.OnAfterDelete(Trigger.old);
    }
}