global class SL_Scheduler_CapitalExpenditureIAIbatch implements Schedulable 
{
    global void execute(SchedulableContext SC)
    {
        Database.executeBatch(new SL_CapitalExpenditureIAIbatch(),200);
    }
}