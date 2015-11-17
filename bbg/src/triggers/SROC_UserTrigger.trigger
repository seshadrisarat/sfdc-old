//Trigger on User
trigger SROC_UserTrigger on User (after insert,after update) {

	SROC_UserTriggerHandler handler = new SROC_UserTriggerHandler();
	
	if(Trigger.isBefore && Trigger.isInsert)
	{
		handler.onBeforeInsert(Trigger.new);
	}
	
    if(Trigger.isAfter && Trigger.isInsert) {

        handler.onAfterInsert(Trigger.newMap);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {

        handler.onAfterUpdate(Trigger.oldMap,Trigger.newMap);   
    }
}