/**
 * \author Vika Osmak 
 * \date 06/23/11
 * \see http://silverline.jira.com/browse/MC-1
 * \brief Test Class for trigger SL_PotentialBuyerInvestor on Potential_Buyer_Investor__c
 */
@isTest
private class SL_Test_PBI_Trigger_Handler 
{
	static testMethod void SL_Test_PBI_Trigger_Handler_coverage() 
    {
     	Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
     	Potential_Buyer_Investor__c ip = new Potential_Buyer_Investor__c(TargetBuyer__c = acc.Id);
     	insert ip;
     	update ip;
     	delete ip;
    }
}