/**
* \arg TriggerName      : SL_Affiliation
* \arg JIRATicket       : PWP-212
* \arg CreatedOn        : 1/Sept/2015
* \arg LastModifiedOn   : 31/Sept/2015
* \arg CreatededBy      : Nrusingh 
* \arg ModifiedBy       : Nrusingh
* \arg Description      : SL_Affiliation trigger
*/
trigger SL_Affiliation on Affiliation__c (before insert, before update, after delete, after insert, after undelete, after update) 
{
    //Creating handler class instance
    SL_AffiliationHandler objAffiliationHandler = new SL_AffiliationHandler();
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert && SL_RecursionHandler.getIsAfterInsert())
        {
            SL_RecursionHandler.setIsAfterInsert(false);
            objAffiliationHandler.onAfterInsert(Trigger.newMap);    
        }
            
        if(Trigger.isUpdate)// && SL_RecursionHandler.getIsAfterUpdate())    
        {
            //SL_RecursionHandler.setIsAfterUpdate(false);
            objAffiliationHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap); 
        }
            
        if(Trigger.isDelete && SL_RecursionHandler.getIsAfterDelete())
        {
            SL_RecursionHandler.setIsAfterDelete(false);
            objAffiliationHandler.onAfterDelete(Trigger.oldMap);
        }
            
        if(Trigger.isUnDelete && SL_RecursionHandler.getIsAfterUnDelete())
        {
            SL_RecursionHandler.setIsAfterUnDelete(false);
            objAffiliationHandler.onAfterUnDelete(Trigger.newMap);    
        }
    }
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
            objAffiliationHandler.onBeforeInsert(Trigger.new);    
       if(Trigger.isUpdate)
            objAffiliationHandler.onBeforeUpdate(Trigger.newMap,Trigger.oldMap);  
    }
}