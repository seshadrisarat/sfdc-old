trigger SL_Relationship_Group on Relationship_Group__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	SL_TriggerFactory.createTriggerDispatcher(Relationship_Group__c.sObjectType);
	
	SL_Relationship_GroupHandler objGrpHandler = new SL_Relationship_GroupHandler(); 
	if(trigger.isAfter && trigger.isUpdate)
	{
		objGrpHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
	}
}