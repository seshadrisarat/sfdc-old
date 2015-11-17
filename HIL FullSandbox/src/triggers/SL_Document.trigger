/**
* @TriggerName  : SL_Document   
* @JIRATicket   : HIL-21
* @CreatedOn    : 13/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger to update HouseHold field value on inserted Document__c.
*/
trigger SL_Document on Document__c (before insert, after insert) 
{
	if(Trigger.isInsert)
	{
		if(Trigger.isBefore)
			SL_DocumentHandler.onBeforeInsert(Trigger.new);
		else if(Trigger.isAfter)
			SL_DocumentHandler.onAfterInsert(Trigger.new);
	}
}