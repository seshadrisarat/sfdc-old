trigger SL_Intranet_Event on Intranet_Event__c (after insert, after update, after delete, before insert, before update) 
{
	// Handler class for calling functions based on event
	SL_Intranet_EventHandler objIntranetEventHandler = new SL_Intranet_EventHandler(Trigger.isExecuting, Trigger.size);
	
	// fires on Before Insert of Notification record
	if(Trigger.isInsert && Trigger.isBefore && SL_RecursionHelper.getIsAllowTrigger())
	{
		objIntranetEventHandler.onBeforeInsert(Trigger.New);
	}
	
	// fires on Before Update of Notification record
	if(Trigger.isUpdate && Trigger.isBefore)
	{
		objIntranetEventHandler.onBeforeUpdate(Trigger.New);
	}	
	
	// fires on After Insert of Intranet Event record
    if(Trigger.isInsert && Trigger.isAfter && SL_RecursionHelper.getIsAllowTrigger())
    {
        objIntranetEventHandler.onAfterInsert(Trigger.newMap);
    }
    
    // fires on After Update of Intranet Event record
    if(Trigger.isUpdate && Trigger.isAfter)
    {
        objIntranetEventHandler.onAfterUpdate(Trigger.newMap);
    }
    
    // fires on Before Delete of Intranet Event record
    if(Trigger.isDelete && Trigger.isAfter)
    {
        objIntranetEventHandler.onAfterDelete(Trigger.oldMap); 
    }
}