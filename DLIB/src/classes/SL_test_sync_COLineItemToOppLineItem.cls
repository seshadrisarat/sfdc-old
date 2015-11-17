/**
 * \author Vladimir Dobrelya
 * \date Feb 20, 2014
 * \see https://silverline.jira.com/browse/SLFF-23
 */
@isTest(SeeAllData=true)
private class SL_test_sync_COLineItemToOppLineItem {
	
	@isTest static void test_insert() {
		createData();
		doAsserts( getOppLineItem() );
	}
	
	@isTest static void test_update() {
		createData();

		Test.startTest();
			pCOLineItem.Description__c += '-CHANGED';
            pCOLineItem.Discount__c += 1;
            pCOLineItem.Qty__c += 1;
            pCOLineItem.Sales_Price__c += 1;
            update pCOLineItem;
		Test.stopTest();

		doAsserts( getOppLineItem() );
	}
	
	@isTest static void test_delete() {
		createData();

		system.assertNotEquals( null, getOppLineItem() );

		Test.startTest();
			delete pCOLineItem;
		Test.stopTest();

		system.assertEquals( null, getOppLineItem() );
	}

	private static void doAsserts( OpportunityLineItem oLineItem ) {
		system.assertEquals( pCOLineItem.Id, oLineItem.CO_Line_Item__c );
		system.assertEquals( pCOLineItem.CurrencyIsoCode, oLineItem.CurrencyIsoCode );
		system.assertEquals( pCOLineItem.Description__c, oLineItem.Description );
		system.assertEquals( pCOLineItem.Discount__c, oLineItem.Discount );
		system.assertEquals( pCOLineItem.Qty__c, oLineItem.Quantity );
		system.assertEquals( pCOLineItem.Sales_Price__c, oLineItem.UnitPrice );
	}

	private static void createData() {
		SL_test_sync_ChangeOrderToOpportunity.createData();
	}

	private static OpportunityLineItem getOppLineItem() {
		OpportunityLineItem oResult;

		for ( OpportunityLineItem oItem : [
			SELECT Id, CO_Line_Item__c, CurrencyIsoCode, Description, Discount, Quantity, UnitPrice
			FROM OpportunityLineItem
			WHERE CO_Line_Item__c = :pCOLineItem.Id ]
		) {
			oResult = oItem;
		}

		return oResult;
	}

	private static CO_Line_Item__c pCOLineItem {
		get {
			if ( pCOLineItem == null ) {
				Pricebook2 oPricebook2 = [ SELECT Id FROM Pricebook2 WHERE IsStandard = true AND isActive = true limit 1 ];

				PricebookEntry oPricebookEntry = new PricebookEntry (
					Product2Id = pProduct2.Id,
					Pricebook2Id = oPricebook2.Id,
					UnitPrice = 3,
					isActive = true
				);
				insert oPricebookEntry;

				pCOLineItem = new CO_Line_Item__c(
					Change_Order__c = SL_test_sync_ChangeOrderToOpportunity.pChangeOrder.Id,
					CurrencyIsoCode = 'USD',
					Description__c = 'Test_pCOLineItem',
					Discount__c = 1,
					Qty__c = 2,
					Sales_Price__c = 1,
					Product__c = pProduct.Id
				);
				insert pCOLineItem;

				pCOLineItem = [
					SELECT Id, CurrencyIsoCode, Description__c, Discount__c, Qty__c, Sales_Price__c, Change_Order__c, Product__c
					FROM CO_Line_Item__c
					WHERE Id = :pCOLineItem.Id
				];
			}
			return pCOLineItem;
		} set;
	}

	private static Product__c pProduct {
		get {
			if ( pProduct == null ) {
				pProduct = new Product__c(
					Product__c = pProduct2.Id
				);
				insert pProduct;
			}
			return pProduct;
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