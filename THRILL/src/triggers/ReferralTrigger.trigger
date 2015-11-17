/**
* ReferralTrigger : Trigger code for Referral object
*/
 trigger ReferralTrigger on Agency_Company__c (before insert, after insert, before update, before delete, after undelete) {
    ReferralTriggerHandler handler = new ReferralTriggerHandler(); 
    
    if (Trigger.isBefore){
     //   if(Trigger.isInsert)
    //        handler.onBeforeInsert(Trigger.new);
     //   else
         if(Trigger.isUpdate)
            handler.onBeforeUpdate(Trigger.oldMap, Trigger.new);
        else if(Trigger.isDelete)
            handler.onBeforeDelete(Trigger.oldMap);
    }
    else{
        if(Trigger.isInsert)
            handler.onAfterInsert(Trigger.new);
        else if(Trigger.isUnDelete)
            handler.onAfterUndelete(Trigger.new);
    } 
}