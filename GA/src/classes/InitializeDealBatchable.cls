global class InitializeDealBatchable implements Database.Batchable<SObject>, Database.Stateful {
    private String query;

    global InitializeDealBatchable(String query) {
		this.query = 'SELECT Id, (SELECT Id FROM Deal_Themes__r WHERE IsDeleted=FALSE LIMIT 1), (SELECT Id FROM Team_Members__r WHERE IsDeleted=FALSE LIMIT 1) FROM Deal__c WHERE IsDeleted=FALSE';
		if (query != null) {
			this.query = query;
		}
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> batch) {
    	Map<Id, Deal__c> deals = new Map<Id, Deal__c>();
    	for (Deal__c d : (List<Deal__c>) batch) {
			if (d.Deal_Themes__r.isEmpty()) {
				deals.put(d.Id, new Deal__c(
					Id = d.Id,
					Theme_s__c = ''
				));
			}
			if (d.Team_Members__r.isEmpty()) {
				if (deals.containsKey(d.Id)) {
					deals.get(d.Id).Deal_Team_Members__c = '';					
				} else {
					deals.put(d.Id, new Deal__c(
						Id = d.Id,
						Deal_Team_Members__c = ''
					));
				}
			}
    	}
    	
    	if (!deals.isEmpty()) {
    		update deals.values();    		
    	}
    }

    global void finish(Database.BatchableContext bc) {}
}