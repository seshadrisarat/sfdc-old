/*
*Class: SL_Test_Account_To_Address
*Description: This test class is used to check the functionality of SL_Account_To_Address class and its code coverage
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@isTest
private class SL_Test_Account_To_Address {

    static testMethod void myUnitTest() 
    {
        MapSettings__c ms = new MapSettings__c(BatchSize__c = 100, Endpoint__c = 'test', Key__c = 'test');
        insert ms;
        Test.setMock(HttpCalloutMock.class, new SL_Test_Response_Mapquest());
        Account objAccount = new Account(Name = 'Test Account', ShippingCity = 'New York City', ShippingState = 'NY', ShippingCountry = 'USA', ShippingPostalCode = '10012', ShippingStreet = '648 Broadway');
        insert objAccount;
        
        Account objAccount01 = new Account(Name = 'Test Account-01', Geocoding_Required__c = false,Location__Latitude__s = -73.837044, Location__Longitude__s = 40.948051,
										 ShippingStreet = 'Test Street', ShippingCity = 'NY', ShippingState = 'DC', ShippingPostalCode = 'PN123');
		insert objAccount01;
        
        List<String> lstAccount = new List<String>{objAccount.id};
        SL_Account_To_Address.ConvertToAddress(lstAccount, false);
        
        List<String> lstAccount01 = new List<String>{objAccount01.id};
        SL_Account_To_Address.ConvertToAddress(lstAccount01, true);
    }
}