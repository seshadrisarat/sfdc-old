global class DealsWorkedRollupBatchable implements Database.Batchable<SObject>, Database.Stateful {
    private String query;
    private Map<Id, Account> companyMap;
    private Set<String> companyDealSet;
    private Set<String> companyDealLTMSet;

    global DealsWorkedRollupBatchable(String query) {
        this.query = 'SELECT Deal__r.CreatedDate, Actual_Fee__c, Contact_Name__r.AccountId FROM Deal_Contact__c WHERE Contact_Name__r.AccountId<>NULL AND Contact_Name__r.Account.RecordType.DeveloperName=\'Intermediary\' AND IsDeleted=FALSE';
        if (query != null) {
            this.query = query;
        }
        companyMap = new Map<Id, Account>();
        companyDealSet = new Set<String>();
        companyDealLTMSet = new Set<String>();
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> batch) {
        Map<Id, Account> companies = new Map<Id, Account>();
        for (Deal_Contact__c dc : (List<Deal_Contact__c>) batch) {
            //  Total Deals Worked on Account
            Account a = getAccount(dc.Contact_Name__r.AccountId);
            // All
            if (!companyDealSet.contains('' + dc.Contact_Name__r.AccountId + dc.Deal__c)) {
                a.Total_Deals_Worked__c++;
                companyDealSet.add('' + dc.Contact_Name__r.AccountId + dc.Deal__c);
            }
            try {
                a.Total_Actual_Fee__c += dc.Actual_Fee__c;
            } catch (Exception e) {
            }
            // YTD
            if (dc.Deal__r.CreatedDate > Date.today().addMonths(-12) && dc.Deal__r.CreatedDate <= Date.today()) {
                if (!companyDealLTMSet.contains('' + dc.Contact_Name__r.AccountId + dc.Deal__c)) {
                    a.Total_Deals_Worked_LTM__c++;
                    companyDealLTMSet.add('' + dc.Contact_Name__r.AccountId + dc.Deal__c);
                }
                try {
                    a.Total_Actual_Fee_LTM__c += dc.Actual_Fee__c;
                } catch (Exception e) {
                }
            }
            companies.put(a.Id, a);
        }

        if (!companies.isEmpty()) {
            update companies.values();
        }
    }

    global void finish(Database.BatchableContext bc) {}

    private Account getAccount(Id aId) {
        Account a = companyMap.get(aId);
        if (a == null) {
            a = new Account(
                Id = aId,
                Total_Deals_Worked__c = 0,
                Total_Actual_Fee__c = 0,
                Total_Deals_Worked_LTM__c = 0,
                Total_Actual_Fee_LTM__c = 0
            );
            companyMap.put(aId, a);
        }
        return a;
    }
}