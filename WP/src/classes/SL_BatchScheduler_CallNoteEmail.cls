/**
* \arg ClassName      : SL_BatchScheduler_CallNoteEmail
* \arg JIRATicket     : WP-136
* \arg CreatedOn      : 22/MAY/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as scheduler class for SL_Batch_CallNotesEmail class.
*/
global class SL_BatchScheduler_CallNoteEmail implements Schedulable
{
	//execute method of schedulable interface
	global void execute(SchedulableContext sc)
	{
		//calling batch process for task
		Database.executeBatch(new SL_Batch_CallNotesEmail(),1);
	}
}