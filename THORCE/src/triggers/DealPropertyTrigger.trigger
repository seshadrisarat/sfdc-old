/*
*       DealPropertyTrigger on the Deal_Property__c object
* 
*       Author  :   Wilson Ng 
*       Date    :   November 15, 2012
* 
*/
trigger DealPropertyTrigger on Deal_Property__c (after insert) {

    DealPropertyTriggerHandler objHandler = new DealPropertyTriggerHandler();
    
    if(Trigger.isAfter && Trigger.isInsert){
        objHandler.onAfterInsert(Trigger.new);
    }
}