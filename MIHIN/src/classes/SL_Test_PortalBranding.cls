/*
*Class: SL_Test_PortalBranding
*Description: This test class is used to test Portal Branding trigger functionality and its code coverage
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@isTest
private class SL_Test_PortalBranding 
{

    static testMethod void myUnitTest() 
    {
        List<Account> lstAccount = new List<Account>{new Account(Name = 'Test Account 1'),
        											 new Account(Name = 'Test Account 2')};
        insert lstAccount;        
        
        List<Portal__c> lstPortalBranding = new List<Portal__c>{new Portal__c(Name = 'Test Portal 1', Portal_Id__c='000000000',Website_URL__c='http://full-mihin.cs11.force.com/eTHIN'),
																new Portal__c(Name = 'Test Portal 2', Portal_Id__c='100000000',Website_URL__c='http://full-mihin.cs11.force.com'),
																new Portal__c(Name = 'DEFAULT_PORTAL_UI', Portal_Id__c='20000000',Website_URL__c='http://full-mihin.cs11.force.com')};
		insert lstPortalBranding;
		
		List<Organization_Portal__c> lstOrganizationPortal = new List<Organization_Portal__c>{new Organization_Portal__c(Organization__c = lstAccount[0].Id, Portal__c = lstPortalBranding[0].Id),
																							  new Organization_Portal__c(Organization__c = lstAccount[1].Id, Portal__c = lstPortalBranding[1].Id)};
		insert lstOrganizationPortal;
		
		List<Contact> lstContact = new List<Contact>{new Contact(LastName = 'Test Contact 1', AccountId = lstAccount[0].Id),
        											 new Contact(LastName = 'Test Contact 2', AccountId = lstAccount[1].Id)};
        insert lstContact;
        
        List<Portal__c> lstPortalBrandingToUpdate = new List<Portal__c>{new Portal__c(Id = lstPortalBranding[0].Id,Portal_Id__c = '500000000000000000',Website_URL__c='http://full-mihin.cs11.force.com')};
        update lstPortalBrandingToUpdate;
    }
}