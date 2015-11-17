/**
* \arg ClassName      : SL_HilliardLyonsAccountHandler
* \arg JIRATicket     : HIL-7
* \arg CreatedOn      : 20/FEB/2015
* \arg LastModifiedOn : 6/APR/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as handler class for SL_HilliardLyonsAccount trigger and is used to update the HL account records to copy the cross object formula field values to corresponding place holder fields.
*/
public with sharing class SL_HilliardLyonsAccountHandler 
{
	/* Start - Variables */
	/* End - Variables */
	
	/* Start - Constuctor */
	public SL_HilliardLyonsAccountHandler()
	{
		//Do Nothing
	}
	/* End - Constuctor */
	
	/*
        * MethodName   : onBeforeInsert
        * Param        : new and old map of financial account records
        * Description  : This method is used to update the Hilliard Lyons Account records corresponding to financial accounts, which in turn updates the group member records
    */
	public void onBeforeInsert(List<Hilliard_Lyons_Account__c> lstHLAccount)
	{
		updateHLAccounts(lstHLAccount);
	}
	
	/*
        * MethodName   : onAfterInsert
        * Param        : new and old map of financial account records
        * Description  : This method is used to update the Hilliard Lyons Account records corresponding to financial accounts, which in turn updates the group member records
    */
	public void onAfterInsert(map<Id,Hilliard_Lyons_Account__c> newMap)
	{
		updateGroupMemberRecords(newMap.values());
		updateSharing(newMap);
	}
	
	/*
        * MethodName   : onAfterUpdate
        * Param        : new and old map of financial account records
        * Description  : This method is used to update the Hilliard Lyons Account records corresponding to financial accounts, which in turn updates the group member records
    */
	public void onAfterUpdate(Map<Id,Hilliard_Lyons_Account__c> newMap, Map<Id,Hilliard_Lyons_Account__c> oldMap)
	{
		//Set<String> setChkFields = new Set<String>{'Role__c','Rep_Code__c'};// set to contain the fields we need to check for
		//Map<Id, Sobject> mapIdToHLAccount = new Map<Id, Sobject>();// map to updated hl account records
		//mapIdToHLAccount = SL_DiffRecordUtil.getRecordsWithDiff(oldMap, newMap, setChkFields);//calling util class method to compare the values of old map and new map.
		
		//if(!mapIdToHLAccount.isEmpty())
		//{
			updateGroupMemberRecords(newMap.values());
			updateSharing(newMap);
			updateFinancialAccount(newMap, oldMap);
		//}
	}
	
	
	private void updateFinancialAccount(Map<Id,Hilliard_Lyons_Account__c> newMap, Map<Id,Hilliard_Lyons_Account__c> oldMap)
	{
		Map <Id, Set <Id>> mapClientIdToFinancialAccIds = new Map <Id, Set <Id>>();
		if(!newMap.isEmpty())
		{
			for(Hilliard_Lyons_Account__c objHilLyon : newMap.values())
			{
				Hilliard_Lyons_Account__c objOldHilLyon;
				if(!oldMap.isEmpty())
				{
					objOldHilLyon = oldMap.get(objHilLyon.Id);
					if(objHilLyon.Client__c != objOldHilLyon.Client__c)
					{
						if(!mapClientIdToFinancialAccIds.containsKey(objOldHilLyon.Client__c))
							mapClientIdToFinancialAccIds.put(objOldHilLyon.Client__c, new Set<Id>{objOldHilLyon.Financial_Account__c});
						else
							mapClientIdToFinancialAccIds.get(objOldHilLyon.Client__c).add(objOldHilLyon.Financial_Account__c);
					}
				}
			}
		}
		if(!mapClientIdToFinancialAccIds.isEmpty())
			removeFA(mapClientIdToFinancialAccIds);
	}
	private void removeFA(Map <Id, Set <Id>> mapClientIdToFinancialAccIds)
	{
		List <Group_Account__c> lstGrpAccounts = new List <Group_Account__c>(); 
		Map <Id, set<Id>> mapHouseholdToSetOfClients = new Map <Id, set<Id>>(); 
		Map <Id, List <Group_Account__c>> mapHouseholdToGrpAccs = new Map <Id, List <Group_Account__c>>(); 
		for(Group_Member__c objGrpMember : [SELECT Id, Client_Prospect__c, Relationship_Group__c FROM Group_Member__c 
												WHERE Client_Prospect__c IN: mapClientIdToFinancialAccIds.keySet()])
		{
			if(!mapHouseholdToSetOfClients.containsKey(objGrpMember.Relationship_Group__c))
				mapHouseholdToSetOfClients.put(objGrpMember.Relationship_Group__c, new Set<Id>{objGrpMember.Client_Prospect__c});
			else
				mapHouseholdToSetOfClients.get(objGrpMember.Relationship_Group__c).add(objGrpMember.Client_Prospect__c);
		}
		
		if(!mapHouseholdToSetOfClients.isEmpty())
		{
			for(Group_Account__c objGA : [SELECT Id, Financial_Account__c, Relationship_Group__c FROM Group_Account__c WHERE Relationship_Group__c 
										  IN:mapHouseholdToSetOfClients.keySet() AND Financial_Account__c !=null])
			{
				
				if(!mapHouseholdToGrpAccs.containsKey(objGA.Relationship_Group__c))
					mapHouseholdToGrpAccs.put(objGA.Relationship_Group__c, new List<Group_Account__c>{objGA});
				else
					mapHouseholdToGrpAccs.get(objGA.Relationship_Group__c).add(objGA);
				
				/*for(Id objId : mapHouseholdToSetOfClients.get(objGA.Relationship_Group__c))
				{
					if(!mapClientIdToFinancialAccIds.isEmpty() && mapClientIdToFinancialAccIds.containsKey(objId) && mapClientIdToFinancialAccIds.get(objId).contains(objGA.Financial_Account__c))
					{
						lstGrpAccounts.add(objGA);
					}
				}*/
			}
		}
		if(!mapHouseholdToGrpAccs.isEmpty())
		{
			for(Id objRGID : mapHouseholdToGrpAccs.keySet())
			{
				for(Group_Account__c objGA : mapHouseholdToGrpAccs.get(objRGID))
				{
					if(!mapHouseholdToSetOfClients.isEmpty() && mapHouseholdToSetOfClients.containsKey(objGA.Relationship_Group__c))
					{
						for(Id objId : mapHouseholdToSetOfClients.get(objGA.Relationship_Group__c))
						{
							if(!mapClientIdToFinancialAccIds.isEmpty() && mapClientIdToFinancialAccIds.containsKey(objId) && mapClientIdToFinancialAccIds.get(objId).contains(objGA.Financial_Account__c))
								lstGrpAccounts.add(objGA);
						}
					}
				}
			}
		}
		
		if (!lstGrpAccounts.isEmpty())
			delete lstGrpAccounts;
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	/*
        * MethodName   : onAfterDelete
        * Param        : new and old map of financial account records
        * Description  : This method is used to update the Hilliard Lyons Account records corresponding to financial accounts, which in turn updates the group member records
    */
	public void onAfterDelete(Map<Id,Hilliard_Lyons_Account__c> oldMap)
	{
		updateGroupMemberRecords(oldMap.values());
		updateSharing(oldMap);
	}
	
	/*
        * MethodName   : onAfterUndelete
        * Param        : new and old map of financial account records
        * Description  : This method is used to update the Hilliard Lyons Account records corresponding to financial accounts, which in turn updates the group member records
    */
	public void onAfterUndelete(List<Hilliard_Lyons_Account__c> lstHLAccount)
	{
		updateGroupMemberRecords(lstHLAccount);
	}

	private void updateSharing(map<Id,Hilliard_Lyons_Account__c> newMap)
	{
		Set<Id> acctIds = new Set<Id>();
		map<Id,Set<Id>> acctRepCodeMap = new map<Id,Set<Id>>();
		Set<String> repCodes = new Set<String>();
		map<String,Id> rcPgIdMap = new map<String,Id>();

		for(Hilliard_Lyons_Account__c h : newMap.values())
		{
			if(h.Client__c != null)
			{
				acctIds.add(h.Client__c);
			}
		}

		Hilliard_Lyons_Account__c[] hlas = [Select Id,Rep_Code__c,Client__c
											From Hilliard_Lyons_Account__c
											WHERE Client__c IN: acctIds];

		for(Hilliard_Lyons_Account__c h : hlas)
		{
			repCodes.add(h.Rep_Code__c);
		}

		Rep_Code__c[] rList = [Select Id,Name
							 From Rep_Code__c
							 WHERE Name IN: repCodes];

		for(Rep_Code__c r : rList)
		{
			rcPgIdMap.put(r.Name,r.Id);
		}

		for(Hilliard_Lyons_Account__c h : hlas)
		{
			if(h.Client__c != null && h.Rep_Code__c != null)
			{
				acctIds.add(h.Client__c);

				if(acctRepCodeMap.containsKey(h.Client__c))
				{
					acctRepCodeMap.get(h.Client__c).add(rcPgIdMap.get(h.Rep_Code__c));
				}else
				{
					acctRepCodeMap.put(h.Client__c, new Set<Id>{rcPgIdMap.get(h.Rep_Code__c)});
				}
			}
		}

		System.debug(acctRepCodeMap);

		AccountShare[] aShare = new AccountShare[]{};
		aShare = [Select Id
				  From AccountShare
				  WHERE AccountId IN: acctIds AND RowCause = 'Manual'];

		delete aShare;

		SL_Util_SharingController.RepCodeType[] shareList = new SL_Util_SharingController.RepCodeType[] {};

        if(acctRepCodeMap != null && !acctRepCodeMap.isEmpty())
        {
            for(Id i : acctRepCodeMap.keySet())
            {
                for(Id j : acctRepCodeMap.get(i))
                {
                    shareList.add(new SL_Util_SharingController.RepCodeType(i, j));
                }
            }
        }

        aShare = SL_Util_SharingController.createSharingRecords(shareList, 'Edit');

        for(AccountShare a : aShare)
        {
        	a.OpportunityAccessLevel = 'Edit';
        }

        Database.insert(aShare,false);
	}
	
	/*
        * MethodName   : updateHLAccounts
        * Param        : new and old map of financial account records
        * Description  : This method is used to update the Hilliard Lyons Account records corresponding to financial accounts, which in turn updates the group member records
    */
	private void updateHLAccounts(List<Hilliard_Lyons_Account__c> lstHLAccountToUpdate)
	{
		//Iterating over hl accounts to copy the values of formula fields to repective place holder fields.
		for(Hilliard_Lyons_Account__c objHLAccount : lstHLAccountToUpdate)
		{
			objHLAccount.Asset_Value_RU__c = objHLAccount.Asset_Value__c;
			objHLAccount.Cash_Available_RU__c = objHLAccount.Cash_Available__c;
			objHLAccount.Money_Market_RU__c = objHLAccount.Money_Market__c;
			objHLAccount.Revenue_Value_RU__c = objHLAccount.Revenue_Value__c;
		}			
	}
	
	/*
        * MethodName   : updateGroupMemberRecords
        * Param        : new and old map of financial account records
        * Description  : This method is used to update the Hilliard Lyons Account records corresponding to financial accounts, which in turn updates the group member records
    */
	private void updateGroupMemberRecords(List<Hilliard_Lyons_Account__c> lstHLAccount)
	{
		Set<Id> setClientIds = new Set<Id>();// this set is used to contain the ids of Client(Account) records.		
		for(Hilliard_Lyons_Account__c objHLAccount : lstHLAccount)
		{
			setClientIds.add(objHLAccount.Client__c);
		}
		if(!setClientIds.isEmpty())
		{
			SL_UpdateGroupMemberController.updateGroupMembers(new Map<Id, Group_Member__c>([SELECT Id FROM Group_Member__c WHERE Client_Prospect__c IN : setClientIds]).keyset());
			SL_Util_UpdateAccountController.updateAccount(setClientIds);
		}
	}
}