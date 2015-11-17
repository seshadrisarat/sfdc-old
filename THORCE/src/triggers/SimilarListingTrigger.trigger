/*
*       SimilarListingTrigger on the Similar_Listing__c object
* 
*       Author  :   Wilson Ng 
*       Date    :   November 09, 2012
* 
*/
trigger SimilarListingTrigger on Similar_Listing__c (before insert, before update, after insert, after update, after delete) {

    SimilarListingTriggerHandler objHandler = new SimilarListingTriggerHandler();
    
    if(Trigger.isBefore && Trigger.isInsert){
        objHandler.onBeforeInsert(Trigger.new);
    }
    else if(Trigger.isBefore && Trigger.isUpdate){
        objHandler.onBeforeUpdate(Trigger.new, Trigger.OldMap);
    }
    else if(Trigger.isAfter && Trigger.isInsert){
        objHandler.onAfterInsert(Trigger.new);
    }
    else if(Trigger.isAfter && Trigger.isUpdate){
        objHandler.onAfterUpdate(Trigger.new, Trigger.OldMap);
    }
    else if(Trigger.isAfter && Trigger.isDelete){
        objHandler.onAfterDelete(Trigger.old);
    }
}