/**
* \arg ClassName      : SL_Schedule_TimeCardFilling
* \arg JIRATicket     : PWP-215
* \arg CreatedOn      : 11/SEP/2015
* \arg CreatededBy    : Lodhi
* \arg Description    : Schedular class to invoke the SL_Batch_TimeCardAvailabilityReminder batch
*/
global class SL_Schedule_TimeCardFilling implements Schedulable 
{ 
    private String strDay;
    private String strTime;
    private String strOtherEmails;
    global SL_Schedule_TimeCardFilling(String strPreferredDay, String strPreferredTime, String strAdditionalEmails) 
    {
        this.strDay = strPreferredDay;
        this.strTime = strPreferredTime;
        this.strOtherEmails = strAdditionalEmails;
    }
    
	global void execute(SchedulableContext SC)
    {
        SL_Batch_TimeCardFillingReminder objBatch = new SL_Batch_TimeCardFillingReminder(strDay, strTime, strOtherEmails);
        Database.executeBatch(objBatch, 200);
    }
}