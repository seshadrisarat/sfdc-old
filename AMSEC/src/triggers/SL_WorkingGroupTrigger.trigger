trigger SL_WorkingGroupTrigger on External_Working_Group_Member__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	SL_WorkingGroupTriggerHandler handler = new SL_WorkingGroupTriggerHandler();
	if(Trigger.isBefore)
	{
		if(Trigger.isInsert)
		{
			handler.onBeforeInsert(Trigger.new);
		}
		else if(Trigger.isUpdate)
		{
			// do nothing
		}
		else if(Trigger.isDelete)
		{
			handler.onBeforeDelete(Trigger.oldMap);
		}
	}
	else if(Trigger.isAfter)
	{
		if(Trigger.isInsert)
		{
			handler.onAfterInsert(Trigger.new);
		}
		else if(Trigger.isUpdate)
		{
			handler.onAfterUpdate(Trigger.newMap,Trigger.oldMap);
		}
		else if(Trigger.isDelete)
		{
			
		}
	}

}