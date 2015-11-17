/**
*  trigger        : SL_TaskTrigger
*  JIRATicket     : CYN-5
*  CreatedOn      : 9/29/15
*  ModifiedBy     : Sanath
*  Description    : Trigger on Before Insert operation on Task
*/
trigger SL_TaskTrigger on Task (before insert) 
{
    SL_ActivityHandler objHandler = new SL_ActivityHandler();
    
    if(trigger.isBefore && trigger.isInsert)
    {
        objHandler.onBeforeInsert(trigger.new);
    }
}