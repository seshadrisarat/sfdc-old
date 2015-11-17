/**
* \arg ClassName      : SL_BatchScheduler_ActivityCount
* \arg JIRATicket     : PWP-7
* \arg CreatedOn      : 24/DEC/2014
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This batch process is used to schedule the SL_Batch_ActivityCount batch process for counting the number of activities.
*/
global class SL_BatchScheduler_ActivityCount implements Schedulable
{
	//execute method of schedulable interface
	global void execute(SchedulableContext sc)
	{
		//calling batch process for task
		Database.executeBatch(new SL_Batch_ActivityCount('Select PWP_Employee__c, External_Contact__c, Event_Count__c, Count_Task__c, Call_Report_Count__c From Relationship__c WHERE PWP_Employee__c!=null AND External_Contact__c!=null'));
	}
}