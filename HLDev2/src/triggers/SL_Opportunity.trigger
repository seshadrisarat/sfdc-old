/**
*  Trigger Name   : SL_Opportunity
*  JIRATicket     : HL-11
*  CreatedOn      : 21/April/2014
*  ModifiedBy     : Prakash
*  Description    : Trigger used to create or update or delete 'Opportunity_Client_Subject__c' Joiner object records 
					when 'Client_c' or 'subject_c' fields on 'Opportunity__c' object has updated.
*/
trigger SL_Opportunity on Opportunity__c (after insert, after update) 
{
	//Creating instance of handler class.
	SL_OpportunityHandler objSL_OpportunityTriggerHandler = new SL_OpportunityHandler(Trigger.isExecuting, Trigger.size);
	
	//If trigger is after insert
	if(trigger.isAfter && trigger.isInsert)
		objSL_OpportunityTriggerHandler.onAfterInsert(Trigger.newMap);  

    //If trigger is after update
	if(trigger.isAfter && trigger.isUpdate)
		objSL_OpportunityTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap); 
}