/**
*  Trigger Name   : SL_Engagement
*  JIRATicket     : HL-11
*  CreatedOn      : 21/April/2014
*  ModifiedBy     : Prakash
*  Description    : Trigger used to create or update or delete 'Engagement Clients/Subjects' Joiner object records 
					when 'Client_c' or 'subject_c' fields on 'Engagement__c' object has updated.
*/
trigger SL_Engagement on Engagement__c (after insert, after update) 
{
	//Creating instance of handler class.
	SL_EngagementHandler handler = new SL_EngagementHandler(Trigger.isExecuting, Trigger.size);
	
	//If trigger is after insert
	if(trigger.isAfter && trigger.isInsert)
		handler.onAfterInsert(Trigger.newMap);  

    //If trigger is after update
	if(trigger.isAfter && trigger.isUpdate)
		handler.onAfterUpdate(Trigger.newMap, Trigger.oldMap); 
}