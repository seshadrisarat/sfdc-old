/*
* @author : sfdcdev, Tamarack Consulting, Inc.
* @date : 03/03/2015
* @description: Test class for TC_ShoreTelDailyCallsBatch
*
* © Copyright 2003 - 2015 Tamarack Consulting, Inc.  All Rights Reserved.
* 
*/

@isTest
private class TC_ShoreTelDailyCallsBatchTest {
	
	@isTest static void testBatch() {        
		Test.StartTest();
		if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued')] < 5){
        	Id batchInstanceId = Database.executeBatch(new  TC_ShoreTelDailyCallsBatch ('Select ID from User where isactive = true and Profile.Name like \'Sales%\' LIMIT 1', 'test@test.com', System.today(), 2014), 1);
        }
        Test.StopTest();
    }
}