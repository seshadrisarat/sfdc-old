/**
* \arg \b ClassName        : SL_Batch_UpdateContact
* \arg \b JIRATicket       : SEGAL-7
* \arg \b CreatedOn        : 9/JUNE/2015
* \arg \b CreatedBy        : Pankaj Ganwani
* \arg \b Description      : This class serves as the one time batch process to update the Default Address Entity field value on existing Contact records.
*/
global class SL_Batch_UpdateContact implements Database.Batchable<Sobject>
{
	/* Start - Constructor */
	public SL_Batch_UpdateContact()
	{
		//Do Nothing
	}
	/* End - Constructor */
	
	//start method of batch process
	global Database.QueryLocator start(Database.BatchableContext bc)
	{
		return Database.getQueryLocator('SELECT Id, Name, Contact__c, Address__r.Entity__r.Name FROM Contact_Address__c WHERE Default_Contact_Address__c = true AND Address__r.Entity__c!=NULL ORDER BY LastModifiedDate, Name');
	}
	
	//execute method to process the sobject records passed by start method
	global void execute(Database.BatchableContext BC, List<Contact_Address__c> scope)
	{
		Map<Id,Contact> mapIdToContact = new Map<Id,Contact>();// map to hold the contact record which needs to be updated with most recent Contact Address record
		Map<Id, String> mapConIdToLatestContAddress = new Map<Id, String>();// map to hold the latest contact address name corresponding to the contact id
		List<Contact_Address__c> lstContactAddressToUpdate = new List<Contact_Address__c>();// list to hold contact address records except most recent default one corresponding to the contact record.
		
		//Iteration to update the contact record with its corresponding most recent contact address record.
		for(Contact_Address__c objContactAddress : scope)
		{			
			mapIdToContact.put(objContactAddress.Contact__c, new Contact(Id = objContactAddress.Contact__c, Default_Address_Entity__c = objContactAddress.Address__r.Entity__r.Name));
			mapConIdToLatestContAddress.put(objContactAddress.Contact__c,objContactAddress.Name);
		}
		
		//Iteration to set the Non default to all contact address records except most recent one
		for(Contact_Address__c objConAddress : [SELECT Id FROM Contact_Address__c WHERE Contact__c IN: mapConIdToLatestContAddress.keyset() AND Name NOT IN : mapConIdToLatestContAddress.values() AND Default_Contact_Address__c = true])
		{
			lstContactAddressToUpdate.add(new Contact_Address__c(Id = objConAddress.Id, Default_Contact_Address__c = false));
		}
		
		update mapIdToContact.values();
		update lstContactAddressToUpdate;
		
	}
	
	//final actions to be performed once the batch execution is completed
	global void finish(Database.BatchableContext BC)
	{
		//Do Nothing	
	}
	
}