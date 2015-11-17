global class ThemeRollupSchedulable implements Schedulable { 
    global void execute(SchedulableContext ctx) {
        Utilities.themeRollup(null);
        Utilities.companyThemeRollup(null);
    }
}