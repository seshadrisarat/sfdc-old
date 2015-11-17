/**
*  ClassName      : SL_RenewalOpportunitySchedulerCaller
*  JIRATicket     : THOR-42
*  CreatedOn      : 24/SEP/2014
*  ModifiedBy     : Sanath Kumar
*  Description    : This is the class to call the renewal opportunity scheduler
*/
public with sharing class SL_RenewalOpportunitySchedulerCaller 
{
	public SL_RenewalOpportunitySchedulerCaller()
	{
	    if(!Test.isRunningTest())
	    {
    	    list<CronTrigger> lstCronTrigger = [SELECT Id FROM CronTrigger where CronJobDetail.Name LIKE 'Renewal Opportunity Creation'];
    	    if(lstCronTrigger.isEmpty())
    	    {
        		SL_SchedulerToCreateRenewalOpportunity objSchedulerToCreateRenewalOpportunity = new SL_SchedulerToCreateRenewalOpportunity();
        		String scheduleBatch1 = '0 0 12 * * ?';///CRON expression to run batch daily at 12:00 PM
        		System.schedule('Renewal Opportunity Creation', scheduleBatch1, objSchedulerToCreateRenewalOpportunity);
    	    }
	    }
	}
}