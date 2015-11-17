/**
*  TriggerName      : SL_ProspectServiceContract
*  JIRATicket     	: STARGAS-37
*  CreatedOn      	: 24/MAR/2015
*  LastModifiedOn   : 23/APR/2015
*  ModifiedBy     	: Pankaj Ganwani
*  Description    	: This trigger is used to update the Opportunity corresponding to the recently inserted/recently updated prospect service contract record's service code.
*/
trigger SL_ProspectServiceContract on Prospect_Service_Contract__c (after insert, after update, after delete) 
{
	if(Trigger.isAfter)
	{
		if(Trigger.isInsert)
			SL_ProspectServiceContractHandler.onAfterInsert(Trigger.new);
		if(Trigger.isUpdate)
			SL_ProspectServiceContractHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
		if(Trigger.isDelete)
			SL_ProspectServiceContractHandler.onAfterDelete(Trigger.old);
	}
}