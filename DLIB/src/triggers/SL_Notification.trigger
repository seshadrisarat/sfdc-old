/**
* @TriggerName  : SL_Notification
* @JIRATicket   : SOCINT-120
* @CreatedOn    : 
* @ModifiedBy   : SL
* @Description  : This trigger is used to check the office address inserted/updated on the the Notification.Notification_Office is available or not
*/
    
trigger SL_Notification on Notification__c (after insert, after update, after delete, before insert, before update) 
{
 	// Handler class for calling functions based on event
	SL_NotificationHandler objNotificationHandler = new SL_NotificationHandler(Trigger.isExecuting, Trigger.size);
	
	// fires on Before Insert of Notification record
	if(Trigger.isInsert && Trigger.isBefore && SL_RecursionHelper.getIsAllowTrigger())
	{
		objNotificationHandler.onBeforeInsert(Trigger.New);
	}
	
	// fires on Before Update of Notification record
	if(Trigger.isUpdate && Trigger.isBefore)
	{
		objNotificationHandler.onBeforeUpdate(Trigger.New);
	}
	// fires on After Insert of Notification record
    if(Trigger.isInsert && Trigger.isAfter && SL_RecursionHelper.getIsAllowTrigger())
    {
        objNotificationHandler.onAfterInsert(Trigger.newMap); 
    } 
    
    // fires on After Update of Notification record
    if(Trigger.isUpdate && Trigger.isAfter)
    {
        objNotificationHandler.onAfterUpdate(Trigger.newMap);
    }
    
    // fires on After Delete of Notification record
    if(Trigger.isDelete && Trigger.isAfter)
    {
        objNotificationHandler.onAfterDelete(Trigger.oldMap); 
    }	
}