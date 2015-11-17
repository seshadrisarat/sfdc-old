/*
*Class: SL_Test_ContactHandler
*Description: Test calss for Contact Trigger.
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@isTest
public with sharing class SL_Test_ContactHandler 
{
	@isTest
	private static void test_ContactHandler()
	{
		
		Profile validProf = [Select Name, Id From Profile where Name = 'HPD - Population Admin' LIMIT 1];
		
		User user1 = [Select ProfileId, Id From User where ProfileId =: validProf.Id LIMIT 1];
		
		List<Portal__c> lstPortalBranding = new List<Portal__c>{new Portal__c(Name = 'Test Portal', Portal_Id__c='000000000',Website_URL__c='http://full-mihin.cs11.force.com/eTHIN'),
																new Portal__c(Name = 'DEFAULT_PORTAL_UI', Portal_Id__c='10000000', Website_URL__c='http://full-mihin.cs11.force.com')};
		insert lstPortalBranding;
		
		List<Account> lstAccount = new List<Account>{new Account(Name = 'Test Account - 01'),
													 new Account (Name = 'Test Account - 02')};
		insert lstAccount;
		
		Organization_Portal__c objOrganizationPortal = new Organization_Portal__c(Organization__c = lstAccount[0].Id,
																				  Portal__c = lstPortalBranding[0].Id);
		
	 	insert objOrganizationPortal;
	 	
	 	Contact objContact = new Contact(LastName = 'Test Contact-01', AccountId = lstAccount[0].Id, 
	 									 OtherStreet = '3601 W 13 Mile Rd', OtherCity = 'Royal Oak', 
	 									 OtherState = 'MI', OtherPostalCode = '48073-6712', OtherCountry = 'US', NPI__c = '898392');
	 	insert objContact;
	 	
	 	System.assertEquals('NPI', [SELECT Type__c FROM Provider_Identifier__c WHERE Provider__c =:objContact.Id LIMIT 1].Type__c);
	 	System.assertEquals('NPI-898392', [SELECT Data_Source_ID__c FROM Provider_Identifier__c WHERE Provider__c =:objContact.Id LIMIT 1].Data_Source_ID__c);
	 	System.assertEquals('898392', [SELECT Name FROM Provider_Identifier__c WHERE Provider__c =:objContact.Id LIMIT 1].Name);
	 	
	 	objContact.OtherState = 'NY';
	 	objContact.OtherCountry = 'USA';
	 	objContact.AccountId = lstAccount[1].Id;
	 	update objContact;
	 	objContact.OtherCity = null;
	 	update objContact;
	 	System.assertEquals(objContact.Location__Latitude__s, null);
	 	System.assertEquals(objContact.Location__Longitude__s, null);
	 	objContact.OtherCity = 'US';
	 	update objContact;
	 	
	 	objContact.OwnerId = user1.Id;
	 	
	 	try {
        	update objContact;
        }
        
        catch (Exception e){
			
			system.debug('------- e -------' + e);
		
		}
	 	
	 	
	}
}