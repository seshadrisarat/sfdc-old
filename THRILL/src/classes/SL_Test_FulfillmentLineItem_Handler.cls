@isTest
private class SL_Test_FulfillmentLineItem_Handler {
	
	@testSetup static void setup() {
		List<Account> lstAccs = new List<Account>{new Account(Name = 'Test Acc - 01', Industry = 'Finance'),
													new Account(Name = 'Test Acc - 02', Industry = 'Finance') };
		insert lstAccs;
		system.assert(lstAccs[0].Id != NULL);
		system.assert(lstAccs[1].Id != NULL);

		List<Opportunity> lstOppsToInsert = new List<Opportunity> {new opportunity(ParentCompany__c = lstAccs[1].Id, AccountId = lstAccs[0].Id, Name = 'Test Opportuntiy - 001', StageName = 'Verbal Approval', CloseDate= Date.Today().addDays(2)),
																	new opportunity(ParentCompany__c = lstAccs[1].Id, AccountId = lstAccs[1].Id, Name = 'Test Opportuntiy - 002', StageName = 'Verbal Approval', CloseDate= Date.Today().addDays(2))};
        insert lstOppsToInsert;
        system.assert(lstOppsToInsert[0].Id != NULL);
        system.assert(lstOppsToInsert[0].Id != NULL);

        Product2 objProduct2 = new Product2(Name = 'test01', isActive=true);
        insert objProduct2;
        system.assert(objProduct2.Id != NULL);

        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=objProduct2.Id, UnitPrice=99, isActive=true);
        insert pbe;
        
        List<OpportunityLineItem>lstOLI = new List<OpportunityLineItem>{new OpportunityLineItem(pricebookentryid=pbe.Id,TotalPrice=2000,Quantity = 2,OpportunityID = lstOppsToInsert[0].Id),
                                                                        new OpportunityLineItem(pricebookentryid=pbe.Id,TotalPrice=2000,Quantity = 2,OpportunityID = lstOppsToInsert[1].Id)};
        insert lstOLI;  
        system.assert(lstOLI[0].Id != NULL);
        system.assert(lstOLI[1].Id != NULL);

        List<Inventory_Order_Line__c> lstInventoryOrderLines = new List<Inventory_Order_Line__c>{new Inventory_Order_Line__c(OpportunityProduct_Id__c = lstOLI[0].Id),
        																						 new Inventory_Order_Line__c(OpportunityProduct_Id__c = lstOLI[1].Id)};
       	insert lstInventoryOrderLines;
		system.assert(lstInventoryOrderLines[0].Id != NULL);
		system.assert(lstInventoryOrderLines[1].Id != NULL);

       	Geo_Market__c objGeoMarket = new Geo_Market__c(Subscriber_Base__c = 10, Name = 'Test Geo Market - 01');
       	insert objGeoMarket;
       	system.assert(objGeoMarket.Id != NULL);
	}
	
	@isTest static void test_method_ForThrwingErrorForDuplicate() {
		List<Inventory_Order_Line__c> lstInventoryOrderLines = [Select Id From Inventory_Order_Line__c];
		system.debug('lstInventoryOrderLines======>>>' +lstInventoryOrderLines);

		Geo_Market__c objGeoMarket = [Select Id From Geo_Market__c Where Name = 'Test Geo Market - 01'];

		Test.startTest();
		Fulfillment_Line_Item__c objFulfillment = new Fulfillment_Line_Item__c(Inventory_Order_Line__c = lstInventoryOrderLines[0].Id, Geo_Market__c = objGeoMarket.Id, End_Date__c = Date.Today().addDays(2), Start_Date__c = Date.today());
		insert objFulfillment;

		try {
			Fulfillment_Line_Item__c objFulfillment1 = new Fulfillment_Line_Item__c(Inventory_Order_Line__c = lstInventoryOrderLines[1].Id, Geo_Market__c = objGeoMarket.Id, End_Date__c = Date.Today().addDays(2), Start_Date__c = Date.today());
			insert objFulfillment1;
		}
		catch(exception ex){
			system.assert(String.valueOf(ex.getmessage()).contains('The Industry Already Exists.'));
		}
		Test.stopTest();
	}
	
}