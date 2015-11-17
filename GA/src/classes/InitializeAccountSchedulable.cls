global class InitializeAccountSchedulable implements Schedulable { 
    global void execute(SchedulableContext ctx) {
        Utilities.InitializeAccount(null);
    }
}