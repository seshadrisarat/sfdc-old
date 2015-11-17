/**
* @TriggerName  : SL_User
* @JIRATicket   : SOCINT-120
* @CreatedOn    : 
* @ModifiedBy   : SL
* @Description  : This trigger is used to check the office address inserted/updated on the the User.User_Offices is available or not
*/
trigger SL_User on User (before insert, before update) 
{
	// Handler class for calling functions based on event
	SL_UserHandler objUserHandler = new SL_UserHandler(Trigger.isExecuting, Trigger.size); 
	
	// fires on Before Insert of User record
	if(Trigger.isInsert && Trigger.isBefore)
	{
		objUserHandler.onBeforeInsert(Trigger.New);
	}
	
	// fires on Before Update of User record
	if(Trigger.isUpdate && Trigger.isBefore && SL_RecursionHelper.getIsAllowTrigger())
	{
		objUserHandler.onBeforeUpdate(Trigger.New);
	}	
}