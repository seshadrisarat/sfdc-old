/**
*  Class Name     : SL_Schedule_NextLeaseBatch_Caller
*  JIRATicket     : THOR-49
*  CreatedOn      : 27/NOV/2014
*  ModifiedBy     : SANATH
*  Description    : This class calls the Next lease batch scheduler.  
*/
public with sharing class SL_Schedule_NextLeaseBatch_Caller 
{
	public SL_Schedule_NextLeaseBatch_Caller()
	{
	    list<CronTrigger> lstCronTrigger = [SELECT Id FROM CronTrigger where CronJobDetail.Name LIKE 'Next Lease Batch Process%'];
	    if(lstCronTrigger.isEmpty())
	    {
    		SL_Schedule_NextLeaseBatch objScheduleNextLeaseBatch = new SL_Schedule_NextLeaseBatch();
    		
    		String scheduleBatch1 = '0 0 12 * * ?';///CRON expression to run batch daily at 12:00 AM
    		
    		System.schedule('Next Lease Batch Process 1', scheduleBatch1, objScheduleNextLeaseBatch);
	    }
	}
}