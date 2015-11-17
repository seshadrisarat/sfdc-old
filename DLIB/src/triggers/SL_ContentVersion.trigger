/**
* @TriggerName  : SL_ContentVersion
* @JIRATicket   : SOCINT-120, SOCINT-281, SOCINT-941
* @CreatedOn    : 5/May/2013
* @ModifiedBy   : SL
* @Description  : This trigger is used to check the office address inserted/updated on the the ContentVersion.ContentVersion_Office is available or not
					and to update/create Recent Update Records
*/

trigger SL_ContentVersion on ContentVersion (before insert, after insert, after update, before update, after delete) 
{
	// Handler class for calling functions based on event
	SL_ContentVersionTriggerHandler objContentHandler = new SL_ContentVersionTriggerHandler(Trigger.isExecuting, Trigger.size);
	
	// fires on Before Update of Content record
	if(Trigger.isUpdate && Trigger.isBefore)
	{
		objContentHandler.onBeforeUpdate(Trigger.New);
	}
	
	// fires on Before Insert of Content record
	if(Trigger.isInsert && Trigger.isBefore)
	{
		objContentHandler.onBeforeUpdate(Trigger.New);
	}	
	
	if(Trigger.isDelete && Trigger.isAfter)
	{
		objContentHandler.onAfterDelete(Trigger.OldMap);
	}
	
	// fires on After Insert of ContentVersion record
    if(Trigger.isInsert && Trigger.isAfter)
    {
        objContentHandler.onAfterInsert(Trigger.newMap); 
    }  
    
    // fires on After Update of ContentVersion record
    if(Trigger.isUpdate && Trigger.isAfter)
    {
        objContentHandler.onAfterUpdate(Trigger.newMap);
    }   
}