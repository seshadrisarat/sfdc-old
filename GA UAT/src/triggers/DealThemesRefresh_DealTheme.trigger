trigger DealThemesRefresh_DealTheme on Deal_Theme__c (after insert, after delete, after undelete) {
    Integer FIELD_LIMIT = 255;

    List<Deal_Theme__c> dealThemes = new List<Deal_Theme__c>();
    if (!Trigger.isDelete) {
        dealThemes.addAll(Trigger.new);
    }
    if (!Trigger.isInsert) {
        dealThemes.addAll(Trigger.old);
    }
    
    Map<Id, Deal__c> deals = new Map<Id, Deal__c>();
    Map<Id, Theme__c> themes = new Map<Id, Theme__c>();
    for (Deal_Theme__c dt : dealThemes) {
        // Add deal to list for processing
        deals.put(dt.Deal__c, new Deal__c(
            Id = dt.Deal__c,
            Theme_s__c = ''
        ));
        
        themes.put(dt.Theme__c, new Theme__c(
            Id = dt.Theme__c,
            Companies__c = 0,
            Deals_Closed__c = 0
        ));
    }

    for (Deal_Theme__c dt : [SELECT Deal__r.Status__c, Theme__r.Name, Theme__r.Deals_Closed__c FROM Deal_Theme__c WHERE Deal__c IN :deals.keySet() AND IsDeleted=FALSE]) {
        Deal__c d = deals.get(dt.Deal__c);
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

    Set<String> themeCompanySet = new Set<String>();
    for (Deal_Theme__c dt : [SELECT Theme__c, Deal__r.Status__c, Deal__r.Related_Company__c FROM Deal_Theme__c WHERE Theme__c IN :themes.keySet() AND IsDeleted=FALSE]) {
        Theme__c t = themes.get(dt.Theme__c);

        if (dt.Deal__r.Status__c == 'Closed') {
            t.Deals_Closed__c++;
        }
    
        if (dt.Deal__r.Related_Company__c != null && !themeCompanySet.contains('' + dt.Theme__c + dt.Deal__r.Related_Company__c)) {
            themeCompanySet.add('' + dt.Theme__c + dt.Deal__r.Related_Company__c);
            t.Companies__c++;
        }
    }
    
    if (!deals.isEmpty()) {
        update deals.values();
    }

    if (!themes.isEmpty()) {
        Database.update(themes.values(), false);
    }
}