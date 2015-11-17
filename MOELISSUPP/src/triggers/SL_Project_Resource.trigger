trigger SL_Project_Resource on Project_Resource__c  (after insert, after update, after delete) 
{
	SL_ProjectResource_Trigger_Handler handler = new SL_ProjectResource_Trigger_Handler(Trigger.isExecuting, Trigger.size);
     
    if(trigger.IsInsert) 
    {
        if(trigger.IsAfter)
        	handler.OnAfterInsert(Trigger.new);
    }
    else if(trigger.IsUpdate)
    {
       if(trigger.IsAfter)
      		handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap,Trigger.new);
    }  
    else if(trigger.IsDelete)
    {
        if(trigger.IsAfter)
            handler.OnAfterDelete(Trigger.old);
    }   
}