/**
 * \author Vladimir Dobrelya
 * \date Feb 20, 2014
 * \see https://silverline.jira.com/browse/SLFF-23
 */
@isTest(SeeAllData=true)
private class SL_test_sync_OppLineItemToCOLineItem {
	
	@isTest static void test_insert() {
		createData();
		doAsserts( getCOLineItem() );
	}
	
	@isTest static void test_update() {
		createData();

		Test.startTest();
			pOpportunityLineItem.Description += '-CHANGED';
            pOpportunityLineItem.Discount += 1;
            pOpportunityLineItem.Quantity += 1;
            pOpportunityLineItem.UnitPrice += 1;
            update pOpportunityLineItem;
		Test.stopTest();

		doAsserts( getCOLineItem() );
	}
	
	@isTest static void test_delete() {
		createData();

		system.assertNotEquals( null, getCOLineItem() );

		Test.startTest();
			delete pOpportunityLineItem;
		Test.stopTest();

		system.assertEquals( null, getCOLineItem() );
	}

	private static void doAsserts( CO_Line_Item__c oLineItem ) {
		system.assertEquals( SL_test_sync_OpportunityToChangeOrder.pOpportunity.Project_Change_Order__c, oLineItem.Change_Order__c );
		system.assertEquals( pOpportunityLineItem.CO_Line_Item__c, oLineItem.Id );
		system.assertEquals( pOpportunityLineItem.CurrencyIsoCode, oLineItem.CurrencyIsoCode );
		system.assertEquals( pOpportunityLineItem.Description, oLineItem.Description__c );
		system.assertEquals( pOpportunityLineItem.Discount, oLineItem.Discount__c );
		system.assertEquals( pOpportunityLineItem.Quantity, oLineItem.Qty__c );
		system.assertEquals( pOpportunityLineItem.UnitPrice, oLineItem.Sales_Price__c );
	}

	private static void createData() {
		SL_test_sync_OpportunityToChangeOrder.createData();
	}

	private static CO_Line_Item__c getCOLineItem() {
		CO_Line_Item__c oResult;

		for ( CO_Line_Item__c oItem : [
			SELECT Id, Change_Order__c, CurrencyIsoCode, Description__c, Discount__c, Qty__c, Sales_Price__c, Product__c
			FROM CO_Line_Item__c
			WHERE Id = :pOpportunityLineItem.CO_Line_Item__c ]
		) {
			oResult = oItem;
		}

		return oResult;
	}

	private static OpportunityLineItem pOpportunityLineItem {
		get {
			if ( pOpportunityLineItem == null ) {
				Pricebook2 oPricebook2 = [ SELECT Id FROM Pricebook2 WHERE IsStandard = true AND isActive = true limit 1 ];

				PricebookEntry oPricebookEntry = new PricebookEntry(
					Product2Id = pProduct2.Id,
					Pricebook2Id = oPricebook2.Id,
					UnitPrice = 3,
					isActive = true
				);
				insert oPricebookEntry;



				pOpportunityLineItem = new OpportunityLineItem(
					OpportunityId = SL_test_sync_OpportunityToChangeOrder.pOpportunity.Id,
					UnitPrice = 1,
					Quantity = 2,
					Discount = 1,
					Description = 'Test_pOpportunityLineItem',
					ServiceDate = Date.today(),
					PricebookEntryId = oPricebookEntry.Id
				);
				insert pOpportunityLineItem;

				pOpportunityLineItem = [
					SELECT Id, OpportunityId, UnitPrice, CurrencyIsoCode, Description, Discount, Quantity, ServiceDate, TotalPrice, CO_Line_Item__c
					FROM OpportunityLineItem
					WHERE Id = :pOpportunityLineItem.Id
				];
			}
			return pOpportunityLineItem;
		} set;
	}

	private static Product2 pProduct2 {
		get {
			if ( pProduct2 == null ) {
				pProduct2 = new Product2(
					Name = 'Test Product Entry',
					Description = 'Test Product Entry',
					isActive = true
				);
				insert pProduct2;
			}
			return pProduct2;
		} set;
	}
}