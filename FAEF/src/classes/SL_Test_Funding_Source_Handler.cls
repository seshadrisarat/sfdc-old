@isTest
public class SL_Test_Funding_Source_Handler {
    //Test method for class SL_Funding_Source_Handler
    static testmethod void testSL_Funding_Source_Handler()
    {
    	insert new Rates__c(Rate_2_Year__c = 22.333, Rate_3_Year__c = 33.333, Rate_4_Year__c = 44.333, 
    						Rate_5_Year__c = 55.333, Rate_7_Year__c = 66.333, Prime__c = 77.333, Date__c = Date.today());
    	Account objAccount = new Account(Name = 'Test');
    	insert objAccount;
    	System.assertNotEquals(objAccount.Id, null);
    	
    	Opportunity objOpportunity = new Opportunity(AccountId = objAccount.Id, Name = 'TestOpp', CloseDate = Date.today() + 10 , StageName = 'Lost');
    	insert objOpportunity;
    	System.assertNotEquals(objOpportunity.Id, null);
    	
    	Letter_of_Intent__c sObjLOI = new Letter_of_Intent__c(Opportunity__c = objOpportunity.Id, Account__c = objAccount.Id);
    	insert sObjLOI;
    	System.assertNotEquals(sObjLOI.Id, null);
    	
    	List<Funding_Source__c> lstFSToInsert = new List<Funding_Source__c>{
    																			new Funding_Source__c(Letter_of_Intent__c = sObjLOI.Id, Collateral__c = 'Test',
    																								  Financial_Product__c = 'First Amendment Deal', 
    																								  Approved_Spread__c = 12,
    																								  Proposed_Spread__c = 2144),
    																			new Funding_Source__c(Letter_of_Intent__c = sObjLOI.Id, Collateral__c = 'Test',
    																								  Financial_Product__c = 'First Amendment Deal', 
    																								  Approved_Spread__c = 1254,
    																								  Proposed_Spread__c = 755),
    																			new Funding_Source__c(Letter_of_Intent__c = sObjLOI.Id, Collateral__c = 'Test',
    																								  Financial_Product__c = 'First Amendment Deal', 
    																								  Approved_Spread__c = 54,
    																								  Proposed_Spread__c = 232),
    																			new Funding_Source__c(Letter_of_Intent__c = sObjLOI.Id, Collateral__c = 'Test',
    																								  Financial_Product__c = 'First Amendment Deal', 
    																								  Approved_Spread__c = 21,
    																								  Proposed_Spread__c = 244),
    																			new Funding_Source__c(Letter_of_Intent__c = sObjLOI.Id, Collateral__c = 'Test',
    																								  Financial_Product__c = 'First Amendment Deal', 
    																								  Approved_Spread__c = 66,
    																								  Proposed_Spread__c = 1734)
    																	   };	
    	insert lstFSToInsert;
    	System.assertEquals([SELECT Id, SWAPS_Rate__c FROM Funding_Source__c WHERE SWAPS_Rate__c != null].size(), 5);
    	update lstFSToInsert;
    	delete lstFSToInsert;
    }
}