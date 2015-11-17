/**
* \arg ClassName      : SL_Schedule_TimeCardAvailability
* \arg JIRATicket     : PWP-215
* \arg CreatedOn      : 08/SEP/2015
* \arg CreatededBy    : Lodhi
* \arg Description    : Schedular class to invoke the SL_Batch_TimeCardAvailabilityReminder batch
*/
global class SL_Schedule_TimeCardAvailability implements Schedulable 
{
    private String strDay;
    private String strTime;
    private String strOtherEmails;
    global SL_Schedule_TimeCardAvailability(String strPreferredDay, String strPreferredTime, String strAdditionalEmails) 
    {
        this.strDay = strPreferredDay;
        this.strTime = strPreferredTime;
        this.strOtherEmails = strAdditionalEmails;
    }
    
	global void execute (SchedulableContext SC)
    {
        SL_Batch_TimeCardAvailabilityReminder objBatch = new SL_Batch_TimeCardAvailabilityReminder(strDay, strTime, strOtherEmails);
        Database.executeBatch(objBatch, 200);
    }
}