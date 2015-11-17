/*
* Create new LP_Committment__c record per mapping below, if Stage__c = Closed
* Trigger Name  : createLPCommittment 
* JIRA Ticket   : GREENHILL-12
* Created on    : 23/Apr/2012
* Author		: Snezhana Storoschuk
* Description   : Implement a trigger on Fundraising_Deal__c to insert and update
*/
trigger SL_CreateLPCommitment on Fundraising_Deal__c (after insert, after update) {
	
	Sl_CreatePLCommitment_Handler handler = new Sl_CreatePLCommitment_Handler(Trigger.isExecuting, Trigger.size);
	
	if (trigger.isInsert && trigger.isAfter) {
        handler.OnAfterInsert(Trigger.newMap);
    }
    else if (trigger.IsUpdate && trigger.isAfter) {
		handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap);
    }
}