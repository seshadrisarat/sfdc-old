trigger LimitChatterCommentFileSize on FeedComment (before insert, before update, after insert, after update) {
	
	if((Trigger.isBefore) && (Trigger.isInsert || Trigger.isUpdate) 
	&& (SROCUtilities.isCCL() || SROCUtilities.isCCU()) )
	{
		LimitChatterFileSizeTriggerHandler.onBefore(trigger.new);
	} 
	
}