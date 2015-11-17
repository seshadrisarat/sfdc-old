/**
* \arg TriggerName      : SL_CallReport
* \arg JIRATicket     	: PWP-17, PWP-18
* \arg CreatedOn      	: 6th/Feb/2015
* \arg LastModifiedOn   : 2/JUNE/2015
* \arg CreatededBy    	: Pradeep Maddi
* \arg LastModifiedBy	: Pankaj Ganwani
*/

trigger SL_CallReport on Call_Report__c (after insert, after update, after delete, before delete) 
{
	SL_Call_ReportHandler objCRHandler = new SL_Call_ReportHandler();
	
	if(Trigger.isAfter)
	{
		// Calling handler class method on After Insert of Call_Report__c
		if(Trigger.isInsert)
			objCRHandler.onAfterInsert(Trigger.newMap);
			
		// Calling handler class method on After update of Call_Report__c
		if(Trigger.isUpdate)
			objCRHandler.onAfterUpdate(Trigger.newMap,Trigger.oldMap);
			
		if(Trigger.isDelete)
			SL_Call_ReportHandler.onAfterDelete();
	}
	else if(Trigger.isBefore)
	{
		SL_Call_ReportHandler.onBeforeDelete(Trigger.oldMap);
	}
}