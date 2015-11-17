/*
*Class: SL_Test_Contact_to_Address
*Description: This test class is used to check the functionality of SL_Contact_to_Address class and its code coverage
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@IsTest
private class SL_Test_Contact_to_Address
{    
    @IsTest
    private static void TestCtA()
    {
        List<Portal__c> lstPortalBranding = new List<Portal__c>{new Portal__c(Name = 'Test Portal', Portal_Id__c='000000000'),
																new Portal__c(Name = 'DEFAULT_PORTAL_UI', Portal_Id__c='10000000')};
		insert lstPortalBranding;
        
        List<Account> lstAccount = new List<Account>{new Account(Name = 'Test Account - 01'),
													 new Account (Name = 'Test Account - 02')};
		insert lstAccount;
        
        Organization_Portal__c objOrganizationPortal = new Organization_Portal__c(Organization__c = lstAccount[0].Id,
																				  Portal__c = lstPortalBranding[0].Id);
		insert objOrganizationPortal;
        
        SL_DefaultAddressForContactMap__c objDefaultAddressForContactMap = new SL_DefaultAddressForContactMap__c(Name = 'SL_DefaultAddress',
        																										Contact_Address__c = 'East Lansing, MI');
        insert objDefaultAddressForContactMap;
        
        MapSettings__c ms = new MapSettings__c(BatchSize__c = 100, Endpoint__c = 'test', Key__c = 'test');
        INSERT ms;
        Test.setMock(HttpCalloutMock.class, new SL_Test_Response_Mapquest());
        Contact c = new Contact(LastName = 'Schmoe', AccountId = lstAccount[0].Id, OtherCity = 'New York', OtherState = 'NY', OtherCountry = 'USA', OtherPostalCode = '10012', OtherStreet = '648 Broadway');
        INSERT c;
        
        Contact objContact = new Contact(LastName = 'Schmoe1', AccountId = lstAccount[0].Id, OtherCity = 'New York', OtherState = 'NY', OtherCountry = 'USA', OtherPostalCode = '10012', OtherStreet = '648 Broadway');
        insert objContact;
        
        Contact objContact1 = new Contact(LastName = 'Schmoe2', AccountId = lstAccount[0].Id);
        insert objContact1;
        
        Contact objContact2 = new Contact(LastName = 'Schmoe3', AccountId = lstAccount[0].Id, Location__Longitude__s=-83.245289,
        								  Location__Latitude__s = 42.501877, Geocoding_Required__c = false);
        insert objContact2;
        
        Contact objContact3 = new Contact(LastName = 'Schmoe1', AccountId = lstAccount[0].Id, OtherCity = 'New York', OtherState = 'NY', OtherCountry = 'USA', OtherPostalCode = '10012');
        insert objContact3;
        
        Contact objContact4 = new Contact(LastName = 'Schmoe1', AccountId = lstAccount[0].Id, OtherState = 'NY', OtherCountry = 'USA', OtherPostalCode = '78877');
        insert objContact4;
        
        Contact objContact5 = new Contact(LastName = 'Schmoe1', AccountId = lstAccount[0].Id, OtherCountry = 'USA', OtherPostalCode = '78877');
        insert objContact5;
        
        
        List<String> cons = new List<String>{c.id};
        SL_Contact_to_Address.ConvertToAddress(cons, false);
        
        List<String> lstContact = new List<String>{objContact.Id};
        SL_Contact_to_Address.ConvertToAddress(lstContact, true);
        
        List<String> lstContact1 = new List<String>{objContact1.Id};
        SL_Contact_to_Address.ConvertToAddress(lstContact1, true);
        
        List<String> lstContact2 = new List<String>{objContact2.Id};
        SL_Contact_to_Address.ConvertToAddress(lstContact2, true);
        
        List<String> lstContact3 = new List<String>{objContact3.Id};
        SL_Contact_to_Address.ConvertToAddress(lstContact3, true);
        
        List<String> lstContact4 = new List<String>{objContact4.Id};
        SL_Contact_to_Address.ConvertToAddress(lstContact4, true);
        
        List<String> lstContact5 = new List<String>{objContact5.Id};
        SL_Contact_to_Address.ConvertToAddress(lstContact5, true);
        
    }
}