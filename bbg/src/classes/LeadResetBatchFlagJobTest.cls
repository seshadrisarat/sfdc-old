@isTest
private class LeadResetBatchFlagJobTest {
	
	private static RecordType srLeadRecordType = [Select Id, DeveloperName From RecordType Where SObjectType = 'Lead' And DeveloperName = 'Sea_Ray_Lead'];
	
    static testMethod void test() {
    	LeadResetBatchFlagsJob.isBulkLeadBulkUpdate = true; 
    	Test.startTest();
    	
    	Lead lead = new Lead(RecordTypeId = srLeadRecordType.Id, PostalCode = '37929', LastName = 'Lead', FirstName = 'Test', Country_ISO_Code__c = 'US', Country = 'United States', City = 'Knoxville', Lead_Emails_Sent__c = False, Batch_Update__c = true);
        insert lead;
        
		Id batchJobId = Database.executeBatch(new LeadResetBatchFlagsJob());
		Test.stopTest();
    }
}