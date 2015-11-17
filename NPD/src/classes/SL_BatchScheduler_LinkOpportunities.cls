/**
* \arg ClassName      : SL_BatchScheduler_LinkOpportunities
* \arg JIRATicket     : NPD-219
* \arg CreatedOn      : 12/Oct/15
* \arg LastModifiedOn : 12/Oct/15
* \arg CreatededBy    : Praful Gadge
* \arg ModifiedBy     : Praful Gadge
* \arg Description    : This batch process is used to schedule the SL_BatchScheduler_LinkOpportunities batch process to Link Opportunities to ISO Goals.
*/
global class SL_BatchScheduler_LinkOpportunities implements Schedulable
{
	//execute method of schedulable interface
	global void execute(SchedulableContext sc)
	{
		//calling batch process
		Database.executeBatch(new SL_Batch_LinkOpportunities());
	}
}