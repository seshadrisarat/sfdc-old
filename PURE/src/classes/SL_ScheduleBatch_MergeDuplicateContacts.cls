/**
* \arg ClassName      : SL_ScheduleBatch_MergeDuplicateContacts
* \arg JIRATicket     : PURE-64
* \arg CreatedOn      : 3rd/March/2015
* \arg LastModifiedOn : 3rd/MArch/2015
* \arg CreatededBy    : Sandeep
* \arg ModifiedBy     : Sandeep
* \arg Description    : This class is used to schedule batch.
*/
global without sharing class SL_ScheduleBatch_MergeDuplicateContacts implements Schedulable  
{
	/**
    @MethodName : execute
    @Param 		: Instance SchedulableContext
    @Description: global Execute Method to perform scheduling batch for merging contact records
    **/
	global void execute(SchedulableContext ctx) 
	{
		Id BatchId = Database.executeBatch(new SL_Batch_MergeDuplicateContacts(), 400);
	}		
	
	/**
    @MethodName : scheduleBatch
    @Param 		: NA
    @Description: static method to run batch daily at 12 AM
    **/
	public static void scheduleBatch() 
	{
		String con_exp= '0 0 0 * * ?';
		
		
		if(!Test.isRunningTest())
			System.schedule('SL_Batch_MergeDuplicateContactsTest', con_exp, new SL_ScheduleBatch_MergeDuplicateContacts());
		else	
			System.schedule('SL_Batch_MergeDuplicateContactsTest11', con_exp, new SL_ScheduleBatch_MergeDuplicateContacts());
	}
}