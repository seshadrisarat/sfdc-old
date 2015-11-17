/*
*Class: SL_Batch_UpdateProviderAccountAddress
*Description: This is the batch class for updating both Contact's and Account's address fields from the Provider_Address__c and Organization_Address__c records respectively.
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/

global without sharing class SL_Batch_UpdateProviderAccountAddress implements Database.Batchable<sObject>
{
	/* Start - Variables */
	global final String Query;
	/* End - Variables */
	
	/* Start - Constructor */
	global SL_Batch_UpdateProviderAccountAddress(String q)
	{
		Query=q;
	}
	/* End - Constructor */
	
	 /*
        @MethodName: start 
        @param : Database.BatchableContext BC
        @Description: It is overriden method of Database.Batchable interface.
    */
	global Database.QueryLocator start(Database.BatchableContext bc) 
	{
	    //Return QueryLocator to execute method
	    return Database.getQueryLocator(query);
	}
	
	 /*
        @MethodName: execute 
        @param : Database.BatchableContext BC and list of sobject records
        @Description: It is overriden method of Database.Batchable interface.
    */
	global void execute(Database.BatchableContext BC,List<SObject> lstSObject)
	{
		List<Contact> lstContact = new List<Contact>();//list of contact records that needs to be updated
		List<Account> lstAccount = new List<Account>();//list of account records that needs to be updated
		
		Map<Id,Map<String,Provider_Address__c>> mapProviderIdToProviderAddress = new Map<Id,Map<String,Provider_Address__c>>();//map of provider id to its corresponding latest addresses
		Map<Id,Map<String,Organization_Address__c>> mapOrganizationIdToOrganizationAddress = new Map<Id,Map<String,Organization_Address__c>>();// map of organization id to its corresponding latest addresses
		
		List<Provider_Address__c> lstProviderAddress = new List<Provider_Address__c>();//Set of provider addresses to be updated
		List<Organization_Address__c> lstOrganizationAddress = new List<Organization_Address__c>();//Set of provider addresses to be updated
		
		//Iterating over list of sobjects to fill map with provider Id and its corresponding addresses
		for(Sobject objSObject : lstSObject)
		{
			//if sobject is Provider_Address__c
			if(objSObject.getSObjectType() == Provider_Address__c.Sobjecttype)
			{
				//typecast sobject to Provider_Address__c
				Provider_Address__c objProviderAddress = (Provider_Address__c)objSObject;
				lstProviderAddress.add(objProviderAddress);
				//Checking if map contains key or not
				if(!mapProviderIdToProviderAddress.containskey(objProviderAddress.Provider__c))
					//putting the first value in map if map is empty
					mapProviderIdToProviderAddress.put(objProviderAddress.Provider__c, new Map<String,Provider_Address__c>{objProviderAddress.Type__c=>objProviderAddress});
				else
					//overridding the map values with latest provider address records
					mapProviderIdToProviderAddress.get(objProviderAddress.Provider__c).put(objProviderAddress.Type__c,objProviderAddress);
			}
			//If sobject is Organization_Address__c
			else if(objSObject.getSObjectType() == Organization_Address__c.Sobjecttype)
			{
				//typecast sobject to Organization_Address__c
				Organization_Address__c objOrganizationAddress = (Organization_Address__c)objSObject;
				lstOrganizationAddress.add(objOrganizationAddress);
				//Checking if map contains key or not
				if(!mapOrganizationIdToOrganizationAddress.containskey(objOrganizationAddress.Organization__c))
					//putting the first value in map if map is empty
					mapOrganizationIdToOrganizationAddress.put(objOrganizationAddress.Organization__c, new Map<String,Organization_Address__c>{objOrganizationAddress.Type__c=>objOrganizationAddress});
				else
					//overridding the map values with latest provider address records
					mapOrganizationIdToOrganizationAddress.get(objOrganizationAddress.Organization__c).put(objOrganizationAddress.Type__c,objOrganizationAddress);
			}
		}
		//Iterating over Provider addresses to update the Contact records
		for(Provider_Address__c objProviderAddress : lstProviderAddress)
		{
			//Checking if provider map contains key or not
			if(mapProviderIdToProviderAddress.containskey(objProviderAddress.Provider__c))
			{
				if(mapProviderIdToProviderAddress.get(objProviderAddress.Provider__c).get(objProviderAddress.Type__c)!=objProviderAddress)
					objProviderAddress.Primary__c = false;//Setting all previous values to non primary
			}
		}
		
		//Iterating over Organization addresses to update the Account records
		for(Organization_Address__c objOrganizationAddress : lstOrganizationAddress)
		{
			//Checking if organization map contains key or not
			if(mapOrganizationIdToOrganizationAddress.containskey(objOrganizationAddress.Organization__c))
			{
				if(mapOrganizationIdToOrganizationAddress.get(objOrganizationAddress.Organization__c).get(objOrganizationAddress.Type__c)!=objOrganizationAddress)
					objOrganizationAddress.Primary__c = false;//Setting all previous values to non primary
			}
		}
		
		//Iterating over organization map keyset to update the organization's addresses
		for(Id OrganizationId : mapOrganizationIdToOrganizationAddress.keyset())
		{
			Account objAccount = new Account(Id = OrganizationId);//Initializing Account object.
			for(Organization_Address__c objOrganizationAddress : mapOrganizationIdToOrganizationAddress.get(OrganizationId).values())
			{
				//Checking if address type is Practice
				if(objOrganizationAddress.Type__c == 'Practice')
				{
													//Calling function to concatenate the street 2 and 3 with street 1
				   	   objAccount.ShippingStreet = concatenateAddress(objOrganizationAddress.Street_Address_1__c, objOrganizationAddress.Street_Address_2__c, objOrganizationAddress.Street_Address_3__c);
				       objAccount.ShippingCity = objOrganizationAddress.City__c;
				       objAccount.ShippingState = objOrganizationAddress.State__c;
				       objAccount.ShippingPostalCode = objOrganizationAddress.Postal_Code__c;
				       objAccount.ShippingCountry = objOrganizationAddress.County__c;
				       objAccount.Geocoding_Required__c = true;
				}
				//Checking if address type is Billing
				else if(objOrganizationAddress.Type__c == 'Billing')
				{
												  //Calling function to concatenate the street 2 and 3 with street 1
				       objAccount.BillingStreet = concatenateAddress(objOrganizationAddress.Street_Address_1__c, objOrganizationAddress.Street_Address_2__c, objOrganizationAddress.Street_Address_3__c);
				       objAccount.BillingCity = objOrganizationAddress.City__c;
				       objAccount.BillingState = objOrganizationAddress.State__c;
				       objAccount.BillingPostalCode = objOrganizationAddress.Postal_Code__c;
				       objAccount.BillingCountry = objOrganizationAddress.County__c;
				}
			}
			lstAccount.add(objAccount);
		}
		
		//Iterating over provider map keyset to update the provider addresses
		for(Id ProviderId : mapProviderIdToProviderAddress.keyset())
		{
			Contact objContact = new Contact(Id = ProviderId);//Initializing Contact object
			for(Provider_Address__c objProviderAddress : mapProviderIdToProviderAddress.get(ProviderId).values())
			{
				//If address type if Practice
				if(objProviderAddress.Type__c == 'Practice')
				{
											   //Calling function to concatenate the street 2 and 3 with street 1
					  objContact.OtherStreet = concatenateAddress(objProviderAddress.Street_Address_1__c, objProviderAddress.Street_Address_2__c, objProviderAddress.Street_Address_3__c);
					  objContact.OtherCity = objProviderAddress.City__c;
					  objContact.OtherState = objProviderAddress.State__c;
					  objContact.OtherPostalCode = objProviderAddress.Postal_Code__c;
					  objContact.OtherCountry = objProviderAddress.Country__c;
					  objContact.Geocoding_Required__c = true;
				}
				//if address type is Mailing
				else if(objProviderAddress.Type__c == 'Mailing')
				{
												  //Calling function to concatenate the street 2 and 3 with street 1
					   objContact.MailingStreet = concatenateAddress(objProviderAddress.Street_Address_1__c, objProviderAddress.Street_Address_2__c, objProviderAddress.Street_Address_3__c);
					   objContact.MailingCity = objProviderAddress.City__c;
					   objContact.MailingState = objProviderAddress.State__c;
					   objContact.MailingPostalCode = objProviderAddress.Postal_Code__c;
					   objContact.MailingCountry = objProviderAddress.Country__c;
				}
			}
			lstContact.add(objContact);
		}
		//Performing update dml
		if(!lstProviderAddress.isEmpty())
			update lstProviderAddress;
		//Performing update dml	
		if(!lstOrganizationAddress.isEmpty())
			update lstOrganizationAddress;
		//Performing update dml	
		if(!lstAccount.isEmpty())
			update lstAccount;
		//Performing update dml	
		if(!lstContact.isEmpty())
			update lstContact;
	}
	
	 /*
        @MethodName: finish 
        @param : Database.BatchableContext BC
        @Description: It is overriden method of Database.Batchable interface.
    */
	global void finish(Database.BatchableContext BC)
    {
        //do nothing.
    }
    
    /*
      @Method Name : concatenateAddress
      @param : street address 1, 2 and 3
      @Description : To concatenate the addresses of street 2 and street 3 with street 1 if 2 and 3 are not blank
    */  
    private String concatenateAddress(String strStreetAddress1, String strStreetAddress2, String strStreetAddress3)
    {
    	if(strStreetAddress2!=null && strStreetAddress2!='')
    		strStreetAddress1+='\n'+strStreetAddress2;
    	if(strStreetAddress3!=null && strStreetAddress3!='')
    		strStreetAddress1+='\n'+strStreetAddress3;
    	
    	return strStreetAddress1;
    }
}