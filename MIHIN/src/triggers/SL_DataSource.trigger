trigger SL_DataSource on Data_Source__c (before insert, before update, after insert, after update) {
	SL_DataSource_Handler handler = new SL_DataSource_Handler();
	if(Trigger.isInsert){
		if(Trigger.isBefore){
			handler.onBeforeInsert(Trigger.new);
		}
		else if(Trigger.isAfter){
			handler.onAfterInsert(Trigger.newMap);
		}
	}
	else if(Trigger.isUpdate){
		if(Trigger.isBefore){
			handler.onBeforeUpdate(Trigger.new);
		}
		else if(Trigger.isAfter){
			handler.onAfterUpdate(Trigger.newMap);
		}
	}

}