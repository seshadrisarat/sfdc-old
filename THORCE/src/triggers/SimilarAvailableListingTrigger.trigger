/*
*       SimilarAvailableListingTrigger on the Similar_Available_Listing__c object
* 
*       Author  :   Wilson Ng 
*       Date    :   November 09, 2012
* 
*/
trigger SimilarAvailableListingTrigger on Similar_Available_Listing__c (before insert) {

    SimilarAvailableListingTriggerHandler objHandler = new SimilarAvailableListingTriggerHandler();
    
    if(Trigger.isBefore && Trigger.isInsert){
        objHandler.onBeforeInsert(Trigger.new);
    }
}