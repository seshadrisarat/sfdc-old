/**
* \arg TriggerName    : SL_Relationship
* \arg JIRATicket     : PWP-5,PWP-8
* \arg CreatedOn      : 11/DEC/2014
* \arg LastModifiedOn : 22/JAN/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This trigger is used to update the account field on relationship object record with corresponding Contact's account if account id is blank. 
*/
trigger SL_Relationship on Relationship__c (before insert, before update, after delete, after insert, after update, after undelete) 
{
	SL_RelationshipHandler objRelationshipHandler = new SL_RelationshipHandler();//instantiating the handler class

	//checking if trigger is fired on before
	if(trigger.isBefore)
	{
		if(Trigger.isInsert)
			objRelationshipHandler.onBeforeInsert(Trigger.new);
		if(Trigger.isUpdate)
			objRelationshipHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
	} 
	else if(trigger.isAfter)
	{
		if(trigger.isInsert)
			objRelationshipHandler.onAfterInsert(Trigger.new);
		
		if(trigger.isUpdate)
			objRelationshipHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);	
		
		if(trigger.isDelete) 
			objRelationshipHandler.onAfterDelete(Trigger.oldMap);
		
		if(trigger.isUnDelete)
			objRelationshipHandler.onAfterUnDelete(Trigger.new);
	}
}