/****************************************************************************************
Name            : psaMilestone
Author          : Julia Kolesnik
Created Date    : January 23, 2014
Description     : psaMilestone trigger
******************************************************************************************/
trigger psaMilestone on pse__Milestone__c (after insert, after update, after delete, after undelete) {
	
	psaMilestoneHandler handler = new psaMilestoneHandler(Trigger.isExecuting, Trigger.size);
	if (trigger.isAfter) {
		if (trigger.isInsert || trigger.isUnDelete) {
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