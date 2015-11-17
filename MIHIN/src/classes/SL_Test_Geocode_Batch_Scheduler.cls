/*
*Class: SL_Test_Geocode_Batch_Scheduler
*Description: This test class is used to test SL_Geocode_Batch_Scheduler functionality and its code coverage
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@isTest
private class SL_Test_Geocode_Batch_Scheduler 
{

    static testMethod void myUnitTest() 
    {
		String CRON_EXP = '0 0 0 1 1 ? 2025';  
        String jobId = System.schedule('Test Job 2', CRON_EXP, new SL_Geocode_Batch_Scheduler());

        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

        System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime));
    }
}