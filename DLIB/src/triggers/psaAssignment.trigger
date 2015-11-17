/****************************************************************************************
Name            : psaAssignment
Author          : Julia Kolesnik
Created Date    : March 07, 2014
Description     : psaAssignment trigger, SLFF-35
******************************************************************************************/
trigger psaAssignment on pse__Assignment__c (before insert, before update) {
	psaAssignmentHandler handler = new psaAssignmentHandler(Trigger.isExecuting, Trigger.size);
	if (trigger.isBefore) {
		if (trigger.isInsert ) {
			handler.onBeforeInsert(trigger.new);
		}
		if (trigger.isUpdate ) {
			handler.onBeforeUpdate(trigger.newMap, trigger.oldMap);
		}
	}
}