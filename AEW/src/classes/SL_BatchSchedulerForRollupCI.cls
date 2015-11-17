/**
* \arg ClassName      : SL_BatchSchedulerForRollupCI
* \arg JIRATicket     : AEW-4
* \arg CreatedOn      : 6th/JAN/2015
* \arg LastModifiedOn : 6th/JAN/2015
* \arg CreatededBy    : Sandeep
* \arg ModifiedBy     : Sandeep
* \arg Description    : Apex Scheduler controller responsible for updating Accounts Records
*/
global class SL_BatchSchedulerForRollupCI implements Schedulable 
{
	
	/**
    @MethodName : execute
    @Param 		: Instance SchedulableContext
    @Description: global Execute Method to perform scheduling task for updating Records
    **/
	global void execute(SchedulableContext ctx) 
	{
		ID BatchId = Database.executeBatch(new SL_Batch_RollupClientInvestments(), 400);
	}		
	
	/**
    @MethodName : scheduleBatch
    @Param 		: NA
    @Description: static method to run batch daily at 12 AM
    **/
	public static void scheduleBatch() 
	{
		String con_exp= '0 0 12 * * ?';
		System.schedule('SL_BatchSchedulerForRollupCITest', con_exp, new SL_BatchSchedulerForRollupCI());
	}
	
}