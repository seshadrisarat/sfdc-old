@isTest
private class psaRollupTest {
	
	@isTest static void test_method_one() {
		Account a = new Account(Name='asdsdgf');
		insert a;
		Opportunity c = new Opportunity(Name='asdasd', AccountId = a.Id, StageName='Closed Won', CloseDate=Date.today(), Type='Existing Business',BA_allocations__c=1234.00, Projected_Start_Date__c=Date.today().addDays(15));
		insert c;
		dlrs__LookupRollupSummary__c d = new dlrs__LookupRollupSummary__c(
			dlrs__AggregateOperation__c = 'SUM',
			dlrs__AggregateResultField__c = 'NumberOfEmployees',
			dlrs__CalculationMode__c = 'Scheduled',
			dlrs__ChildObject__c = 'Opportunity',
			dlrs__FieldToAggregate__c = 'BA_allocations__c',
			dlrs__ParentObject__c = 'Account',
			dlrs__RelationshipCriteria__c = '',
			dlrs__RelationshipCriteriaFields__c = '',
			dlrs__RelationshipField__c = 'AccountId',
			Batch_Order__c = 1,
			Batch_Active__c = true
			);
		insert d;
		Test.startTest();
		Database.executeBatch(new psaRollups());
		Test.stopTest();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}