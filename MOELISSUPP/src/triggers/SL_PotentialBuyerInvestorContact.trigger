/** 
 * \author Vika Osmak 
 * \date 06/15/11
 * \see http://silverline.jira.com/browse/MC-2
 * \brief trigger on Potential_Buyer_Investor_Contact__c . 
 * \test SL_Test_PBIContact_Trigger_Handler
 */
trigger SL_PotentialBuyerInvestorContact on Potential_Buyer_Investor_Contact__c  (after delete, after insert, after undelete, after update, before delete, before insert, before update) 
{
	SL_PBIContact_Trigger_Handler handler = new  SL_PBIContact_Trigger_Handler(Trigger.isExecuting, Trigger.size);
     
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
           // handler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap);
        }
        else
        {    
            //handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap);
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