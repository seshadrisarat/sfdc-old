/**
*  Class Name     : SL_ScheduleActivityMilestoneBatch_Caller
*  JIRATicket     : THOR-56
*  CreatedOn      : 18/MAR/2015
*  ModifiedBy     : SANATH
*  Description    : Scheduler Caller for SL_ActivityMilestoneBatch
*/
public with sharing class SL_ScheduleActivityMilestoneBatch_Caller 
{
	public SL_ScheduleActivityMilestoneBatch_Caller()
	{
	    list<CronTrigger> lstCronTrigger = [SELECT Id FROM CronTrigger where CronJobDetail.Name LIKE 'Activity Milestone Batch%'];
	    if(lstCronTrigger.isEmpty())
	    {
    		SL_ScheduleActivityMilestoneBatch objBatch = new SL_ScheduleActivityMilestoneBatch();
    		
    		String scheduleBatch1 = '0 0 12 * * ?';///CRON expression to run batch daily at 12:00 AM
    		
    		System.schedule('Activity Milestone Batch 1', scheduleBatch1, objBatch);
    	}
	}
}