/**
* \arg TriggerName      : SL_Opportunity
* \arg JIRATicket     	: PWP-77
* \arg CreatedOn      	: 23/JULY/2015
* \arg LastModifiedOn	: 23/JULY/2015
* \arg CreatededBy    	: Lodhi 
* \arg ModifiedBy     	: Lodhi
* \arg Description      : trigger on opportunity
*/
trigger SL_Opportunity on Opportunity (after delete, after insert, after update) 
{
    //Creating handler class instance
    SL_OpportunityHandler objOpportunityHandler = new SL_OpportunityHandler();
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
            objOpportunityHandler.onAfterInsert(Trigger.newMap);    
            
        if(Trigger.isUpdate)    
            objOpportunityHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
            
        if(Trigger.isDelete)
            objOpportunityHandler.onAfterDelete(Trigger.oldMap);
    }
}