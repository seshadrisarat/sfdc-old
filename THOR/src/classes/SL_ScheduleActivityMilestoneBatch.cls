/**
*  Class Name     : SL_ScheduleActivityMilestoneBatch
*  JIRATicket     : THOR-56
*  CreatedOn      : 18/MAR/2015
*  ModifiedBy     : SANATH
*  Description    : Scheduler for SL_ActivityMilestoneBatch
*/
global class SL_ScheduleActivityMilestoneBatch implements Schedulable 
{
	global void execute(SchedulableContext SC)
	{
		String strQuery1 = 'SELECT Id FROM Opportunity';
		SL_ActivityMilestoneBatch batch1 = new SL_ActivityMilestoneBatch(strQuery1); 
		database.executeBatch(batch1,10);
		
		String strQuery2 = 'SELECT Id FROM Lead';
		SL_ActivityMilestoneBatch batch2 = new SL_ActivityMilestoneBatch(strQuery2); 
		database.executeBatch(batch2,10);
	}
}