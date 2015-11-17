/**
*  Class Name     : SL_MyBuildingServiceRequestBatch_Caller
*  JIRATicket     : THOR-13
*  CreatedOn      : 4/NOV/2014
*  ModifiedBy     : SANATH
*  Description    : Scheduler caller for SL_MyBuildingServiceRequestBatch
*/
public with sharing class SL_MyBuildingServiceRequestBatch_Caller 
{
	public SL_MyBuildingServiceRequestBatch_Caller()
    {
        list<CronTrigger> lstCronTrigger = [SELECT Id FROM CronTrigger where CronJobDetail.Name LIKE 'Create Events in MyBuilding 1'];
	    if(lstCronTrigger.isEmpty())
	    {
            SL_ScheduleMyBuildingServiceRequestBatch objScheduler = new SL_ScheduleMyBuildingServiceRequestBatch ();
            
            String strCron1 = '0 0 0/12 * * ?';
            
            System.schedule('Create Events in MyBuilding 1', strCron1 , objScheduler);
	    }
    }
}