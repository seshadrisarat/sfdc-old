/*
@ClassName      :   SL_Schedule_BatchToCreateEvent_Caller
@Date           :   28/SEP/2014
@Description    :   This class should be used to calling the scheduler class 'SL_Schedule_BatchToCreateEvent' to create Events in MyBuilding.  
*/

public with sharing class SL_Schedule_BatchToCreateEvent_Caller 
{
     /*
    @MethodName : Constructor
    @param      : None
    @Description: This constructor is giving a call to the scheduler to schedule at every 1 hour
    */
    public SL_Schedule_BatchToCreateEvent_Caller()
    {
        list<CronTrigger> lstCronTrigger = [SELECT Id FROM CronTrigger where CronJobDetail.Name LIKE 'Create Events in MyBuilding'];
	    if(lstCronTrigger.isEmpty())
	    {
            SL_Schedule_BatchToCreateEvent objScheduler = new SL_Schedule_BatchToCreateEvent ();
            
            //Cron expression for each hour.
            String strCron = '0 0 * * * ?';
            System.schedule('Create Events in MyBuilding', strCron , objScheduler );
	    }
    }
}