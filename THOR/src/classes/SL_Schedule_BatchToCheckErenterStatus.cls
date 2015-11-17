/**
*  ClassName      : SL_Schedule_BatchToCheckErenterStatus
*  JIRATicket     : THOR-11
*  CreatedOn      : 14/OCT/2014
*  ModifiedBy     : Sanath Kumar
*  Description    : This is the scheduler class to schedule Batch to check eRenter status
*/
global class  SL_Schedule_BatchToCheckErenterStatus  implements Schedulable
{
	/*
        *MethodName : execute 
        *param      : SchedulableContext SC
        *Description: This method schedules the respective batch class based on given cron expression
    */
    global void execute(SchedulableContext SC) 
    {
    	String PENDING = 'PENDING';
    	String strQuery = 'SELECT Current_Address_Country__c, SSN_C__c,Opportunity__c,Name ,e_Renter__c, e_renter_Application_Status__c, e_renter_Application_Status_Message__c'
    	                  + ' FROM Contact_Role__c'
    	                  + ' WHERE e_Renter__c != null AND (e_renter_Application_Status__c = null OR e_renter_Application_Status__c =: PENDING)';
    	
    	SL_BatchToCheckErenterStatus objBatchToCheckErenterStatus = new SL_BatchToCheckErenterStatus(strQuery);
    	database.executeBatch(objBatchToCheckErenterStatus, 1);
    }
}