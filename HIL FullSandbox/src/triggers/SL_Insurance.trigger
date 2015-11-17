/**
* @TriggerName  : SL_Insurance   
* @JIRATicket   : HIL-21
* @CreatedOn    : 13/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger to update HouseHold field value on inserted Insurance__c.
*/
trigger SL_Insurance on Insurance__c (before insert, after insert) 
{
	if(Trigger.isInsert)
	{
		if(Trigger.isBefore)
			SL_InsuranceHandler.onBeforeInsert(Trigger.new);
		else if(Trigger.isAfter)
			SL_InsuranceHandler.onAfterInsert(Trigger.new);
	}
}