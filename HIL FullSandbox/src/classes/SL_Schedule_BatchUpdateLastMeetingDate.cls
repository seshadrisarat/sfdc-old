public without sharing class SL_Schedule_BatchUpdateLastMeetingDate 
{
    //This class calls Schedular
    public SL_Schedule_BatchUpdateLastMeetingDate()
    {
        SL_BatchScheduler_LastMeetingDate batchSchedule = new SL_BatchScheduler_LastMeetingDate();
        String scheduleBatch = '0 10 0 ? * *';
        System.schedule('Update Last meeting Date', scheduleBatch, batchSchedule);
    }
}