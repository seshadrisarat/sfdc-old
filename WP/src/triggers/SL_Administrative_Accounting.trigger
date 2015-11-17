trigger SL_Administrative_Accounting on Administrative_Accounting__c (after delete, after insert, after update) 
{
	SL_handler_AdministrativeAccounting handler = new  SL_handler_AdministrativeAccounting(Trigger.isExecuting, Trigger.size);
    
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