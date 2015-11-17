trigger SL_Company_List_Trigger on Company_List__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
     
    SL_Company_List_Handler handler = new Sl_Company_List_Handler(Trigger.isExecuting, Trigger.size);
     
    if(trigger.IsInsert){
        if(trigger.IsBefore){
            handler.OnBeforeInsert(Trigger.new);
        }
        else{
            handler.OnAfterInsert(Trigger.newMap);
            //These are commented out since we are not using them and there is a limit on the number of @future calls.      
            //SL_Company_List_Handler.OnAfterInsertAsync(trigger.newMap.keySet());
        }
    }
     
    else if(trigger.IsUpdate){
        if(trigger.IsBefore){
            handler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap);
        }
        else{    
            handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap);
      //These are commented out since we are not using them and there is a limit on the number of @future calls.      
      //    SL_Opportunity_Trigger_Handler.OnAfterUpdateAsync(trigger.newMap.keySet());
        }
    }   
     
    else if(trigger.isDelete){
        if(trigger.IsBefore){
            handler.OnBeforeDelete(Trigger.oldMap);
        }
        else{
            handler.OnAfterDelete(Trigger.oldMap);
      //These are commented out since we are not using those functions and there is a limit on the number of @future calls.      
      //    SL_Opportunity_Trigger_Handler.OnAfterDeleteAsync(trigger.newMap.keySet());
        }
    }
     
    else{
        handler.OnUndelete(trigger.new);
    }
             
}