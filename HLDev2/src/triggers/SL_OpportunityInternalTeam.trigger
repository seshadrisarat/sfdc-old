/**
*  Trigger Name   : SL_OpportunityInternalTeam
*  JIRATicket     : HL-90
*  CreatedOn      : 21/Jan/2015
*  ModifiedBy     : 
*  Description    : Trigger used to create manual sharing record for Opportunity. 
*/
trigger SL_OpportunityInternalTeam on Opportunity_Internal_Team__c (after delete, after insert, after update) 
{
	//Creating instance of handler class.
	SL_OpportunityInternalTeamHandler objOIT = new SL_OpportunityInternalTeamHandler(Trigger.isExecuting, Trigger.size);
	
	//If trigger is after insert
	if(Trigger.isAfter && Trigger.isInsert)
		objOIT.onAfterInsert(Trigger.new);
	
	//If trigger is after delete     
	if(Trigger.isAfter && Trigger.isDelete)
		objOIT.onAfterDelete(Trigger.oldMap);
		
	//If trigger is after Update     
	if(Trigger.isAfter && Trigger.isUpdate)
		objOIT.onAfterUpdate(Trigger.oldMap, Trigger.newMap);	
}