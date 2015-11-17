/*
@ClassName      :   SL_Schedule_BatchToCreateEvent_Caller
@Date           :   23/SEP/2014
@Description    :   This class should be used to calling the scheduler class 'SL_Schedule_BatchToCreateEvent' to create Events in MyBuilding.  
*/

public with sharing class SL_Schedule_BatchToCreateEvent_Caller 
{
     /*
    @MethodName : Constructor
    @param      : None
    @Description: This constructor is giving a call to the scheduler to schedule at every 30 minutes
    */
    public SL_Schedule_BatchToCreateEvent_Caller()
    {
        SL_Schedule_BatchToCreateEvent objScheduler = new SL_Schedule_BatchToCreateEvent ();
        
        //Cron expression for every 30 minutes
        String strCron = '0 30 0-23 * * ?';
        System.schedule('Create Events in MyBuilding', strCron , objScheduler );
    }
}