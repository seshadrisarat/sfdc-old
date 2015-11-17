global class InitializeThemeBatchable implements Database.Batchable<SObject>, Database.Stateful {
    private String query;

    global InitializeThemeBatchable(String query) {
		this.query = 'SELECT Id, (SELECT Id FROM Deal_Themes__r WHERE IsDeleted=FALSE LIMIT 1) FROM Theme__c WHERE IsDeleted=FALSE';
		if (query != null) {
			this.query = query;
		}
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> batch) {
    	List<Theme__c> themes = new List<Theme__c>();
    	for (Theme__c t : (List<Theme__c>) batch) {
			if (t.Deal_Themes__r.isEmpty()) {
				themes.add(new Theme__c(
					Id = t.Id,
					Companies__c = 0,
					Deals_Closed__c = 0,
					Companies_Called__c = 0,
					Companies_Met__c = 0,
					Companies_Taken_to_IC__c = 0
				));
			}
    	}
    	
    	if (!themes.isEmpty()) {
    		update themes;    		
    	}
    }

    global void finish(Database.BatchableContext bc) {}
}