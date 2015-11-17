/*Trigger on insert of Funding Submission   
* Trigger Name  : SL_Funding_Submission 
* Created on    : 08/27/2013
* Modified by   : 
* Description   :
*/
trigger SL_Funding_Source on Funding_Source__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
     
    SL_Funding_Source_Handler handler = new SL_Funding_Source_Handler(Trigger.isExecuting, Trigger.size);
     
    if(trigger.IsInsert){
        if(trigger.IsBefore){
            //handler.OnBeforeInsert(Trigger.new);
        }
        else{
            handler.OnAfterInsert(Trigger.newMap);
            //SL_Opportunity_Trigger_Handler.OnAfterInsertAsync(trigger.newMap.keySet());
        }
    }
     
    else if(trigger.IsUpdate){
        if(trigger.IsBefore){
            //handler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap);
        }
        else{    
            handler.OnAfterUpdate(Trigger.newMap);
            //SL_Opportunity_Trigger_Handler.OnAfterUpdateAsync(trigger.newMap.keySet());
        }
    }   
     
    else if(trigger.isDelete){
        if(trigger.IsBefore){
            //handler.OnBeforeDelete(Trigger.oldMap);
        }
        else{
            //handler.OnAfterDelete(Trigger.oldMap);
            //SL_Opportunity_Trigger_Handler.OnAfterDeleteAsync(trigger.newMap.keySet());
        }
    }
     
    else{
        //handler.OnUndelete(trigger.new);
    }
             
}