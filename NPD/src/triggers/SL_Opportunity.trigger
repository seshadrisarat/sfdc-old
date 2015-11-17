trigger SL_Opportunity on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	SL_TriggerFactory.createTriggerHandler(Opportunity.sObjectType);
}