/**
* \arg ClassName      : SL_ProjectHandler
* \arg JIRATicket     : DLIB-4
* \arg CreatedOn      : 22/Aug/2014
* \arg LastModifiedOn : 25/AUg/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Handler class for SL_Project trigger.
*/
public without sharing class SL_ProjectHandler 
{
	/* Start - Variables */
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;   
	/* End - Variables */
	
	/*  Consructor */      
	public SL_ProjectHandler(boolean isExecuting, integer size)
	{
		m_isExecuting = isExecuting;
		BatchSize = size;      
	}
	/* End - Constructor */
	
	/*
		@MethodName		: onAfterInsert
		@param			: New map of id to project
		@Description	: Method to be called when a Project__c has been inserted
	*/ 
	public void onAfterInsert(Map<Id, Project__c> mapIdToProjectNew)
	{
		Map<Id, Set<String>> mapPIdToSetOfPicklistValueToInsert = new Map<Id, Set<String>>();// Map of parent id to picklist values
		Set<String> setPicklistToInsert = new Set<String>();// set of picklist values
		
		//Iterate on project for creating the topic assignment records  
		for(Project__c objProject : mapIdToProjectNew.values())   
		{
			if(!mapPIdToSetOfPicklistValueToInsert.containsKey(objProject.Id))
			{
				mapPIdToSetOfPicklistValueToInsert.put(objProject.Id, new Set<String>());
			}
			if(objProject.Classification__c != null)
			{
				setPicklistToInsert.addAll(objProject.Classification__c.split(';'));
				mapPIdToSetOfPicklistValueToInsert.get(objProject.Id).addAll(objProject.Classification__c.split(';'));
			}
		}
		SL_TopicAssigments.createTopicAssignment(mapPIdToSetOfPicklistValueToInsert, setPicklistToInsert);
	}
	/*End */
	
	/*
		@MethodName		: onAfterUpdate
		@param			: New and Old map of id to project
		@Description	: Method to be called when Project__c records has been updated
	*/
	public void onAfterUpdate(Map<Id, Project__c> mapIdToProjectOld, Map<Id, Project__c> mapIdToProjectNew)
	{
		Map<Id, Set<String>> mapPIdToSetOfPicklistValueToInsert = new Map<Id, Set<String>>();// map parent id to set of picklist values for inserting the topic assignment
		Map<Id, Set<String>> mapPIdToSetOfPicklistValueToDelete = new Map<Id, Set<String>>();// map parent id to set of picklist values for deleting the topic assignment
		Set<String> setPicklistToInsert = new Set<String>();// set of picklist values for insert topic assignment records
		Set<String> setPicklistToDelete = new Set<String>();// set of picklist values for delete topic assignment records
		Set<Id> setProjectIdUpdated = new Set<Id>();//set of project id for fetching all child Project_Asset__c records
 		
		//Iterating on Project__c for inserting and deleting Topic Assignment record corrosponding to Projects picklist values
		for(Project__c objProject : mapIdToProjectNew.values())   
		{
			if(objProject.Classification__c != mapIdToProjectOld.get(objProject.Id).Classification__c)
			{
				if(!mapPIdToSetOfPicklistValueToInsert.containsKey(objProject.Id) && !mapPIdToSetOfPicklistValueToDelete.containsKey(objProject.Id))
				{
					mapPIdToSetOfPicklistValueToInsert.put(objProject.Id, new Set<String>());
					mapPIdToSetOfPicklistValueToDelete.put(objProject.Id, new Set<String>());
				}
				if(mapIdToProjectOld.get(objProject.Id).Classification__c != null && objProject.Classification__c != null)
				{
					setProjectIdUpdated.add(objProject.Id);
					Set<String> setCommonPickValues = new Set<String>();
					Set<String> setPickValuesOld = new Set<String>();
					setPickValuesOld.addAll(mapIdToProjectOld.get(objProject.Id).Classification__c.split(';'));
					Set<String> setPickValuesNew = new Set<String>();
					setPickValuesNew.addAll(objProject.Classification__c.split(';'));
					setPickValuesOld.removeAll(objProject.Classification__c.split(';'));
					setPickValuesNew.removeAll(mapIdToProjectOld.get(objProject.Id).Classification__c.split(';'));
					setPicklistToInsert.addAll(setPickValuesNew);
					setPicklistToDelete.addAll(setPickValuesOld);
					mapPIdToSetOfPicklistValueToInsert.get(objProject.Id).addAll(setPickValuesNew);
					mapPIdToSetOfPicklistValueToDelete.get(objProject.Id).addAll(setPickValuesOld);
				}
				else if(mapIdToProjectOld.get(objProject.Id).Classification__c != null)
				{
					setProjectIdUpdated.add(objProject.Id);
					setPicklistToDelete.addAll(mapIdToProjectOld.get(objProject.Id).Classification__c.split(';'));
					mapPIdToSetOfPicklistValueToDelete.get(objProject.Id).addAll(mapIdToProjectOld.get(objProject.Id).Classification__c.split(';'));
				}
				else if(objProject.Classification__c != null)
				{
					setProjectIdUpdated.add(objProject.Id);
					setPicklistToInsert.addAll(objProject.Classification__c.split(';'));
					mapPIdToSetOfPicklistValueToInsert.get(objProject.Id).addAll(objProject.Classification__c.split(';'));
				}
			}	
		}
		
		//Iterating all the child records related to Project__c records. 
		for(Project_Asset__c objPA : [SELECT Id,
											 SL_Project__c
									    FROM Project_Asset__c
									   WHERE SL_Project__c IN : setProjectIdUpdated])
		{
			mapPIdToSetOfPicklistValueToInsert.put(objPA.Id, mapPIdToSetOfPicklistValueToInsert.get(objPA.SL_Project__c));
			mapPIdToSetOfPicklistValueToDelete.put(objPA.Id, mapPIdToSetOfPicklistValueToDelete.get(objPA.SL_Project__c));
		}
		SL_TopicAssigments.deleteTopicAssignment(mapPIdToSetOfPicklistValueToDelete, setPicklistToDelete);
		SL_TopicAssigments.createTopicAssignment(mapPIdToSetOfPicklistValueToInsert, setPicklistToInsert);
	}
	/*End */
	
	/*
		@MethodName		: onAfterUndelete
		@param			: New map of Project__c id to object
		@Description	: Method to be called when Project__c records has been Undeleted
	*/
	public void onAfterUndelete(Map<Id, Project__c> mapIdToProjectNew)
	{
		Map<Id, Set<String>> mapPIdToSetOfPicklistValueToInsert = new Map<Id, Set<String>>();// Map of parent id to picklist values
		Set<String> setPicklistToInsert = new Set<String>();// set of picklist values
		Set<Id> setProjectIdUpdated = new Set<Id>();//set of project id for fetching all child Project_Asset__c records
		
		//Iterate on project for creating the topic assignment records  
		for(Project__c objProject : mapIdToProjectNew.values())   
		{
			if(!mapPIdToSetOfPicklistValueToInsert.containsKey(objProject.Id))
			{
				mapPIdToSetOfPicklistValueToInsert.put(objProject.Id, new Set<String>());
			}
			if(objProject.Classification__c != null)
			{
				setProjectIdUpdated.add(objProject.Id);
				setPicklistToInsert.addAll(objProject.Classification__c.split(';'));
				mapPIdToSetOfPicklistValueToInsert.get(objProject.Id).addAll(objProject.Classification__c.split(';'));
			}
		}
		
		//Iterating all the child records related to Project__c records. 
		for(Project_Asset__c objPA : [SELECT Id,
											 SL_Project__c
									    FROM Project_Asset__c
									   WHERE SL_Project__c IN : setProjectIdUpdated])
		{
			mapPIdToSetOfPicklistValueToInsert.put(objPA.Id, mapPIdToSetOfPicklistValueToInsert.get(objPA.SL_Project__c));
		}
		SL_TopicAssigments.createTopicAssignment(mapPIdToSetOfPicklistValueToInsert, setPicklistToInsert);
	}
	/*End */
}