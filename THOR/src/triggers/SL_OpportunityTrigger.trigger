/**
*  Trigger Name   : SL_OpportunityTrigger
*  JIRATicket     : THOR-6
*  CreatedOn      : 11/AUG/2014
*  ModifiedBy     : Pradeep
*  Description    : Trigger to update Unit availability based on Opportunity Stage.
*/
trigger SL_OpportunityTrigger on Opportunity (after insert, after update, before insert, before update) 
{
    SL_OpportunityTriggerHandler objOpportunityHandler = new SL_OpportunityTriggerHandler();  
    
    if(trigger.isBefore && trigger.isInsert)
    { 
        objOpportunityHandler.onBeforeInsert(trigger.new);
    }
    
    if(trigger.isBefore && trigger.isUpdate)
    {
        objOpportunityHandler.onBeforeUpdate(trigger.new,trigger.oldMap);
    }
    
    if(trigger.isAfter && trigger.isInsert)  
    {
        objOpportunityHandler.onAfterInsert(trigger.newMap);
    }
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        objOpportunityHandler.onAfterUpdate(trigger.oldMap,trigger.newMap);
    }  
}