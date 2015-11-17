/*
*Trigger: SL_Account
*Description: This trigger is used to validate tansfering the Account record and updating value of Geolocation_Required__c field based on the shipping address
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
trigger SL_Account on Account (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
     
    SL_Account_Trigger_Handler handler = new SL_Account_Trigger_Handler(Trigger.isExecuting, Trigger.size);
     
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
            System.debug(Trigger.New[0].isCustomerPortal);
      //    SL_Opportunity_Trigger_Handler.OnAfterUpdateAsync(trigger.newMap.keySet());
        }
    }  
     
    else if(trigger.isDelete){
        if(trigger.IsBefore){
            handler.OnBeforeDelete(Trigger.oldMap);
        }
        else{
            handler.OnAfterDelete(Trigger.oldMap);
      //    SL_Opportunity_Trigger_Handler.OnAfterDeleteAsync(trigger.newMap.keySet());
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