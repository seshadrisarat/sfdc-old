/*
*       PropertyLeaseTrigger on the PropertyLease__c object
* 
*       Author  :   Wilson Ng 
*       Date    :   November 15, 2012
* 
*/
trigger PropertyLeaseTrigger on Property_Lease__c (after insert) {

	PropertyLeaseTriggerHandler objHandler = new PropertyLeaseTriggerHandler();
    
    if(Trigger.isAfter && Trigger.isInsert){
        objHandler.onAfterInsert(Trigger.new);
    }
}