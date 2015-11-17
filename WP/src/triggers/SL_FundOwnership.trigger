trigger SL_FundOwnership on Fund_Ownership__c (before insert, after delete, after insert, after update) 
{
	SL_handler_FundOwnership handler = new  SL_handler_FundOwnership(Trigger.isExecuting, Trigger.size);
     
    if(trigger.IsInsert)
    {
        if(trigger.IsBefore)	{
            handler.OnBeforeInsert(Trigger.new);
        }
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