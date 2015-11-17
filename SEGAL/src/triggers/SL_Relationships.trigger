/**
*  Trigger Name   : SL_Relationships
*  JIRATicket     : SEGAL-5
*  CreatedOn      : 8/JAN/2015
*  ModifiedBy     : Sanath Kumar
*  Description    : This is the trigger on Relationship object
*/
trigger SL_Relationships on Relationships__c (after delete, after insert, after update, before insert, before update) 
{
	SL_RelationshipTriggerHandler objRelationshipTriggerHandler = new SL_RelationshipTriggerHandler();
	
	if(trigger.isBefore && trigger.isInsert)
	{
		objRelationshipTriggerHandler.onBeforeInsert(trigger.new);
	}
	
	if(trigger.isBefore && trigger.isUpdate)
	{
		objRelationshipTriggerHandler.onBeforeUpdate(trigger.oldMap, trigger.newMap);
	}
	
	if(trigger.isAfter && trigger.isInsert)
	{
		objRelationshipTriggerHandler.onAfterInsert(trigger.new);
	}
	
	if(trigger.isAfter && trigger.isUpdate)
	{
		objRelationshipTriggerHandler.onAfterUpdate(trigger.oldMap, trigger.newMap);
	}
	
	if(trigger.isAfter && trigger.isDelete)
	{
		objRelationshipTriggerHandler.onAfterDelete(trigger.old);
	}
	
}