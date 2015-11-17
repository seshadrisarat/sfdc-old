/**
* \arg TriggerName      : SL_Case
* \arg JIRATicket       : YNHH-110
* \arg CreatedOn        : 17/JULY/2015
* \arg LastModifiedOn   : 17/JULY/2015
* \arg CreatededBy      : Sanath 
* \arg ModifiedBy       : Sanath
* \arg Description      : Trigger on case object to create share records 
*/
trigger SL_Case on Case (Before insert, Before update, After update, After insert) 
{
    SL_CaseHandler objHandler = new SL_CaseHandler();
  
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
            objHandler.onAfterInsert(trigger.new);
        if(trigger.isUpdate)
            objHandler.onAfterUpdate(trigger.new , trigger.oldMap);
    }

    if(trigger.isBefore && trigger.isInsert){
        objHandler.onBeforeInsert(trigger.new);
    }
    
    if(trigger.isBefore && trigger.isUpdate){
        objHandler.onBeforeUpdate(trigger.oldMap, trigger.NewMap);
    }
}