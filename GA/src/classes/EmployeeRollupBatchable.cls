global class EmployeeRollupBatchable implements Database.Batchable<SObject>, Database.Stateful {
    private String query;
    private Map<Id, User> users;

    global EmployeeRollupBatchable(String query) {
        this.query = 'SELECT Id FROM User';
        if (query != null) {
            this.query = query;
        }
        users = new Map<Id, User>();
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> batch) {
        for (User u : (List<User>) batch) {
            users.put(u.Id, new User(
                Id = u.Id,
                Active_Deals__c = 0
            ));
        }

        for (Team_Member__c tm : [SELECT User__c FROM Team_Member__c WHERE Deal__r.Status__c NOT IN ('Closed','Passed','On Hold','Funded by Others')]) {
            if (users.get(tm.User__c) == null) {
            	users.put(tm.User__c, new User(
            		Id = tm.User__c,
            		Active_Deals__c = 0
            	));
            }
            users.get(tm.User__c).Active_Deals__c++;
        }
    }

    global void finish(Database.BatchableContext bc) {
        Database.update(users.values(), false);
    }
}