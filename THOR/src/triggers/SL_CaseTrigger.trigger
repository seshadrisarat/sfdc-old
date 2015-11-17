/**
*  Trigger Name   : SL_CaseTrigger
*  JIRATicket     : THOR-29
*  CreatedOn      : 28/SEP/2014
*  ModifiedBy     : SANATH
*  Description    : Trigger to create Events in Mybuilding when case is inserted with recordtype 'Move In Process' or 'Move Out Process'.
*/

trigger SL_CaseTrigger on Case(after insert) 
{
     ///Create an object of handler class
    SL_CaseTriggerHandler objCaseHandler = new SL_CaseTriggerHandler();
    
    if(trigger.isAfter && trigger.isInsert)
    {
        ///Call onAfterInsert method after an event record is inserted
        objCaseHandler.onAfterInsert(trigger.new);
    }
}