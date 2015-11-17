global class scheduledBatchClearLastNext implements Schedulable{
  global void execute(SchedulableContext SC){
    BatchClearLastNext myBatch = new BatchClearLastNext();
    database.executeBatch(myBatch);   
  }
}