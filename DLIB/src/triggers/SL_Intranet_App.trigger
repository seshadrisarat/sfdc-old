trigger SL_Intranet_App on Intranet_App__c (after insert, after update, after delete, before insert, before update) 
{
	// Handler class for calling functions based on event
	SL_Intranet_AppHandler objIntranetAppHandler = new SL_Intranet_AppHandler(Trigger.isExecuting, Trigger.size);
	
	// fires on Before Insert of Notification record
	if(Trigger.isInsert && Trigger.isBefore && SL_RecursionHelper.getIsAllowTrigger())
	{
		objIntranetAppHandler.onBeforeInsert(Trigger.New);
	}
	
	// fires on Before Update of Notification record
	if(Trigger.isUpdate && Trigger.isBefore)
	{
		objIntranetAppHandler.onBeforeUpdate(Trigger.New);
	}	
	
	 // fires on After Update of Intranet App record
    if(Trigger.isUpdate && Trigger.isAfter)
    {
        objIntranetAppHandler.onAfterUpdate(Trigger.newMap);
    }    
    
    // fires on After Delete of Intranet App record
    if(Trigger.isDelete && Trigger.isAfter)
    {
        objIntranetAppHandler.onAfterDelete(Trigger.oldMap);  
    }
 
    // fires on After Insert of Intranet App record
    if(Trigger.isInsert && Trigger.isAfter && SL_RecursionHelper.getIsAllowTrigger())
    {
        objIntranetAppHandler.onAfterInsert(Trigger.newMap);
    } 
}