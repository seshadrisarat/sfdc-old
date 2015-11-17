@isTest
private class Test_FundCommitmentCounterTrigger 
{
	static testMethod void FundCommitmentCounterTrigger() 
	{
		Account testCompany1 = new Account(Name='Test');
		insert testcompany1;
		Account testCompany2 = new Account(Name='Test2',ParentId = testcompany1.Id);
		insert testcompany2;
		List<Fund__c> List_Funds = new List<Fund__c>();
		Fund__c testFund1 = new Fund__c(Name = 'Moelis & Company Holdings LLC');
		List_Funds.add(testFund1);
		Fund__c testFund2 = new Fund__c(Name = 'Moelis Capital Partners Opportunity Fund I, LP');
		List_Funds.add(testFund2);
		Fund__c testFund3 = new Fund__c(Name = 'Moelis Capital Partners Opportunity Fund I-A, LP');
		List_Funds.add(testFund3);
		Fund__c testFund4 = new Fund__c(Name = 'Moelis Capital Partners Co-Investment Program');
		List_Funds.add(testFund4);
		insert List_Funds;
		
		List<Fund_Commitment__c> List_FundCommitments = new List<Fund_Commitment__c>();
		for(Fund__c tmp : List_Funds)
		{
			Fund_Commitment__c newFundCommitment = new Fund_Commitment__c(Fund__c = tmp.Id, Investor__c = testcompany2.Id,Amount__c = 100);
			insert newFundCommitment; 
			List_FundCommitments.add(newFundCommitment);
		}
		//insert List_FundCommitments; 
		update List_FundCommitments; 
		delete List_FundCommitments;
	}
}