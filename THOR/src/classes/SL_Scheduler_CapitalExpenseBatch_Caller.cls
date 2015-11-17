public class SL_Scheduler_CapitalExpenseBatch_Caller {

    public static String CRON_EXP = '0 0 1/12 * * ?';///CRON expression to run batch every 12 hrs at 1am/1pm
    
    public SL_Scheduler_CapitalExpenseBatch_Caller()
    {
        list<CronTrigger> lstCronTrigger = [SELECT Id FROM CronTrigger where CronJobDetail.Name LIKE 'Capital Expenditure IAI Batch'];
	    if(lstCronTrigger.isEmpty())
	    {
    		 System.schedule('Capital Expenditure IAI Batch', CRON_EXP , new SL_Scheduler_CapitalExpenditureIAIbatch());
	    }
    }

}