/*
*Class: SL_Geocode_Batch_Scheduled
*Description: This batch class is used to update geolocation fields on both Account and Contact objects based upon Account's Shipping Address and Contact's Other Address
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
global class SL_Geocode_Batch_Scheduled implements Database.Batchable<sObject>, Database.AllowsCallouts
{
	global final String Query;
	global SL_Geocode_Batch_Scheduled(String q)
	{
		Query=q;
	}
	global Database.QueryLocator start(Database.BatchableContext bc) 
	{
	    return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC,List<SObject> scope)
	{
	    List<String> contacts = new List<String>();
	    List<String> lstAccountId = new List<String>();//List to hold Account ids.
	    for(SObject s : scope)
	    {
	        if(s.getSObjectType() == Contact.Sobjecttype)//if sobject is contact
	        {
	            Contact c = (Contact) s;
	            contacts.add(c.id);
	        }
	        else if(s.getSObjectType() == Account.Sobjecttype)//if sobject is account
	        {
	        	Account objAccount = (Account)s;
	        	lstAccountId.add(objAccount.Id);
	        }
	    }
	    if(!contacts.isEmpty() && contacts!=null)
	    	List<List<String>> latLng = SL_Contact_to_Address.ConvertToAddress(contacts, false);
		if(!lstAccountId.isEmpty() && lstAccountId!=null)
	    	List<List<String>> lstAccountCoordinates = SL_Account_To_Address.ConvertToAddress(lstAccountId, false);//Calling function to get coordinates
	}
	
	global void finish(Database.BatchableContext BC)
	{
		// do nothing	
	}
}