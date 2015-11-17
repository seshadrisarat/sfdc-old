/**
* \arg ClassName      : SL_Batch_CreateRelationships
* \arg JIRATicket     : PWP-5
* \arg CreatedOn      : 4/DEC/2014
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This batch process is used to create Relationship records corresponding to Task and Event records.
*/
global class SL_Batch_CreateRelationships implements Database.Batchable<sobject>, Database.Stateful  
{
	String strQuery;//variable to hold the batch query that has been passed from scheduler
	Boolean isTask;//variable to check the type of scope variable
	 
	/* Start - Constructor */
	global SL_Batch_CreateRelationships(String strBatchQuery)
	{
		strQuery = strBatchQuery;
		isTask = false;
	}
	/* End - Constructor */
	
	//start method of batch
	global Database.Querylocator start(Database.BatchableContext BC)
	{    	
    	return Database.getQueryLocator(strQuery);
    }
	
	//execute method of batch
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
   		List<Relationship__c> lstRelationship = new List<Relationship__c>();//list of relationship records that needs to be created
   		Set<Id> setOwnerId = new Set<Id>();//set to collect unique user ids
   		Set<Id> setContactId = new Set<Id>();//set to collect unique contact ids
   		Set<String> setOwnerContactId = new Set<String>();//set to collect unique combination of owner and contact ids
   		isTask = scope.getSObjectType() == Task.getSObjectType() ? true:false;
   		String strRelationshipName = isTask ? 'TaskRelations' : 'EventRelations';//storing the relationship name into a variable
   		
   		//Iterating over list of sobjects that are retured from SOQL
   		for(Sobject objSobject : scope)
   		{
   			//Checking if relationship records are not empty
   			if(!objSobject.getSObjects(strRelationshipName).isEmpty())
   			{   				
   				//Iterating over task relations and creating the relationship records
   				for(Sobject objActivityRelations : objSobject.getSObjects(strRelationshipName))
   				{
   					//checking if relationship relationid belongs to contact
   					if(Id.valueOf(String.valueOf(objActivityRelations.get('RelationId'))).getSobjectType() == Contact.sobjectType)
   					{
   						String ownerId = String.valueOf(objSobject.get('OwnerId'));
   						String contactId = String.valueOf(objActivityRelations.get('RelationId'));
   						
   						//collecting the contact and owner ids into a set so that only unique record is created
   						setOwnerId.add(ownerId);
   						setContactId.add(contactId);
   						setOwnerContactId.add(String.format('{0}-{1}', new List<String>{ownerId,contactId}));
   					}
   				}
   			}
   		}
   		
   		//fetching the relationship records that are already present corresponding to the current contact and user
   		for(Relationship__c objRelationship : [SELECT PWP_Employee__c, External_Contact__c FROM Relationship__c WHERE PWP_Employee__c IN:setOwnerId AND External_Contact__c IN:setContactId])
   		{
   			//removing those combinations for which relationship is already exist to make sure that new relationship records will be unique.
   			setOwnerContactId.remove(String.format('{0}-{1}', new List<String>{objRelationship.PWP_Employee__c,objRelationship.External_Contact__c}));   				
   		}
   		
   		//Iterating over to create records
   		for(String strRelationship : setOwnerContactId)
   		{
   			String[] strSplittedString = strRelationship.split('-');
   			lstRelationship.add(new Relationship__c(PWP_Employee__c = strSplittedString[0], External_Contact__c = strSplittedString[1]));
   		}
   		
   		//checking if list is not empty
   		if(!lstRelationship.isEmpty())
   			insert lstRelationship;//inserting the relationship records
    }
	
	//finish method of batch
    global void finish(Database.BatchableContext BC)
    {
   		if(isTask)
		{
			//executing the event batch from finish method for creating the unique relationship records.
			Database.executeBatch(new SL_Batch_CreateRelationships('SELECT Id, OwnerId, (SELECT RelationId, EventId FROM EventRelations) FROM Event WHERE WhoId!=null AND isChild = false'));
		}
	}
}