@isTest
private class CLASS_NAME {

	private static testMethod void test() {
	    
	    Account objAccount = new Account(Name = 'TestAccount-1');
        Insert objAccount;
        
        List<Investor_Entity__c> lstInvestor_Entity = new List<Investor_Entity__c>
                                                        {
                                                           new Investor_Entity__c(Name = 'TestInvestor - 1', Account__c = objAccount.Id, Commitment_Amount__c = 10),
                                                           new Investor_Entity__c(Name = 'TestInvestor - 2', Account__c = objAccount.Id, Commitment_Amount__c = 20)
                                                        };
        insert lstInvestor_Entity;
	}

}