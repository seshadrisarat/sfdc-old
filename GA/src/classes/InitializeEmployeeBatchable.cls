global class InitializeEmployeeBatchable implements Database.Batchable<SObject>, Database.Stateful {
    private String query;

    global InitializeEmployeeBatchable(String query) {
		this.query = 'SELECT Id, (SELECT Id FROM Team_Members__r WHERE Deal__r.Status__c<>\'Passed\' AND Deal__r.Status__c<>\'Deal Won\' AND IsDeleted=FALSE LIMIT 1) FROM Employee__c WHERE IsDeleted=FALSE';
		if (query != null) {
			this.query = query;
		}
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> batch) {
    	List<Employee__c> employees = new List<Employee__c>();
    	for (Employee__c e : (List<Employee__c>) batch) {
			if (e.Team_Members__r.isEmpty()) {
				employees.add(new Employee__c(
					Id = e.Id,
					Active_Deals__c = 0
				));
			}
    	}
    	
    	if (!employees.isEmpty()) {
    		update employees;    		
    	}
    }

    global void finish(Database.BatchableContext bc) {}
}