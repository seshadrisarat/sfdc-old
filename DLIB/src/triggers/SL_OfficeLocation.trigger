/**
* @TriggerName  : SL_OfficeLocation
* @JIRATicket   : SOCINT-120
* @CreatedOn    : 
* @ModifiedBy   : SL
* @Description  : This trigger is used to Update Notifications, Users and Content records whenever Office Location is inserted/Updated/Deleted .
*/

trigger SL_OfficeLocation on Office_Locations__c (after insert, after update, after delete) 
{

	// Handler class for calling functions based on event
	SL_OfficeLocationHandler objOfficeLocationHandler = new SL_OfficeLocationHandler(Trigger.isExecuting, Trigger.size);
	
	// fires on After Insert of OfficeLocation record
	if(Trigger.isInsert && Trigger.isAfter && SL_RecursionHelper.getIsAllowTrigger())
	{
		objOfficeLocationHandler.onAfterInsert(Trigger.NewMap);
	}
	
	// fires on After Update of OfficeLocation record
	if(Trigger.isUpdate && Trigger.isAfter)
	{
		objOfficeLocationHandler.onAfterUpdate(Trigger.OldMap , Trigger.NewMap);
	}
	
	// fires on After Delete of OfficeLocation record
	if(Trigger.isDelete && Trigger.isAfter)
	{
		objOfficeLocationHandler.onAfterDelete(Trigger.OldMap);
	}

}