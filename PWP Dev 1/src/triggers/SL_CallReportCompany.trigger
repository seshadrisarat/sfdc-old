/**
* \arg TriggerName      : SL_CallReportCompany
* \arg JIRATicket     	: PWP-9
* \arg CreatedOn      	: 5/DEC/2014
* \arg LastModifiedOn 	: -
* \arg CreatededBy    	: Pankaj Ganwani
* \arg ModifiedBy     	: Pankaj Ganwani
* \arg Description    	: This trigger is used to create call report share records corresponding to those call report company records for coverage team members
*/
trigger SL_CallReportCompany on Call_Report_Company__c (after delete, after insert, after update, after undelete) 
{
	SL_CallReportCompanyHandler objCRCHandler = new SL_CallReportCompanyHandler();
	
	if(Trigger.isAfter)
	{
		if(Trigger.isInsert)
			objCRCHandler.onAfterInsert(Trigger.new);
		if(Trigger.isUpdate)
			objCRCHandler.onAfterUpdate(Trigger.newMap,Trigger.oldMap);
		if(Trigger.isDelete)
			objCRCHandler.onAfterDelete(Trigger.old);
		if(Trigger.isUnDelete)
			objCRCHandler.onAfterUndelete(Trigger.new);
	}
}