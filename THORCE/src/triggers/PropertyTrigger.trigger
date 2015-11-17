/*
*       PropertyTrigger on the Property__c object
* 
*       Author  :   Wilson Ng 
*       Date    :   November 09, 2012
* 
*/
trigger PropertyTrigger on Property__c (before insert, before update, after insert, after update, before delete) {

    AddressTranslate at = new AddressTranslate();
    
    PropertyTriggerHandler objHandler = new PropertyTriggerHandler();
    
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
    else if(Trigger.isAfter && Trigger.isUpdate){
        objHandler.onAfterUpdate(Trigger.new, Trigger.OldMap);
    }
    else if(Trigger.isBefore && Trigger.isDelete){
        objHandler.onBeforeDelete(Trigger.old);
    }
}