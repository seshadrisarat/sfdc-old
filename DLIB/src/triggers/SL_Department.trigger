trigger SL_Department on Department__c (after delete, after insert, after update) 
{
	// Handler class for calling functions based on event
	SL_DepartmentHandler objDepartmentHandler = new SL_DepartmentHandler(Trigger.isExecuting, Trigger.size);
	
	// fires on After Insert of OfficeLocation record
	if(Trigger.isInsert && Trigger.isAfter && SL_RecursionHelper.getIsAllowTrigger())
	{
		objDepartmentHandler.onAfterInsert(Trigger.NewMap);
	}
	
	// fires on After Update of OfficeLocation record
	if(Trigger.isUpdate && Trigger.isAfter)
	{
		objDepartmentHandler.onAfterUpdate(Trigger.OldMap , Trigger.NewMap);
	}
	
	// fires on After Delete of OfficeLocation record
	if(Trigger.isDelete && Trigger.isAfter)
	{
		objDepartmentHandler.onAfterDelete(Trigger.OldMap);
	}
}