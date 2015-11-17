/**
    * \arg ClassName      : SL_Test_ProductManagementToolCtrl
    * \arg JIRATicket     : NPD-87
    * \arg CreatedOn      : 25/Sep/2015
    * \arg LastModifiedOn : 
    * \arg CreatededBy    : Sandeep
    * \arg ModifiedBy     : 
    * \arg Description    : Test Class for the SL_ProductManagementToolCtrl class.
*/
@isTest
private class SL_Test_ProductManagementToolCtrl 
{
	private static testMethod void test() 
	{
        Account a = new Account(Name='testAccount', Industry='Other', Type='Prospect', BillingCity = 'London');
        insert a; 
        
        Product_Bundle__c objProductBundle = new Product_Bundle__c(Name = 'Test Prodcut Bundle', CurrencyIsoCode ='USD',
                                                                                Accounting_Units__c = 'Test Accounting unit',
                                                                                Product_Family__c = 'Test Product Family',
                                                                                Product_Group__c = 'Test Product Group',
                                                                                Product_Identifier__c = 'Test Product Identifier 1',
                                                                                Product_Offering__c = 'Test Product Offering 1',
                                                                                Retailers__c = 'Test Retailers 1');
        insert objProductBundle;
        
        Product2 prod = new Product2(Name = 'Base Motor Oil Add-on: Census Divisions/Regions', Family = 'Premium Services', Product_Group__c = 'Store Level Enabled',
                                                Product_Identifier__c = 'Test Identifier - 1', isActive = true, Product_Offering__c = 'POS Geographies/Store Groups' );
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity(Name='Test', Account = a,  NextStep='test', PriceBook2Id = pricebookId, CloseDate = System.today(),
                                          AccountId=a.Id, StageName='Closed Won - One Time', Probability = 100, Billing_Details__c = 'Test',
                                          Billing_Contact_Info_Address__c = 'test@test.com', ContractTerm__c = 5);
        insert opp;
        
        
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true );
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry( Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        // if test failures then please add the Product name, product offering, product family and product group in prodcut field set
        ApexPages.StandardController stdController = new ApexPages.StandardController(opp);
        SL_ProductManagementToolCtrl objProdctMgntTool = new SL_ProductManagementToolCtrl(stdController);
        objProdctMgntTool.strSelectedProductIdentifier = 'Test Identifier - 1';
        objProdctMgntTool.addIntoSelectedProduct();
        objProdctMgntTool.lstProduct2Wrapper[0].strCombinationOfAllFields = '~~~Product_Offering__c--->POS Geographies/Store Groups~~~Name--->Base Motor Oil Add-on: Census Divisions/Regions~~~Family--->Premium Services~~~Product_Group__c--->Store Level Enabled';
        objProdctMgntTool.createOppLineItems();
        objProdctMgntTool.getMonths();
        objProdctMgntTool.intSelectedProductTableRowNo = 1;
        objProdctMgntTool.removeProductFromSelectedProduct();
        objProdctMgntTool.cancel();
	}
}