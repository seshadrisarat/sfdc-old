/**
* @TriggerName  : SL_ProductsServices   
* @JIRATicket   : HIL-21
* @CreatedOn    : 13/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger to update HouseHold field value on inserted Products_Services__c.
*/
trigger SL_ProductsServices on Products_Services__c (before insert, after insert) 
{
	if(Trigger.isInsert)
	{
		if(Trigger.isBefore)
			SL_ProductsServicesHandler.onBeforeInsert(Trigger.new);
		if(Trigger.isAfter)
			SL_ProductsServicesHandler.onAfterInsert(Trigger.new);
	}
}