global class ThemeRollupBatchable implements Database.Batchable<SObject>, Database.Stateful {
    private final Integer FIELD_LIMIT = 255;

    private String query;
    private Map<Id, Theme__c> themeMap;
    private Map<Id, Deal__c> dealMap;
    private Set<String> themeCompanySet;

    global ThemeRollupBatchable(String query) {
        this.query = query = 'SELECT Theme__r.Name, Deal__r.Status__c, Deal__r.Related_Company__c, Deal__r.Taken_to_IC__c FROM Deal_Theme__c WHERE IsDeleted=FALSE';
        if (query != null) {
            this.query = query;
        }
        themeMap = new Map<Id, Theme__c>();
        dealMap = new Map<Id, Deal__c>();
        themeCompanySet = new Set<String>();
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> batch) {
        Map<Id, Theme__c> themes = new Map<Id, Theme__c>();
        Map<Id, Deal__c> deals = new Map<Id, Deal__c>();
        for (Deal_Theme__c dt : (List<Deal_Theme__c>) batch) {
            // Deals Closed and # of Companies on Theme
            Theme__c t = getTheme(dt.Theme__c);
            if (dt.Deal__r.Status__c == 'Closed') {
                t.Deals_Closed__c++;
            }
            if (dt.Deal__r.Related_Company__c != null) {
                /*
                if (!themeCompanySet.contains('' + t.Id + dt.Deal__r.Related_Company__c + '_companies')) {
                    t.Companies__c++;
                    themeCompanySet.add('' + t.Id + dt.Deal__r.Related_Company__c + '_companies');
                }
                */
                if (dt.Deal__r.Taken_to_IC__c) {
                    if (!themeCompanySet.contains('' + t.Id + dt.Deal__r.Related_Company__c + '_ic')) {
                        t.Companies_Taken_to_IC__c++;
                        themeCompanySet.add('' + t.Id + dt.Deal__r.Related_Company__c + '_ic');
                    }                   
                }
            }
            themes.put(t.Id, t);

            // Theme(s) on Deal
            Deal__c d = getDeal(dt.Deal__c);
            String initials = d.Theme_s__c;
            if (initials == null) {
                initials = '';
            }
            if (initials.length() > 0) {
                initials += ',';
            }
            initials += dt.Theme__r.Name;
            if (initials.length() > FIELD_LIMIT) {
                initials = initials.substring(0,FIELD_LIMIT-3) + '...';
            }
            
            if (d.Theme_s__c != initials) {
                d.Theme_s__c = initials;
                deals.put(d.Id, d);
            }
        }

        if (!themes.isEmpty()) {
            update themes.values();
        }
        if (!deals.isEmpty()) {
            update deals.values();
        }
    }

    global void finish(Database.BatchableContext bc) {}

    private Theme__c getTheme(Id tId) {
        Theme__c t = themeMap.get(tId);
        if (t == null) {
            t = new Theme__c(
                Id = tId,
                Deals_Closed__c = 0,
                //Companies__c = 0,
                Companies_Taken_to_IC__c = 0
            );
            themeMap.put(tId, t);
        }
        return t;
    }

    private Deal__c getDeal(Id dId) {
        Deal__c d = dealMap.get(dId);
        if (d == null) {
            d = new Deal__c(
                Id = dId,
                Theme_s__c = ''
            );
            dealMap.put(dId, d);
        }
        return d;
    }
}