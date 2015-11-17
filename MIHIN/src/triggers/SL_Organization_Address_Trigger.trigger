/*
*Trigger: SL_Organization_Address_Trigger
*Description: This trigger is used to keep only one primary address for each type corresponding to each Organization and updating the corresponding Organization record with primary Mailing and Practice Address.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
trigger SL_Organization_Address_Trigger on Organization_Address__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
     
   SL_Organization_Address_Handler handler = new SL_Organization_Address_Handler(Trigger.isExecuting, Trigger.size);
     
    if(trigger.IsInsert){
        if(trigger.IsBefore){
            handler.OnBeforeInsert(Trigger.new);
        }
        else{
            handler.OnAfterInsert(Trigger.newMap);
            //SL_Organization_Address_Handler.OnAfterInsertAsync(trigger.newMap.keySet());
        }
    }
     
    else if(trigger.IsUpdate){
        if(trigger.IsBefore){
            handler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap);
        }
        else{    
            handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap);
      //    SL_Organization_Address_Handler.OnAfterUpdateAsync(trigger.newMap.keySet());
        }
    }   
     
    else if(trigger.isDelete){
        if(trigger.IsBefore){
            handler.OnBeforeDelete(Trigger.oldMap);
        }
        else{
            handler.OnAfterDelete(Trigger.oldMap);
      //    SL_Organization_Address_Handler.OnAfterDeleteAsync(trigger.newMap.keySet());
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