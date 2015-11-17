trigger CC_Community_Content_Trigger on CORECONNECT__CC_Community_Content__c (after insert, after update, before insert, 
before update) {
	
	if(Trigger.IsBefore && Trigger.IsInsert)
	{
		CC_Community_Content_TriggerHandler.handleEventsBeforeInsert(Trigger.New);
	}
	else if(Trigger.IsBefore && Trigger.IsUpdate)
	{
		CC_Community_Content_TriggerHandler.handleEventsBeforeUpdate(Trigger.OldMap, Trigger.New);
	}
	else if(Trigger.IsAfter && Trigger.IsInsert)
	{
		CC_Community_Content_TriggerHandler.handleEventsAfterInsert(Trigger.New);
	}
	else if(Trigger.IsAfter && Trigger.IsUpdate)
	{
		CC_Community_Content_TriggerHandler.handleEventsAfterUpdate(Trigger.OldMap, Trigger.New);
	}

}