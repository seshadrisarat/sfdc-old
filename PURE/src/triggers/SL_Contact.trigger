trigger SL_Contact on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    Final Static Boolean ACTIVE = false;
	SL_Contact_Trigger_Handler handler = new SL_Contact_Trigger_Handler(Trigger.isExecuting, Trigger.size);

    if(ACTIVE){
    	if(trigger.IsUpdate){
            if(trigger.IsAfter){
                handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap);
            }
        }

        if(trigger.IsInsert){
        	if(trigger.IsAfter){
        		handler.onAfterInsert(Trigger.newMap);
        	}
        }

        if(trigger.IsUndelete){
        	if(trigger.IsAfter){
        		handler.onAfterUndelete(Trigger.newMap);
        	}
        }
    }
}