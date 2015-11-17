trigger SL_Contact on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	SL_TriggerFactory.createTriggerHandler(Contact.sObjectType);
}