/*
*Trigger: SL_Provider_Address_Trigger
*Description: This used to keep only one primary address for each type corresponding to each contact and updating the corresponding Contact record with primary Mailing and Practice Address.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
trigger SL_Provider_Address_Trigger on Provider_Address__c (after delete, before insert, before update) {
     
    SL_Provider_Address_Handler handler = new SL_Provider_Address_Handler(Trigger.isExecuting, Trigger.size);
     
    if(trigger.IsInsert){
        if(trigger.IsBefore){
            handler.OnBeforeInsert(Trigger.new);
        }
    }
     
    else if(trigger.IsUpdate){
        if(trigger.IsBefore){
            handler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap);
        }
    }   
     
    else if(trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old);
    }
             
}