global class InitializeAccountBatchable implements Database.Batchable<SObject>, Database.Stateful {
    private String query;

    global InitializeAccountBatchable(String query) {
        this.query = 'SELECT Id, (SELECT Id FROM Deals__r WHERE IsDeleted=FALSE LIMIT 1), (SELECT Id FROM RelatedDeals__r WHERE IsDeleted=FALSE LIMIT 1) FROM Account WHERE Account.RecordType.DeveloperName=\'Intermediary\' AND IsDeleted=FALSE';
        if (query != null) {
            this.query = query;
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> batch) {
        Map<Id, Account> accounts = new Map<Id, Account>();
        for (Account a : (List<Account>) batch) {
            if (a.Deals__r.isEmpty()) {
                accounts.put(a.Id, new Account(
                    Id = a.Id,
                    Total_Intros_Referred__c = 0,
                    Total_Exclusives_Referred__c = 0,
                    Total_Exclusives_Referred_Value_MM__c = 0,
                    Total_Intros_Referred_Value_MM__c = 0,
                    Total_Intros_Referred_LTM__c = 0,
                    Total_Exclusives_Referred_LTM__c = 0,
                    Total_Exclusives_Referred_Value_LTM__c = 0,
                    Total_Intros_Referred_Value_LTM__c = 0
                ));
            }
            if (a.RelatedDeals__r.isEmpty()) {
                if (accounts.containsKey(a.Id)) {
                    accounts.get(a.Id).Total_Deals_Worked__c = 0;                   
                } else {
                    accounts.put(a.Id, new Account(
                        Id = a.Id,
                        Total_Deals_Worked__c = 0,
                        Total_Actual_Fee__c = 0,
                        Total_Deals_Worked_LTM__c = 0,
                        Total_Actual_Fee_LTM__c = 0
                    ));
                }
            }
        }
        
        if (!accounts.isEmpty()) {
            update accounts.values();           
        }
    }

    global void finish(Database.BatchableContext bc) {}
}