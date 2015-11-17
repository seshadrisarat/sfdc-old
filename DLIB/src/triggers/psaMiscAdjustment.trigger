/****************************************************************************************
Name            : psaMiscAdjustment
Author          : Julia Kolesnik
Created Date    : January 13, 2014
Description     : psaMiscAdjustment trigger
******************************************************************************************/
trigger psaMiscAdjustment on pse__Miscellaneous_Adjustment__c (after insert) {
    
    psaMiscAdjustmentHandler handler = new psaMiscAdjustmentHandler(Trigger.isExecuting, Trigger.size);
    if (trigger.isAfter) {
        if (trigger.isInsert) {
            handler.onAfterInsert(trigger.new);
        }
    }
}