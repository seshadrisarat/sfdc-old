/*
*       ListingCompTrigger on the Listing_Comp__c object
* 
*       Author  :   Wilson Ng 
*       Date    :   November 15, 2012
* 
*/
trigger ListingCompTrigger on Listing_Comp__c (before insert) {

    ListingCompTriggerHandler objHandler = new ListingCompTriggerHandler();
    
    if(Trigger.isBefore && Trigger.isInsert){
        objHandler.onBeforeInsert(Trigger.new);
    }
}