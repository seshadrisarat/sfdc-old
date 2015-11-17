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
private class SL_TestPriceTableInlineVF {
	private static String strOilRecTypeOpportunity = '';
	private static String strOilRecTypePriceTable = '';
	private static String strPropaneRecTypePriceTable = '';
	private static String strPropaneRecTypeOpportunity = '';
	private static Account objAcc;
	private static Opportunity objOpp;
	
    static testMethod void myUnitTest() 
    {
	    createTestData();
    	objOpp.Tank_Type__c = 'test';
    	update objOpp;
    	ApexPages.StandardController sc = new ApexPages.standardController(objOpp);
		SL_PricingTableInlineVF objPTInlineVF = new SL_PricingTableInlineVF(sc);
		objOpp.Override__c = true;
		objPTInlineVF.updateOpportunity();
		objPTInlineVF.refreshOpportunity();
    }
    
    static testMethod void checkForupdateOpportunityRemote()
    {
    	createTestData();
    	Price_Table__c objPT = new Price_Table__c(Price_Type__c= 'Fixed', RecordTypeId = strOilRecTypePriceTable, Fixed_Price__c = 12);
    	insert objPT;
    	
    	Test.startTest();
    	SL_PricingTableInlineVF.updateOpportunityRemote(objOpp.Id, objPT.Id,'Ceiling');
    	Test.stopTest();
    }
    
    static testMethod void testRemoteAction()
    {
    	createTestData();
				
    	Price_Table__c objPT = new Price_Table__c(Price_Type__c= 'Ceiling', RecordTypeId = strOilRecTypePriceTable);
    	insert objPT;
    	
    	//Test.startTest();
    	//SL_PricingTableInlineVF.updateOpportunity(objOpp.Id, objPT.Id);
    	//Test.StopTest();
    	system.assertEquals([Select Pricing_Type__c From Opportunity LIMIT 1 ].Pricing_Type__c,  objPT.Price_Type__c);
    }
    
    static testMethod void testRemoteActionPropaneRecordType()
    {
    	createTestData();
		objOpp.RecordTypeId = 	strPropaneRecTypeOpportunity;
		objOpp.Override__c = true;
		update objOpp;	
    	Price_Table__c objPT = new Price_Table__c(Price_Type__c= 'Ceiling', RecordTypeId = strPropaneRecTypePriceTable);
    	insert objPT;
    	
    	//Test.startTest();
    	//SL_PricingTableInlineVF.updateOpportunity(objOpp.Id, objPT.Id);
    	//Test.StopTest();
    	system.assertEquals([Select Pricing_Type__c From Opportunity LIMIT 1 ].Pricing_Type__c,  objPT.Price_Type__c);
    }
    
    
    private static void createTestData()
    {
    	DivOilPriceGrp__c objDivOilPriceGrp = new DivOilPriceGrp__c(Name = 'Test DivOilPrice');
		insert objDivOilPriceGrp;
		
		Division__c objDiv = new Division__c(Name='test', Division__c ='41', Database__c = '10',Service_Company__c = 'DivCompany', DivOilPriceGrpLU__c = objDivOilPriceGrp.Id);
		insert objDiv;
		
		Territory__c objTerr = new Territory__c(Name='TestTerriority', Division__c = objDiv.Id, Zip_Postal_Code__c = '1140');
		insert objTerr;
    	
    	objAcc = new Account(LastName='TestAcc', Territory__c = objTerr.Id);
	    insert objAcc;
	    
		for(RecordType objRecordType : [SELECT Id, sObjectType, Name FROM RecordType WHERE (sObjectType = 'Opportunity' OR sObjectType = 'Price_Table__c') AND isActive = TRUE])
			if(objRecordType.sObjectType == 'Opportunity' && objRecordType.Name == 'Oil')
				strOilRecTypeOpportunity = objRecordType.Id;
			else if(objRecordType.sObjectType == 'Price_Table__c' && objRecordType.Name == 'Oil')
				strOilRecTypePriceTable = objRecordType.Id;
			else if(objRecordType.sObjectType == 'Price_Table__c' && objRecordType.Name == 'Propane')
				strPropaneRecTypePriceTable = objRecordType.Id;
			else if(objRecordType.sObjectType == 'Opportunity' && objRecordType.Name == 'Propane')
				strPropaneRecTypeOpportunity = objRecordType.Id;
				 
	
		objOpp = new Opportunity(Name='TestOppt',Pricing_Type__c= 'Ceiling', CloseDate=Date.today(), HHAU__c = '5Linx',StageName='Open',  AccountId =objAcc.Id, RecordTypeId= strOilRecTypeOpportunity );
		insert objOpp;
    	
    }
}