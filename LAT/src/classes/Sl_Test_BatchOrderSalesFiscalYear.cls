@isTest
private class Sl_Test_BatchOrderSalesFiscalYear {

	private static testMethod void createSalesOrderLineRecords() 
	{
	    Profile objProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
	    User objUserInactive = new User(FirstName='Test', LastName='User 1' , Alias='Al1' , 
	                                                           Email='Test1@testmail.com',Username='test1@testsmail.com',
	                                                           CommunityNickname='usr1',Integration_ID__c='test IntegrationId 1',
	                                                           EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
	                                                           LocaleSidKey='en_US', ProfileId = objProfile.Id,
	                                                           TimeZoneSidKey='America/Los_Angeles',isActive=true);
		insert objUserInactive;
		
		SL_SalesOrdersHandler__c objSetting = new SL_SalesOrdersHandler__c(Name='Sl_SalesOrderInactiveOwner' , InActive_User__c=objUserInactive.Id);
		insert objSetting;
		
        Sales_Orders__c objSalesOrder = new Sales_Orders__c(Fiscal_Year__c = 14);
        insert objSalesOrder;
        
        Sales_Orders__c objSalesOrder1 = new Sales_Orders__c(Fiscal_Year__c = 14);
        insert objSalesOrder1;
        
        List<Sales_Order_Lines__c> lstOrderLineItemsToInsert = new List<Sales_Order_Lines__c>();
        lstOrderLineItemsToInsert.add(new Sales_Order_Lines__c(Month__c='JAN' , Sales_Order__c=objSalesOrder1.Id));
        lstOrderLineItemsToInsert.add(new Sales_Order_Lines__c(Month__c='APR' , Sales_Order__c=objSalesOrder1.Id));
        lstOrderLineItemsToInsert.add(new Sales_Order_Lines__c(Month__c='MAY' , Sales_Order__c=objSalesOrder1.Id));
        
        insert lstOrderLineItemsToInsert;
        
        Test.startTest();
            database.executeBatch(new SL_Batch_OrderSalesUpdateByFiscalYear());
        Test.stopTest();
        
        List<Sales_Order_Lines__c> lstOrderLineItems = [Select Id,Month__c from Sales_Order_Lines__c where Sales_Order__c =: objSalesOrder.Id]; 
        system.assertEquals(12 , lstOrderLineItems.size());
        system.assertEquals('JAN' , lstOrderLineItems[0].Month__c);
        system.assertEquals('AUG' , lstOrderLineItems[7].Month__c);
        
        lstOrderLineItems = [Select Id,Month__c from Sales_Order_Lines__c where Sales_Order__c =: objSalesOrder1.Id]; 
        //system.assertEquals(12 , lstOrderLineItems.size());
        //system.assertEquals('DEC' , lstOrderLineItems[11].Month__c);
	}

}