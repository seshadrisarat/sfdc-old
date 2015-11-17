/**
*  Class Name     : SL_ScheduleMyBuildingServiceRequestBatch
*  JIRATicket     : THOR-13
*  CreatedOn      : 4/NOV/2014
*  ModifiedBy     : SANATH
*  Description    : Scheduler for SL_MyBuildingServiceRequestBatch
*/
global class  SL_ScheduleMyBuildingServiceRequestBatch implements Schedulable 
{
	global void execute(SchedulableContext SC)
	{
		SL_MyBuildingServiceRequestBatch objMyBuildingServiceRequestBatch = new SL_MyBuildingServiceRequestBatch();
		Database.executeBatch(objMyBuildingServiceRequestBatch, 1);
	}
}