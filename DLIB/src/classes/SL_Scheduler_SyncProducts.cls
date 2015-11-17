/**
* @ClassName 	:	SL_Scheduler_SyncProducts
* @JIRATicket   :	Silverline-145
* @CreatedOn    :	7/Jan/2013
* @ModifiedBy   :	Rehan
* @Description  :
*/

/**
Percentage of best practices followed	:	100%
No of SOQL queries used					:	0
No of collections used					:	0
Exception Handling implemented			:	No
Coding standards followed				:	Yes
Naming conventions followed				:	Yes
Third party integrations				:	No
Maximum of No of records tested with	:	0
Customer Approval						:
Last Modified Date						:	7/Jan/2013
Approved by								:

*/

global class SL_Scheduler_SyncProducts implements Schedulable
{
	global void execute(SchedulableContext SC)
	{
		String strQuery = 'SELECT Id, Product__c ' +
					  	  'From Product__c';

		SL_NightlyBatch_SyncProducts objBatchClass = new SL_NightlyBatch_SyncProducts(strQuery);
		database.executebatch(objBatchClass, 200);
	}
}