public with sharing class FootstepsSendLeadsJob  implements Schedulable {
	
	
	public Set<ID> leadIDsToSendToFootsteps {
		
		get {
			
			if (leadIDsToSendToFootsteps == null){
				leadIDsToSendToFootsteps = new Set<Id>();
			}
			return leadIDsToSendToFootsteps;
		}
		set;
		
	}
	
	public map<Id, set<Id>> leadIdsToDealerIdMap {
		get {
			if (leadIdsToDealerIdMap == null) {
				leadIdsToDealerIdMap = new map<Id, set<Id>>();
			}
			return leadIdsToDealerIdMap;
		}
		set;
	}
	
	public FootstepsSendLeadsJob(map<Id, set<Id>> leadIdsToDealerIdMap_Input){
		leadIdsToDealerIdMap = 	leadIdsToDealerIdMap_Input;
	}
	
	public FootstepsSendLeadsJob(Set<Id> leadIDsToSendToFootsteps_Input){
		leadIDsToSendToFootsteps = leadIDsToSendToFootsteps_Input;
	}
	
	public void execute( SchedulableContext sc ) {
	    System.debug( sc.getTriggerId() );
	    System.debug( 'leadIDsToSendToFootsteps: ' + leadIDsToSendToFootsteps );
	    System.debug( 'leadIdsToDealerIdMap: ' + leadIdsToDealerIdMap );
	    CronTrigger c = [SELECT Id FROM CronTrigger WHERE Id = :sc.getTriggerId() ];
	    
	    if (!leadIDsToSendToFootsteps.isEmpty()) {
	    	system.debug('Sending set of ids to footsteps');
	    	LeadFootstepsService.sendToFootsteps(leadIDsToSendToFootsteps);
	    }
	    else if (!leadIdsToDealerIdMap.isEmpty()) {
	    	string jsonInput = JSON.serialize(leadIdsToDealerIdMap);
	    	system.debug('Sending json data map to footsteps - ' + jsonInput);
	    	LeadFootstepsService.sendToFootsteps(jsonInput);	
	    }
	    System.abortJob( sc.getTriggerId() );
    }
    
}