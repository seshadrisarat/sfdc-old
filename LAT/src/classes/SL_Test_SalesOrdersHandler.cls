@isTest
private class SL_Test_SalesOrdersHandler 
{
	private static testmethod void updateOwnerId() 
	{
        /*User objUser_AGABBOTT = [Select Id , Integration_ID__c from User where Integration_ID__c = 'AGABBOTT' Limit 1];
        User objUser_NAHMARIPOUR = [Select Id , Integration_ID__c from User where Integration_ID__c = 'NAHMARIPOUR' Limit 1];
        
        Sales_Orders__c objSalesOrder = new Sales_Orders__c(IntegrationID__c = 'AGABBOTT'); 
	    
	    Test.startTest();
	        
	        insert objSalesOrder;
	        system.assertEquals(objUser_AGABBOTT.Id , [Select OwnerId from Sales_Orders__c where Id =: objSalesOrder.Id].OwnerId);
	        objSalesOrder.IntegrationID__c = 'NAHMARIPOUR';
	        update objSalesOrder;
	        
	    Test.stopTest();     
	    
	    system.assertEquals(SL_SalesOrdersHandler__c.getValues('Sl_SalesOrderInactiveOwner').InActive_User__c , [Select OwnerId from Sales_Orders__c where Id =: objSalesOrder.Id].OwnerId);*/
	    Profile objProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
	    List<User> lstUsersToInsert = new List<User>{ new User(FirstName='Test', LastName='User 1' , Alias='Al1' , 
	                                                           Email='Test1@testmail.com',Username='test1@testsmail.com',
	                                                           CommunityNickname='usr1',Integration_ID__c='test IntegrationId 1',
	                                                           EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
	                                                           LocaleSidKey='en_US', ProfileId = objProfile.Id,
	                                                           TimeZoneSidKey='America/Los_Angeles',isActive=true),
	                                                  new User(FirstName='Test', LastName='User 3' , Alias='Al2' , 
	                                                           Email='Test2@testmail.com',Username='test2@testsmail.com',
	                                                           CommunityNickname='usr2',Integration_ID__c='test IntegrationId 2',
	                                                           EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',
	                                                           LocaleSidKey='en_US', ProfileId = objProfile.Id,
	                                                           TimeZoneSidKey='America/Los_Angeles',isActive=true),
	                                                  new User(FirstName='Test', LastName='User 2' , Alias='Al3' , 
	                                                           Email='Test3@testmail.com',Username='test3@testsmail.com',
	                                                           CommunityNickname='usr3',Integration_ID__c='test IntegrationId 3',
	                                                           EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',
	                                                           LocaleSidKey='en_US', ProfileId = objProfile.Id,
	                                                           TimeZoneSidKey='America/Los_Angeles',isActive=false)           
	                        
	    };
	    insert lstUsersToInsert;
	    SL_SalesOrdersHandler__c objSetting = new SL_SalesOrdersHandler__c(Name='Sl_SalesOrderInactiveOwner' , InActive_User__c=lstUsersToInsert[2].Id);
	    insert objSetting;
	    
	    Sales_Orders__c objSalesOrder = new Sales_Orders__c(IntegrationID__c = 'test IntegrationId 1'); 
	    
	    Test.startTest();
	        
	        insert objSalesOrder;
	        system.assertEquals(lstUsersToInsert[0].Id , [Select OwnerId from Sales_Orders__c where Id =: objSalesOrder.Id].OwnerId);
	        //objSalesOrder.IntegrationID__c = 'test IntegrationId 3';
	        //update objSalesOrder;
	        
	    Test.stopTest();  
	}

}