/**
* @ClassName    : SL_SchedulerBatchOnEmployee
* @JIRATicket   : Moelis-117
* @CreatedOn    : 20/11/2013
* @ModifiedBy   : SL
* @Description  : Schedular for SL_BatchOnEmployee_SyncUser batch
*/

/**
@Developer Name							: Sandeep
Percentage of best practices followed	: 100%
No of SOQL queries used					: 0
No of collections used					: 0
Exception Handling implemented			: Yes
Coding standards followed				: Yes
Naming conventions followed				: Yes
Third party integrations				: No
Maximum of No of records tested with	: 
Customer Approval						: 
Last Modified Date						: 20/11/2013
Approved by								: 

*/
global without sharing class SL_SchedulerBatchOnEmployee implements Schedulable
{
	//This Class calls Batch class
	global void execute(SchedulableContext sc)
	{
		// An instance of a SL_BatchEmployee Class created  
		SL_BatchOnEmployee_SyncUser objBatch = new SL_BatchOnEmployee_SyncUser();
		// Database.executeBatch method called to begin a batch job.
		Database.executeBatch(objBatch, 100);
			
	}
}