/**
*  ClassName      : SL_BatchToCheckErenterStatus_Caller
*  JIRATicket     : THOR-11
*  CreatedOn      : 15/OCT/2014
*  ModifiedBy     : Sanath Kumar
*  Description    : This is the class to call the SL_Schedule_BatchToCheckErenterStatus scheduler
*/
public with sharing class SL_BatchToCheckErenterStatus_Caller 
{
	public SL_BatchToCheckErenterStatus_Caller()
	{
	    /*list<CronTrigger> lstCronTrigger = [SELECT Id, State, NextFireTime , CronJobDetailId FROM CronTrigger ];
        Map<Id, CronJobDetail> mapCronJobDetails = new Map<Id, CronJobDetail>([SELECT  Id, Name FROM CronJobDetail WHERE Id IN ( SELECT CronJobDetailId FROM CronTrigger ) AND Name LIKE 'Batch to Check e-Renter Status%']);*/
        list<CronTrigger> lstCronTrigger = [SELECT Id FROM CronTrigger where CronJobDetail.Name LIKE 'Batch to Check e-Renter Status%'];
	    if(lstCronTrigger.isEmpty())
        {
    		SL_Schedule_BatchToCheckErenterStatus objScheduleBatchToCheckErenterStatus = new SL_Schedule_BatchToCheckErenterStatus();
    		
    		String scheduleBatch1 = '0 0 * * * ?';
    		String scheduleBatch2 = '0 10 * * * ?';
    		String scheduleBatch3 = '0 20 * * * ?';
    		String scheduleBatch4 = '0 30 * * * ?';
    		String scheduleBatch5 = '0 40 * * * ?';
    		String scheduleBatch6 = '0 50 * * * ?';
    		
    		System.schedule('Batch to Check e-Renter Status 1', scheduleBatch1, objScheduleBatchToCheckErenterStatus);
    		System.schedule('Batch to Check e-Renter Status 2', scheduleBatch2, objScheduleBatchToCheckErenterStatus);
    		System.schedule('Batch to Check e-Renter Status 3', scheduleBatch3, objScheduleBatchToCheckErenterStatus);
    		System.schedule('Batch to Check e-Renter Status 4', scheduleBatch4, objScheduleBatchToCheckErenterStatus);
    		System.schedule('Batch to Check e-Renter Status 5', scheduleBatch5, objScheduleBatchToCheckErenterStatus);
    		System.schedule('Batch to Check e-Renter Status 6', scheduleBatch6, objScheduleBatchToCheckErenterStatus); 
        }
	}
}