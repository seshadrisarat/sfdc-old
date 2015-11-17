/****************************************************************************************
Name            : psaTimecard
Author          : Julia Kolesnik
Created Date    : January 21, 2014
Description     : psaTimecard trigger
******************************************************************************************/
trigger psaTimecard on pse__Timecard_Header__c (after insert, after update, after delete, after undelete) {
	
	psaTimecardHandler handler = new psaTimecardHandler(Trigger.isExecuting, Trigger.size);
	if (trigger.isAfter && !psaTimecardHandler.isDone) {
		if (trigger.isInsert || trigger.isUndelete) {
			handler.onAfterInsert(trigger.new);
		}
		if (trigger.isUpdate) {
			handler.onAfterUpdate(trigger.newMap, trigger.oldMap);
		}
		if (trigger.isDelete) {
			handler.onAfterDelete(trigger.old);
		}
	}
}