/**
* @ClassName 		: SL_Product_Handler
* @JIRATicket   	: Silverline-145
* @CreatedOn    	: 3/JAN/2013
* @ModifiedBy   	: Rehan
* @Description 	 	: This is the controller class for SL_Product_Handler trigger.
*/

/**
@Rehan
Percentage of best practices followed	: 100%
No of SOQL queries used					: 0
No of collections used					: 0
Exception Handling implemented			: Yes
Coding standards followed				: Yes
Naming conventions followed				: Yes
Third party integrations				: No
Maximum of No of records tested with	: 10
Customer Approval						:
Last Modified Date						: 3/JAN/2013
Approved by								:

*/
public with sharing class SL_Product_Handler
{
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;

	public static boolean isRecursion= false;

	/**
		* Constructor		: Initialise the global variables
		* @param			: None.
	*/
	public SL_Product_Handler(boolean isExecuting, integer size)
	{
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	/*
		@MethodName		: onAfterInsert
		@param			: mapOld  (Trigger Old Values)
		@param			: mapNew (Trigger New Values)
		@Description	: To check the Gender Value
	*/
	public void onAfterInsert(Map<Id, Product2> mapOld, Map<Id, Product2> mapNew)
	{
		try
		{
			syncStandardProductWithCustomProduct(mapOld, mapNew);
		}
		catch(Exception e)
		{
			// do nothing
		}
		//ffirule.IntegrationRuleEngine.triggerHandler();
	}

	/*
		@MethodName		: onAfterUpdate
		@param			: mapOld  (Trigger Old Values)
		@param			: mapNew (Trigger New Values)
		@Description	: To update the record like how many time it has updated
	*/
	public void onAfterUpdate(Map<Id, Product2> mapOld, Map<Id, Product2> mapNew)
	{
		try
		{
			syncStandardProductWithCustomProduct(mapOld, mapNew);
		}
		catch(Exception e)
		{
			// do nothing
		}
		//ffirule.IntegrationRuleEngine.triggerHandler();
	}

	private void syncStandardProductWithCustomProduct(Map<Id, Product2> mapOld, Map<Id, Product2> mapNew)
	{
		List<Product__c> lstProductUpsert = new List<Product__c>();
		Map<Id, Id> mapStdProduct_CustomProduct = new Map<Id, Id>();
		Map<Id, Decimal> mapProductId_UnitPrice = new Map<Id, Decimal>();

		if(mapOld != NULL && mapNew != NULL)
		{
			for(Product__c objCustomProduct : [Select Id, Product__c from Product__c where Product__c IN: mapNew.keyset()])
			{
				mapStdProduct_CustomProduct.put(objCustomProduct.Product__c, objCustomProduct.Id);
			}
		}

		if(mapNew != NULL)
		{
			for(PricebookEntry objPriceBookEntry : [Select UseStandardPrice, UnitPrice, Product2Id, Pricebook2Id
													From PricebookEntry
													WHERE Pricebook2.IsStandard = true AND Product2Id IN: mapNew.keyset()])
			{
				mapProductId_UnitPrice.put(objPriceBookEntry.Product2Id, objPriceBookEntry.UnitPrice);
			}
		}

		if(mapNew != NULL)
		{
			for(Product2 objStdProduct : mapNew.values())
			{
				Product__c objProductUpsert;
				//should only create products for services but this is referenced in too many test classes 
				//if(!objStdProduct.pse__IsServicesProduct__c) continue;
				
				if(mapOld == null || !mapOld.containsKey(objStdProduct.Id))
					objProductUpsert = new Product__c();
				else
					objProductUpsert = new Product__c(Id = mapStdProduct_CustomProduct.get(objStdProduct.Id));

				objProductUpsert.Product__c = objStdProduct.Id;
				objProductUpsert.Active__c = objStdProduct.isActive;
				objProductUpsert.Name = objStdProduct.Name;
				objProductUpsert.Description__c = objStdProduct.Description;
				objProductUpsert.PC_IsServicesProduct__c = objStdProduct.pse__IsServicesProduct__c;
				objProductUpsert.Standard_Price__c = mapProductId_UnitPrice.get(objStdProduct.Id);

				lstProductUpsert.add(objProductUpsert);
			}
		}

		if(lstProductUpsert.size() > 0)
		{
			upsert lstProductUpsert;
		}
	}

	static Product2 objProduct;
	static PricebookEntry objPricebookEntry;

	@isTest(seeAllData = true)
	private static void SL_Product_Handler()
	{
		objProduct = new Product2();
        objProduct.Name = 'Test-Product1';
        objProduct.ProductCode = '1234567890123';
        objProduct.IsActive = true;
        insert objProduct;

		// Checking the Product__c record is been created or not
		system.assert([Select Id, Product__c from Product__c where Product__c = : objProduct.Id] != NULL);

        objPricebookEntry = new PricebookEntry();
        objPricebookEntry.Product2Id = objProduct.Id;
        Pricebook2 spb = [select Id from Pricebook2 where IsStandard = true LIMIT 1];
        objPricebookEntry.Pricebook2Id = spb.Id;
        objPricebookEntry.UseStandardPrice = false;
        objPricebookEntry.UnitPrice = 1;
        objPricebookEntry.IsActive = true;
        insert objPricebookEntry;

        objProduct.ProductCode = 'Test-Product2';
        update objProduct;

        // Checking the PriceBookEntry Unit Price is been stored in Product__c Standard_Price__c field
        system.assert([Select Id, Standard_Price__c, Product__c from Product__c where Product__c = : objProduct.Id].Standard_Price__c == 1);
	}

}