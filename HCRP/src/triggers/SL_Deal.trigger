trigger SL_Deal on Deal__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	SL_TriggerFactory.createTriggerDispatcher(Deal__c.sObjectType);
}