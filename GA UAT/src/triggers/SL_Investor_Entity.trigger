/*Trigger on Investor_Entity__c
    @Trigger Name  : SL_Investor_Entity
    @JIRATicket    : GA-18
    @Created by    : Sandeep
    @Created Date  : 04/13/2015
    @Modified by   : 
    @Description   : RollUp the SL_Investor_Entity CommitmentAmount to Account
*/

trigger SL_Investor_Entity on Investor_Entity__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    // This is the only line of code that is required.
    SL_TriggerFactory.createTriggerDispatcher(Investor_Entity__c.sObjectType);
    
    //initilize the handler and call the respective method
    SL_Investor_EntityHelper handler = new SL_Investor_EntityHelper();
    //call respective based on event
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
            handler.onAfterInsert(Trigger.newMap);
        if(Trigger.isUpdate)
            handler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
        if(Trigger.isDelete)
            handler.onAfterDelete(Trigger.oldMap);
        if(Trigger.isUndelete)
            handler.onAfterUnDelete(Trigger.newMap);
    }
}