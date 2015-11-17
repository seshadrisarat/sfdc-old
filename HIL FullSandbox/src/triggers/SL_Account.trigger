trigger SL_Account on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	SL_TriggerFactory.createTriggerDispatcher(Account.sObjectType);
}