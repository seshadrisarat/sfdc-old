global class scheduledBatchableLastNextTaskEvent implements Schedulable{
	global void execute(SchedulableContext SC){
		BatchLastNextEvent myBatch3 = new BatchLastNextEvent();
		database.executeBatch(myBatch3);	
	}
}