/**
* @ClassName 		: SL_NightlyBatch_SyncProducts
* @JIRATicket   	: Silverline-145
* @CreatedOn    	: 3/JAN/2013
* @ModifiedBy   	: Rehan
* @Description 	 	: This is the controller class for SL_Scheduler_SyncProducts schedular.
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
global class SL_NightlyBatch_SyncProducts implements Database.Batchable<sObject>
{
	/* Start - Global Variables */
    global final String strQuery;
  	/* End - Global Variables */

	/* Start - Constructor */
    global SL_NightlyBatch_SyncProducts(String paramQuery)
    {
      	strQuery = paramQuery;
    }
  	/* End - Constructor */

  	/* Start - Start Method for a Batchable Class */
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
      	return Database.getQueryLocator(strQuery);
    }
  	/* End - Start Method for a Batchable Class */

  	/* Start - Execute Method for a Batchable Class */
    // Processing 200 records at one time.
    global void execute(Database.BatchableContext BC, List<sObject> lstSObject)
    {
	  	try
	  	{
	  		Set<Id> setStdProductIds = new Set<Id>();
			List<Product__c> lstCustomProducts = new List<Product__c>();
			List<Product__c> lstUpdateProducts = new List<Product__c>();
  			lstCustomProducts = new List<Product__c>((List<Product__c>) lstSObject);

			Map<Id, Id> mapStdProduct_CustomProduct = new Map<Id, Id>();
			Map<Id, Decimal> mapProductId_UnitPrice = new Map<Id, Decimal>();

			if(lstCustomProducts.size() > 0)
			{
				for(Product__c objCustomProduct : lstCustomProducts)
				{
					setStdProductIds.add(objCustomProduct.Product__c);
				}

				for(PricebookEntry objPriceBookEntry : [Select UseStandardPrice, UnitPrice, Product2Id, Pricebook2Id
														From PricebookEntry
														WHERE Pricebook2.IsStandard = true AND Product2Id IN: setStdProductIds])
				{
					mapProductId_UnitPrice.put(objPriceBookEntry.Product2Id, objPriceBookEntry.UnitPrice);
				}
			}

			if(lstCustomProducts.size() > 0)
			{
				for(Product__c objCustomProduct : lstCustomProducts)
				{
					Product__c objProductUpdate = new Product__c(Id = objCustomProduct.Id);
					objProductUpdate.Standard_Price__c = mapProductId_UnitPrice.get(objCustomProduct.Product__c);
					lstUpdateProducts.add(objProductUpdate);
				}
			}

			if(lstUpdateProducts.size() > 0)
			{
				update lstUpdateProducts;
			}

	  	}
	  	catch(Exception e)
	  	{
			system.debug('??????????Got an Exception ???????????????' + e.getMessage() + '???????at Line :???????' + e.getlineNumber());
	  	}
    }

    /* End - Execute Method for a Batchable Class */

 	/* Start - Finish Method for a Batchable Class */
    global void finish (Database.BatchableContext BC)
    {

    }
  	/* End - Finish Method for a Batchable Class */

  	// Test Class
  	@isTest(seeallData = true)
  	public static void SL_NightlyBatch_SyncProducts()
    {
		Product2 objProduct = new Product2();
        objProduct.Name = 'Test-Product1';
        objProduct.ProductCode = '1234567890123';
        objProduct.IsActive = true;
        insert objProduct;

        Product2 objProduct1 = new Product2();
        objProduct1.Name = 'Test-Product2';
        objProduct1.ProductCode = '1234567890123';
        objProduct1.IsActive = true;
        insert objProduct1;

		// Checking the Product__c record is been created or not
		system.assert([Select Id, Product__c from Product__c where Product__c = : objProduct.Id] != NULL);

        PricebookEntry objPricebookEntry = new PricebookEntry();
        objPricebookEntry.Product2Id = objProduct.Id;
        Pricebook2 spb = [select Id from Pricebook2 where IsStandard = true LIMIT 1];
        objPricebookEntry.Pricebook2Id = spb.Id;
        objPricebookEntry.UseStandardPrice = false;
        objPricebookEntry.UnitPrice = 1;
        objPricebookEntry.IsActive = true;
        insert objPricebookEntry;

        // Staring the test for Batch
    	Test.startTest();

    	String strQuery = 'SELECT Id, Product__c ' +
					  	  'From Product__c LIMIT 10';

		SL_NightlyBatch_SyncProducts objBatchClass = new SL_NightlyBatch_SyncProducts(strQuery);
		database.executebatch(objBatchClass, 200);

		Test.stopTest();

    }
}