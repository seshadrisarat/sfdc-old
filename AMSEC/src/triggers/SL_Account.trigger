trigger SL_Account on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	// This is the only line of code that is required.
	SL_TriggerFactory.createTriggerHandler(Account.sObjectType);
}