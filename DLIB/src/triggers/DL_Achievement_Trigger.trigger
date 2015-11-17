trigger DL_Achievement_Trigger on Dreamforce_Achievements__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
     
    SL_Achievement_Handler handler = new SL_Achievement_Handler(Trigger.isExecuting, Trigger.size);
     
    if(trigger.IsInsert){
        if(trigger.IsBefore){
            handler.OnBeforeInsert(Trigger.new);
        }
        else{
            handler.OnAfterInsert(Trigger.newMap);
            //SL_Achievement_Handler handler.OnAfterInsertAsync(trigger.newMap.keySet());
        }
    }
     
    else if(trigger.IsUpdate){
        if(trigger.IsBefore){
            handler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap);
        }
        else{    
            handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap);
      //    SL_Achievement_Handler handler.OnAfterUpdateAsync(trigger.newMap.keySet());
        }
    }   
     
    else if(trigger.isDelete){
        if(trigger.IsBefore){
            handler.OnBeforeDelete(Trigger.oldMap);
        }
        else{
            handler.OnAfterDelete(Trigger.oldMap);
      //    SL_Achievement_Handler handler.OnAfterDeleteAsync(trigger.newMap.keySet());
        }
    }
     
    else{
        if(trigger.IsBefore){
            handler.OnBeforeUndelete(trigger.new);
        }
        else{
            handler.OnAfterUndelete(trigger.new);
        }
    }
             
}