/**
*  ClassName      : SL_RelationshipTriggerHandler
*  JIRATicket     : SEGAL-5
*  CreatedOn      : 8/JAN/2015
*  ModifiedBy     : Sanath Kumar
*  Description    : This is the handler class for Relationship Trigger
*/
public with sharing class SL_RelationshipTriggerHandler 
{
	///Get Id of different recordtypes
	static final Id CONTACT_TO_CONTACT_RECORDTYPEID = [SELECT ID FROM RecordType WHERE sObjectType = 'Relationships__c' AND DeveloperName ='Contact_to_Contact'].ID;
	static final Id ENTITY_TO_ENTITY_RECORDTYPEID = [SELECT ID FROM RecordType WHERE sObjectType = 'Relationships__c' AND DeveloperName ='Entity_to_Entity'].ID;
	public static  Boolean isAlreadyExecuting = false;
	
	/*
    	* MethodName   : onBeforeInsert
        * param        : trigger.new
        * Description  : This method is called before Realtionship records are inserted
    */
	public void onBeforeInsert(List<Relationships__c> lstRelationships)
	{
		List<Relationships__c> lstFilteredRelationships = new List<Relationships__c>();
		Set<String> setRecord1IdRecord2Id = new Set<String>();
		Set<Id> setRecord1Id = new Set<Id>();
		Set<Id> setRecord2Id = new Set<Id>();
		
		///Create a list of Relationships whose record type is either Contact-Contact or Entity-Entity
		for(Relationships__c objRelationships:lstRelationships)
		{
			if((objRelationships.RecordTypeId == CONTACT_TO_CONTACT_RECORDTYPEID && objRelationships.Contact1__c != null && objRelationships.Contact2__c != null) ||
			   (objRelationships.RecordTypeId == ENTITY_TO_ENTITY_RECORDTYPEID && objRelationships.Entity1__c != null && objRelationships.Entity2__c != null))
			{
				lstFilteredRelationships.add(objRelationships);
				
				if(objRelationships.RecordTypeId == CONTACT_TO_CONTACT_RECORDTYPEID)
				{
					setRecord1IdRecord2Id.add(objRelationships.Contact1__c + '-' + objRelationships.Contact2__c + '-' + objRelationships.Primary_Relationship_Type__c + '-' + objRelationships.Reciprocal_Relationship_Type__c);
					setRecord1Id.add(objRelationships.Contact1__c);
					setRecord2Id.add(objRelationships.Contact2__c);
				}
				else if(objRelationships.RecordTypeId == ENTITY_TO_ENTITY_RECORDTYPEID)
				{
					setRecord1IdRecord2Id.add(objRelationships.Entity1__c + '-' + objRelationships.Entity2__c + '-' + objRelationships.Primary_Relationship_Type__c + '-' + objRelationships.Reciprocal_Relationship_Type__c);
					setRecord1Id.add(objRelationships.Entity1__c);
					setRecord2Id.add(objRelationships.Entity2__c);
				}
			}
		}
		
		if(!lstFilteredRelationships.isEmpty())
			checkForDulpicateRelationshipRecords(lstFilteredRelationships,setRecord1IdRecord2Id,setRecord1Id,setRecord2Id);
	}
	
	/*
    	* MethodName   : onBeforeUpdate
        * param        : trigger.oldMap, trigger.newMap
        * Description  : This method is called before Realtionship records are updated
    */
	public void onBeforeUpdate(Map<Id,Relationships__c> mapOldRelationships,Map<Id,Relationships__c> mapNewRelationships)
	{
		List<Relationships__c> lstFilteredRelationships = new List<Relationships__c>();
		Set<String> setRecord1IdRecord2Id = new Set<String>();
		Set<Id> setRecord1Id = new Set<Id>();
		Set<Id> setRecord2Id = new Set<Id>();
		
		
		///Create a list of Relationships whose record type is either Contact-Contact or Entity-Entity
		for(Id objNewRelationshipId:mapNewRelationships.keyset())
		{
			if((mapNewRelationships.get(objNewRelationshipId).RecordTypeId == CONTACT_TO_CONTACT_RECORDTYPEID && mapNewRelationships.get(objNewRelationshipId).Contact1__c != null && mapNewRelationships.get(objNewRelationshipId).Contact2__c != null
					&& (mapNewRelationships.get(objNewRelationshipId).Contact1__c != mapOldRelationships.get(objNewRelationshipId).Contact1__c ||
						mapNewRelationships.get(objNewRelationshipId).Contact2__c != mapOldRelationships.get(objNewRelationshipId).Contact2__c ||
						mapNewRelationships.get(objNewRelationshipId).Primary_Relationship_Type__c != mapOldRelationships.get(objNewRelationshipId).Primary_Relationship_Type__c ||
						mapNewRelationships.get(objNewRelationshipId).Reciprocal_Relationship_Type__c != mapOldRelationships.get(objNewRelationshipId).Reciprocal_Relationship_Type__c)) ||
			   (mapNewRelationships.get(objNewRelationshipId).RecordTypeId == ENTITY_TO_ENTITY_RECORDTYPEID && mapNewRelationships.get(objNewRelationshipId).Entity1__c != null && mapNewRelationships.get(objNewRelationshipId).Entity2__c != null
					&& (mapNewRelationships.get(objNewRelationshipId).Entity1__c != mapOldRelationships.get(objNewRelationshipId).Entity1__c ||
						mapNewRelationships.get(objNewRelationshipId).Entity2__c != mapOldRelationships.get(objNewRelationshipId).Entity2__c ||
						mapNewRelationships.get(objNewRelationshipId).Primary_Relationship_Type__c != mapOldRelationships.get(objNewRelationshipId).Primary_Relationship_Type__c ||
						mapNewRelationships.get(objNewRelationshipId).Reciprocal_Relationship_Type__c != mapOldRelationships.get(objNewRelationshipId).Reciprocal_Relationship_Type__c)))
			{
				lstFilteredRelationships.add(mapNewRelationships.get(objNewRelationshipId));
				
				if(mapNewRelationships.get(objNewRelationshipId).RecordTypeId == CONTACT_TO_CONTACT_RECORDTYPEID)
				{
					setRecord1IdRecord2Id.add(mapNewRelationships.get(objNewRelationshipId).Contact1__c + '-' + mapNewRelationships.get(objNewRelationshipId).Contact2__c + '-' + mapNewRelationships.get(objNewRelationshipId).Primary_Relationship_Type__c + '-' + mapNewRelationships.get(objNewRelationshipId).Reciprocal_Relationship_Type__c);
					setRecord1Id.add(mapNewRelationships.get(objNewRelationshipId).Contact1__c);
					setRecord2Id.add(mapNewRelationships.get(objNewRelationshipId).Contact2__c);
				}
				else if(mapNewRelationships.get(objNewRelationshipId).RecordTypeId == ENTITY_TO_ENTITY_RECORDTYPEID)
				{
					setRecord1IdRecord2Id.add(mapNewRelationships.get(objNewRelationshipId).Entity1__c + '-' + mapNewRelationships.get(objNewRelationshipId).Entity2__c + '-' + mapNewRelationships.get(objNewRelationshipId).Primary_Relationship_Type__c + '-' + mapNewRelationships.get(objNewRelationshipId).Reciprocal_Relationship_Type__c);
					setRecord1Id.add(mapNewRelationships.get(objNewRelationshipId).Entity1__c);
					setRecord2Id.add(mapNewRelationships.get(objNewRelationshipId).Entity2__c);
				}
			}
		}
		
		if(!lstFilteredRelationships.isEmpty())
			checkForDulpicateRelationshipRecords(lstFilteredRelationships,setRecord1IdRecord2Id, setRecord1Id,setRecord2Id);
	}
	
	/*
    	* MethodName   : onAfterInsert
        * param        : trigger.new
        * Description  : This method is called after Realtionship records are inserted
    */
	public void onAfterInsert(List<Relationships__c> lstRelationships)
	{
		List<Relationships__c> lstFilteredRelationships = new List<Relationships__c>();
		
		///Create a list of Relationships whose record type is either Contact-Contact or Entity-Entity
		for(Relationships__c objRelationships:lstRelationships)
		{
			if((objRelationships.RecordTypeId == CONTACT_TO_CONTACT_RECORDTYPEID && objRelationships.Contact1__c != null && objRelationships.Contact2__c != null) ||
			   (objRelationships.RecordTypeId == ENTITY_TO_ENTITY_RECORDTYPEID && objRelationships.Entity1__c != null && objRelationships.Entity2__c != null))
			{
				lstFilteredRelationships.add(objRelationships);
			}
		}
		
		if(SL_RelationshipTriggerHandler.isAlreadyExecuting)
      	{
        	// if was executed during the same context 
	      	// avoid recursion
	      	return;
    	}
    	
    	SL_RelationshipTriggerHandler.isAlreadyExecuting = true;
    	
    	if(!lstFilteredRelationships.isEmpty())
			createInverseRelationships(lstFilteredRelationships);
	}
	
	/*
    	* MethodName   : onAfterUpdate
        * param        : trigger.oldMap, trigger.newMap
        * Description  : This method is called after Realtionship records are updated
    */
	public void onAfterUpdate(Map<Id,Relationships__c> mapOldRelationships,Map<Id,Relationships__c> mapNewRelationships)
	{
		List<Relationships__c> lstFilteredRelationshipsToInsert = new List<Relationships__c>();
		List<Relationships__c> lstFilteredRelationshipsToDelete = new List<Relationships__c>();
		
		///Create lists of Realtionship records to be inserted and deleted
		for(Id objNewRelationshipId:mapNewRelationships.keyset())
		{
			if((mapNewRelationships.get(objNewRelationshipId).RecordTypeId == CONTACT_TO_CONTACT_RECORDTYPEID && mapNewRelationships.get(objNewRelationshipId).Contact1__c != null && mapNewRelationships.get(objNewRelationshipId).Contact2__c != null
					&& (mapNewRelationships.get(objNewRelationshipId).Contact1__c != mapOldRelationships.get(objNewRelationshipId).Contact1__c ||
						mapNewRelationships.get(objNewRelationshipId).Contact2__c != mapOldRelationships.get(objNewRelationshipId).Contact2__c ||
						mapNewRelationships.get(objNewRelationshipId).Primary_Relationship_Type__c != mapOldRelationships.get(objNewRelationshipId).Primary_Relationship_Type__c ||
						mapNewRelationships.get(objNewRelationshipId).Reciprocal_Relationship_Type__c != mapOldRelationships.get(objNewRelationshipId).Reciprocal_Relationship_Type__c)) ||
			   (mapNewRelationships.get(objNewRelationshipId).RecordTypeId == ENTITY_TO_ENTITY_RECORDTYPEID && mapNewRelationships.get(objNewRelationshipId).Entity1__c != null && mapNewRelationships.get(objNewRelationshipId).Entity2__c != null
					&& (mapNewRelationships.get(objNewRelationshipId).Entity1__c != mapOldRelationships.get(objNewRelationshipId).Entity1__c ||
						mapNewRelationships.get(objNewRelationshipId).Entity2__c != mapOldRelationships.get(objNewRelationshipId).Entity2__c ||
						mapNewRelationships.get(objNewRelationshipId).Primary_Relationship_Type__c != mapOldRelationships.get(objNewRelationshipId).Primary_Relationship_Type__c ||
						mapNewRelationships.get(objNewRelationshipId).Reciprocal_Relationship_Type__c != mapOldRelationships.get(objNewRelationshipId).Reciprocal_Relationship_Type__c)))
			{
				lstFilteredRelationshipsToInsert.add(mapNewRelationships.get(objNewRelationshipId));
			}
			if(mapNewRelationships.get(objNewRelationshipId).RecordTypeId == CONTACT_TO_CONTACT_RECORDTYPEID && mapOldRelationships.get(objNewRelationshipId).Contact1__c != null && mapOldRelationships.get(objNewRelationshipId).Contact2__c != null 
			       && (mapNewRelationships.get(objNewRelationshipId).Contact1__c != mapOldRelationships.get(objNewRelationshipId).Contact1__c ||
						mapNewRelationships.get(objNewRelationshipId).Contact2__c != mapOldRelationships.get(objNewRelationshipId).Contact2__c ||
						mapNewRelationships.get(objNewRelationshipId).Primary_Relationship_Type__c != mapOldRelationships.get(objNewRelationshipId).Primary_Relationship_Type__c ||
						mapNewRelationships.get(objNewRelationshipId).Reciprocal_Relationship_Type__c != mapOldRelationships.get(objNewRelationshipId).Reciprocal_Relationship_Type__c) ||  
				   (mapNewRelationships.get(objNewRelationshipId).RecordTypeId == ENTITY_TO_ENTITY_RECORDTYPEID && mapOldRelationships.get(objNewRelationshipId).Entity1__c != null && mapOldRelationships.get(objNewRelationshipId).Entity2__c != null
				   && (mapNewRelationships.get(objNewRelationshipId).Entity1__c != mapOldRelationships.get(objNewRelationshipId).Entity1__c ||
						mapNewRelationships.get(objNewRelationshipId).Entity2__c != mapOldRelationships.get(objNewRelationshipId).Entity2__c ||
						mapNewRelationships.get(objNewRelationshipId).Primary_Relationship_Type__c != mapOldRelationships.get(objNewRelationshipId).Primary_Relationship_Type__c ||
						mapNewRelationships.get(objNewRelationshipId).Reciprocal_Relationship_Type__c != mapOldRelationships.get(objNewRelationshipId).Reciprocal_Relationship_Type__c)) )
			{
				lstFilteredRelationshipsToDelete.add(mapOldRelationships.get(objNewRelationshipId));
			}
		}
		
		if(SL_RelationshipTriggerHandler.isAlreadyExecuting)
      	{
        	// if was executed during the same context 
	      	// avoid recursion
	      	return;
    	}
    	
    	SL_RelationshipTriggerHandler.isAlreadyExecuting = true;
    	
		if(!lstFilteredRelationshipsToDelete.isEmpty() && !mapNewRelationships.isEmpty())
			deleteOldInverseRelationships(lstFilteredRelationshipsToDelete,mapNewRelationships);
			
		if(!lstFilteredRelationshipsToInsert.isEmpty())
			createInverseRelationships(lstFilteredRelationshipsToInsert);
	}
	
	/*
    	* MethodName   : onAfterUpdate
        * param        : trigger.old
        * Description  : This method is called after Realtionship records are deleted
    */
	public void onAfterDelete(List<Relationships__c> lstRelationships)
	{
		List<Relationships__c> lstRelationshipsToDelete = new List<Relationships__c>();
		
		///Create a list of old reciprocal Relationships to delete
		for(Relationships__c objRelationships:lstRelationships)
		{
			if(objRelationships.Primary_Reciprocal_Relationship_Id__c != null)
				lstRelationshipsToDelete.add(objRelationships);
		}
		
		if(SL_RelationshipTriggerHandler.isAlreadyExecuting)
      	{
        	// if was executed during the same context 
	      	// avoid recursion
	      	return;
    	}
    	
    	SL_RelationshipTriggerHandler.isAlreadyExecuting = true;
    	
		if(!lstRelationshipsToDelete.isEmpty())
			deleteOldInverseRelationships(lstRelationshipsToDelete,new Map<Id,Relationships__c>());
	}
	
	
	/*
    	* MethodName   : checkForDulpicateRelationshipRecords
        * param        : List<Relationships__c> lstRelationships
        * Description  : This method checks for duplicate Realtionship records before they are inserted
    */
	private void checkForDulpicateRelationshipRecords(List<Relationships__c> lstRelationships, Set<String> setRecord1IdRecord2Id,Set<Id> setRecord1Id,Set<Id> setRecord2Id)
	{
		Set<String> setDuplicateContacts = new Set<String>();
		Set<String> setDuplicateEntities = new Set<String>();
		
		///Create set for duplicate records
		for(Relationships__c objRelationships:[SELECT Id,Contact1__c,Contact2__c,Entity1__c,Entity2__c,RecordTypeId,Primary_Relationship_Type__c,Reciprocal_Relationship_Type__c
		                                       FROM Relationships__c
		                                       WHERE (RecordTypeId =: ENTITY_TO_ENTITY_RECORDTYPEID AND Entity1__c IN: setRecord1Id AND Entity2__c IN: setRecord2Id)
		                                       OR (RecordTypeId =: CONTACT_TO_CONTACT_RECORDTYPEID AND Contact1__c IN: setRecord1Id AND Contact2__c IN: setRecord2Id)])
		{
			if(objRelationships.RecordTypeId == CONTACT_TO_CONTACT_RECORDTYPEID && setRecord1IdRecord2Id.contains(objRelationships.Contact1__c + '-' + objRelationships.Contact2__c + '-' + objRelationships.Primary_Relationship_Type__c + '-' + objRelationships.Reciprocal_Relationship_Type__c))
			{
				setDuplicateContacts.add(objRelationships.Contact1__c + '-' + objRelationships.Contact2__c + '-' + objRelationships.Primary_Relationship_Type__c + '-' + objRelationships.Reciprocal_Relationship_Type__c);
			}
			else if(objRelationships.RecordTypeId == ENTITY_TO_ENTITY_RECORDTYPEID && setRecord1IdRecord2Id.contains(objRelationships.Entity1__c + '-' + objRelationships.Entity2__c + '-' + objRelationships.Primary_Relationship_Type__c + '-' + objRelationships.Reciprocal_Relationship_Type__c))
			{
				setDuplicateEntities.add(objRelationships.Entity1__c + '-' + objRelationships.Entity2__c + '-' + objRelationships.Primary_Relationship_Type__c + '-' + objRelationships.Reciprocal_Relationship_Type__c);
			}
		}
		
		///Show Error message
		for(Relationships__c objRelationships:lstRelationships)
		{
			if(objRelationships.RecordTypeId == CONTACT_TO_CONTACT_RECORDTYPEID)
			{
				if(setDuplicateContacts.contains(objRelationships.Contact1__c + '-' + objRelationships.Contact2__c + '-' + objRelationships.Primary_Relationship_Type__c + '-' + objRelationships.Reciprocal_Relationship_Type__c))
					objRelationships.addError('Duplicate RelationShip Record Exists With Same Contact And Related To (Contact) Values');
				else
					setDuplicateContacts.add(objRelationships.Contact1__c + '-' + objRelationships.Contact2__c + '-' + objRelationships.Primary_Relationship_Type__c + '-' + objRelationships.Reciprocal_Relationship_Type__c);
			}
			else if(objRelationships.RecordTypeId == ENTITY_TO_ENTITY_RECORDTYPEID)
			{ 	
				if(setDuplicateEntities.contains(objRelationships.Entity1__c + '-' + objRelationships.Entity2__c + '-' + objRelationships.Primary_Relationship_Type__c + '-' + objRelationships.Reciprocal_Relationship_Type__c))
					objRelationships.addError('Duplicate RelationShip Record Exists With Same Entity And Related To (Entity) Values');
				else
					setDuplicateEntities.add(objRelationships.Entity1__c + '-' + objRelationships.Entity2__c + '-' + objRelationships.Primary_Relationship_Type__c + '-' + objRelationships.Reciprocal_Relationship_Type__c);
			}
		}
	}
	
	
	/*
    	* MethodName   : createInverseRelationships
        * param        : List<Relationships__c> lstRelationships
        * Description  : This method creates inverse relationships
    */
	private void createInverseRelationships(List<Relationships__c> lstRelationships)
	{
		SL_GenericClassCreateReciprocalRelations objGenericClassCreateReciprocalRelations = new SL_GenericClassCreateReciprocalRelations(lstRelationships);
	}
	
	/*
    	* MethodName   : deleteOldInverseRelationships
        * param        : List<Relationships__c> lstRelationships
        * Description  : This method deletes old inverse relationships
    */
	private void deleteOldInverseRelationships(List<Relationships__c> lstRelationships, Map<Id,Relationships__c> mapNewRelationships)
	{
		Set<Id> setRelationshipsIdToDelete = new Set<Id>();
		List<Relationships__c> lstRelationshipsToDelete = new List<Relationships__c>();
		List<Relationships__c> lstNewRelationshipsToUpdate = new List<Relationships__c>();
		
		///Create a set of inverse relationship ids of old relationship records
		for(Relationships__c objRelationships:lstRelationships)
		{
			if(objRelationships.Primary_Reciprocal_Relationship_Id__c != null)
				setRelationshipsIdToDelete.add(objRelationships.Primary_Reciprocal_Relationship_Id__c);
		}		
		
		///Create a list of inverse relationships to delete
		if(!setRelationshipsIdToDelete.isEmpty())
			lstRelationshipsToDelete = [SELECT Id FROM Relationships__c WHERE Id IN:setRelationshipsIdToDelete];  
		
		///Make Primary_Reciprocal_Relationship_Id__c as blank on new Primary relationship records
		for(Relationships__c objRelationships:mapNewRelationships.values())
		{
			Relationships__c objRelationshipsNew = new Relationships__c(Id = objRelationships.Id);
			objRelationshipsNew.Primary_Reciprocal_Relationship_Id__c = '';
			lstNewRelationshipsToUpdate.add(objRelationshipsNew);
		}
		
		if(!lstNewRelationshipsToUpdate.isEmpty())
			update lstNewRelationshipsToUpdate;
			
		if(!lstRelationshipsToDelete.isEmpty())
			delete lstRelationshipsToDelete;
	}
}