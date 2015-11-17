/**
*  ClassName      : SL_BuildingTriggerHandler
*  JIRATicket     : THOR-62
*  CreatedOn      : 27/03/2015
*  ModifiedBy     : Sanath
*  Description    : This is the handler class for Building trigger
*/
public with sharing class SL_BuildingTriggerHandler 
{
	/*
        * MethodName   : onAfterUpdate
        * param        : trigger.oldMap,trigger.newMap
        * Description  : Will invoke on After Update of Building__c record
    */
	public void onAfterUpdate(map<Id,Building__c> mapOldBuilding,map<Id,Building__c> mapNewBuilding)
	{
		Set<Id> setBuildingId = new Set<Id>();
		
		///Create a set of Building id whose Building_Manager__c field ahs been updated
		for(Id objBuildingId:mapNewBuilding.keyset())
		{
			if(mapOldBuilding.get(objBuildingId).Building_Manager__c != mapNewBuilding.get(objBuildingId).Building_Manager__c)
			{
				setBuildingId.add(objBuildingId);
			}
		}
		
		if(!setBuildingId.isEmpty())
			updateRelatedOpportunityBasedOnBuildingManager(setBuildingId);
	}
	
	
	/*
        * MethodName   : updateRelatedOpportunityBasedOnBuildingManager
        * param        : Set<Id> setBuildingId
        * Description  : Will update Property_Manager_Email__c field on Opportunity
    */
	private void updateRelatedOpportunityBasedOnBuildingManager(Set<Id> setBuildingId)
	{
		List<Opportunity> lstOpportunity = new List<Opportunity>();
		
		///Update Property_Manager_Email__c field on Opportunity
		for(Opportunity objOpportunity:[SELECT Id,Property_Manager_Email__c,Apartment__r.Building__r.Building_Manager__r.Email,
		                                Apartment__c,Apartment__r.Building__c,Apartment__r.Building__r.Building_Manager__c
		                                FROM Opportunity
		                                WHERE Apartment__r.Building__c IN:setBuildingId])
		{
			if(objOpportunity.Apartment__c != null && objOpportunity.Apartment__r.Building__c != null && objOpportunity.Apartment__r.Building__r.Building_Manager__c != null)
				objOpportunity.Property_Manager_Email__c = objOpportunity.Apartment__r.Building__r.Building_Manager__r.Email;
			else if(objOpportunity.Apartment__c != null && objOpportunity.Apartment__r.Building__c != null && objOpportunity.Apartment__r.Building__r.Building_Manager__c == null)
				objOpportunity.Property_Manager_Email__c = ''; 
				
			lstOpportunity.add(objOpportunity);
		}
		
		if(!lstOpportunity.isEmpty())
			database.update(lstOpportunity,false);
	}
}