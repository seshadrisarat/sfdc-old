/**
* @TriggerName  : SL_Opportunity   
* @JIRATicket   : HIL-21
* @CreatedOn    : 12/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger to update HouseHold field value on inserted Opportunity and to create sharing records based on Rep codes.
*/

Trigger SL_Opportunity on Opportunity (before insert, after insert)
{
 	if(Trigger.isInsert) 
	{
 		if(Trigger.isBefore)
  			SL_OpportunityHandler.onBeforeInsert(Trigger.new);
  		if(Trigger.isAfter)
  			SL_OpportunityHandler.onAfterInsert(Trigger.new);
 	}
}