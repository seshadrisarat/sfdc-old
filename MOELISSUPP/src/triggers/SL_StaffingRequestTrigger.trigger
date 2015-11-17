/*Trigger on insert Staffing_Request__c
* Trigger Name 	: SL_StaffingRequestTrigger
* JIRA Ticket   : MOELISSUPP-2
* Created on    : 09/May/2013
* Modified by   : SL
* Description   : This trigger will share the current Staffing_Request__c records with Employee_Profile__c.User. 
*/

trigger SL_StaffingRequestTrigger on Staffing_Request__c (after insert, after update) 
{
	// initialize the handler class SL_StaffingRequest_Handler
	SL_StaffingRequest_Handler handler = new SL_StaffingRequest_Handler(Trigger.isExecuting, Trigger.size);
	
	// fires only on the After Insert
	if(Trigger.isInsert && Trigger.isAfter)
	{
		if(SL_RecursionHelper.getisInsert())
			handler.onAfterInsert(Trigger.NewMap);
	}
	// fires only on the After Update
	if(Trigger.isUpdate && Trigger.isAfter)
	{
		if(SL_RecursionHelper.getisUpdate())
			handler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
	}

}