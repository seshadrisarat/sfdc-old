/**
*  trigger        : SL_LaserOwnedTrigger
*  JIRATicket     : CYN-5
*  CreatedOn      : 9/29/15
*  ModifiedBy     : Sanath
*  Description    : Trigger on After Insert operation on Laser Owned
*/
trigger SL_LaserOwnedTrigger on Laser_Owned__c (after update) 
{
    SL_LaserOwnedHandler objHandler = new SL_LaserOwnedHandler();
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        objHandler.onAfterUpdate(trigger.new , trigger.oldMap);
    }
}