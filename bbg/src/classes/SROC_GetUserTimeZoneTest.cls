@isTest
private class SROC_GetUserTimeZoneTest {

    static testMethod void myUnitTest() 
    {
        Account objAccount= new Account(Name ='Account', ShippingCity  = 'Test');
        insert objAccount;
        ApexPages.StandardController sc = new ApexPages.StandardController(objAccount);
        SROC_GetUserTimeZone obj = new SROC_GetUserTimeZone(sc);
    }
}