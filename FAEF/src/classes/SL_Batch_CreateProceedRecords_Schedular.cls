/**
	* \arg \b ClassName      : SL_Batch_CreateProceedRecords_Schedular
	* \arg \b JIRATicket     : FAEF-38
	* \arg \b CreatedOn      : 12/Sep/2014
	* \arg \b ModifiedBy     : Pankaj Ganwani
	* \arg \b Description    : This schedulable class is used to schedule SL_Batch_CreateProceedRecords batch process 	
*/
global with sharing class SL_Batch_CreateProceedRecords_Schedular implements Schedulable
{	
	/*
        @MethodName: execute 
        @param : SchedulableContext sc
        @Description: It is execute method of Database.Batchable interface.
    */
   	global void execute(SchedulableContext sc) 
   	{
	    //Parameters of ExecuteBatch(context,BatchSize)
	    database.executebatch(new SL_Batch_CreateProceedRecords(),200);
   	}
}