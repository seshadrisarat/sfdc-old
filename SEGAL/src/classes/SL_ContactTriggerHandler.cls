/**
*  ClassName   	  : SL_ContactTriggerHandler
*  JIRATicket     : SEGAL-11
*  CreatedOn      : 23/APR/2015
*  ModifiedBy     : Pradeep
*  Description    : Handler class for SL_ContactTrigger to ensure when user merges the contacts then the address which matches the Selected Mailing address in 'Select the values to retain' step should be selected as primary and all the remaining addresses for contact should be marked as unprimary.
*/

public with sharing class SL_ContactTriggerHandler 
{
	//Constructor
	public SL_ContactTriggerHandler()
	{
		// do nothing      
	}
	
	// Method called on after update of Contact record due to merge operation on contacts.
	public void onAfterUpdate(map<Id,Contact> mapNewContacts)
	{
		checkContactMailingAddressAsPrimary(mapNewContacts);
	}
	
	// Method used to check matching Contact Address with Contact MailingAddress as Primary and uncheck all the remaining Contact addresses for contact as unprimary.
	private void checkContactMailingAddressAsPrimary(Map<Id,Contact> mapNewContacts)
	{
		List<Contact_Address__c> lstContactAddressesForContactsToUpdate = new List<Contact_Address__c>(); // List of contact addresses to update.
		
		// Querying Contact Addresses for contact
		for(Contact_Address__c objConAddr : [Select Address__c,Contact_Combined_Address__c,Contact__r.MailingCountry,Contact__r.MailingState,Contact__r.MailingCity,Contact__r.MailingStreet,Contact__r.MailingPostalCode,Default_Contact_Address__c,Contact__c,Contact_Address_3__c,Contact_Address_2__c,Contact_Address_1__c,Contact_City__c,Contact_State__c,Contact_Country__c,Contact_Zipcode__c
									         from Contact_Address__c
										     where Contact__c IN:mapNewContacts.keySet()])
		{
	        //String strCombinedContactMailingStreet = objConAddr.Contact_Address_1__c != null ? objConAddr.Contact_Address_1__c : '' + ' ' + objConAddr.Contact_Address_2__c != null ? objConAddr.Contact_Address_2__c : '' + ' ' + objConAddr.Contact_Address_3__c != null ? objConAddr.Contact_Address_3__c : '' ;
	        
	        // Creating combination for contact Mailing address
	        String strContactAddrCombination = objConAddr.Contact_Combined_Address__c + '_' + objConAddr.Contact_City__c + '_' + objConAddr.Contact_State__c + '_' + objConAddr.Contact_Country__c + '_' + objConAddr.Contact_Zipcode__c;
	        String strContactMailingAddrComb = objConAddr.Contact__r.MailingStreet + '_' + objConAddr.Contact__r.MailingCity + '_' + objConAddr.Contact__r.MailingState + '_' + objConAddr.Contact__r.MailingCountry + '_' + objConAddr.Contact__r.MailingPostalCode;
	        
	        // Checking if Contact_Address__c matches with contact mailing address 
	        if(strContactAddrCombination.equals(strContactMailingAddrComb))
	        {
	        	objConAddr.Default_Contact_Address__c = true;
        		lstContactAddressesForContactsToUpdate.add(objConAddr);
	        }
	        // If Contact_Address__c does not matches with contact mailing address then updating Default_Contact_Address__c to false 
	        else
	        {
        		objConAddr.Default_Contact_Address__c = false;
        		lstContactAddressesForContactsToUpdate.add(objConAddr);
	        }	
		}		
		// Updating Contact Addresses for contacts
		if(!lstContactAddressesForContactsToUpdate.isEmpty())			
			Database.update(lstContactAddressesForContactsToUpdate,false);		
	}
}