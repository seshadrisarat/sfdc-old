trigger SL_DealTrigger on Deal__c (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete) {
SL_DealTriggerHandlerOld handler = new SL_DealTriggerHandlerOld();
        if (Trigger.isBefore) {
            //call your handler.before method
        
        } else if (Trigger.isAfter) 
        {
            if(Trigger.isUpdate)
            {
                handler.isAfterUpdate(Trigger.newMap,Trigger.oldMap);
            }
            if(trigger.isInsert)
                handler.onAfterInsert(trigger.newMap);
            if(trigger.isDelete)
                handler.onAfterDelete(trigger.oldMap); 
        } 
}