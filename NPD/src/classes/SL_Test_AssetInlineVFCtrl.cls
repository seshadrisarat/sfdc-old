/**  
* \arg ClassName        : SL_Test_AssetInlineVFCtrl
* \arg JIRATicket       : NPD-138
* \arg CreatedOn        : 29/Sep/2015
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Sandeep
* \arg ModifiedBy       : 
* \arg Description      : Test class for SL_AssetInlineVFCtrl controller
*/
@isTest
private class SL_Test_AssetInlineVFCtrl 
{
	private static testMethod void testAssetInlineVFCtrl() 
	{
        Account objAccount = new Account(Name = 'Test Account', BillingCity = 'NYC');
        insert objAccount;
        
        Account objAccount1 = new Account(Name = 'Test Account', Corporate_Account__c = objAccount.Id, BillingCity = 'NYC');
        insert objAccount1;
        
        Account objAccount2 = new Account(Name = 'Test Account', Company_Account__c = objAccount1.Id, BillingCity = 'NYC');
        insert objAccount2;
        
        Account objAccount3 = new Account(Name = 'Test Account', Company_Account__c = objAccount.Id, BillingCity = 'NYC');
        insert objAccount3;
        
        List<Asset> lstAsset = new List<Asset>{
            new Asset(Name = 'Test Asset 1', AccountId = objAccount.Id, PurchaseDate = Date.Today().addDays(-2), UsageEndDate = Date.today().addDays(2)),
            new Asset(Name = 'Test Asset 2', AccountId = objAccount1.Id, PurchaseDate = Date.Today().addDays(-2), UsageEndDate = Date.today().addDays(2)),
            new Asset(Name = 'Test Asset 3', AccountId = objAccount2.Id, PurchaseDate = Date.Today().addDays(-2), UsageEndDate = Date.today().addDays(2))
        };
        insert lstAsset;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(objAccount);
        SL_AssetInlineVFCtrl objCtrl = new SL_AssetInlineVFCtrl(stdController);
        
        system.assertEquals(objCtrl.lstAsset.size(), 2);
	}
}