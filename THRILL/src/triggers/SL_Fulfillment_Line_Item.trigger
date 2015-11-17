trigger SL_Fulfillment_Line_Item on Fulfillment_Line_Item__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	SL_TriggerFactory.createTriggerHandler(Fulfillment_Line_Item__c.sObjectType);
}