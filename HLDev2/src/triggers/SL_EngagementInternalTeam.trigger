/**
*  Trigger Name   : SL_EngagementInternalTeam
*  JIRATicket     : HL-31
*  CreatedOn      : 06/OCT/2014
*  ModifiedBy     : 
*  Description    : Trigger used to create manual sharing record for Engagements. 
*/
trigger SL_EngagementInternalTeam on Engagement_Internal_Team__c (after insert, after delete, after update) 
{
	//Creating instance of handler class.
	SL_EngagementInternalTeamHandler objEIT = new SL_EngagementInternalTeamHandler(Trigger.isExecuting, Trigger.size);
	
	//If trigger is after insert
	if(Trigger.isAfter && Trigger.isInsert)
		objEIT.onAfterInsert(Trigger.new);
	
	//If trigger is after delete    
	if(Trigger.isAfter && Trigger.isDelete)
		objEIT.onAfterDelete(Trigger.oldMap);
		
	//If trigger is after update    
	if(Trigger.isAfter && Trigger.isUpdate)
		objEIT.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
			
}
/* End */