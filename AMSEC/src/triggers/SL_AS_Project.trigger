trigger SL_AS_Project on AS_Project__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	SL_TriggerFactory.createTriggerHandler(AS_Project__c.sObjectType);
}