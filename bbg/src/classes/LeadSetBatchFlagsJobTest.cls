@isTest(seeAllData=true)
private class LeadSetBatchFlagsJobTest {
	
    static testMethod void test() {
    	LeadSetBatchFlagsJob.isBulkLeadBulkUpdate = true; 
    	Test.startTest();
    	
    	//Get a lead, any lead
    	Lead lead = [SELECT Id, Assigned_Dealer_1__c FROM Lead Where isDeleted = False LIMIT 1];
        lead.Assigned_Dealer_1__c = null;
    	update lead;
        
		Id batchJobId = Database.executeBatch(new LeadSetBatchFlagsJob());
		Test.stopTest();
    }
}