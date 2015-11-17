/**
* @TriggerName  : SL_Liability   
* @JIRATicket   : HIL-21
* @CreatedOn    : 13/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger to update HouseHold field value on inserted Liability__c.
*/
trigger SL_Liability on Liability__c (before insert, after insert) 
{
	if(Trigger.isInsert)
	{
		if(Trigger.isBefore)
			SL_LiabilityHandler.onBeforeInsert(Trigger.new);
		else if(Trigger.isAfter)
			SL_LiabilityHandler.onAfterInsert(Trigger.new);
	}
}