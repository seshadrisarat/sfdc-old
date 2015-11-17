global class InitializeThemeSchedulable implements Schedulable { 
    global void execute(SchedulableContext ctx) {
        Utilities.initializeTheme(null);
    }
}