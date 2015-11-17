/**
* @ClassName 		: SL_ProjectAssetHandler
* @JIRATicket   	: DLIB-3
* @CreatedOn    	: 20/AUG/2014
* @ModifiedBy   	: Harsh
* @Description 	 	: This is the controller class for SL_ProjectAssetHandler trigger.
*/

public without sharing class SL_ProjectAssetHandler 
{
	/* Start - Variables */
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;   
	/* End - Variables */
	
	/*  Consructor */      
	public SL_ProjectAssetHandler(boolean isExecuting, integer size)
	{
		m_isExecuting = isExecuting;
		BatchSize = size;      
	}
	
	/*   
		@MethodName		: onAfterInsert
		@param			: lstNewProjectAsset (Trigger New Values)
		@Description	: Method to be called when a Project_Asset__c has been inserted
	*/    
	public void onAfterInsert(List<Project_Asset__c> lstProjectAssetNew)
	{
		manageTopicAssigment(lstProjectAssetNew);
	}   
	
	/*   
		@MethodName		: onAfterUpdate
		@param			: mapProjectAssetOld (Trigger Old Values), mapProjectAssetNew (Trigger New Values)
		@Description	: Method to be called when a Project_Asset__c has been updated
	*/
	public void onAfterUpdate(Map<Id, Project_Asset__c> mapProjectAssetOld, Map<Id, Project_Asset__c> mapProjectAssetNew)
	{
		Map<Id, Project_Asset__c> mapIdToProjectAsset = new Map<Id, Project_Asset__c>();//Map contains Id to Project Asset object
		Map<Id, Set<String>> mapPAIdToSetOfPicklistValueToInsert = new Map<Id, Set<String>>();//Map of Project Asset Id to Set of Picklist Values for Insert case
		Map<Id, Set<String>> mapPAIdToSetOfPicklistValueToDelete = new Map<Id, Set<String>>();//Map contains Project Asset Id to set of Picklist value for Delete Case
		Set<String> setPicklistToInsert = new Set<String>();//Set of Picklist values for Insert case
		Set<String> setPicklistToDelete = new Set<String>();//Set of Picklist values for Delete case
		
		for(Project_Asset__c objProjectAsset : mapProjectAssetNew.values())   
		{
			//Checking the Condition whether the Picklist values has been modified or not.
			if(mapProjectAssetOld.get(objProjectAsset.Id).Integration_Tools__c != objProjectAsset.Integration_Tools__c ||
			   mapProjectAssetOld.get(objProjectAsset.Id).Custom_Dev_Type__c != objProjectAsset.Custom_Dev_Type__c ||
			   mapProjectAssetOld.get(objProjectAsset.Id).Miscellaneous__c != objProjectAsset.Miscellaneous__c ||
			   mapProjectAssetOld.get(objProjectAsset.Id).Legacy_Systems__c != objProjectAsset.Legacy_Systems__c ||
			   mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_Features__c != objProjectAsset.Salesforce_Features__c ||
			   mapProjectAssetOld.get(objProjectAsset.Id).Vendor__c !=objProjectAsset.Vendor__c ||
			   mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_Product__c != objProjectAsset.Salesforce_Product__c || 
			   mapProjectAssetOld.get(objProjectAsset.Id).Silverline_Product__c != objProjectAsset.Silverline_Product__c ||
			   mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_License_Type__c != objProjectAsset.Salesforce_License_Type__c)
			{
				
				if(!mapPAIdToSetOfPicklistValueToInsert.containsKey(objProjectAsset.Id) && !mapPAIdToSetOfPicklistValueToDelete.containsKey(objProjectAsset.Id))
				{
					mapPAIdToSetOfPicklistValueToInsert.put(objProjectAsset.Id, new Set<String>());
					mapPAIdToSetOfPicklistValueToDelete.put(objProjectAsset.Id, new Set<String>());
				}
				//for Integration_Tools__c Multiselected Picklist values 
				if(mapProjectAssetOld.get(objProjectAsset.Id).Integration_Tools__c != null && objProjectAsset.Integration_Tools__c != null)
				{
					Set<String> setCommonPickValues = new Set<String>();
					Set<String> setPickValuesOld = new Set<String>();
					setPickValuesOld.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Integration_Tools__c.split(';'));
					Set<String> setPickValuesNew = new Set<String>();
					setPickValuesNew.addAll(objProjectAsset.Integration_Tools__c.split(';'));
					setPickValuesOld.removeAll(objProjectAsset.Integration_Tools__c.split(';'));
					setPickValuesNew.removeAll(mapProjectAssetOld.get(objProjectAsset.Id).Integration_Tools__c.split(';'));
					setPicklistToInsert.addAll(setPickValuesNew);
					setPicklistToDelete.addAll(setPickValuesOld);
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(setPickValuesNew);
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(setPickValuesOld);
				}
				else if(mapProjectAssetOld.get(objProjectAsset.Id).Integration_Tools__c != null)
				{
					setPicklistToDelete.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Integration_Tools__c.split(';'));
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(mapProjectAssetOld.get(objProjectAsset.Id).Integration_Tools__c.split(';'));
				}
				else if(objProjectAsset.Integration_Tools__c != null)
				{
					setPicklistToInsert.addAll(objProjectAsset.Integration_Tools__c.split(';'));
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Integration_Tools__c.split(';'));
				}
				
				//for Custom_Dev_Type__c Multiselected Picklist values 
				if(mapProjectAssetOld.get(objProjectAsset.Id).Custom_Dev_Type__c != null && objProjectAsset.Custom_Dev_Type__c != null)
				{
					Set<String> setCommonPickValues = new Set<String>();
					Set<String> setPickValuesOld = new Set<String>();
					setPickValuesOld.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Custom_Dev_Type__c.split(';'));
					Set<String> setPickValuesNew = new Set<String>();
					setPickValuesNew.addAll(objProjectAsset.Custom_Dev_Type__c.split(';'));
					setPickValuesOld.removeAll(objProjectAsset.Custom_Dev_Type__c.split(';'));
					setPickValuesNew.removeAll(mapProjectAssetOld.get(objProjectAsset.Id).Custom_Dev_Type__c.split(';'));
					setPicklistToInsert.addAll(setPickValuesNew);
					setPicklistToDelete.addAll(setPickValuesOld);
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(setPickValuesNew);
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(setPickValuesOld);
				}
				else if(mapProjectAssetOld.get(objProjectAsset.Id).Custom_Dev_Type__c != null)
				{
					setPicklistToDelete.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Custom_Dev_Type__c.split(';'));
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(mapProjectAssetOld.get(objProjectAsset.Id).Custom_Dev_Type__c.split(';'));
				}
				else if(objProjectAsset.Custom_Dev_Type__c != null)
				{
					setPicklistToInsert.addAll(objProjectAsset.Custom_Dev_Type__c.split(';'));
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Custom_Dev_Type__c.split(';'));
				}
				
				//for Miscellaneous__c Multiselected Picklist values 
				if(mapProjectAssetOld.get(objProjectAsset.Id).Miscellaneous__c != null && objProjectAsset.Miscellaneous__c != null)
				{
					Set<String> setCommonPickValues = new Set<String>();
					Set<String> setPickValuesOld = new Set<String>();
					setPickValuesOld.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Miscellaneous__c.split(';'));
					Set<String> setPickValuesNew = new Set<String>();
					setPickValuesNew.addAll(objProjectAsset.Miscellaneous__c.split(';'));
					setPickValuesOld.removeAll(objProjectAsset.Miscellaneous__c.split(';'));
					setPickValuesNew.removeAll(mapProjectAssetOld.get(objProjectAsset.Id).Miscellaneous__c.split(';'));
					setPicklistToInsert.addAll(setPickValuesNew);
					setPicklistToDelete.addAll(setPickValuesOld);
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(setPickValuesNew);
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(setPickValuesOld);
				}
				else if(mapProjectAssetOld.get(objProjectAsset.Id).Miscellaneous__c != null)
				{
					setPicklistToDelete.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Miscellaneous__c.split(';'));
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(mapProjectAssetOld.get(objProjectAsset.Id).Miscellaneous__c.split(';'));
				}
				else if(objProjectAsset.Miscellaneous__c != null)
				{
					setPicklistToInsert.addAll(objProjectAsset.Miscellaneous__c.split(';'));
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Miscellaneous__c.split(';'));
				}
				
				//for Legacy_Systems__c Multiselected Picklist values 
				if(mapProjectAssetOld.get(objProjectAsset.Id).Legacy_Systems__c != null && objProjectAsset.Legacy_Systems__c != null)
				{
					Set<String> setCommonPickValues = new Set<String>();
					Set<String> setPickValuesOld = new Set<String>();
					setPickValuesOld.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Legacy_Systems__c.split(';'));
					Set<String> setPickValuesNew = new Set<String>();
					setPickValuesNew.addAll(objProjectAsset.Legacy_Systems__c.split(';'));
					setPickValuesOld.removeAll(objProjectAsset.Legacy_Systems__c.split(';'));
					setPickValuesNew.removeAll(mapProjectAssetOld.get(objProjectAsset.Id).Legacy_Systems__c.split(';'));
					setPicklistToInsert.addAll(setPickValuesNew);
					setPicklistToDelete.addAll(setPickValuesOld);
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(setPickValuesNew);
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(setPickValuesOld);
				}
				else if(mapProjectAssetOld.get(objProjectAsset.Id).Legacy_Systems__c != null)
				{
					setPicklistToDelete.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Legacy_Systems__c.split(';'));
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(mapProjectAssetOld.get(objProjectAsset.Id).Legacy_Systems__c.split(';'));
				}
				else if(objProjectAsset.Legacy_Systems__c != null)
				{
					setPicklistToInsert.addAll(objProjectAsset.Legacy_Systems__c.split(';'));
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Legacy_Systems__c.split(';'));
				}
				
				//for Salesforce_Features__c Multiselected Picklist values 
				if(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_Features__c != null && objProjectAsset.Salesforce_Features__c != null)
				{
					Set<String> setCommonPickValues = new Set<String>();
					Set<String> setPickValuesOld = new Set<String>();
					setPickValuesOld.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_Features__c.split(';'));
					Set<String> setPickValuesNew = new Set<String>();
					setPickValuesNew.addAll(objProjectAsset.Salesforce_Features__c.split(';'));
					setPickValuesOld.removeAll(objProjectAsset.Salesforce_Features__c.split(';'));
					setPickValuesNew.removeAll(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_Features__c.split(';'));
					setPicklistToInsert.addAll(setPickValuesNew);
					setPicklistToDelete.addAll(setPickValuesOld);
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(setPickValuesNew);
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(setPickValuesOld);
				}
				else if(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_Features__c != null)
				{
					setPicklistToDelete.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_Features__c.split(';'));
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_Features__c.split(';'));
				}
				else if(objProjectAsset.Salesforce_Features__c != null)
				{
					setPicklistToInsert.addAll(objProjectAsset.Salesforce_Features__c.split(';'));
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Salesforce_Features__c.split(';'));
				}
				
				//for Vendor__c Multiselected Picklist values 
				if(mapProjectAssetOld.get(objProjectAsset.Id).Vendor__c != null && objProjectAsset.Vendor__c != null)
				{
					Set<String> setCommonPickValues = new Set<String>();
					Set<String> setPickValuesOld = new Set<String>();
					setPickValuesOld.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Vendor__c.split(';'));
					Set<String> setPickValuesNew = new Set<String>();
					setPickValuesNew.addAll(objProjectAsset.Vendor__c.split(';'));
					setPickValuesOld.removeAll(objProjectAsset.Vendor__c.split(';'));
					setPickValuesNew.removeAll(mapProjectAssetOld.get(objProjectAsset.Id).Vendor__c.split(';'));
					setPicklistToInsert.addAll(setPickValuesNew);
					setPicklistToDelete.addAll(setPickValuesOld);
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(setPickValuesNew);
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(setPickValuesOld);
				}
				else if(mapProjectAssetOld.get(objProjectAsset.Id).Vendor__c != null)
				{
					setPicklistToDelete.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Vendor__c.split(';'));
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(mapProjectAssetOld.get(objProjectAsset.Id).Vendor__c.split(';'));
				}
				else if(objProjectAsset.Vendor__c != null)
				{
					setPicklistToInsert.addAll(objProjectAsset.Vendor__c.split(';'));
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Vendor__c.split(';'));
				}
				
				//for Salesforce_Product__c Multiselected Picklist values 
				if(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_Product__c != null && objProjectAsset.Salesforce_Product__c != null)
				{
					Set<String> setCommonPickValues = new Set<String>();
					Set<String> setPickValuesOld = new Set<String>();
					setPickValuesOld.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_Product__c.split(';'));
					Set<String> setPickValuesNew = new Set<String>();
					setPickValuesNew.addAll(objProjectAsset.Salesforce_Product__c.split(';'));
					setPickValuesOld.removeAll(objProjectAsset.Salesforce_Product__c.split(';'));
					setPickValuesNew.removeAll(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_Product__c.split(';'));
					setPicklistToInsert.addAll(setPickValuesNew);
					setPicklistToDelete.addAll(setPickValuesOld);
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(setPickValuesNew);
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(setPickValuesOld);
				}
				else if(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_Product__c != null)
				{
					setPicklistToDelete.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_Product__c.split(';'));
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_Product__c.split(';'));
				}
				else if(objProjectAsset.Salesforce_Product__c != null)
				{
					setPicklistToInsert.addAll(objProjectAsset.Salesforce_Product__c.split(';'));
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Salesforce_Product__c.split(';'));
				}
				
				//for Silverline_Product__c Multiselected Picklist values 
				if(mapProjectAssetOld.get(objProjectAsset.Id).Silverline_Product__c != null && objProjectAsset.Silverline_Product__c != null)
				{
					Set<String> setCommonPickValues = new Set<String>();
					Set<String> setPickValuesOld = new Set<String>();
					setPickValuesOld.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Silverline_Product__c.split(';'));
					Set<String> setPickValuesNew = new Set<String>();
					setPickValuesNew.addAll(objProjectAsset.Silverline_Product__c.split(';'));
					setPickValuesOld.removeAll(objProjectAsset.Silverline_Product__c.split(';'));
					setPickValuesNew.removeAll(mapProjectAssetOld.get(objProjectAsset.Id).Silverline_Product__c.split(';'));
					setPicklistToInsert.addAll(setPickValuesNew);
					setPicklistToDelete.addAll(setPickValuesOld);
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(setPickValuesNew);
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(setPickValuesOld);
				}
				else if(mapProjectAssetOld.get(objProjectAsset.Id).Silverline_Product__c != null)
				{
					setPicklistToDelete.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Silverline_Product__c.split(';'));
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(mapProjectAssetOld.get(objProjectAsset.Id).Silverline_Product__c.split(';'));
				}
				else if(objProjectAsset.Silverline_Product__c != null)
				{
					setPicklistToInsert.addAll(objProjectAsset.Silverline_Product__c.split(';'));
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Silverline_Product__c.split(';'));
				}
				
				
				//for Salesforce_License_Type__c Multiselected Picklist values 
				if(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_License_Type__c != null && objProjectAsset.Salesforce_License_Type__c != null)
				{
					Set<String> setCommonPickValues = new Set<String>();
					Set<String> setPickValuesOld = new Set<String>();   
					setPickValuesOld.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_License_Type__c.split(';'));
					Set<String> setPickValuesNew = new Set<String>();
					setPickValuesNew.addAll(objProjectAsset.Salesforce_License_Type__c.split(';'));
					setPickValuesOld.removeAll(objProjectAsset.Salesforce_License_Type__c.split(';'));
					setPickValuesNew.removeAll(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_License_Type__c.split(';'));
					setPicklistToInsert.addAll(setPickValuesNew);
					setPicklistToDelete.addAll(setPickValuesOld);
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(setPickValuesNew);
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(setPickValuesOld);
				}
				else if(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_License_Type__c != null)
				{
					setPicklistToDelete.addAll(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_License_Type__c.split(';'));
					mapPAIdToSetOfPicklistValueToDelete.get(objProjectAsset.Id).addAll(mapProjectAssetOld.get(objProjectAsset.Id).Salesforce_License_Type__c.split(';'));
				} 
				else if(objProjectAsset.Salesforce_License_Type__c != null)
				{
					setPicklistToInsert.addAll(objProjectAsset.Salesforce_License_Type__c.split(';'));
					mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Salesforce_License_Type__c.split(';'));
				}
			}
		}
		SL_TopicAssigments.deleteTopicAssignment(mapPAIdToSetOfPicklistValueToDelete, setPicklistToDelete);
		SL_TopicAssigments.createTopicAssignment(mapPAIdToSetOfPicklistValueToInsert, setPicklistToInsert);
	}
	/* End */
	
	/*   
		@MethodName		: onAfterUndelete
		@param			: list of Project_Asset__c
		@Description	: Method to be called when a Project_Asset__c has been undeleted
	*/
	
	public void onAfterUndelete(List<Project_Asset__c> lstProjectAssetNew)
	{
		manageTopicAssigment(lstProjectAssetNew);
	}
	/* End */
	
	/*   
		@MethodName		: manageTopicAssigment()
		@param			: list of Project_Asset__c
		@Description	: Method to be called when a Project_Asset__c has been undeleted
	*/
	private void manageTopicAssigment(List<Project_Asset__c> lstProjectAsset)
	{
		Map<Id, Set<String>> mapPAIdToSetOfPicklistValueToInsert = new Map<Id, Set<String>>();//Map contains Project Asset Id to set of Picklist values for Insert case
		Set<String> setPicklistValues = new Set<String>(); //set for Picklist values
		
		for(Project_Asset__c objProjectAsset : lstProjectAsset)   
		{
			if(!mapPAIdToSetOfPicklistValueToInsert.containsKey(objProjectAsset.Id))
			{
				mapPAIdToSetOfPicklistValueToInsert.put(objProjectAsset.Id, new Set<String>());
			}
			
			//Filter all Piclist values that are not null to add in set
			if(objProjectAsset.Integration_Tools__c != null)
			{
				setPicklistValues.addAll(objProjectAsset.Integration_Tools__c.split(';'));
				mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Integration_Tools__c.split(';'));
			}
			if(objProjectAsset.Custom_Dev_Type__c != null)
			{
				setPicklistValues.addAll(objProjectAsset.Custom_Dev_Type__c.split(';'));
				mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Custom_Dev_Type__c.split(';'));
			}
			if(objProjectAsset.Legacy_Systems__c != null)
			{
				setPicklistValues.addAll(objProjectAsset.Legacy_Systems__c.split(';'));
				mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Legacy_Systems__c.split(';'));
			}
			if(objProjectAsset.Miscellaneous__c != null)
			{
				setPicklistValues.addAll(objProjectAsset.Miscellaneous__c.split(';'));
				mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Miscellaneous__c.split(';'));
			}
			if(objProjectAsset.Salesforce_Features__c != null)
			{
				setPicklistValues.addAll(objProjectAsset.Salesforce_Features__c.split(';'));
				mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Salesforce_Features__c.split(';'));
			}
			if(objProjectAsset.Vendor__c != null)
			{
				setPicklistValues.addAll(objProjectAsset.Vendor__c.split(';'));
				mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Vendor__c.split(';'));
			}
			if(objProjectAsset.Salesforce_Product__c != null)
			{
				setPicklistValues.addAll(objProjectAsset.Salesforce_Product__c.split(';'));
				mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Salesforce_Product__c.split(';'));
			}
			if(objProjectAsset.Silverline_Product__c != null)
			{
				setPicklistValues.addAll(objProjectAsset.Silverline_Product__c.split(';'));
				mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Silverline_Product__c.split(';'));

			}
			if(objProjectAsset.Salesforce_License_Type__c != null)
			{
				setPicklistValues.addAll(objProjectAsset.Salesforce_License_Type__c.split(';'));
				mapPAIdToSetOfPicklistValueToInsert.get(objProjectAsset.Id).addAll(objProjectAsset.Salesforce_License_Type__c.split(';'));
			}
		}
		SL_TopicAssigments.createTopicAssignment(mapPAIdToSetOfPicklistValueToInsert, setPicklistValues);
	}
	/* End */
}