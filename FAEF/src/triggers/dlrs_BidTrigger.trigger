/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_BidTrigger on Bid__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler();
    
    /*** Added by Harsh Chandra as per FAEF-31 on 15/Sep/2014 **/
     //Handler class for calling functions based on event
    SL_Bid_Handler objSLBidhandler = new SL_Bid_Handler();
    
    // calling on After Insert
    if(trigger.isAfter && Trigger.isInsert)
    	objSLBidhandler.onAfterInsert(trigger.newMap);
    
   // calling on after Update
    if(Trigger.isAfter && Trigger.isUpdate)
    	objSLBidhandler.onAfterUpdate(trigger.oldMap, trigger.newMap);
    /***** Ends */
}