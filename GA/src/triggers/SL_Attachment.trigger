trigger SL_Attachment on Attachment (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	SL_TriggerFactory.createTriggerDispatcher(Attachment.sObjectType);
	
	/* Start - This code snippet has been added as per the requirement of GA-26*/
	if(Trigger.isAfter)
	{
		if(Trigger.isInsert)
			SL_AttachmentHandler.onAfterInsert(Trigger.new);
		if(Trigger.isDelete)
			SL_AttachmentHandler.onAfterDelete(Trigger.old);		
	}
	/* End - This code snippet has been added as per the requirement of GA-26*/
}