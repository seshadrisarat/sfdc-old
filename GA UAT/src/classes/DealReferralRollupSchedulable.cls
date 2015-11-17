global class DealReferralRollupSchedulable implements Schedulable { 
    global void execute(SchedulableContext ctx) {
        Utilities.dealReferralRollup(null);
    }
}