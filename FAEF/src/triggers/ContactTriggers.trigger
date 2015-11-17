trigger ContactTriggers on Contact (after insert, after update) {
	
	if(Trigger.isAfter) {
		//Check if the ContactTrigger is already running.
        if(!TriggerMonitor.ExecutedTriggers.contains('updateAccountLastCallAttemptFields')){ 
            ContactTriggers.updateAccountLastCallAttemptFields(Trigger.new);
        	TriggerMonitor.ExecutedTriggers.add('updateAccountLastCallAttemptFields');
        }

        if(Trigger.isUpdate) UpdateVMInPersonDates.copyDateFromContactToAccount(Trigger.new, Trigger.OldMap);
	}
	 
}