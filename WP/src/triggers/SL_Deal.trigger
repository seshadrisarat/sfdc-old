/** 
* \author Vladimir Prishlyak
* \date 10/09/2012
* \see https://silverline.jira.com/browse/WP-4
* \details Expense Code Generation Trigger logic 
* \
*/
trigger SL_Deal on Deal__c (before insert, before update, after update, before delete, after delete)
{
	if (kjoDealReportController.bCheckingDealWriteability) return;
	SL_handler_Deal handler = new  SL_handler_Deal(Trigger.isExecuting, Trigger.size);
     
    if(trigger.IsInsert)
    {
        if(trigger.IsBefore)
        {
            handler.OnBeforeInsert(Trigger.new);
        }
        else
        {
            //handler.OnAfterInsert(Trigger.newMap);
        }
    }
    else if(trigger.IsUpdate)
    {
        if(trigger.IsBefore)
        {
        	handler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap);
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
        	handler.OnBeforeDelete(Trigger.old);
        }
        else
        {    
            handler.OnAfterDelete(Trigger.old);
        }
    }   
}