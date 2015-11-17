/**
*  Trigger Name   : SL_Case
*  JIRATicket     : LAT-2
*  CreatedOn      : 
*  ModifiedBy     : 
*  Description    : trigger to call handler class method on required events.
*/

trigger SL_Case on Case (after insert) {
    
    SL_CaseHandler handler = new SL_CaseHandler();
    
    if(trigger.isAfter && trigger.isInsert)
        handler.onAfterInsert(trigger.newMap);

}