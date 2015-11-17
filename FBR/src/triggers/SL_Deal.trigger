/**
* \arg TriggerName      : SL_Deal
* \arg JIRATicket       : FBR-1
* \arg CreatedOn        : 19/MAR/2015
* \arg LastModifiedOn   : -
* \arg CreatededBy      : Nrusingh
* \arg LastModifiedBy   : -
*/

trigger SL_Deal on Deals__c (after insert, after update, before insert, before update) 
{
    SL_DealHandler objSL_DealHandler = new SL_DealHandler ();
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
            objSL_DealHandler.onAfterInsert(Trigger.new);
        if(Trigger.isUpdate)
            objSL_DealHandler.onAfterUpdate(Trigger.newMap,Trigger.oldMap);
    }
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
            objSL_DealHandler.onBeforeInsert(Trigger.new);
        if(Trigger.isUpdate)
            objSL_DealHandler.onBeforeUpdate(Trigger.newMap,Trigger.oldMap);
    }
    
}