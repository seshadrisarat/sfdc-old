trigger DealThemesRefresh_Task on Task (after insert, after update) {
    Set<Id> accountIds = new Set<Id>();
    for (Task t : Trigger.new) {
        accountIds.add(t.AccountId);
    }
    accountIds.remove(null);

    // Get list of affected themes
    Set<Id> themeIds = new Set<Id>();
    for (Company_Theme__c ct : [SELECT Theme__c FROM Company_Theme__c WHERE Company__c IN :accountIds AND IsDeleted=FALSE]) {
        themeIds.add(ct.Theme__c);
    }
    // Update list of accounts associated to those themes
    for (Company_Theme__c ct : [SELECT Company__c FROM Company_Theme__c WHERE Theme__c IN :themeIds AND IsDeleted=FALSE]) {
        accountIds.add(ct.Company__c);
    }

    Set<String> taskThemeSet = new Set<String>();
    for (Task t : [SELECT AccountId, Type FROM Task WHERE AccountId IN :accountIds AND Type IN ('Prospect Call','Prospect Meeting Notes') AND IsDeleted=FALSE AND Account.Themes__c<>NULL AND IsClosed=TRUE]) {
        taskThemeSet.add('' + t.Type + t.AccountId);
    }

    Map<Id, Theme__c> themes = new Map<Id, Theme__c>();
    for (Company_Theme__c ct : [SELECT Company__c, Theme__c FROM Company_Theme__c WHERE Company__c IN :accountIds AND IsDeleted=FALSE]) {
        Theme__c t = new Theme__c(
            Id = ct.Theme__c,
            Companies_Called__c = 0,
            Companies_Met__c = 0
        );
        if (taskThemeSet.contains('Prospect Call' + ct.Company__c)) {
            t.Companies_Called__c = 1;
        }
        if (taskThemeSet.contains('Prospect Meeting Notes' + ct.Company__c)) {
            t.Companies_Met__c = 1;
        }
        
        if (themes.containsKey(ct.Theme__c)) {
            themes.get(ct.Theme__c).Companies_Called__c += t.Companies_Called__c;
            themes.get(ct.Theme__c).Companies_Met__c += t.Companies_Met__c;
        } else {
            themes.put(t.Id, t);
        }
    }

    if (!themes.isEmpty()) {
        update themes.values();
    }
}