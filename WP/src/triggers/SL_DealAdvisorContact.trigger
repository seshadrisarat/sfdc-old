trigger SL_DealAdvisorContact on Deal_Advisor_Contact__c (before insert, after insert, after update, after delete) 
{
	SL_handler_DealAdvisorContact handler = new  SL_handler_DealAdvisorContact(Trigger.isExecuting, Trigger.size);
     
    if(trigger.IsInsert)
    {
        if(trigger.IsBefore)
        {
            handler.OnBeforeInsert(Trigger.new);
        }
        else
        { 
            handler.OnAfterInsert(Trigger.newMap); 
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
            handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap);
        }
    } 
    else if(trigger.IsDelete)
    {
        if(trigger.IsBefore)
        {
        }
        else
        {    
            handler.OnAfterDelete(Trigger.old);
        }
    }
}