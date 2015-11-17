/**
* @TriggerName  : SL_FinancialPlan   
* @JIRATicket   : HIL-21
* @CreatedOn    : 13/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger to update HouseHold field value on inserted Financial_Plan__c.
*/
trigger SL_FinancialPlan on Financial_Plan__c (before insert, after insert) 
{
	if(Trigger.isInsert)
	{
		if(Trigger.isBefore)
			SL_FinancialPlanHandler.onBeforeInsert(Trigger.new);
		else if(Trigger.isAfter)
			SL_FinancialPlanHandler.onAfterInsert(Trigger.new);
	}
}