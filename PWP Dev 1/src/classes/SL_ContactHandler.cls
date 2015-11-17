/**
* \arg ClassName      : SL_ContactHandler
* \arg JIRATicket     : PWP-6, PWP-169
* \arg CreatedOn      : 8/DEC/2014
* \arg LastModifiedOn : 20/AUG/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This is the Handler class for SL_Contact Trigger.
*/
public without sharing class SL_ContactHandler 
{
    private static final String implisitContactText = 'Contact created by Implisit™';// variable to hold the text which is used to identify whether the Contact has been created by Implisit or not.
    private static List<Relationship__c> lstRelationshipToDelete = new List<Relationship__c>();
    
    /**
	    @MethodName : onBeforeInsert
	    @Param 		: List<Contact> lstContact
	    @Description: This method called on before insert of contact record.
    **/
	public void onBeforeInsert(List<Contact> lstContact)
	{
		updateContactPhone(lstContact, null);
	}
	
	/**
	    @MethodName : onBeforeUpdate
	    @Param 		: List<Contact> lstContact
	    @Description: This method called on before update of contact record.
    **/
	public void onBeforeUpdate(List<Contact> lstContact, map<Id,Contact> mapOldContact)
	{
		updateContactPhone(lstContact, mapOldContact);
	}
	
	/**
	    @MethodName : onBeforeDelete
	    @Param 		: map of all those contacts that are going to be deleted.
	    @Description: This method calls collectRelationships method to hold the Relationship records related to the Contacts which are going to be deleted.
    **/
	public void onBeforeDelete(Map<Id, Contact> mapIdToContact)
	{
		collectRelationships(mapIdToContact.keyset());
	}
	
	/**
	    @MethodName : onAfterDelete
	    @Param 		: -
	    @Description: This method is calls deleteRelationships method which deletes all those relationship records that have been holded in static list. 
    **/
	public void onAfterDelete()
	{
		deleteRelationships();
	}
	
	/**
	    @MethodName : collectRelationships
	    @Param 		: Set of Contact Ids which are going to be deleted
	    @Description: This method is called by onBeforeDelete method to hold the relationship records corresponding to deleted contacts
    **/
	private void collectRelationships(Set<Id> setContactIds)
	{
		lstRelationshipToDelete.addAll([SELECT Id FROM Relationship__c WHERE External_Contact__c IN : setContactIds]);
	}
	
	/**
	    @MethodName : deleteRelationships
	    @Param 		: -
	    @Description: This method is called by onAfterDelete method and used to delete the Relationship records holded in static list.
    **/
	private void deleteRelationships()
	{
		delete lstRelationshipToDelete;
	}
	
	/**
	    @MethodName : updateContactPhone
	    @Param 		: List<Contact> lstContact
	    @Description: This method will format the contact phone number
    **/
	private void updateContactPhone(List<Contact> lstContact, map<Id,Contact> mapOldContact)
	{
	    List<SL_ContactPhoneFormat__c> lstContactPhoneFormat = SL_ContactPhoneFormat__c.getall().values();//get all values from custom setting

	    for(Contact objContact: lstContact)
	    {
	        if(!Trigger.isUpdate || (Trigger.isUpdate && (objContact.AssistantPhone != mapOldContact.get(objContact.Id).AssistantPhone || 
	                                                        objContact.Phone != mapOldContact.get(objContact.Id).Phone ||
	                                                        objContact.Fax != mapOldContact.get(objContact.Id).Fax ||
	                                                        objContact.HomePhone != mapOldContact.get(objContact.Id).HomePhone ||
	                                                        objContact.MobilePhone != mapOldContact.get(objContact.Id).MobilePhone ||
	                                                        objContact.OtherPhone != mapOldContact.get(objContact.Id).OtherPhone )))
	        {
	            for(SL_ContactPhoneFormat__c objContactPhoneFormat: lstContactPhoneFormat)
	            {
                    objContact.AssistantPhone = getFormattedPhoneNo(objContact.AssistantPhone, objContactPhoneFormat);
                    objContact.Phone = getFormattedPhoneNo(objContact.Phone, objContactPhoneFormat);
                    objContact.Fax = getFormattedPhoneNo(objContact.Fax, objContactPhoneFormat);
                    objContact.HomePhone = getFormattedPhoneNo(objContact.HomePhone, objContactPhoneFormat);
                    objContact.MobilePhone = getFormattedPhoneNo(objContact.MobilePhone, objContactPhoneFormat);
                    objContact.OtherPhone = getFormattedPhoneNo(objContact.OtherPhone, objContactPhoneFormat);
	            }
	        }
	    }
	}
	
	//This method will return the formatted phone number based on custom setting regex
	private String getFormattedPhoneNo(String strPhoneValue, SL_ContactPhoneFormat__c objContactPhoneFormat)
	{
	    if(String.isNotEmpty(strPhoneValue))
	    {
	        Pattern p = Pattern.compile(objContactPhoneFormat.MatchedRegEx__c);
    	    Matcher objMatchPhone = p.matcher(strPhoneValue);
    	    if(objMatchPhone.find())
                strPhoneValue = strPhoneValue.replaceAll(objContactPhoneFormat.MatchedRegEx__c, objContactPhoneFormat.replaceRegEx__c);
	    }
	    return strPhoneValue;
	}
	
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
	    @MethodName : onAfterInsert
	    @Param 		: list of inserted Contact records
	    @Description: This method will call createRelationships method to insert the relationship records corresponding to Implisit Contacts.
    **/
	public void onAfterInsert(List<Contact> lstContact)
	{
		createRelationships(lstContact);
	}
	
	/**
	    @MethodName : createRelationships
	    @Param 		: list of Contact records 
	    @Description: This method is used to create Relationship records based on those Contact records that are inserted via Implisit.
    **/
	void createRelationships(List<Contact> lstContact)
	{
		List<Relationship__c> lstRelationship = new List<Relationship__c>();		
		for(Contact objContact : lstContact)
		{
			if(String.isNotEmpty(objContact.Description) && objContact.Description.containsIgnoreCase(implisitContactText))
				lstRelationship.add(new Relationship__c(PWP_Employee__c = objContact.OwnerId, Source__c = 'Email', External_Contact__c = objContact.Id));
		}		
		insert lstRelationship;
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
		Set<Id> setContactIds = new Set<Id>();// set to hold those contact records whose owner has been changed.
		
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
			
			//Added by Pankaj Ganwani as per the requirement of PWP-169
			if(objContact.OwnerId!=objOldContact.OwnerId)
			{
				setContactIds.add(objContact.Id);
			}
		}
		//query the Relationship records based on the Contact Id and Account Id
		for(Relationship__c objRelation : [SELECT Id, 
											External_Contact__r.AccountId,
											External_Contact__r.OwnerId,
											External_Contact__c,
											Account__c FROM Relationship__c 
											WHERE (External_Contact__c IN :setUpdatedContact AND 
											Account__c IN :setPreviousAccount) OR External_Contact__c IN :setContactIds])
		{
			//add to the list for update the Relationship records with new AccountId
			if(setUpdatedContact.contains(objRelation.External_Contact__c) && setPreviousAccount.contains(objRelation.Account__c) && setContactIds.contains(objRelation.External_Contact__c))
			{
				objRelation.Account__c = objRelation.External_Contact__r.AccountId;
				objRelation.PWP_Employee__c = objRelation.External_Contact__r.OwnerId;
			}
			else if(setUpdatedContact.contains(objRelation.External_Contact__c) && setPreviousAccount.contains(objRelation.Account__c))
			{
				objRelation.Account__c = objRelation.External_Contact__r.AccountId;
			}
			else if(setContactIds.contains(objRelation.External_Contact__c))
			{
				objRelation.PWP_Employee__c = objRelation.External_Contact__r.OwnerId;
			}
			
			lstRelationshipToUpdate.add(objRelation);
		}
		//check whether List empty or not and perform the update operation
		if(!lstRelationshipToUpdate.isEmpty())
			update lstRelationshipToUpdate;
	}
}