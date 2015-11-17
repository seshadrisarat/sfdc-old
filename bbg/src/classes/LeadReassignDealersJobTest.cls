@isTest
private class LeadReassignDealersJobTest {
	/*
    
    private static RecordType srLeadRecordType = [Select Id, DeveloperName From RecordType Where SObjectType = 'Lead' And DeveloperName = 'Sea_Ray_Lead'];
    private static Id dealerRecordTypeId = [Select Id from RecordType where sobjectType = 'Account' and developername = 'Dealer'].Id; 

    static testMethod void test() {
        LeadReassignDealersJob.isBulkLeadBulkUpdate = true; 
        Test.startTest();
        
        Account dealer = new Account(Name = 'Dealer', Dealer_Number__c = '999.99', RecordTypeId = dealerRecordTypeId, ShippingCity = 'Test', ShippingState = 'GA');
        insert dealer;
        
        Lead lead = new Lead(RecordTypeId = srLeadRecordType.Id, PostalCode = '37929', LastName = 'Lead', FirstName = 'Test', Country_ISO_Code__c = 'US', Country = 'United States', City = 'Knoxville', Assigned_Dealer_1__c = dealer.Id, Assigned_Dealer_2__c = dealer.Id, Assigned_Dealer_3__c = dealer.Id, Lead_Emails_Sent__c = False, Batch_Update__c = True, Batch_Error__c = False);
        insert lead;
        
        LeadRoutingAllowedRecordTypes__c allowedRecordType = new LeadRoutingAllowedRecordTypes__c(Name = 'Sea_Ray_Lead');
        insert allowedRecordType;
         
        Id batchJobId = Database.executeBatch(new LeadReassignDealersJob(), 9);
        Test.stopTest();
    }
    */
}