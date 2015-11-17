/**
* \arg TriggerName      : SL_HilliardLyonsAccount
* \arg JIRATicket       : HIL-7
* \arg CreatedOn        : 20/FEB/2015
* \arg LastModifiedOn   : -
* \arg CreatededBy      : Pankaj Ganwani
* \arg ModifiedBy       : -
* \arg Description      : This trigger is used to update the HL account records to copy the cross object formula field values to corresponding place holder fields.
*/
trigger SL_HilliardLyonsAccount on Hilliard_Lyons_Account__c (after delete, after insert, after undelete, 
after update, before insert, before update) 
{
	SL_HilliardLyonsAccountHandler objHLAccountHandler = new SL_HilliardLyonsAccountHandler();
	
	if(Trigger.isAfter)
	{
		if(Trigger.isInsert)
		{
			objHLAccountHandler.onAfterInsert(Trigger.newMap);
		}

		if(Trigger.isUpdate)
		{
			objHLAccountHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
		}

		if(Trigger.isDelete)
			objHLAccountHandler.onAfterDelete(Trigger.oldMap);
		if(Trigger.isUnDelete)
			objHLAccountHandler.onAfterUndelete(Trigger.new);
	}
	
	if(Trigger.isBefore)
	{
		if(Trigger.isInsert)
			objHLAccountHandler.onBeforeInsert(Trigger.new);
	}
}