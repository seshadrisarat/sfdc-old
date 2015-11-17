trigger SL_Bid on Bid__c (after insert, after update, after delete)
{
	SL_handler_Bid handler = new  SL_handler_Bid(Trigger.isExecuting, Trigger.size);
     
    if(trigger.IsInsert)
    {
        if(trigger.IsBefore)
        {
            //handler.OnBeforeInsert(Trigger.new);
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
            handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap );
        }
    }   
    else if(trigger.IsDelete)
    {
        if(trigger.IsBefore)
        {
        	//handler.OnBeforeDelete(Trigger.old);
        }
        else
        {    
            handler.OnAfterDelete(Trigger.oldMap);
        }
    }   
}