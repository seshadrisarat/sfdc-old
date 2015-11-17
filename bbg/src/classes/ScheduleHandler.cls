global class ScheduleHandler implements Schedulable {
	
	
	public Set<ID> leadIDsToSendToFootsteps {
		
		get {
			
			if (leadIDsToSendToFootsteps == null){
				leadIDsToSendToFootsteps = new Set<Id>();
			}
			return leadIDsToSendToFootsteps;
		}
		set;
		
	}
	
	public Set<ID> ownerIDsToSendToFootsteps {
		
		get {
			
			if (ownerIDsToSendToFootsteps == null){
				ownerIDsToSendToFootsteps = new Set<Id>();
			}
			return ownerIDsToSendToFootsteps;
		}
		set;
		
	}
	
	
	public ScheduleHandler(){
		
	}
	
	public ScheduleHandler(Set<Id> leadIDsToSendToFootsteps_Input){
		leadIDsToSendToFootsteps = leadIDsToSendToFootsteps_Input;
	}
	
	public ScheduleHandler(Set<Id> ids, boolean owner){
		if (owner) {
			ownerIDsToSendToFootsteps = ids;
		}
		else {
			leadIDsToSendToFootsteps = ids;
		}
		
	}
	
	public void execute( SchedulableContext sc ) {
	    System.debug( sc.getTriggerId() );
	    System.debug( 'leadIDsToSendToFootsteps: ' + leadIDsToSendToFootsteps );
	    System.debug( 'ownerIDsToSendToFootsteps: ' + ownerIDsToSendToFootsteps );
	    CronTrigger c = [SELECT Id FROM CronTrigger WHERE Id = :sc.getTriggerId() ];
	    if (leadIDsToSendToFootsteps != null && !leadIDsToSendToFootsteps.isEmpty()) {
	   		LeadServices.sendFootstepsLeads(leadIDsToSendToFootsteps);
	    }
	    else if (ownerIDsToSendToFootsteps != null && !ownerIDsToSendToFootsteps.isEmpty()) {
	    	OwnerServices.sendFootstepsOwners(ownerIDsToSendToFootsteps);
	    }
	    System.abortJob( sc.getTriggerId() );
    }
    
}