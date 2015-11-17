/**
*  ClassName   	  : SL_AddressHandler
*  JIRATicket     : SEGAL-6
*  CreatedOn      : 20/JAN/2015
*  ModifiedBy     : Pradeep
*  Description    : This is the trigger on Address object to ensure If an Address is changed, all Contacts that have that Address as their Primary address should be updated.
*/

public without sharing class SL_AddressHandler 
{
	//Constructor
	public SL_AddressHandler()
	{
		// do nothing      
	}
	
	// Method called on after update of Address__c record
	public void onAfterInsert(map<Id,Address__c> mapNewAddresses)
	{
		// Method called to create Contact Address Associations for address records with 'Contact Address' recordtype.
		createContactAddressAssociations(mapNewAddresses);
	}
	
	// Method called on after update of Address__c record
	public void onAfterUpdate(map<Id,Address__c> mapOldAddresses,map<Id,Address__c> mapNewAddresses)
	{
		// Method called to update Contact Mailing Address when the primary address for contact is updated
		updateContactMailingAddress(mapOldAddresses,mapNewAddresses);
	}
	
	// Method called on before Delete of Address__c record
	public void onBeforeDelete(map<Id,Address__c> mapOldAddresses)
	{
		// Method called to update Contact Mailing Address to blank when the primary address for contact is deleted
		updateContactMailingAddressToBlank(mapOldAddresses);
	}
	
	// Method used to create Contact Address Associations for address records with 'Contact Address' recordtype.
	private void createContactAddressAssociations(map<Id,Address__c> mapNewAddresses)
	{
		String Contact_Address_RECORDTYPE_ID = [Select Id From RecordType Where SobjectType='Address__c' AND DeveloperName = 'Contact_Address'].Id;
		list<Contact_Address__c> lstContactAddressesAsscToCreateForAddr = new list<Contact_Address__c>(); 
		
		// Iterating through newly inserted addresses
		for(Address__c objAddress : mapNewAddresses.values())
		{
			// Checking for Contact Address RecordType
			if(objAddress.RecordTypeId == Contact_Address_RECORDTYPE_ID && objAddress.Contact__c != null)
			{
				// Creating contact address association for address
				Contact_Address__c objCAToCreate = new Contact_Address__c(Address__c = objAddress.Id,Contact__c = objAddress.Contact__c);
				lstContactAddressesAsscToCreateForAddr.add(objCAToCreate);
			}
		}
		// Inserting Contact Address Associations
		if(!lstContactAddressesAsscToCreateForAddr.isEmpty())
			Database.insert(lstContactAddressesAsscToCreateForAddr,false);
	}
	
	// Method used to update Contact Mailing Address when the primary address for contact is updated
	private void updateContactMailingAddress(map<Id,Address__c> mapOldAddresses,map<Id,Address__c> mapNewAddresses)
	{
		set<Id> setUpdatedAddressIds = new set<Id>(); // Set used to store updated address Ids
		set<Id> setAccountIdsForUpdatedAddresses = new set<Id>();
		map<Id,Contact> mapContactIdToContact = new map<Id,Contact>();
		map<Id,Account> mapAccountIdToAccount = new map<Id,Account>();
		
		//Filtering address records whose address is updated.
		for(Address__c objAddress : mapNewAddresses.values())
		{
			if(objAddress.Address_1__c != mapOldAddresses.get(objAddress.Id).Address_1__c || objAddress.Address_2__c != mapOldAddresses.get(objAddress.Id).Address_2__c ||
			   objAddress.Address_3__c != mapOldAddresses.get(objAddress.Id).Address_3__c || objAddress.City__c	 != mapOldAddresses.get(objAddress.Id).City__c	 ||
			   objAddress.Country__c != mapOldAddresses.get(objAddress.Id).Country__c || objAddress.State__c != mapOldAddresses.get(objAddress.Id).State__c ||
			   objAddress.Zipcode__c != mapOldAddresses.get(objAddress.Id).Zipcode__c || objAddress.Address_Fax__c != mapOldAddresses.get(objAddress.Id).Address_Fax__c || objAddress.Address_Phone__c != mapOldAddresses.get(objAddress.Id).Address_Phone__c)
			{
				setUpdatedAddressIds.add(objAddress.Id);
				
				if(objAddress.Entity__c != null)
					setAccountIdsForUpdatedAddresses.add(objAddress.Entity__c);
			}   
		}
		
		// Used to query accounts for updated addresses to map with contact Default Address entity field.
		if(!setAccountIdsForUpdatedAddresses.isEmpty())
			mapAccountIdToAccount = new map<Id,Account>([Select Id,Name from Account where Id IN:setAccountIdsForUpdatedAddresses]);
			
		// Querying all the Contact Address records having updated address as their primary address.
		for( Contact_Address__c objContactAddress : [Select Address__c,Address__r.Entity__c,Address__r.Address_Fax__c,Address__r.Address_Phone__c,Contact__c,Default_Contact_Address__c,Contact_City__c,Contact_Combined_Address__c,Contact_Country__c,Contact_State__c,Contact_Zipcode__c
													 from Contact_Address__c
													 where Default_Contact_Address__c = true and Address__c IN:setUpdatedAddressIds order by LastModifiedDate ASC])
		{
			// Updating Contacts Mailing Address with their primary address
			Contact objContact = new Contact(Id = objContactAddress.Contact__c,MailingStreet = objContactAddress.Contact_Combined_Address__c,MailingCity = objContactAddress.Contact_City__c,
	            							 MailingState = objContactAddress.Contact_State__c,MailingCountry = objContactAddress.Contact_Country__c,
	            							 MailingPostalCode = objContactAddress.Contact_Zipcode__c,Fax = objContactAddress.Address__r.Address_Fax__c,Main_Phone1__c =objContactAddress.Address__r.Address_Phone__c
	            							 );
	        if(mapAccountIdToAccount.containsKey(objContactAddress.Address__r.Entity__c))    							 
	        	objContact.Default_Address_Entity__c = mapAccountIdToAccount.get(objContactAddress.Address__r.Entity__c).Name;    							 
	        
	        mapContactIdToContact.put(objContact.Id,objContact);
		}											 
		
		// Updating Contacts Mailing Address
		if(!mapContactIdToContact.isEmpty())	
			Database.update(mapContactIdToContact.values(),false);
	}
	
	// Method used to update Contact Mailing Address to blank when the primary address for contact is deleted..
	private void updateContactMailingAddressToBlank(map<Id,Address__c> mapOldAddresses)
	{
		map<Id,Contact> mapContactIdToContact = new map<Id,Contact>();
		
		// Querying all the Contact Address records having deleted address as their primary address.
		for( Contact_Address__c objContactAddress : [Select Address__c,Contact__c,Default_Contact_Address__c,Contact_City__c,Contact_Combined_Address__c,Contact_Country__c,Contact_State__c,Contact_Zipcode__c
													 from Contact_Address__c
													 where Default_Contact_Address__c = true and Address__c IN:mapOldAddresses.keySet()])
		{
			// Updating Contacts Mailing Address to blank
			Contact objContact = new Contact(Id = objContactAddress.Contact__c,MailingStreet = null,MailingCity = null,
	            							 MailingState = null,MailingCountry = null,
	            							 MailingPostalCode = null,Fax = null,Main_Phone1__c = null,Default_Address_Entity__c = null);
	        
	        mapContactIdToContact.put(objContact.Id,objContact);
		}	
		
		// Updating Contacts Mailing Address
		if(!mapContactIdToContact.isEmpty())	
			Database.update(mapContactIdToContact.values(),false);
	}
}