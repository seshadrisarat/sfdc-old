/** 
* \author Sergey Karnyushin
* \date 10/16/2012
* \see https://silverline.jira.com/browse/WP-9
* \details Financial Trigger Handler
* \
*/
trigger SL_Financial on Financial__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
     
    SL_Financial_Trigger_Handler handler = new Sl_Financial_Trigger_Handler(Trigger.isExecuting, Trigger.size);
     
    if(trigger.IsInsert){
        if(trigger.IsBefore){
            handler.OnBeforeInsert(Trigger.new);
        }
        else{
            handler.OnAfterInsert(Trigger.newMap);
            //SL_Opportunity_Trigger_Handler.OnAfterInsertAsync(trigger.newMap.keySet());
        }
    }
    
    else if(trigger.IsUpdate){
        if(trigger.IsBefore){
            handler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap);
        }
        else{    
            handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap);
			//SL_Opportunity_Trigger_Handler.OnAfterUpdateAsync(trigger.newMap.keySet());
        }
    }   
     
    else if(trigger.isDelete){
        if(trigger.IsBefore){
            handler.OnBeforeDelete(Trigger.oldMap);
        }
        else{
            handler.OnAfterDelete(Trigger.oldMap);
			//SL_Opportunity_Trigger_Handler.OnAfterDeleteAsync(trigger.newMap.keySet());
        }
    }
     
    else{
        handler.OnUndelete(trigger.new);
    }
             
}