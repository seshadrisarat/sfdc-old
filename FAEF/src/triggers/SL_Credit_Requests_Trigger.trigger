trigger SL_Credit_Requests_Trigger on Credit_Requests__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
     
    SL_Credit_Requests_Handler handler = new SL_Credit_Requests_Handler(Trigger.isExecuting, Trigger.size);
     
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
            handler.OnAfterUpdate(Trigger.newMap, Trigger.oldMap);
            //SL_Opportunity_Trigger_Handler.OnAfterUpdateAsync(trigger.newMap.keySet());
        }
    }   
     
    else if(trigger.isDelete){
        if(trigger.IsBefore){
            handler.onBeforeDelete(Trigger.oldMap);
        }
        else{
            //handler.onAfterDelete(Trigger.oldMap);
            //SL_Opportunity_Trigger_Handler.OnAfterDeleteAsync(trigger.newMap.keySet());
        }
    }
    else{
        handler.onAfterUnDelete(trigger.newMap);
    }
             
}