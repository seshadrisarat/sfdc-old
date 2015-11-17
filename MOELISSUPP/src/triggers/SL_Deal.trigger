/** 
 * \author Vika Osmak 
 * \date 06/15/11
 * \see http://silverline.jira.com/browse/MC-1
 * \brief trigger on Ibanking_Project__c(Deal). 
 * \test SL_Test_Deal_Trigger_Handler
 */
trigger SL_Deal on Ibanking_Project__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) 
{
	SL_Deal_Trigger_Handler handler = new  SL_Deal_Trigger_Handler(Trigger.isExecuting, Trigger.size);
     
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
            handler.OnBeforeUpdate(Trigger.newMap,Trigger.oldMap);
        }
        else
        {    
            handler.OnAfterUpdate(Trigger.newMap,Trigger.oldMap);
        }
    }   
    else if(trigger.isDelete)
    {
        if(trigger.IsBefore)
        {
            //handler.OnBeforeDelete(Trigger.oldMap);
        }
        else
        {
            //handler.OnAfterDelete(Trigger.oldMap);
        }
    }
    else
    {
        //handler.OnUndelete(trigger.new);
    }
}