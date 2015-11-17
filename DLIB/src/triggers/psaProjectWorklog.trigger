/****************************************************************************************
Name            : psaProjectWorklog
Author          : Julia Kolesnik
Created Date    : January 27, 2014
Description     : psaProjectWorklog trigger
******************************************************************************************/
trigger psaProjectWorklog on Worklog__c (before insert, before update, after insert, after update, after delete, after undelete) {
	
	psaProjectWorklogHandler handler = new psaProjectWorklogHandler(Trigger.isExecuting, Trigger.size);
	//old logic from https://silverline.jira.com/browse/SLPSA-2 
	//SL_Worklog_TriggerHandler SL_handler = new SL_Worklog_TriggerHandler(Trigger.isExecuting, Trigger.size);
	//if(psaProjectWorklogHandler.isFirstRun()) {
		if (trigger.isBefore) {
			if (trigger.isInsert) {
				handler.onBeforeInsert(trigger.new);
				//SL_handler.onBeforeInsert(trigger.new);
			}
			if (trigger.isUpdate) {
				handler.onBeforeUpdate(trigger.newMap, trigger.oldMap);
				//SL_handler.onBeforeUpdate(trigger.oldMap, trigger.newMap);
			}
		}
		if (trigger.isAfter) {
			if (trigger.isInsert || trigger.isUndelete) {
				handler.onAfterInsert(trigger.new);
			}
			if (trigger.isUpdate) {
				handler.onAfterUpdate(trigger.newMap, trigger.oldMap);
			}
			if (trigger.isDelete) {
				handler.onAfterDelete(trigger.old);
			}
			//psaProjectWorklogHandler.setRun();
		}
	//}

}