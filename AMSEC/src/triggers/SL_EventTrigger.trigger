trigger SL_EventTrigger on Event (
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
	    	
	    
		}
}