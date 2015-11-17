/**
* \arg TriggerName      : SL_FinancialAccount
* \arg JIRATicket       : HIL-7
* \arg CreatedOn        : 18/FEB/2015
* \arg LastModifiedOn   : 20/FEB/2015
* \arg CreatededBy      : Pankaj Ganwani
* \arg ModifiedBy       : Pankaj Ganwani
* \arg Description      : This trigger is used to update the HL account records corresponding to updated financial accounts which in turn updates the Group member records.
*/
trigger SL_FinancialAccount on Financial_Account__c (after update, after delete, before delete) 
{
	SL_FinancialAccountHandler objFinancialAccountHandler = new SL_FinancialAccountHandler();
	
	if(Trigger.isAfter)
	{
		if(Trigger.isUpdate)
			objFinancialAccountHandler.onAfterUpdate(Trigger.oldMap,Trigger.newMap);
		if(Trigger.isDelete)
			objFinancialAccountHandler.onAfterDelete();
	}
	
	if(Trigger.isBefore)
		objFinancialAccountHandler.onBeforeDelete(Trigger.oldMap);
}