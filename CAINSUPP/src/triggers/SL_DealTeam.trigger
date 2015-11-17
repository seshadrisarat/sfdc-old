/**
* \arg TriggerName    : SL_DealTeam
* \arg JIRATicket     : CAINSUPP-14
* \arg CreatedOn      : 09/17/2015
* \arg CreatededBy    : Manu
* \arg ModifiedBy     : Manu
* \arg Description    : Generic Trigger for Cain_Deal_Team__c
*/
trigger SL_DealTeam on Cain_Deal_Team__c (after insert, after update) {
	//Instantiating the Handler class.
	SL_DealTeamHandler objSL_DealTeamHandler = new SL_DealTeamHandler();
	
	if(Trigger.isAfter && Trigger.isInsert)
	{
		objSL_DealTeamHandler.onAfterInsert(Trigger.newMap); 
	}
	
	if(Trigger.isAfter && Trigger.isUpdate)
	{
		objSL_DealTeamHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
	}
}