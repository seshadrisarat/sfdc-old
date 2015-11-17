global class DealsWorkedRollupSchedulable implements Schedulable { 
    global void execute(SchedulableContext ctx) {
        Utilities.dealsWorkedRollup(null);
    }
}