global class Scheduled_Rating_TGC implements Schedulable{	
	global void execute(SchedulableContext SC)
	{
        BatchTGCUpdate myBatch2 = new BatchTGCUpdate();
		database.executeBatch(myBatch2);
	}
}