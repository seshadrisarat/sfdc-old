/**
*  Class Name     : SL_Schedule_NextLeaseBatch
*  JIRATicket     : THOR-49
*  CreatedOn      : 27/NOV/2014
*  ModifiedBy     : SANATH
*  Description    : This class calls the Next lease batch.  
*/
public with sharing class SL_Schedule_NextLeaseBatch implements Schedulable 
{
	/*
        @MethodName : execute 
        @param      : SchedulableContext SC
        @Description: This method schedules the respective batch class based on given cron expression
    */
    public void execute(SchedulableContext SC) 
    {
    	///Call the batch
        SL_NextLeaseBatchProcess objNextLeaseBatch = new SL_NextLeaseBatchProcess('SELECT Id FROM Apartment__c');
        Database.executeBatch(objNextLeaseBatch,50);
    }
}