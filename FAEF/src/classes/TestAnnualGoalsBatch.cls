@isTest(SeeAllData=true)
private class TestAnnualGoalsBatch 
{
    static testMethod void testBatch() 
    {        
		Test.StartTest();
		if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued')] < 5)
        {
        	Id batchInstanceId = Database.executeBatch(new AnnualGoalsBatch('Select ID from User where isactive = true and Profile.Name like \'Sales%\' LIMIT 1', 'dev@sfdcdev.com'), 1);
        }	
        Test.StopTest();
    }
}