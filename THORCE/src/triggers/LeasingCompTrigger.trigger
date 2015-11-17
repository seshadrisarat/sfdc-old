/*
*       LeasingCompTrigger on the Leasing_Comp__c object
* 
*       Author  :   Wilson Ng 
*       Date    :   November 15, 2012
* 
*/
trigger LeasingCompTrigger on Leasing_Comp__c (before insert) {

    LeasingCompTriggerHandler objHandler = new LeasingCompTriggerHandler();
    
    if(Trigger.isBefore && Trigger.isInsert){
        objHandler.onBeforeInsert(Trigger.new);
    }
}