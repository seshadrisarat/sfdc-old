/**
* \arg TriggerName    : SL_RollUpDealTeamMembersToDeal
* \arg JIRATicket     : MOELISSUPP-17
* \arg CreatedOn      : 21/01/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This trigger works to store the Bankers names in comma separated fashion in Deal_Team_Members__c field on Deal Object 
*/

trigger SL_RollUpDealTeamMembersToDeal on Project_Resource__c (after delete, after insert, after update) 
{
	//Instantiating the handler class.
	SL_RollUpDealTeamMembersToDealHandler objSL_RollUpDealTeamMembersToDealHandler = new SL_RollUpDealTeamMembersToDealHandler();
	
	if(Trigger.isAfter && Trigger.isInsert)
	{
		objSL_RollUpDealTeamMembersToDealHandler.onAfterInsert(Trigger.new);//Calling onAfterInsert method of Handler.
	}
	
	if(Trigger.isAfter && Trigger.isUpdate)
	{
		objSL_RollUpDealTeamMembersToDealHandler.onAfterUpdate(Trigger.oldMap,Trigger.newMap);//Calling onAfterUpdate method of Handler.
	}
	
	if(Trigger.isAfter && Trigger.isDelete)
	{
		objSL_RollUpDealTeamMembersToDealHandler.onAfterDelete(Trigger.old);//Calling onAfterDelete method of Handler.
	}
}