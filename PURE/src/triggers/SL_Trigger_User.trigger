trigger SL_Trigger_User on User (after insert, after update) {

	SL_Handler_User handler = new SL_Handler_User(Trigger.isExecuting, Trigger.size);

	if (Trigger.isAfter) {
        if(Trigger.isInsert){
            handler.OnAfterInsert(Trigger.newMap);
        }
    	
        if(Trigger.isUpdate){
            handler.OnAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
	}
}