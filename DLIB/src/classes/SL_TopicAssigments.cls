/**
* @ClassName 		: SL_TopicAssigments
* @JIRATicket   	: DLIB-3 and DLIB-4
* @CreatedOn    	: 22/AUG/2014
* @ModifiedBy   	: Harsh
* @Description 	 	: 
*/
public with sharing class SL_TopicAssigments 
{
	/* Start - Variables */
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_TopicAssigments()
	{
		// do nothing....
	}
	
	/* End - Constructor */
	/*   
		@MethodName		: createTopicAssignment
		@param			: 
		@Description	: To insert Topic Assignment records
	*/
	public static void createTopicAssignment(Map<Id, Set<String>> mapParentIdToSetOfPicklistValue, Set<String> setPicklistValues)
	{
		List<TopicAssignment> lstTopicAssignmentToInsert = new List<TopicAssignment>();//List of Topic Assignment to create record
		Map<String, String> mapPicklistValueToTopicId = new Map<String, String>();//Map picklist values to Topic Id for Library Topic object
		for(Library_Topic__c objLT : [SELECT Id,
											 Name,
											 Topic_ID__c
									    FROM Library_Topic__c
									   WHERE Name IN: setPicklistValues]) 
		{
			mapPicklistValueToTopicId.put(objLT.Name, objLT.Topic_ID__c);
		}
		
		for(Id parentId : mapParentIdToSetOfPicklistValue.keySet())
		{
			for(String strPicklistValue : mapParentIdToSetOfPicklistValue.get(parentId))
			{
				if(mapPicklistValueToTopicId.containsKey(strPicklistValue))
				{
					lstTopicAssignmentToInsert.add(new TopicAssignment(TopicId = mapPicklistValueToTopicId.get(strPicklistValue), EntityId = parentId));
				}	
			}
		}
		
		//perform dml
		if(!lstTopicAssignmentToInsert.isEmpty())
			insert lstTopicAssignmentToInsert;
	}
	/* End */
	/*   
		@MethodName		: deleteTopicAssignment
		@param			: 
		@Description	: To delete Topic Assignment records
	*/
	public static void deleteTopicAssignment(Map<Id, Set<String>> mapParentIdToSetOfPicklistValue, Set<String> setPicklistValues)
	{
		List<TopicAssignment> lstTopicAssignmentToDelete = new List<TopicAssignment>();//List of Topic Assignment to create record
		Map<String, String> mapPicklistValueToTopicId = new Map<String, String>();//Map picklist values to Topic Id for Library Topic object
		Map<String, TopicAssignment> mapEntityId_TopicIdToTA = new Map<String, TopicAssignment>(); //Map EntityId Topic Id key to Topic Assignment
		
		for(Library_Topic__c objLT : [SELECT Id,
											 Name,
											 Topic_ID__c
									    FROM Library_Topic__c
									   WHERE Name IN: setPicklistValues]) 
		{
			mapPicklistValueToTopicId.put(objLT.Name, objLT.Topic_ID__c);
		}
		
		for(TopicAssignment objTA : [SELECT Id, 
										    TopicId, 
										    EntityId 
									   FROM TopicAssignment 
									  WHERE EntityId IN: mapParentIdToSetOfPicklistValue.keySet() 
									    AND TopicId IN: mapPicklistValueToTopicId.values()])
		{
			mapEntityId_TopicIdToTA.put(objTA.TopicId +'_'+ objTA.EntityId, objTA);
		}
		
		for(Id parentId : mapParentIdToSetOfPicklistValue.keySet())
		{
			for(String strPicklistValue : mapParentIdToSetOfPicklistValue.get(parentId))
			{
				if(mapPicklistValueToTopicId.containsKey(strPicklistValue) 
					&& mapEntityId_TopicIdToTA.containsKey(mapPicklistValueToTopicId.get(strPicklistValue)+'_'+parentId))
				{
					lstTopicAssignmentToDelete.add(mapEntityId_TopicIdToTA.get(mapPicklistValueToTopicId.get(strPicklistValue)+'_'+parentId));
				}
			}
		}
		
		//perform delete
		if(!lstTopicAssignmentToDelete.isEmpty())
			delete lstTopicAssignmentToDelete;
	}
	/* End */
}