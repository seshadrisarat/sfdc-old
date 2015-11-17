/**  
* \arg ClassName      : SL_InstallationAdjustment
* \arg JIRATicket     : STARGAS-45
* \arg CreatedOn      : 24/JULY/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This trigger is used to update the Installation_Job__c record with the related most recent Installation_Adjustments__c child record on insertion, updation and deletion of Installation_Adjustments__c record.
*/
trigger SL_InstallationAdjustment on Installation_Adjustments__c (after delete, after insert, after update) 
{
	if(Trigger.isAfter)
	{
		if(Trigger.isInsert)
			SL_InstallationAdjustmentHandler.onAfterInsert(Trigger.new);
		else if(Trigger.isUpdate)
			SL_InstallationAdjustmentHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
		else 
			SL_InstallationAdjustmentHandler.onAfterDelete(Trigger.old);
	}
}