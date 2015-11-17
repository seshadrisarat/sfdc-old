/**
* @TriggerName  : SL_IncomeSource   
* @JIRATicket   : HIL-21
* @CreatedOn    : 13/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger to update HouseHold field value on inserted Income_Source__c.
*/
trigger SL_IncomeSource on Income_Source__c (before insert, after insert) 
{
	if(Trigger.isInsert)
	{
		if(Trigger.isBefore)
			SL_IncomeSourceHandler.onBeforeInsert(Trigger.new);
		else if(Trigger.isAfter)
			SL_IncomeSourceHandler.onAfterInsert(Trigger.new);
	}
}