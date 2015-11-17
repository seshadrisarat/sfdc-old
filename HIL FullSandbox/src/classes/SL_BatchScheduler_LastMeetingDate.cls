global with sharing class SL_BatchScheduler_LastMeetingDate implements Schedulable
{
    //This Class calls Batch class
    global void execute(SchedulableContext sc)
    {
        try
        {
            // An instance of a Batch Class created  
            Sl_BatchUpdateLastMeetingDate objBatch = new Sl_BatchUpdateLastMeetingDate();
            
            // Database.executeBatch method called to begin a batch job.
            Database.executeBatch(objBatch, 100);
        }
        catch(Exception e)
        {
            //Show exception in debug logs if any
            System.debug('### Exception: ' + e);
        }
        
    }
}