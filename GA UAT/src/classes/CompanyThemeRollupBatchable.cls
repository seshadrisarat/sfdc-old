global class CompanyThemeRollupBatchable implements Database.Batchable<SObject>, Database.Stateful {

    private String query;
    private Map<Id,Theme__c> themeCompanySize;
    private Map<Id,Set<Id>> themeCompanySet;

    global CompanyThemeRollupBatchable(String query) {

        this.query = query = 'SELECT Company__c, Company__r.Pursuable__c, Company_Pursuable__c, Theme__c, IsDeleted FROM Company_Theme__c';
        if (query != null) {
            this.query = query;
        }
        themeCompanySize = new Map<Id,Theme__c>();
        themeCompanySet = new Map<Id,Set<Id>>();
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> batch) {
        for (Company_Theme__c ct : (List<Company_Theme__c>) batch) {
            
            ID t = ct.Theme__c;
            ID a = ct.Company__c;
            
            if (themeCompanySet.get(t) == null) {
                themeCompanySet.put(t, new Set<Id>());
            }
            if (ct.Company__r.Pursuable__c && !ct.isDeleted) {
                //add the company to the theme map
                themeCompanySet.get(t).add(a);
            }
            
            System.debug('ct: ' + ct);
            System.debug('themeCompanySet : ' + t + ' -- ' + themeCompanySet.get(t));
            
            // # of Pursuable Companies
            themeCompanySize.put(t,new Theme__c(Id=t,Companies__c=themeCompanySet.get(t).size()));
        }

        if (themeCompanySize.keyset().size() > 0) {
            update themeCompanySize.values();
        }
    }

    global void finish(Database.BatchableContext bc) {}
}