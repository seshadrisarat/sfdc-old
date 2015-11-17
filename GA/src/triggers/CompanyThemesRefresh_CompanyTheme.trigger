trigger CompanyThemesRefresh_CompanyTheme on Company_Theme__c (after insert, after delete, after undelete) {
    Integer FIELD_LIMIT = 255;

    List<Company_Theme__c> companyThemes = new List<Company_Theme__c>();
    if (!Trigger.isDelete) {
        companyThemes.addAll(Trigger.new);
    }
    if (!Trigger.isInsert) {
        companyThemes.addAll(Trigger.old);
    }
    
    Map<Id, Account> accounts = new Map<Id, Account>();
    Map<Id, Theme__c> themes = new Map<Id, Theme__c>();
    for (Company_Theme__c ct : companyThemes) {
        // Add account to list for processing
        accounts.put(ct.Company__c, new Account(
            Id = ct.Company__c,
            Themes__c = ''
        ));
        
        themes.put(ct.Theme__c, new Theme__c(Id = ct.Theme__c, Companies__c = 0));
    }

    for (Company_Theme__c ct : [SELECT Company__c, Theme__r.Name FROM Company_Theme__c WHERE Company__c IN :accounts.keySet() AND IsDeleted=FALSE]) {
        Account a = accounts.get(ct.Company__c);
        String initials = a.Themes__c;
        if (initials == null) {
            initials = '';
        }
        if (initials.length() > 0) {
            initials += ',';
        }
        initials += ct.Theme__r.Name;
        if (initials.length() > FIELD_LIMIT) {
            initials = initials.substring(0,FIELD_LIMIT-3) + '...';
        }           
        if (a.Themes__c != initials) {
            a.Themes__c = initials;
            accounts.put(a.Id, a);
        }
    }
    
    if (!accounts.isEmpty()) {
        update accounts.values();
    }
    
    // this will reset all company count on themes to 0
    if (!themes.isEmpty()) {
        update themes.values();
    }
    
    //update company count on themes
    Utilities.companyThemeRollup(null);
}