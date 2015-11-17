/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SL_Test_Batch_RollupClientInvestments 
{

    static testMethod void myUnitTest() 
    {
		List<Account> lstAccountToInsert = new List<Account>();
		List<Client_Investment__c> lstClientInvestmentToInsert = new List<Client_Investment__c>();
		
		/* Insert Account */ 
		Account objAccount = new Account(Name = 'TestAccuntName');
		insert objAccount; 
		
		for(Integer i = 1; i <= 10; i++ )
		{
			lstAccountToInsert.add(new Account(Name = 'TestAccount'+1, ParentId = objAccount.Id));
		}
				
		insert lstAccountToInsert;
		
		/* Insert Fund */ 
		Fund__c objFund = new Fund__c(Name = 'Test Fund');
    	insert objFund;
		
		/* Insert client investment record */ 
		Client_Investment__c objCI1 = new Client_Investment__c(Name = 'TestClientInvestment', Organization__c = objAccount.Id, NAV__c = 10.0, GPV__c = 20.0, 
																	 Total_Distribution_Amount__c = 30.0, Total_Contribution_Amount__c = 40.0, Fund__c = objFund.Id,
																	 Exclude_from_Rollup__c = true);
		insert objCI1;															 
		
		Client_Investment__c objCI = new Client_Investment__c(Name = 'TestClientInvestment', Organization__c = objAccount.Id, NAV__c = 10.0, GPV__c = 20.0, 
																	 Total_Distribution_Amount__c = 30.0, Total_Contribution_Amount__c = 40.0, Fund__c = objFund.Id,
																	 Exclude_from_Rollup__c = false);
		insert objCI;
																	 
		for(Account objAcc : lstAccountToInsert)
		{
			
			lstClientInvestmentToInsert.add(new Client_Investment__c(Name = 'Client' + objAcc.Name, Organization__c = objAcc.Id, NAV__c = 1.0, GPV__c = 2.0, 
																	 Total_Distribution_Amount__c = 3.0, Total_Contribution_Amount__c = 4.0, Fund__c = objFund.Id,
																	 Exclude_from_Rollup__c = false ));
		}
		
		/* Inserting list client investments records */
		insert lstClientInvestmentToInsert;
		
		/* Executing batch */ 
		Test.startTest();
			Database.executeBatch(new SL_Batch_RollupClientInvestments());
		Test.stopTest();
		
		List<Account> lstUpdatedAccount = [ SELECT NAV__c, GPV__c, Total_Distribution_Amount__c, Total_Contribution_Amount__c FROM Account WHERE Id=: objAccount.Id];
		
		System.assertEquals(lstUpdatedAccount[0].NAV__c, 20.0);
		System.assertEquals(lstUpdatedAccount[0].GPV__c, 40.0);
		System.assertEquals(lstUpdatedAccount[0].Total_Distribution_Amount__c, 60.0);
		System.assertEquals(lstUpdatedAccount[0].Total_Contribution_Amount__c, 80.0);
    }
}