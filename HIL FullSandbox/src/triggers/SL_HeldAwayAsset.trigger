/**
* @TriggerName  : SL_HeldAwayAsset   
* @JIRATicket   : HIL-21
* @CreatedOn    : 13/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger to update HouseHold field value on inserted Held_Away_Asset__c.
*/
trigger SL_HeldAwayAsset on Held_Away_Asset__c (before insert) 
{
	if(Trigger.isInsert) 
	{
 		if(Trigger.isBefore)
  			SL_HeldAwayAssetHandler.onBeforeInsert(Trigger.new);
 	}
}