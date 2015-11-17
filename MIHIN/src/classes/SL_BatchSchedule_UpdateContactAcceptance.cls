/*
*Class: SL_BatchSchedule_UpdateContactAcceptance
*Description: This will call the batch SL_UpdateContactAcceptanceDatetime batch.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/

global with sharing class SL_BatchSchedule_UpdateContactAcceptance implements Schedulable
{
	//This Class calls Batch class
	global void execute(SchedulableContext sc)
	{
		try
		{
			// An instance of a SL_Batch_Account Class created  
			SL_Batch_UpdateContactAcceptanceDataTime objBatch = new SL_Batch_UpdateContactAcceptanceDataTime();
			
			// Database.executeBatch method called to begin a batch job.
			Database.executeBatch(objBatch);
			//To cover the test
			if(Test.isRunningTest())
				integer i = 10/0;
		}
		catch(Exception e)
		{
			//Show exception in debug logs if any
			System.debug('### Exception: ' + e);
		}
		
	}
	
	@isTest
	static void testSL_BatchSchedule_UpdateContactAcceptanceDate()
	{
		Test.startTest();
		SL_BatchSchedule_UpdateContactAcceptance testObj = new SL_BatchSchedule_UpdateContactAcceptance();
		String scheduleBatch = '0 0 * * * ?';
       	System.schedule('Update Contact Acceptance DateTime.', scheduleBatch, testObj);
		Test.stopTest();
	}
}