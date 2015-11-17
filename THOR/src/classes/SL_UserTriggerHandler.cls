/**
*  ClassName      : SL_UserTriggerHandler
*  JIRATicket     : THOR-62
*  CreatedOn      : 25/03/2015
*  ModifiedBy     : Sanath
*  Description    : This is the handler class for User trigger
*/
public with sharing class SL_UserTriggerHandler 
{
	/*
        * MethodName   : onAfterUpdate
        * param        : trigger.oldMap,trigger.newMap
        * Description  : Will invoke on After Update of User record
    */
	public void onAfterUpdate(map<Id,User> mapOldUser,map<Id,User> mapNewUser)
	{
		Set<Id> setUserId = new Set<Id>();
		
		for(Id objUserId:mapNewUser.keyset())
		{
			///Check if Email or Title on User has been changed
			if((mapOldUser.get(objUserId).Email != mapNewUser.get(objUserId).Email)
			   || (mapOldUser.get(objUserId).Title != mapNewUser.get(objUserId).Title))
			{
				setUserId.add(objUserId);
			}
		}
		
		if(!setUserId.isEmpty())
			updateRelatedOpportunityBasedOnUser(setUserId);
	}
	
	/*
        * MethodName   : updateRelatedOpportunityBasedOnUser
        * param        : Set<Id> setUserId
        * Description  : Method to update Property_Manager_Email__c, Leasing_Agent_Title__c fields on Opportunity
    */
	private void updateRelatedOpportunityBasedOnUser(Set<Id> setUserId)
	{
		List<Opportunity> lstOpportunity = new List<Opportunity>();
		
		///Create data for opportunity to be updated
		for(Opportunity objOpportunity:[SELECT Id,Property_Manager_Email__c,Leasing_Agent_Title__c,
		                                Apartment__r.Building__r.Building_Manager__r.Email,Leasing_Agent__r.Title,
		                                Apartment__c,Apartment__r.Building__c,Apartment__r.Building__r.Building_Manager__c,Leasing_Agent__c
		                                FROM Opportunity
		                                WHERE (Apartment__r.Building__r.Building_Manager__c IN:setUserId OR Leasing_Agent__c IN:setUserId)])
		{
			if(objOpportunity.Apartment__c != null && objOpportunity.Apartment__r.Building__c != null && objOpportunity.Apartment__r.Building__r.Building_Manager__c != null)
				objOpportunity.Property_Manager_Email__c = objOpportunity.Apartment__r.Building__r.Building_Manager__r.Email;
			if(objOpportunity.Leasing_Agent__c != null)
				objOpportunity.Leasing_Agent_Title__c = objOpportunity.Leasing_Agent__r.Title;
			
			lstOpportunity.add(objOpportunity);
		}
		
		if(!lstOpportunity.isEmpty())
			database.update(lstOpportunity,false);
	} 
}