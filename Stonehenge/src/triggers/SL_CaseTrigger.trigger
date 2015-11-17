/**
*  Trigger Name   : SL_CaseTrigger
*  JIRATicket     : STONEPIII-7
*  CreatedOn      : 19/SEP/2014
*  CreatedBy      : Pradeep
*  ModifiedBy     : Pankaj Ganwani
*  Description    : Trigger to create Events in Mybuilding when case is inserted with recordtype 'Move In Process' or 'Move Out Process'.
*/

trigger SL_CaseTrigger on Case(after insert, after update) 
{
     ///Create an object of handler class
    SL_CaseTriggerHandler objCaseHandler = new SL_CaseTriggerHandler();
    
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
            objCaseHandler.onAfterInsert(trigger.new);
        if(trigger.isUpdate)
            objCaseHandler.onAfterUpdate(trigger.newMap, trigger.oldMap);
    } 
}