/**
* @TriggerName  : SL_Interests   
* @JIRATicket   : HIL-21
* @CreatedOn    : 13/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger to update HouseHold field value on inserted Interests__c.
*/
trigger SL_Interests on Interests__c (before insert, after insert) 
{
	if(Trigger.isInsert) 
	{
 		if(Trigger.isBefore)
  			SL_InterestsHandler.onBeforeInsert(Trigger.new);
  		else if(Trigger.isAfter)
  			SL_InterestsHandler.onAfterInsert(Trigger.new);
 	}
}