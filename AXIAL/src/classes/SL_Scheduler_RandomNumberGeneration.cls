/**
	* ClassName      : SL_Scheduler_RandomNumberGeneration
	* JIRATicket     : AXIAL-3
	* CreatedOn      : 29/Jun/2015
	* ModifiedBy     : Prakash
	* Description    : This schedulable class is used to call the SL_Batch_RandomNumberGeneratorOnAcc 	
*/
global with sharing class SL_Scheduler_RandomNumberGeneration implements Schedulable
{
	/*
        @MethodName: execute 
        @param : SchedulableContext sc
        @Description: It is execute method of Database.Batchable interface.
    */
   	global void execute(SchedulableContext sc) 
   	{
	    //Parameters of ExecuteBatch(context,BatchSize)
	    database.executebatch(new SL_Batch_RandomNumberGeneratorOnAcc(),200);
   	}
}