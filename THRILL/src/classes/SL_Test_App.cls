/**
* \arg ClassName      : SL_Test_App
* \arg JIRATicket     : THRILL-2
* \arg CreatedOn      : 15/SEPT/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as test class for SL_App controller.
*/
@isTest
private class SL_Test_App 
{
    @testSetup
    static void setup()
    {
    	Account objAccount = new Account(Name = 'Test Account');
    	insert objAccount;
    	
    	Opportunity objOpportunity = new Opportunity(Name = 'Test Opp', CloseDate = Date.today(), StageName = 'Open', ParentCompany__c = objAccount.Id);
    	insert objOpportunity;
    	
    	Id pricebookId = Test.getStandardPricebookId();
    	
    	List<Product2>  lstProduct = new List<Product2>{
        													new Product2(Name = 'Test Product 1'),
        													new Product2(Name = 'Test Product 2'),
        													new Product2(Name = 'Test Product 3')
        												};
        insert lstProduct;
        
        List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry>{
        																	new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = lstProduct[0].Id,UnitPrice = 1200,IsActive = true),
        																	new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = lstProduct[1].Id,UnitPrice = 1300,IsActive = true),
        																	new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = lstProduct[2].Id,UnitPrice = 1400,IsActive = true)
        															     };
        insert lstPriceBookEntry;
        
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>{
        																					new OpportunityLineItem(OpportunityId = objOpportunity.Id,PricebookEntryId = lstPriceBookEntry[0].Id,Quantity = 2, TotalPrice = 300),
        																					new OpportunityLineItem(OpportunityId = objOpportunity.Id,PricebookEntryId = lstPriceBookEntry[1].Id,Quantity = 2, TotalPrice = 300),
        																					new OpportunityLineItem(OpportunityId = objOpportunity.Id,PricebookEntryId = lstPriceBookEntry[2].Id,Quantity = 2, TotalPrice = 300)
        																				};
        insert lstOpportunityLineItem;
        
        List<Inventory_Order_Line__c> lstIOL = new List<Inventory_Order_Line__c>{
        																			new Inventory_Order_Line__c(OpportunityProduct_Id__c = lstOpportunityLineItem[0].Id),
        																			new Inventory_Order_Line__c(OpportunityProduct_Id__c = lstOpportunityLineItem[1].Id),
        																			new Inventory_Order_Line__c(OpportunityProduct_Id__c = lstOpportunityLineItem[1].Id)
        																		};
        insert lstIOL;
    }
    
    static testMethod void test_MediaPlan() 
    {
        Id oppId = [SELECT id FROM Opportunity LIMIT 1].Id;
        
        Test.startTest();
        SL_App.MediaPlan objMediaPlan = SL_App.getOpportunityData(oppId);
        Test.stopTest();
        
        System.assertEquals(objMediaPlan.Name, 'Test Opp');
        System.assertEquals(objMediaPlan.oppId, oppId);
        System.assertEquals(objMediaPlan.lstOLIW.size(), 3);
    }
}