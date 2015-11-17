/**
* \arg \b ClassName      : SL_ContactAddressAssociationHandler
* \arg \b JIRATicket     : SEGAL-6
* \arg \b CreatedOn      : 1/19/2015
*/

public with sharing class SL_ContactAddressAssociationHandler 
{
	//Constructor
	public SL_ContactAddressAssociationHandler()
	{
		// do nothing      
	}
	
	// Method called on After insert of Contact_Address__c record
	public void onAfterInsert(map<Id,Contact_Address__c> mapNewContactAddresses)
	{
		// Method called to ensure there is only primary contact address associated with contact
		updateContactMailingAddrWithPrimaryContactAddress(null,mapNewContactAddresses,'isInsert');
	}
	
	// Method called on after update of Contact_Address__c record
	public void onAfterUpdate(map<Id,Contact_Address__c> mapOldContactAddresses,map<Id,Contact_Address__c> mapNewContactAddresses)
	{
		// Method called to ensure there is only primary contact address associated with contact and if user updates address field for Contact Address record which was primary then update contact mailing address with newly updated address value.
		updateContactMailingAddrWithPrimaryContactAddress(mapOldContactAddresses,mapNewContactAddresses,'isUpdate');
	}
	
	// Method called on after delete of Contact_Address__c record
	public void onAfterDelete(map<Id,Contact_Address__c> mapOldContactAddresses)
	{
		// Method called to update contact Mailing address to blank when primary contact address association record is deleted.
		updateContactMailingAddrToBlank(mapOldContactAddresses);
	}
	
	// Method used to ensure there is only primary contact address associated with contact and if user updates address field for Contact Address record which was primary then update contact mailing address with newly updated address value.
	private void updateContactMailingAddrWithPrimaryContactAddress(map<Id,Contact_Address__c> mapOldContactAddresses,map<Id,Contact_Address__c> mapNewContactAddresses,String strEvent)
	{
		map<Id,String> mapContactIdToLatestContactAddr = new map<Id,String>();
		set<Id> setUpdatedPrimaryAddrIds = new set<Id>();
		map<Id,String> mapAccountIdToName = new map<Id,String>();
		
		// Iterating through newly inserted or updated Contact Addresses.
		for(Contact_Address__c objConAddr : mapNewContactAddresses.values())
		{
			// Filtering the records based on insert or update case
			if((strEvent == 'isInsert' && objConAddr.Default_Contact_Address__c) || (strEvent == 'isUpdate' && ((objConAddr.Default_Contact_Address__c != mapOldContactAddresses.get(objConAddr.Id).Default_Contact_Address__c) || (objConAddr.Default_Contact_Address__c && objConAddr.Address__c != mapOldContactAddresses.get(objConAddr.Id).Address__c)
																					 )))
			{
				// Collecting the latest Contact Address for contact if there are more than Contact Address which was primary.
				if(!mapContactIdToLatestContactAddr.containskey(objConAddr.Contact__c))
					mapContactIdToLatestContactAddr.put(objConAddr.Contact__c,objConAddr.Name);
					
				else if(objConAddr.Name > mapContactIdToLatestContactAddr.get(objConAddr.Contact__c))
				{
					mapContactIdToLatestContactAddr.put(objConAddr.Contact__c,objConAddr.Name);
				}	
			}
			
			if(objConAddr.Address__c != null)
				setUpdatedPrimaryAddrIds.add(objConAddr.Address__c);
		}	
		
		// Used to query accounts for updated addresses to map with contact Default Address entity field.
		for( Address__c objAddress : [Select Id,Entity__c,Entity__r.Id,Entity__r.Name from Address__c where Entity__c != null AND Id IN:setUpdatedPrimaryAddrIds] )
		{
			mapAccountIdToName.put(objAddress.Entity__c,objAddress.Entity__r.Name);
		}
		
		if(!mapContactIdToLatestContactAddr.isEmpty())
		{
			list<Contact_Address__c> lstContactAddressesToUpdateDefaultConAddr = new list<Contact_Address__c>();
			list<Contact> lstContactsToUpdateMailingAddress = new list<Contact>();
			
	    	// Querying Contact Address records	to update Default_Contact_Address__c to false													   		  
			for( Contact_Address__c objContactAddr : [Select Name,Default_Contact_Address__c,Contact__c 
													  from Contact_Address__c 
													  where Name Not IN:mapContactIdToLatestContactAddr.values() AND Contact__c IN:mapContactIdToLatestContactAddr.keySet()])
			{
				Contact_Address__c objContactAddress = new Contact_Address__c(Id = objContactAddr.Id,Default_Contact_Address__c = false);
				lstContactAddressesToUpdateDefaultConAddr.add(objContactAddress);
			}		
			
			if(strEvent == 'isUpdate')
			{
				// Querying the Default_Contact_Address__c for contacts and updating Contact Mailing address with its Default_Contact_Address__c. 
				for(Contact_Address__c objContactAddr : [Select Name,Address__c,Address__r.Entity__c,Address__r.Address_Fax__c,Address__r.Address_Phone__c,Contact_Address_1__c,Contact_Address_2__c,Contact_Address_3__c,Contact_Combined_Address__c,Default_Contact_Address__c,Contact__c,Contact_City__c,Contact_Country__c,Contact_State__c,Contact_Zipcode__c
														 from Contact_Address__c
														 where Name IN:mapContactIdToLatestContactAddr.values() ])
	            {
	            	Contact objContact;
	            	
	            	// Updating Contact Mailing Address with its Default_Contact_Address__c
	            	if(objContactAddr.Default_Contact_Address__c)
	            	{
	            		String strCombinedContactMailingStreet = '' ;
	            		strCombinedContactMailingStreet = objContactAddr.Contact_Address_1__c != null ? objContactAddr.Contact_Address_1__c : '' + ' ' + objContactAddr.Contact_Address_2__c != null ? objContactAddr.Contact_Address_2__c : '' + ' ' + objContactAddr.Contact_Address_3__c != null ? objContactAddr.Contact_Address_3__c : '' ;
	            		
	            		objContact = new Contact(Id=objContactAddr.Contact__c,MailingStreet = strCombinedContactMailingStreet,MailingCity = objContactAddr.Contact_City__c,
	            								 MailingState = objContactAddr.Contact_State__c,MailingCountry = objContactAddr.Contact_Country__c,
	            								 MailingPostalCode = objContactAddr.Contact_Zipcode__c,Fax = objContactAddr.Address__r.Address_Fax__c,Main_Phone1__c = objContactAddr.Address__r.Address_Phone__c,
	            								 Default_Address_Entity__c = objContactAddr.Address__r.Entity__c);
	            								 
	            		if(mapAccountIdToName.containsKey(objContactAddr.Address__r.Entity__c))    							 
	        				objContact.Default_Address_Entity__c = mapAccountIdToName.get(objContactAddr.Address__r.Entity__c);						 
	            	}	
	            	// Updating contact Mailing address to blank if there is no Primary Default_Contact_Address__c for contact.
	            	else
	            	{
	            		objContact = new Contact(Id=objContactAddr.Contact__c,MailingStreet = null,MailingCity = null,
	            								  MailingState = null,MailingCountry = null,
	            							      MailingPostalCode = null,Fax = null,Main_Phone1__c = null,Default_Address_Entity__c =null);
	            	}	
	            	lstContactsToUpdateMailingAddress.add(objContact);								 
	            }					
	            
	            // Updating Contacts Mailing Address
				if(!lstContactsToUpdateMailingAddress.isEmpty())	
					Database.update(lstContactsToUpdateMailingAddress,false);
			}
			// Updating Contact_Address Default_Contact_Address__c
			if(!lstContactAddressesToUpdateDefaultConAddr.isEmpty())
				Database.update(lstContactAddressesToUpdateDefaultConAddr,false);
		}	
	}
	
	// Method used to update contact Mailing address to blank when primary contact address association record for contact is deleted.
	private void updateContactMailingAddrToBlank(map<Id,Contact_Address__c> mapOldContactAddresses)
	{
		map<Id,Contact> mapContactIdToContact = new map<Id,Contact>();
		
		// Iterating through deleted Contact Address Associations
		for(Contact_Address__c objConAddr : mapOldContactAddresses.values())	
		{
			// Checking if the deleted Contact Address is primary or not
			if(objConAddr.Default_Contact_Address__c)
			{
				// Updating Deleted 'Contact Address' parent Contacts Mailing Address to blank
				Contact objContact = new Contact(Id = mapOldContactAddresses.get(objConAddr.Id).Contact__c,MailingStreet = null,MailingCity = null,
	            								 MailingState = null,MailingCountry = null,
	            							 	 MailingPostalCode = null,Fax=null,Main_Phone1__c = null,Default_Address_Entity__c =null);
	        
	        	mapContactIdToContact.put(objContact.Id,objContact);
			}
		}	
		
		// Updating Contacts Mailing Address
		if(!mapContactIdToContact.isEmpty())	
			Database.update(mapContactIdToContact.values(),false);
	}
}