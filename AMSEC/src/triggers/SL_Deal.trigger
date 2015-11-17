trigger SL_Deal on Deal__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	SL_TriggerFactory.createTriggerHandler(Deal__c.sObjectType);
}