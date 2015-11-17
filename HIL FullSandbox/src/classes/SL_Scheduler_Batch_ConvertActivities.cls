global class SL_Scheduler_Batch_ConvertActivities implements Schedulable
{
	global void execute(SchedulableContext sc)
	{
		SL_Batch_ConvertActivities cjBatch = new SL_Batch_ConvertActivities();
		Database.executeBatch(cjBatch,50);
	}
}