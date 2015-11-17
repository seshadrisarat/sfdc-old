public with sharing class FootstepsSendAccountsJob  implements Schedulable {
	
	
	public Set<ID> accountIDsToSendToFootsteps {
		
		get {
			
			if (accountIDsToSendToFootsteps == null){
				accountIDsToSendToFootsteps = new Set<Id>();
			}
			return accountIDsToSendToFootsteps;
		}
		set;
		
	}
	
	public map<Id, set<Id>> accountIdsToDealerIdMap {
		get {
			if (accountIdsToDealerIdMap == null) {
				accountIdsToDealerIdMap = new map<Id, set<Id>>();
			}
			return accountIdsToDealerIdMap;
		}
		set;
	}
	
	public FootstepsSendAccountsJob(){
		
	}
	
	
	public FootstepsSendAccountsJob(map<Id, set<Id>> accountIdsToDealerIdMap_Input){
		accountIdsToDealerIdMap = 	accountIdsToDealerIdMap_Input;
	}
	
	public FootstepsSendAccountsJob(Set<Id> accountIDsToSendToFootsteps_Input){
		accountIDsToSendToFootsteps = accountIDsToSendToFootsteps_Input;
	}
	
	public void execute( SchedulableContext sc ) {
	    System.debug( sc.getTriggerId() );
	    System.debug( 'accountIDsToSendToFootsteps: ' + accountIDsToSendToFootsteps );
	    System.debug( 'accountIdsToDealerIdMap: ' + accountIdsToDealerIdMap );
	    CronTrigger c = [SELECT Id FROM CronTrigger WHERE Id = :sc.getTriggerId() ];
	    
	    if (!accountIDsToSendToFootsteps.isEmpty()) {
	    	system.debug('Sending set of ids to footsteps');
	    	AccountFootstepsService.sendToFootsteps(accountIDsToSendToFootsteps);
	    }
	     else if (!accountIdsToDealerIdMap.isEmpty()) {
	    	string jsonInput = JSON.serialize(accountIdsToDealerIdMap);
	    	system.debug('Sending json data map to footsteps - ' + jsonInput);
	    	AccountFootstepsService.sendToFootsteps(jsonInput);	
	    }
	    System.abortJob( sc.getTriggerId() );
    }
    
}