@isTest
private class SL_Test_EngagementTrigger 
{
	@isTest static void test_EngagementTrigger() 
	{
		Account objClientAccount = new Account(Name='Test Client Account');
		insert objClientAccount;
		
		Account objClientAccountToUpdate = new Account(Name='Test Client Account');
		insert objClientAccountToUpdate;

		Account objSubjectAccount = new Account(Name='Test Subject Account');
		insert objSubjectAccount;

		Engagement__c objEngagementNew = new Engagement__c(Name='Test Engagement', Client__c = objClientAccount.Id, 
															  Subject__c = objSubjectAccount.Id, Stage__c = 'Advisory',
															  Line_of_Business__c = 'CF', Job_Type__c = 'Take Over Defense',
															  Primary_Office__c = 'AT', Industry_Group__c = 'BUS', Industry__c = 'Coal');
		insert objEngagementNew;
		
		Engagement_Counterparty__c objEC = new Engagement_Counterparty__c(Name = 'TestEC', Company__c = objSubjectAccount.Id, 
																		  Engagement__c = objEngagementNew.Id);
		insert objEC; 
		
		Revenue_Accrual__c objRA = new Revenue_Accrual__c(Engagement__c = objEngagementNew.Id, Month__c = 'Jan', Year__c = '2003');
		insert objRA;
		
		//check whether 2 client subject records are created
		system.AssertEquals([Select Id From Engagement_Client_Subject__c where Engagement__c = :objEngagementNew.Id].Size(), 2);
		
		objEngagementNew.Name = 'dndTestEngagement';
		objEngagementNew.Client__c = objClientAccountToUpdate.Id;
		update objEngagementNew;

		// check whether the previous combination of joiner record is deleted, Now it should be deleted
		system.AssertEquals([Select Id From Engagement_Client_Subject__c where Engagement__c = :objEngagementNew.Id AND Client_Subject__c = :objClientAccount.Id].Size(), 0);
		// check whether the updated client Account is created in the Joiner
		system.AssertEquals([Select Id From Engagement_Client_Subject__c where Engagement__c = :objEngagementNew.Id].Size(), 2);
	}
}