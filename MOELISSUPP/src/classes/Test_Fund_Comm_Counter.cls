@isTest
private class Test_Fund_Comm_Counter {
	static testMethod void testThis() {
		Account acct = new Account(name='Test');
		Fund__c fund = new Fund__c(name='Test');
		insert acct;
		insert fund;
		Fund_Commitment__c fc = new Fund_Commitment__c(Investor__c=acct.id, Fund__c=fund.id);
		insert fc;
	}
}