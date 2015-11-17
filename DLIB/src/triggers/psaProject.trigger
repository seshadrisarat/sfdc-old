trigger psaProject on pse__Proj__c (before insert, before update, after insert, after update ) {
	psaProjectHandler oHandler = new psaProjectHandler();
	if (trigger.isBefore) {
		if (trigger.isInsert) {
			oHandler.onBeforeInsert(trigger.new);
		}
		if (trigger.isUpdate) {
			oHandler.onBeforeUpdate(trigger.newMap, trigger.oldMap);
		}
	}
    if ( trigger.isAfter ) { 
    	if ( trigger.IsInsert ) {
        
            oHandler.OnAfterInsert( Trigger.newMap );
        }
        if (trigger.isUpdate) {
			oHandler.onAfterUpdate(trigger.newMap, trigger.oldMap);
		}
    }
}