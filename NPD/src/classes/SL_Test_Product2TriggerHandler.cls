/**  
* \arg ClassName        : SL_Test_Product2TriggerHandler
* \arg JIRATicket       : NPD-220
* \arg CreatedOn        : 13/OCT/2015
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Sandeep
* \arg ModifiedBy       : 
* \arg Description      : Test class for Product2 Handler.
*/

@isTest
private class SL_Test_Product2TriggerHandler 
{
	private static testMethod void testProduct2TriggerHandler() 
	{
        List<Product2> lstProduct2 = new List<Product2>();
        List<Product2> lstProduct2ToUpdate = new List<Product2>();
        for(Integer i = 1; i <= 3; i++)
        {
             Product2 prod = new Product2(Name = 'Test Product '+i, Family = 'Premium Services', Product_Group__c = 'Store Level Enabled',
                                          Product_Identifier__c = 'Test Identifier - '+i, isActive = true, Product_Offering__c = 'POS Geographies/Store Groups' ,
                                         Product_LOB__c = 'USA - 3662 - Toys POS', Product_BU__c = 'Canada Food/Softlines', 
                                         CurrencyIsoCode ='USD', Product_Data_Source__c = 'Consumer Only',
                                         Product_Launch_Date__c = Date.today().addDays(2), ALR_Retailer__c = 'Advance');
                lstProduct2.add(prod);
        }
        insert lstProduct2;
        
        Product2 prod = new Product2(Name = 'Test Product 4', Family = 'Premium Services', Product_Group__c = 'Store Level Enabled',
                                          Product_Identifier__c = 'Test Identifier - 1', isActive = true, Product_Offering__c = 'POS Geographies/Store Groups' ,
                                         Product_LOB__c = 'USA - 3662 - Toys POS', Product_BU__c = 'Canada Food/Softlines', 
                                         CurrencyIsoCode ='USD', Product_Data_Source__c = 'Consumer Only',
                                         Product_Launch_Date__c = Date.today().addDays(2), ALR_Retailer__c = 'Advance');
        
        SL_Product2TriggerHandler.isRecursive = false;
        insert prod;
        
        System.assertEquals([SELECT Id FROM Product_Bundle__c WHERE Product_Identifier__c = 'Test Identifier - 1'].size(), 1);
        System.assertEquals([SELECT Id FROM Product_Bundle__c WHERE Product_Identifier__c = 'Test Identifier - 2'].size(), 1);
        System.assertEquals([SELECT Id FROM Product_Bundle__c WHERE Product_Identifier__c = 'Test Identifier - 3'].size(), 1);
        
        prod.isActive = false;
        lstProduct2ToUpdate.add(prod);
        for(Product2 objProduct2:lstProduct2)
        {
            objProduct2.isActive = false;
            lstProduct2ToUpdate.add(objProduct2);
        }
        
        SL_Product2TriggerHandler.isRecursive = false;
        update lstProduct2ToUpdate;
        
        System.assertEquals([SELECT Id FROM Product_Bundle__c WHERE Product_Identifier__c = 'Test Identifier - 1'].size(), 0);
        System.assertEquals([SELECT Id FROM Product_Bundle__c WHERE Product_Identifier__c = 'Test Identifier - 2'].size(), 0);
        System.assertEquals([SELECT Id FROM Product_Bundle__c WHERE Product_Identifier__c = 'Test Identifier - 3'].size(), 0);
        
        lstProduct2ToUpdate = new List<Product2>();
        for(Product2 objProduct2:lstProduct2)
        {
            objProduct2.isActive = true;
            lstProduct2ToUpdate.add(objProduct2);
        }
        SL_Product2TriggerHandler.isRecursive = false;
        update lstProduct2ToUpdate;
        
        System.assertEquals([SELECT Id FROM Product_Bundle__c WHERE Product_Identifier__c = 'Test Identifier - 1'].size(), 1);
        System.assertEquals([SELECT Id FROM Product_Bundle__c WHERE Product_Identifier__c = 'Test Identifier - 2'].size(), 1);
        System.assertEquals([SELECT Id FROM Product_Bundle__c WHERE Product_Identifier__c = 'Test Identifier - 3'].size(), 1);
        
        SL_Product2TriggerHandler.isRecursive = false;
        delete lstProduct2ToUpdate;
        
        System.assertEquals([SELECT Id FROM Product_Bundle__c WHERE Product_Identifier__c = 'Test Identifier - 1'].size(), 0);
        System.assertEquals([SELECT Id FROM Product_Bundle__c WHERE Product_Identifier__c = 'Test Identifier - 2'].size(), 0);
        System.assertEquals([SELECT Id FROM Product_Bundle__c WHERE Product_Identifier__c = 'Test Identifier - 3'].size(), 0);
	}
}