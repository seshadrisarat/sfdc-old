/*
*       ListingTrigger on the Listing__c object
* 
*       Author  :   Wilson Ng 
*       Date    :   November 14, 2012
* 
*/
trigger ListingTrigger on Listing__c (before insert, before update, after insert, before delete, after update) {

    ListingTriggerHandler objHandler = new ListingTriggerHandler();

    AddressTranslate at = new AddressTranslate();
    
    
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            at.translateSobjectAddresses(Trigger.new);
        }
        else if(Trigger.isUpdate)
        {
            at.findSobjectsRequiringTranslation(Trigger.newMap,trigger.oldMap);
        }
    }   
    if(Trigger.isAfter && Trigger.isInsert){
        objHandler.onAfterInsert(Trigger.new);
    }
    
    else if(Trigger.isAfter && Trigger.isUpdate)
    {
        objHandler.onAfterUpdate(Trigger.newMap,Trigger.oldMap);
    }
    
    else if(Trigger.isBefore && Trigger.isDelete){
        objHandler.onBeforeDelete(Trigger.old);
    }
}