trigger DealThemesRefresh_Theme on Theme__c (after update, after delete, after undelete) {
    Boolean refresh = false;
    if (Trigger.isUpdate) {
        for (Theme__c t : Trigger.new) {
            refresh |= (t.Name != Trigger.oldMap.get(t.Id).Name);
        }
    } else {
        refresh = true;
    }
    
    if (refresh) {
        Utilities.themeRollup(null);
        Utilities.companyThemeRollup(null);
    }
}