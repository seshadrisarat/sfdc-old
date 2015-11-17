trigger SL_Product2 on Product2 (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	SL_TriggerFactory.createTriggerHandler(Product2.sObjectType);
}