/**
* \arg ClassName      : SL_BusinessAddressHandler
* \arg JIRATicket     : OAKHILL-3
* \arg CreatedOn      : 01/SEP/2014
* \arg LastModifiedOn : 01/SEP/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Handler class for SL_BusinessAddress trigger.
*/
public with sharing class SL_BusinessAddressHandler 
{
	/* Start - Variables*/
	/* End - Variables*/
	
	/* Start - Constructor*/
	public SL_BusinessAddressHandler()
	{
		//do nothing.
	} 	
	/* End - Constructor*/
	
	/*
		@MethodName : onAfterInsert 
		@param 	    : List of Business_Address__c
		@Description: Method called when new Business_Address__c is inserted. 
	*/
	public void onAfterInsert(List<Business_Address__c> lstBusinessAddress)
	{
		Map<Id, Business_Address__c> mapOrgIdToBusinessAddressFiltered = new Map<Id, Business_Address__c>();//Map organization id to Id, Business_Address__c filtered.
		
		//Iterate on Business_Address__c for checking the primary field for putting the filtered values in the map.
		for(Business_Address__c objBA : lstBusinessAddress)
		{
			if(objBA.Primary_Address__c == true)
				mapOrgIdToBusinessAddressFiltered.put(objBA.Organization__c, objBA);
		}
		if(!mapOrgIdToBusinessAddressFiltered.isEmpty())
			UpdateAccountBusinessAddress(mapOrgIdToBusinessAddressFiltered);               
 	}
	/* End */
	
	/*
		@MethodName : onAfterUpdate 
		@param 	    : Old and new map of Business_Address__c
		@Description: Method called when Business_Address__c is updated. 
	*/
	public void onAfterUpdate(Map<Id, Business_Address__c> mapIdToBusinessAddressOld, List<Business_Address__c> lstBusinessAddressNew)
	{
		Map<Id, Business_Address__c> mapOrgIdToBusinessAddressFiltered = new Map<Id, Business_Address__c>();//Map organization id to Id, Business_Address__c filtered.
		
		//Iterating on Business_Address__c for taking the Business_Address__c id into set  
		for(Business_Address__c objBA : lstBusinessAddressNew)
		{
			if((objBA.Primary_Address__c == true && (objBA.City__c != mapIdToBusinessAddressOld.get(objBA.Id).City__c
			   || objBA.Country__c != mapIdToBusinessAddressOld.get(objBA.Id).Country__c
			   || objBA.State_Province__c != mapIdToBusinessAddressOld.get(objBA.Id).State_Province__c
			   || objBA.Street__c != mapIdToBusinessAddressOld.get(objBA.Id).Street__c
			   || objBA.Zip_Postal_Code__c != mapIdToBusinessAddressOld.get(objBA.Id).Zip_Postal_Code__c)) || objBA.Primary_Address__c == true)
			{
				mapOrgIdToBusinessAddressFiltered.put(objBA.Organization__c, objBA);
			}			   
		}
		if(!mapOrgIdToBusinessAddressFiltered.isEmpty())
			UpdateAccountBusinessAddress(mapOrgIdToBusinessAddressFiltered);
	}
	/* End */
	
	/*
		@MethodName : onAfterInsert 
		@param 	    : List of Business_Address__c
		@Description: Method called when new Business_Address__c is inserted. 
	*/
	public void onBeforeDelete(List<Business_Address__c> lstBusinessAddress)
	{
		//Iterating on Business_Address__c for checking the primary field if true then message will display.
		for(Business_Address__c objBA : lstBusinessAddress)
		{
			if(objBA.Primary_Address__c == true)
				objBA.addError(Label.OnDeletePrimaryAddress);
		}
	}
	/* End */
	
	/*
		@MethodName : UpdateAccountBusinessAddress 
		@param 	    : Map of Organization id to Business_Address__c.
		@Description: Method called when new Business_Address__c is inserted or updated. 
	*/
	private void UpdateAccountBusinessAddress(Map<Id, Business_Address__c> mapOrgIdToBusinessAddress)
	{
		List<Account> lstAccount = new List<Account>();//List of Organization to update.
		List<Business_Address__c> lstBusinessAddressToUpdate = new List<Business_Address__c>();//List of Business_Address__c to update the primary address field.
		Set<Id> setBusinessAddressId = new Set<Id>();//Set of Business_Address__c Id.
		
		//Iterate on organization to update the primary address.
		for(Id accountId : mapOrgIdToBusinessAddress.keySet())
		{
			// Commented temporarily for getting deployed in production as well as activating the Country/State Picklists feature in production
			
			lstAccount.add(new Account(Id = accountId,
									   BillingStreet = mapOrgIdToBusinessAddress.get(accountId).Street__c,
									   BillingState = mapOrgIdToBusinessAddress.get(accountId).State_Province__c,
									   BillingPostalCode = mapOrgIdToBusinessAddress.get(accountId).Zip_Postal_Code__c,
									   BillingCity = mapOrgIdToBusinessAddress.get(accountId).City__c,
									   BillingCountry = mapOrgIdToBusinessAddress.get(accountId).Country__c));
			setBusinessAddressId.add(mapOrgIdToBusinessAddress.get(accountId).Id);						   
		}
		if(!lstAccount.isEmpty())
			update lstAccount;
		
		//Iterating on Business_Address__c to updaate the primary address field to false.
		for(Business_Address__c objBA : [SELECT Id,
												Primary_Address__c
										   FROM	Business_Address__c
										  WHERE Organization__c IN : mapOrgIdToBusinessAddress.keySet() 
										    AND Id NOT IN : setBusinessAddressId])
		{
			lstBusinessAddressToUpdate.add(new Business_Address__c(Id = objBA.Id,
																   Primary_Address__c = false));
		}
		if(!lstBusinessAddressToUpdate.isEmpty())										    
			update lstBusinessAddressToUpdate;								    
	}
	/* End */
}