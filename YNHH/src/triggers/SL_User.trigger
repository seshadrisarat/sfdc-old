/*	
	@Trigger Name  : SL_User
	@JIRATicket    : YNHH-109
	@Created by    : Sandeep 
	@Created on    : 17/7/2015
	@Modified by   : 
	@Description   : Trigger will fire on after insert or after update of User
*/

trigger SL_User on User (after insert, after update, before insert , before update)
{
    SL_User_Handler handler = new SL_User_Handler();
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            //handler.onAfterInsert(Trigger.New);
        }
        if(Trigger.isUpdate)
        {
           // handler.onAfterUpdate(Trigger.NewMap, Trigger.OldMap);
        }
    }
    
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            //handler.onBeforeInsert(Trigger.New);
        }
        if(Trigger.isUpdate)
        {
           // handler.onBeforeUpdate(Trigger.NewMap, Trigger.OldMap);
        }
    }
}