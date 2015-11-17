/**
* @TriggerName  : SL_HouseholdToAccountAff   
* @JIRATicket   : HIL-21
* @CreatedOn    : 13/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger to update HouseHold field value on inserted Household_To_Account_Affiliation__c.
*/
trigger SL_HouseholdToAccountAff on Household_To_Account_Affiliation__c (before insert) 
{
	if(Trigger.isInsert)
	{
		if(Trigger.isBefore)
			SL_HouseholdToAccountAffHandler.onBeforeInsert(Trigger.new);
	}
}