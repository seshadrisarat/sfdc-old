/**
* \arg ClassName        : SL_DealHandler
* \arg JIRATicket     	: FBR-1
* \arg CreatedOn      	: 19/MAR/2015
* \arg LastModifiedOn   : -
* \arg CreatededBy    	: Nrusingh
* \arg LastModifiedBy	: -
*/

public without sharing class SL_DealHandler 
{
	/* Start - Variables */
	static final String READ_PERMISSION = 'Read';
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_DealHandler()
	{
		//Do Nothing
	}
	/* End - Constructor */
	
	/*
        * MethodName   : onBeforeInsert
        * Param        : map of inserted deals
        * Description  : This method is used to update the Deal owner
    */
	public void onBeforeInsert(List <Deals__c> lstInsertedDeals)
	{
		// Calling updateDealOwner method 
		updateDealOwner(lstInsertedDeals,'beforeInsert');
	}
	
	
	/*
        * MethodName   : onAfterInsert
        * Param        : map of inserted deals
        * Description  : This method is used to create the child Deal Team Member record and create Deals_Share object
    */
	public void onAfterInsert(List <Deals__c> lstInsertedDeals)
	{
		// Calling updateDealOwner method
		updateDealOwner(lstInsertedDeals,'afterInsert');
	}
	
	/*
        * MethodName   : onAfterUpdate
        * Param        : Map of new Deal and Map of old Deal 
        * Description  : This method is used to update the Deal owner
    */
	public void onBeforeUpdate(Map<Id,Deals__c> mapNewUpdatedDeal, Map<Id,Deals__c> mapOldUpdatedDeal)
	{
		Map<Id,Deals__c> mapDealIdToDeal = new Map<Id,Deals__c> ();
		
		for(Deals__c objDeal : mapNewUpdatedDeal.values())
		{
			if(objDeal.Lead_Banker__c != null && objDeal.Lead_Banker__c != mapOldUpdatedDeal.get(objDeal.Id).Lead_Banker__c)
			{
				mapDealIdToDeal.put(objDeal.id, objDeal);
			}
		}
		
		// Checking if the deals.Lead_Banker__c is updated and calling updateDealOwner method
		if(!mapDealIdToDeal.isEmpty() && mapDealIdToDeal != null)
			updateDealOwner(mapDealIdToDeal.values(),'beforeUpdate');
	}
	
	/*
        * MethodName   : onAfterUpdate
        * Param        : Map of new Deal and Map of old Deal 
        * Description  : This method is used to create the child Deal Team Member record and update permission of Deal as read.
    */
	public void onAfterUpdate(Map<Id,Deals__c> mapNewUpdatedDeal, Map<Id,Deals__c> mapOldUpdatedDeal)
	{
		Map<Id,Deals__c> mapDealIdToDeal = new Map<Id,Deals__c> ();
		for(Deals__c objDeal : mapNewUpdatedDeal.values())
		{
			if(objDeal.Lead_Banker__c != mapOldUpdatedDeal.get(objDeal.Id).Lead_Banker__c)
			{
				mapDealIdToDeal.put(objDeal.id, objDeal);
			}
		}
		
		// Checking if the deals.Lead_Banker__c is updated and calling updateDealOwner method
		if(!mapDealIdToDeal.isEmpty() && mapDealIdToDeal != null)
			updateDealOwner(mapDealIdToDeal.values(),'afterUpdate');
	}
	
	/*
        * MethodName   : updateDealOwner
        * Param        : mapInsertedDeal, mapDealIdToCreatedById
        * Description  : update Deal owner, insert Deal Team Member, Create Sharing Record methods are called
    */
	private void updateDealOwner(List <Deals__c> lstInsertedDeals, String strBeforeOrAfter)
	{
		
		Map<Id,Id> mapDealIdToCreatedById = new Map <Id,Id> ();
		Set <Id> setBankerId = new Set <Id> (); 
		Map <Id,Id> mapContactIdToUserId = new Map <Id,Id> ();
		Set <Id> setDealId = new Set <Id> (); 
		
		// Itereting through the map of newly inserting/updating Deals and maintain a map of Deal and Deal.Lead Banker
		for(Deals__c objDeal : lstInsertedDeals)
		{
			setBankerId.add(objDeal.Lead_Banker__c);
			
			if(objDeal.id != null)
			{
				setDealId.add(objDeal.id);
				mapDealIdToCreatedById.put(objDeal.id, objDeal.CreatedById);
			}
		}
		
		// Checking if the mapDealIdToLeadBankerId is not empty and not null
		if(!setBankerId.isEmpty() && setBankerId != null)
		{
			// Fetching Contact.User where Contact id present in the previous map and User__c not null
			for(Contact objContact : [SELECT Id, User__c FROM Contact WHERE Id IN: setBankerId AND User__c != null])
			{
				mapContactIdToUserId.put(objContact.Id,objContact.User__c);
			}
			
			// mapContactIdToUserId is not null calling updateDeal and createSharingRecords method
			if((!mapContactIdToUserId.isEmpty() && mapContactIdToUserId != null) && (strBeforeOrAfter == 'beforeInsert' || strBeforeOrAfter == 'beforeUpdate'))
			{
				// Calling updateDeal method
				updateDeal(lstInsertedDeals,mapContactIdToUserId);
			}
			// calling insertDealTeamMemberAndCreateSharingRec record 
			if(strBeforeOrAfter == 'afterInsert' || strBeforeOrAfter == 'afterUpdate')
				insertDealTeamMemberAndCreateSharingRec(lstInsertedDeals,mapDealIdToCreatedById,setDealId);
		}
	}
	
	/*
        * MethodName   : updateDeal
        * Param        : mapDealIdToLeadBankerId, mapContactIdToUserId
        * Description  : This method is used to update the Deal owner
    */
	private void updateDeal(List <Deals__c>lstDeals, Map <Id,Id> mapContactIdToUserId)
	{
		if(!mapContactIdToUserId.isEmpty() && mapContactIdToUserId != null)
		{
			for(Deals__c objDeal : lstDeals)
			{
				if(mapContactIdToUserId.containsKey(objDeal.Lead_Banker__c))
					objDeal.OwnerId = mapContactIdToUserId.get(objDeal.Lead_Banker__c);
			}
		}
	}
	
	/*
        * MethodName   : insertDealTeamMember
        * Param        : mapDealIdToLeadBankerId
        * Description  : This method is used to insert child Deal Team Member and insert sharing record
    */
	private void insertDealTeamMemberAndCreateSharingRec (List <Deals__c>lstDeals, Map<Id,Id> mapDealIdToCreatedById, Set <Id> setDealId)
	{
		List <Deal_Team_Member__c> lstInsertDealTeamMember = new List <Deal_Team_Member__c> ();
		List<Deals__Share> lstDealShare = new List<Deals__Share>();
		Map <Id,Set<Id>> mapDealIdToSetOfContactId = new Map <Id,Set<Id>> ();
		
		// Query to get all the Deal Team Members related to the particular Deal for avoiding duplicate Deal Team Member 
		for(Deal_Team_Member__c objDealTeamMember : [SELECT Id,Related_Deal__c, FBR_Team_Member__c FROM  Deal_Team_Member__c WHERE Related_Deal__c IN: setDealId])
		{
			if(mapDealIdToSetOfContactId.containsKey(objDealTeamMember.Related_Deal__c))
	        	mapDealIdToSetOfContactId.get(objDealTeamMember.Related_Deal__c).add(objDealTeamMember.FBR_Team_Member__c);
  			else
   				mapDealIdToSetOfContactId.put(objDealTeamMember.Related_Deal__c,new Set<Id>{objDealTeamMember.FBR_Team_Member__c});
		}
		
		for(Deals__c objDeal : lstDeals)
		{
			if((mapDealIdToSetOfContactId.isEmpty() || mapDealIdToSetOfContactId == null)
			 || (!mapDealIdToSetOfContactId.isEmpty() && mapDealIdToSetOfContactId != null && mapDealIdToSetOfContactId.containsKey(objDeal.Id) 
			 && !mapDealIdToSetOfContactId.get(objDeal.Id).contains(objDeal.Lead_Banker__c)))
				lstInsertDealTeamMember.add(new Deal_Team_Member__c(Related_Deal__c = objDeal.Id, FBR_Team_Member__c = objDeal.Lead_Banker__c));
			
			if(!mapDealIdToCreatedById.isEmpty() && mapDealIdToCreatedById.containsKey(objDeal.Id))
				lstDealShare.add(new Deals__Share(ParentId = objDeal.Id, UserOrGroupId = mapDealIdToCreatedById.get(objDeal.Id), AccessLevel = READ_PERMISSION));
		}
		
		// Inserting new Deal Team Member based on the newly inserting / updating Deal.Contact
		if(!lstInsertDealTeamMember.isEmpty() && lstInsertDealTeamMember != null)
			insert  lstInsertDealTeamMember;
		
		// Insert Deal Share record
		if(!lstDealShare.isEmpty())
			Database.insert(lstDealShare,false);
	}
}