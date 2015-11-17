/**
    * \arg ClassName      : SL_TimeCardBatchScheduleManager
    * \arg JIRATicket     : PWP-215
    * \arg CreatedOn      : 09/Sep/2015
    * \arg LastModifiedOn : 13/Sep/2015
    * \arg CreatededBy    : Lodhi
    * \arg ModifiedBy     : Lodhi
    * \arg Description    : Test class for SL_TimeCardBatchScheduleManager class.
*/
@isTest
private class SL_Test_TimeCardBatchScheduleManager 
{
	private static testMethod void Test_TimeCardBatchSchedunager() 
	{
        List<Time_Card_Batch_Scheduler__c> lstTCBS = new List<Time_Card_Batch_Scheduler__c>{
            new Time_Card_Batch_Scheduler__c(Additional_Recipients__c = 'test1@test.com', Day__c = 'Mon', Frequency__c = 'Every 1 hour', 
                                             Is_Availability_Reminder__c = true, Time__c = '11.50'),
            new Time_Card_Batch_Scheduler__c(Additional_Recipients__c = 'test2@test.com', Day__c = 'Mon', Frequency__c = 'Every 30 minutes', 
                                             Is_Availability_Reminder__c = true, Time__c = '11.50'),
            new Time_Card_Batch_Scheduler__c(Additional_Recipients__c = 'test3@test.com', Day__c = 'Mon', Frequency__c = 'Every 1 hour', 
                                             Is_Availability_Reminder__c = false, Time__c = '11.50'),
            new Time_Card_Batch_Scheduler__c(Additional_Recipients__c = 'test4@test.com', Day__c = 'Mon', Frequency__c = 'Every 30 minutes', 
                                             Is_Availability_Reminder__c = false, Time__c = '11.50')                                             
        };
        insert lstTCBS;
        Apexpages.standardController sc = new Apexpages.standardController(new Time_Card_Batch_Scheduler__c());
        SL_TimeCardBatchScheduleManager objScheduler = new SL_TimeCardBatchScheduleManager(sc);
        objScheduler.scheduleJOB();
        objScheduler.abortJOB();
        
        Apexpages.standardController sc1 = new Apexpages.standardController(lstTCBS[0]);
        SL_TimeCardBatchScheduleManager objScheduler1 = new SL_TimeCardBatchScheduleManager(sc1);
        objScheduler1.scheduleJOB();
        objScheduler1.abortJOB();
        
        Apexpages.standardController sc2 = new Apexpages.standardController(lstTCBS[1]);
        SL_TimeCardBatchScheduleManager objScheduler2 = new SL_TimeCardBatchScheduleManager(sc2);
        objScheduler2.scheduleJOB();
        objScheduler2.abortJOB();
        
        Apexpages.standardController sc3 = new Apexpages.standardController(lstTCBS[2]);
        SL_TimeCardBatchScheduleManager objScheduler3 = new SL_TimeCardBatchScheduleManager(sc3);
        objScheduler3.scheduleJOB();
        objScheduler3.abortJOB();
        
        Apexpages.standardController sc4 = new Apexpages.standardController(lstTCBS[3]);
        SL_TimeCardBatchScheduleManager objScheduler4 = new SL_TimeCardBatchScheduleManager(sc4);
        objScheduler4.scheduleJOB();
        
        Apexpages.currentPage().getParameters().put('Id', lstTCBS[3].Id);
        Apexpages.standardController sc5 = new Apexpages.standardController(lstTCBS[3]);
        SL_TimeCardBatchScheduleManager objScheduler5 = new SL_TimeCardBatchScheduleManager(sc5);
        objScheduler5.abortJOB();
	}
}