/**
* \arg ClassName      : SL_ContactHandler
* \arg JIRATicket     : PWP-6
* \arg CreatedOn      : 8/DEC/2014
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This is the Handler class for SL_Contact Trigger.
*/
public without sharing class SL_ContactHandler 
{
	/**
	    @MethodName : onAfterUpdate
	    @Param 		: map<Id,Contact> mapNewContact, map<Id,Contact> mapOldContact 
	    @Description: This method called on after update of contact record.
    **/
	public void onAfterUpdate(map<Id,Contact> mapNewContact, map<Id,Contact> mapOldContact)
	{
		updateRelationshipRecords(mapNewContact,mapOldContact);//calling method to update the relationship records
	}
	
	/**
	    @MethodName : updateRelationshipRecords
	    @Param 		: map<Id,Contact> mapNewContact, map<Id,Contact> mapOldContact 
	    @Description: This method will be called from on after update event to update relationship records corresponding to previous accountid of contact
    **/
	void updateRelationshipRecords(map<Id,Contact> mapNewContact, map<Id,Contact> mapOldContact)
	{
		Set<Id> setPreviousAccount = new Set<Id>(); //set to hold the Old AccountId
		Set<Id> setUpdatedContact = new Set<Id>();//set to hold the updated contact ids
		List<Relationship__c> lstRelationshipToUpdate = new List<Relationship__c>();//List for update the Relationship record
		
		//iterate over the new Contact map 
		for(Contact objContact : mapNewContact.Values())
		{
			Contact objOldContact = mapOldContact.get(objContact.Id);
			//check wheather old Contact AccountId and New Contact AccountId equals or not
			if((objContact.AccountId != objOldContact.AccountId) && objContact.AccountId != null && objOldContact.AccountId != null)
			{				
				setPreviousAccount.add(objOldContact.AccountId);
				setUpdatedContact.add(objContact.Id);
			}
		}
		
		//query the Relationship records based on the Contact Id and Account Id
		for(Relationship__c objRelation : [SELECT Id, 
											External_Contact__r.AccountId, 
											Account__c FROM Relationship__c 
											WHERE External_Contact__c IN :setUpdatedContact AND 
											Account__c IN :setPreviousAccount])
		{
			//add to the list for update the Relationship records with new AccountId
			lstRelationshipToUpdate.add(new Relationship__c(Id = objRelation.Id,
															Account__c = objRelation.External_Contact__r.AccountId));
		}
		//check whether List empty or not and perform the update operation
		if(!lstRelationshipToUpdate.isEmpty())
			update lstRelationshipToUpdate;
	}
}