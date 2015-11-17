/**
 * \author Vika Osmak 
 * \date 06/24/11
 * \see http://silverline.jira.com/browse/MC-1
 * \brief Test Class for trigger SL_PotentialBuyerInvestor on Potential_Buyer_Investor__c
 */
@isTest
private class SL_Test_PBIContact_Trigger_Handler 
{
	static testMethod void  SL_Test_PBIContact_Trigger_Handler_coverage() 
    {
     	Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
     	Potential_Buyer_Investor__c pbi = new Potential_Buyer_Investor__c(TargetBuyer__c = acc.Id);
     	insert pbi;
     	Potential_Buyer_Investor_Contact__c pbic = new Potential_Buyer_Investor_Contact__c(Contact__c = cntct.id,Target_Buyer__c = pbi.Id);
     	insert pbic;
     	update pbic;
     	delete pbic;
    }
}