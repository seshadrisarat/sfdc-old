/*
*Class: SL_PortalBrandinHandler
*Description: This is handler class for the Contact to update the Latitude, Longitude and Geocoding_Required__c fields on change of the other contact address.
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public with sharing class SL_PortalBrandinHandler 
{
	public SL_PortalBrandinHandler()
	{
		
	}
	
	public void onAfterUpdate(Map<Id,Portal__c> mapNewIdToPortalBranding, Map<Id,Portal__c> mapOldIdToPortalBranding)
	{
		Map<Id,String> mapOrganizationIdToPortalId = new Map<Id,String>();//map of organization id to portal id
		List<Contact> lstContact = new List<Contact>();// map of contacts to be updated
		
		//Iterating over organization portal object to create a map of organization id to portal id
		for(Organization_Portal__c objOrganizationPortal :[SELECT Organization__c,Portal__r.Portal_Id__c, Portal__r.Website_URL__c
														   FROM Organization_Portal__c 
														   WHERE Portal__c IN:  mapNewIdToPortalBranding.keyset()])
		{
			mapOrganizationIdToPortalId.put(objOrganizationPortal.Organization__c,objOrganizationPortal.Portal__r.Website_URL__c);
		}
		
		//Iterating over Contact object to update the contacts correspondig to the portal ids
		for(Contact objContact : [SELECT Portal_Id__c,AccountId, Portal_URL__c FROM Contact WHERE AccountId IN:mapOrganizationIdToPortalId.keyset()])
		{
			objContact.Portal_URL__c = mapOrganizationIdToPortalId.get(objContact.AccountId);
			lstContact.add(objContact);
		}
		
		if(lstContact!=null && !lstContact.isEmpty())
			update lstContact;//perform DML
	}
}