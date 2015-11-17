/**
*  Class Name    : SL_Test_CommitmentHandler
*  CreatedOn     : 30/04/2015
*  ModifiedBy    : Sandeep
*  ModifiedDate  : 
*  Description   : This is the Test class for commitment trigger 
*/
@isTest
private class SL_Test_CommitmentHandler 
{
	@isTest static void testUpdateAccountRollupCommitAmount() 
	{
		Account objAccount = new Account(Name = 'TestAccount');
		insert objAccount;

		Account objAccount1 = new Account(Name = 'TestAccount1');
		insert objAccount1;

		Investor_Entity__c objInvestorEntity = new Investor_Entity__c(Name = 'IN-1', Account__c = objAccount.Id);
		insert objInvestorEntity;

		Investor_Entity__c objInvestorEntity1 = new Investor_Entity__c(Name = 'IN-2', Account__c = objAccount1.Id);
		insert objInvestorEntity1;

		Commitment_Type__c objCommitType = new Commitment_Type__c(Name = 'Test');
		insert objCommitType;

		List<Commitment__c> lst = new List<Commitment__c>{

					    new Commitment__c(Name = 'C-1',Commitment_Type__c = objCommitType.Id, Amount__c = 1,
					                     	Investor_Entity__c = objInvestorEntity.Id),
					    new Commitment__c(Name = 'C-2',Commitment_Type__c = objCommitType.Id, Amount__c = 2,
					                     	Investor_Entity__c = objInvestorEntity.Id),
					    new Commitment__c(Name = 'C-2',Commitment_Type__c = objCommitType.Id, Amount__c = 3,
					                     	Investor_Entity__c = objInvestorEntity1.Id),
					    new Commitment__c(Name = 'C-2',Commitment_Type__c = objCommitType.Id, Amount__c = 4,
					                     	Investor_Entity__c = objInvestorEntity1.Id)
		};
		insert lst;
		system.debug('=================='+[SELECT Id, Commitment_Amount_Rolled_Up__c FROM Account ]);
		system.assertEquals([SELECT Commitment_Amount_Rolled_Up__c FROM Account WHERE Id =: objAccount.Id].Commitment_Amount_Rolled_Up__c , 3);
		system.assertEquals([SELECT Commitment_Amount_Rolled_Up__c FROM Account WHERE Id =: objAccount1.Id].Commitment_Amount_Rolled_Up__c , 7);

		lst[0].Amount__c = 11;
		lst[3].Amount__c = 11;
		update lst;

		system.assertEquals([SELECT Commitment_Amount_Rolled_Up__c FROM Account WHERE Id =: objAccount.Id].Commitment_Amount_Rolled_Up__c , 13);
		system.assertEquals([SELECT Commitment_Amount_Rolled_Up__c FROM Account WHERE Id =: objAccount1.Id].Commitment_Amount_Rolled_Up__c , 14);
		
		delete lst[0];
		delete lst[3];

		system.assertEquals([SELECT Commitment_Amount_Rolled_Up__c FROM Account WHERE Id =: objAccount.Id].Commitment_Amount_Rolled_Up__c , 2);
		system.assertEquals([SELECT Commitment_Amount_Rolled_Up__c FROM Account WHERE Id =: objAccount1.Id].Commitment_Amount_Rolled_Up__c , 3);
	}
}