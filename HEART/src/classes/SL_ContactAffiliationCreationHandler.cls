/**  
* \arg TriggerName    : SL_ContactAffiliationCreationTrigger
* \arg JIRATicket     : HEART-11
* \arg CreatedOn      : 11/Aug/2014
* \arg LastModifiedOn : 12/Oct/2015
* \arg CreatededBy    : Prakash
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : Handler class for Contact Trigger
*/

public with sharing class SL_ContactAffiliationCreationHandler 
{
	/* Start - Variables */
	private static Set<Id> setAffiliationId = new Set<Id>();// Variable to hold the Ids of those Affiliation records which belongs to previous Firm of updated Contact.
	private boolean m_isExecuting = false;
    private integer BatchSize = 0; 
    /* End - Variables */
    
	/* Start-Constructor */
	public SL_ContactAffiliationCreationHandler( boolean isExecuting, integer size )
	{
		m_isExecuting = isExecuting;
        BatchSize = size;
	}
	/* End-Constructor */
	
	/*
		@MethodName : onBeforeUpdate 
		@param 	    : list of updated contacts, map<ID, Contact> mapNewContacts
		@Description: Method is used to hold the Affiliation records which belongs to previous Firm so that they can be updated in onAfterUpdate event.
	*/
	public void onBeforeUpdate(List<Contact> lstContact, Map<Id, Contact> mapOldIdToContact)
	{
		Set<Id> setContactId = new Set<Id>();
		Set<Id> setAccountId = new Set<Id>();
		
		for(Contact objContact : lstContact)
		{
		    Contact objOldContact = mapOldIdToContact.get(objContact.Id);
		    if(objOldContact.AccountId!=NULL && objContact.AccountId!=objOldContact.AccountId)
		    {
		        setContactId.add(objContact.Id);
		        setAccountId.add(objOldContact.AccountId);
		    }
		}
		
		setAffiliationId = (new Map<Id, Affiliation__c>([SELECT Id FROM Affiliation__c WHERE Account__c IN : setAccountId AND Contact__c IN : setContactId AND Status__c = 'Current'])).keyset();
	}
	
	
	/*
		@MethodName : onAfterInsert 
		@param 	    : map<ID, Contact> mapNewContacts
		@Description: When Contact record is created, Create "Affiliation__c" record to the corresponding Contact and populate the fields mentioned in field mappings
	*/
	
	public void OnAfterInsert(map<ID, Contact> mapNewContacts ) 
	{
		generateAffiliation(Null, mapNewContacts);		
	} 
	
	/*
		@MethodName : OnAfterUpdate 
		@param 	    :  map<ID, Contact> mapOldContacts, map<ID, Contact> mapNewContacts
		@Description: When Contact record is updated, Create new "Affiliation__c" record to the corresponding Contact and populate the fields mentioned in field mappings
	*/
	public void OnAfterUpdate( map<ID, Contact> mapOldContacts, map<ID, Contact> mapNewContacts )
	{
		generateAffiliation(mapOldContacts, mapNewContacts);
		
	}
	
	/*
		@MethodName : generateAffiliation 
		@param 	    : Contact Records
		@Description: Create "Affiliation__c" record to the corresponding Contact and populate the fields mentioned in field mappings
	*/
	private void generateAffiliation(map<ID, Contact> mapOldContacts, map<ID, Contact> mapNewContacts ) 
	{
		List<Affiliation__c> lstAffiliationsToInsert = new List<Affiliation__c>();
		
		if(mapOldContacts == NULL)
		{
			for ( Contact objContact : mapNewContacts.values() ) 
			{
				Affiliation__c objAffiliation = new Affiliation__c(Contact__c = objContact.Id,  Account__c = objContact.AccountId, Status__c = 'Current', Role__c = 'Employee');
				lstAffiliationsToInsert.add(objAffiliation);
			}
		}
		else
		{
			//Set<ID> setOldAccountIds = new Set<ID>();
		
			for ( ID ContactIds : mapNewContacts.keySet() ) 
			{
				if (mapNewContacts.get(ContactIds).AccountId != mapOldContacts.get(ContactIds).AccountId) 
				{
					//setOldAccountIds.add(mapOldContacts.get(ContactIds).AccountId );
					Affiliation__c objAffiliation = new Affiliation__c(Contact__c = mapNewContacts.get(ContactIds).Id,  Account__c = mapNewContacts.get(ContactIds).AccountId, Status__c = 'Current', Role__c = 'Employee');
					lstAffiliationsToInsert.add(objAffiliation);
				}
			}
		
			if (!setAffiliationId.isEmpty()) 
			{
				for (Affiliation__c objAffilation : [SELECT Status__c FROM Affiliation__c WHERE Id IN :setAffiliationId]) 
				{
					objAffilation.Status__c = 'Former';
					lstAffiliationsToInsert.add(objAffilation);
				}
			}
		}
		
		
		if ( !lstAffiliationsToInsert.isEmpty() ) 
		{
			Database.Upsert(lstAffiliationsToInsert) ;
		}
    	
    } 

}