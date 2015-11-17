global class InitializeDealSchedulable implements Schedulable { 
    global void execute(SchedulableContext ctx) {
        Utilities.initializeDeal(null);
    }
}