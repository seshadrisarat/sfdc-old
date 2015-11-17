/**
* \arg ClassName      : SL_BatchSchedule_SendEmailReminder
* \arg JIRATicket     : PWP-18
* \arg CreatedOn      : 20/APR/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as scheduler for SL_Batch_SendEmailReminder batch process which intends to send email reminders to activity owners if the call report has not been created corresponding to that Activity.
*/
global class SL_BatchSchedule_SendEmailReminder implements Schedulable
{
	//execute method of schedulable interface
	global void execute(SchedulableContext sc)
	{
		//calling batch process for task
		Database.executeBatch(new SL_Batch_SendEmailReminder(), 100);
	}
}