trigger SL_TaskTrigger on Task (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {
		SL_ActivityWorkingGroupHandler handler = new SL_ActivityWorkingGroupHandler();
		if (Trigger.isBefore) {
	    	//call your handler.before method
	    
		} else if (Trigger.isAfter) {
	    	//call handler.after method
	    
		}
}