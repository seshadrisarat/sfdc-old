/*	
	@Trigger Name  : SL_Contact
	@JIRATicket    : YNHH-109,YNHH-139
	@Created by    : Sandeep 
	@Created on    : 17/7/2015
	@Modified by   : 
	@Description   : Trigger will fire on after insert or after update of contact
*/
trigger SL_Contact on Contact (before insert, before update, after insert, after update) 
{
    SL_Contact_Handler handler = new SL_Contact_Handler();
    
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            handler.onBeforeInsert(Trigger.New);
        }
        if(Trigger.isUpdate && SL_Contact_Handler.isUpdateAllowed)
        {
            handler.onBeforeUpdate(Trigger.NewMap, Trigger.OldMap);
        }
    }
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            handler.onAfterInsert(Trigger.New);
        }
        if(Trigger.isUpdate && SL_Contact_Handler.isUpdateAllowed)
        {
            handler.onAfterUpdate(Trigger.NewMap, Trigger.OldMap);
        }
    }
}