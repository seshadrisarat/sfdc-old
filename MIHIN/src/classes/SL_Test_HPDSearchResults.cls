/*
*Class: SL_Test_HPDSearchResults
*Description: This test class is used to test SL_HPD_SearchController class and its code coverage
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@isTest
private class SL_Test_HPDSearchResults {

    static testMethod void myUnitTest() 
    {
        Account objAccount = new Account(Name='Test Organization',
        								ShippingStreet='Broadway',
        								ShippingCity = 'New York City',
        								ShippingState = 'NY',
        								ShippingPostalCode = '10012');
        insert objAccount;
        
        Contact objContact = new Contact(FirstName = 'TestName',
        								LastName = 'TestProvider',
        								NPI__c = '000000',
        								AccountId = objAccount.Id);
        insert objContact;
        
        SL_DistanceParameters__c objDistanceParameters = new SL_DistanceParameters__c(Name=' Distance Parameters',
        																			   minValue__c = 0.0,
        																			   maxValue__c = 1000,
        																			   stepSize__c = 5);
        insert objDistanceParameters;
        
        MapSettings__c objMapSettings = new MapSettings__c(BatchSize__c=10,Endpoint__c='https://open.mapquestapi.com/geocoding/v1/batch?',
        												   Key__c='Fmjtd%7Cluubnuu7ng%2C2a%3Do5-9uy0hw');
        insert objMapSettings;
        SL_HPD_SearchController objSearchContoller = new SL_HPD_SearchController();
        objSearchContoller.strFirstName ='TestName';
        objSearchContoller.strOrgName = 'Test Organization';
        objSearchContoller.strStreet ='';
        objSearchContoller.strCity ='';
        objSearchContoller.strState = '';
        objSearchContoller.strZipCode ='';
		objSearchContoller.decWithinMilesOfLocation = 0.0;
        MapSettings__c ms = MapSettings__c.getInstance();
        objSearchContoller.searchOrganizationsAndProviders();
        objSearchContoller.redirectToLogin();
        objSearchContoller.firstOrganizationPage();
        objSearchContoller.lastOrganizationPage();
        objSearchContoller.prevOrganizationPage();
        objSearchContoller.nextOrganizationPage();
        objSearchContoller.firstProviderPage();
        objSearchContoller.lastProviderPage();
        objSearchContoller.nextProviderPage();
        objSearchContoller.prevProviderPage();
        objSearchContoller.getSortRecordProvide();
        objSearchContoller.getSortRecordOrganizer();
        objSearchContoller.clearAllInputs();
    }
}