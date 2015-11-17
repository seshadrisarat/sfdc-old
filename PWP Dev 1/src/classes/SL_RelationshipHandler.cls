/**
* \arg TriggerName    : SL_RelationshipHandler
* \arg JIRATicket     : PWP-5,PWP-8
* \arg CreatedOn      : 11/DEC/2014
* \arg LastModifiedOn : 17/MAR/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as handler class for relationship trigger to update the account field on relationship object record with corresponding Contact's account if account id is blank. 
*/
public without sharing class SL_RelationshipHandler 
{
	/* Start - Class Variables */
	/* End - Class Variables */
	
	/* Start - Constructor */
	public SL_RelationshipHandler()
	{
		//Do Nothing
	}
	/* End - Constructor */

	 /*!
    * MethodName : onAfterInsert
    * param      : Map of the new Relationship__c record
    * Description: This method will be called from the trigger on After insert of Relationship__c records.
	*/	
	public void onAfterInsert(List<Relationship__c> lstRelationship) 
	{		
	    //Calling method to create EntitySubscription records corresponding to Relationship__c
		//createEntitySubscription(lstRelationship);
	}
	  
	  /*!
    * MethodName : onAfterDelete
    * param      : Map of the old Relationship__c record
    * Description: This method will be called from the trigger on After delete of the Relationship records.
	*/
    public void onAfterDelete(map<ID, sObject> oldRecords)
    {        
    	List<RelSci_Processing__c> processingRecordsList  = new List<RelSci_Processing__c>();
		Map<Id, Relationship__c> oldResolvedRecords = (map<Id, Relationship__c>)oldRecords;

		//Collect all pwp Employees
		Set<Id> pwpEmployeeCol = new Set<Id>();
		for(Relationship__c oldRelItem: oldResolvedRecords.values())
		{
			if (oldRelItem.PWP_Employee__c != null)
			{
				pwpEmployeeCol.add(oldRelItem.PWP_Employee__c);
			}
		}

		//Collect all pwpEmployee Usernames
		Map<Id, User> userCollection = new Map<Id, User>([Select Id, username from User where Id in :pwpEmployeeCol]);

        //check for all records where relsci entityid is populated
        for(Relationship__c item:oldResolvedRecords.values()) 
        {        	
        	if (item != null)
        	{				
				if (String.isNotEmpty(item.RelSci_EntityId__c)) 
				{
					RelSci_Processing__c processingRec = new RelSci_Processing__c(RelSci_EntityId__c = item.RelSci_EntityId__c, RelSci_User_Identifier__c = userCollection.get(item.PWP_Employee__c).username);
					processingRecordsList.add(processingRec);
					system.debug('==processingRecordsList=='+processingRecordsList);
				}
        	}    		
    	}
    	Database.insert(processingRecordsList, false);
    	//Calling method to delete EntitySubscription records corresponding to Relationship__c
		//deleteEntitySubscription(oldRecords.values());
    }
    
    public void onAfterUpdate(map<ID, sObject> oldRecords, map<ID, sObject> updatedRecords) 
    {
		//check for all records where relsci entityid is populated and user or contact is changed
		//write to processing object 
		//clear integration fields
        Map<Id, Relationship__c> oldResolvedRecords =(map<Id, Relationship__c>)oldRecords;
		List<RelSci_Processing__c> processingRecordsList  = new List<RelSci_Processing__c>();
		List<Relationship__c> recordsToClearIntegrationFields  = new List<Relationship__c>();
		
		/* Start - This comes under PWP-12 - Pankaj Ganwani*/
		/*List<Relationship__c> lstRelationshipToInsertES = new List<Relationship__c>();//List of Relationship__c to create the EntitySubscription
	    List<Relationship__c> lstRelationshipToDeleteES = new List<Relationship__c>();//List of Relationship__c to delete the EntitySubscription
		
		Map<Id,Relationship__c> mapRelationshipToNew = (Map<Id,Relationship__c>)updatedRecords;
		Map<Id,Relationship__c> mapRelationshipToOld = (Map<Id,Relationship__c>)oldRecords;
		//Iterating on Relationship__c to get the updated Relationship__c whose account or pwp employee is changed
		for(Relationship__c objRelationship : mapRelationshipToNew.Values())
		{
			if(objRelationship.Account__c != mapRelationshipToOld.get(objRelationship.Id).Account__c 
			   || objRelationship.PWP_Employee__c != mapRelationshipToOld.get(objRelationship.Id).PWP_Employee__c)
			{
				lstRelationshipToDeleteES.add(mapRelationshipToOld.get(objRelationship.Id));
				lstRelationshipToInsertES.add(objRelationship);
			}
		}
		//Calling method to delete EntitySubscription records corresponding to Relationship__c
  		if(!lstRelationshipToDeleteES.isEmpty())
  			deleteEntitySubscription(lstRelationshipToDeleteES);
  		
  		//Calling method to create EntitySubscription records corresponding to Relationship__c	
		if(!lstRelationshipToInsertES.isEmpty()) 
			createEntitySubscription(lstRelationshipToInsertES);*/
		/* End - This comes under PWP-12 - Pankaj Ganwani*/  
		
		//Collect all pwp Employees
		Set<Id> pwpEmployeeCol = new Set<Id>();
		for(Relationship__c oldRelItem : oldResolvedRecords.values())
		{
			if (oldRelItem.PWP_Employee__c != null)
			{
				pwpEmployeeCol.add(oldRelItem.PWP_Employee__c);
			}
		}
		//Collect all pwpEmployee Usernames
		Map<Id, User> userCollection = new Map<Id, User>([Select Id, username from User where Id in :pwpEmployeeCol]);

        //check for all records where relsci entityid is populated
        for(sObject item:updatedRecords.values()) 
        {
        	Relationship__c relationship = (Relationship__c) item;
   		
        	if (relationship != null)
        	{				
				Relationship__c oldrelationship = (Relationship__c)oldResolvedRecords.get(relationship.id);

				String relSciEntityId = '';
				if (String.isNotEmpty(relationship.RelSci_EntityId__c))
				{
					relSciEntityId = relationship.RelSci_EntityId__c;
				}
				else 
				{
					if (oldrelationship != null)
					{
						if (String.isNotEmpty(oldrelationship.RelSci_EntityId__c))
						{
							relSciEntityId = oldrelationship.RelSci_EntityId__c;
						}

					}
				}

				if (String.isNotEmpty(relSciEntityId)) 
				{
					
					boolean HasUserChanged = false;
					boolean HasContactChanged = false;
					if(relationship.PWP_Employee__c != oldrelationship.PWP_Employee__c) 
					{
						HasUserChanged = true;
					}

					if (relationship.External_Contact__c != oldrelationship.External_Contact__c) 
					{
						HasContactChanged = true;
					}

					//check if user or contact has changed
					if (HasContactChanged || HasUserChanged)
					{
						
						System.debug('RelSci_EntityId__c: ' + relSciEntityId);
						System.debug('PWP_Employee__c: ' + oldrelationship.PWP_Employee__c);
						System.debug('oldrelationship.Id: ' + oldrelationship.Id);
						System.debug('PWP_Employee__r.username: ' + userCollection.get(oldrelationship.PWP_Employee__c).username);
						//System.debug('PWP_Employee__r.email: ' + userCollection.get(oldrelationship.PWP_Employee__c).email);
						
						//use old userid
						RelSci_Processing__c processingRec = new RelSci_Processing__c(RelSci_EntityId__c = relSciEntityId, RelSci_User_Identifier__c = userCollection.get(oldrelationship.PWP_Employee__c).username);
						processingRecordsList.add(processingRec);

						Relationship__c resetRecord = new Relationship__c(id=relationship.id, RelSci_EntityId__c= '',RelSci_SyncId__c = '', RelSci_Status__c = '');
						recordsToClearIntegrationFields.add(resetRecord);
					}

				}
        	}    		
    	}

    	Database.insert(processingRecordsList, false);
    	DataBase.update(recordsToClearIntegrationFields, false);

    }
    
    /*
	@Method Name	: onAfterUnDelete
	@Parameters		: List<Relationship__c> lstRelationship
	@Description	: This method is called on After UnDelete 
	*/
	public void onAfterUnDelete(List<Relationship__c> lstRelationship)
	{
		//Calling method to create EntitySubscription records corresponding to Relationship__c
		//createEntitySubscription(lstRelationship);
	}
	/* End */
    
	/*
    * MethodName        : onBeforeInsert
    * param             : list of relationship records which are going to be inserted
    * Description       : This function is used to populate the account id in relationship record if this is null
    */
	public void onBeforeInsert(List<Relationship__c> lstRelationship)
	{
		updateAccount(lstRelationship,NULL);//calling method to update the relationship records
	}
	
	/*
    * MethodName        : onBeforeUpdate
    * param             : map of new and old relationship records
    * Description       : This function is used to populate the account id in relationship record if the corresponding contact record is updated
    */
	public void onBeforeUpdate(Map<Id, Relationship__c> mapOldIdToRelationship, Map<Id, Relationship__c> mapNewIdToRelationship)
	{
		updateAccount(mapNewIdToRelationship.values(),mapOldIdToRelationship);//calling method to update the relationship records
	}

	/*
    * MethodName        : updateAccount
    * param             : list of relationship records and old map of relationship records
    * Description       : This function is used to populate the account id in relationship record if the corresponding contact record is updated and is called from both onbeforeinsert and onbeforeupdate methods
    */
	void updateAccount(List<Relationship__c> lstRelationship, Map<Id, Relationship__c> mapIdToRelationship)
	{
		Map<Id,Id> mapContactIdToAccountId = new Map<Id,Id>();// this map is used to hold the account corresponding to external contact
		Set<Id> setContactId = new Set<Id>();// set to hold contact id of those relationship records whose account is null
		List<Relationship__c> lstRelationshipToUpdate = new List<Relationship__c>();// list of relationship records that needs to be updated
		
		//Iterating over relationship records to filter the records whose account is null and external contact is not null
		for(Relationship__c objRelationship:lstRelationship)
		{
			//checking for insert and update events
			if(((Trigger.isInsert && objRelationship.Account__c == NULL) 
				|| 
				((Trigger.isUpdate && objRelationship.External_Contact__c != mapIdToRelationship.get(objRelationship.Id).External_Contact__c) || objRelationship.Account__c == NULL)) && objRelationship.External_Contact__c!=NULL)
			{
				setContactId.add(objRelationship.External_Contact__c);
				lstRelationshipToUpdate.add(objRelationship);
			}
		}
		
		//checking if list is empty
		if(!lstRelationshipToUpdate.isEmpty())
		{
			//fetching all the contact records to fill the map with contact id and its corresponding account id
			for(Contact objContact : [SELECT Id, AccountId FROM Contact WHERE Id IN : setContactId AND AccountId!=NULL])
			{
				mapContactIdToAccountId.put(objContact.Id, objContact.AccountId);
			}
			
			//Iterating over relationship object to update the account field
			for(Relationship__c objRelationship : lstRelationshipToUpdate)
			{
				if(mapContactIdToAccountId.containskey(objRelationship.External_Contact__c))
					objRelationship.Account__c = mapContactIdToAccountId.get(objRelationship.External_Contact__c);
			}
		}
	}
	
	/*
	@Method Name	: createEntitySubscription
	@Parameters		: List<Relationship__c> lstRelationship
	@Description	: This method is called on After Insert, After Update and After Undelete 
	*/
	/*private void createEntitySubscription(List<Relationship__c> lstRelationship)
	{
		List<EntitySubscription> lstEntitySubscription = new List<EntitySubscription>();//list of entity relationship records that are going to be inserted.
		
		//Iterating over list of inserted relationship records to create ES records
		for(Relationship__c objRelationship : lstRelationship)
		{
			if(objRelationship.Account__c != null && objRelationship.PWP_Employee__c != null)
			{
				lstEntitySubscription.add(new EntitySubscription(ParentId = objRelationship.Account__c, SubscriberId = objRelationship.PWP_Employee__c));
			}
		}
		
		//Calling method to create EntitySubscription records corresponding to Relationship__c
		if(!lstEntitySubscription.isEmpty())
			Database.insert(lstEntitySubscription,false);
	}*/
	/* End */
	
	/*
	@Method Name	: deleteES
	@Parameters		: List<Relationship__c> lstRelationship
	@Description	: This method is called on After Insert 
	*/
	/*private void deleteEntitySubscription(List<Relationship__c> lstRelationship)
	{
		List<EntitySubscription> lstEntitySubscription = new List<EntitySubscription>();//List of EntitySubscription to delete
		Set<Id> setAccountId = new Set<Id>();//Set of account id
		Set<Id> setPWPEmployee = new Set<Id>();//Set of user id   
		Set<String> setAcountIdToEmployeeId = new Set<String>();//Set of string with combination of accountid and user id
		
		//Iterating on Relationship__c to get account id and user id into set
		for(Relationship__c objRelationship : lstRelationship)
		{
			if(objRelationship.Account__c != null && objRelationship.PWP_Employee__c != null)
			{
				setAccountId.add(objRelationship.Account__c);
				setPWPEmployee.add(objRelationship.PWP_Employee__c);
			}
		}
		
		//Iterating on Relationship__c to create set of accountid and user id key combination
		for(Relationship__c objRelationship :[SELECT Account__c, 
													 PWP_Employee__c 
											    FROM Relationship__c
											   WHERE Account__c IN: setAccountId
											     AND PWP_Employee__c IN: setPWPEmployee])
		{
			setAcountIdToEmployeeId.add(objRelationship.Account__c +'_'+ objRelationship.PWP_Employee__c);
			
		}
		
		//Iterating on Coverage_Team_Members__c for avoiding the deletion of EntitySubscription records if its present for Coverage_Team_Members__c 
		for(Coverage_Team_Members__c objCoverageTeamMembers:[SELECT Company__c, 
																	PWP_Employee__c 
                    										   FROM Coverage_Team_Members__c
                   											  WHERE Company__c IN: setAccountId
                     										    AND PWP_Employee__c IN: setPWPEmployee])
		{
		   	setAcountIdToEmployeeId.add(objCoverageTeamMembers.Company__c +'_'+ objCoverageTeamMembers.PWP_Employee__c);
		}
		
		//Iterating  on EntitySubscription to delete 
		for(EntitySubscription objEntitySubscription:[SELECT ParentId, 
															 SubscriberId 
    												    FROM EntitySubscription
    												   WHERE ParentId IN: setAccountId
    												     AND SubscriberId IN: setPWPEmployee])
		{
		    if(!setAcountIdToEmployeeId.contains(objEntitySubscription.ParentId+'_'+objEntitySubscription.SubscriberId))
		    	lstEntitySubscription.add(objEntitySubscription);
		}
		//Delete the EntitySubscription records
		if(!lstEntitySubscription.isEmpty())
			Database.delete(lstEntitySubscription,false);
	}*/
	/* End */
}