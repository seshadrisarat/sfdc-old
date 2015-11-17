/**
* \arg ClassName      : SL_FinancialAccountHandler
* \arg JIRATicket     : HIL-7
* \arg CreatedOn      : 18/FEB/2015
* \arg LastModifiedOn : 4/APR/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as handler class for SL_FinancialAccount trigger and is used to update the HL account records corresponding to updated financial accounts which in turn updates the Group member records.
*/
public with sharing class SL_FinancialAccountHandler 
{
	/* Start - Variables */
	static Set<Id> setGMIdsToUpdate = new Set<Id>();// This set is used to contain the ids of group member records that will be passed to the future method to update the corresponding group member records on after delete.
	static Set<Id> setAccountIdToUpdate = new Set<Id>(); //This set is used to contain the account ids corresponding to the HL account records.
	static Set<Id> setFinanicalAccountIdDeleted = new Set<Id>();
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_FinancialAccountHandler()
	{
		//Do Nothing
	}
	/* End - Constructor */

	public void onAfterInsert(Map<Id, Financial_Account__c> newMap)
	{
		updateSharing(newMap);
	}
	
	/*
        * MethodName   : onAfterUpdate
        * Param        : new and old map of financial account records
        * Description  : This method is used to update the Hilliard Lyons Account records corresponding to financial accounts, which in turn updates the group member records
    */
	public void onAfterUpdate(Map<Id, Financial_Account__c> oldMap, Map<Id, Financial_Account__c> newMap)
	{
		Set<String> chkFlds = new Set<String>{'Money_Market_Balance__c','Revenue__c','Cash_Available__c','Total_Account_Equity__c' ,'Rep_Code__c'}; //List of fields we are checking for
		Map<Id,Sobject> finAcctMap = new Map<Id,Sobject>();// map of updated financial account records
		Set<Id> setGMIds = new Set<Id>();// set to hold the ids of group member records
		
		//calling util class to compare oldmap values with newmap to detect the difference
		//finAcctMap = SL_DiffRecordUtil.getRecordsWithDiff(oldMap, newMap, chkFlds);
		
		if(!finAcctMap.isEmpty())
		{
			//setGMIds = updateHLAccounts(finAcctMap.keySet());
			//if(!setGMIds.isEmpty())
				//SL_UpdateGroupMemberController.updateGroupMembers(setGMIds);
		}

		updateSharing(newMap);
		updateFinancialAccount(oldMap, newMap);

		map<Id,Hilliard_Lyons_Account__c> hMap = new map<Id,Hilliard_Lyons_Account__c>([Select Id,Client__c From Hilliard_Lyons_Account__c WHERE Financial_Account__c IN: newMap.keyset()]);

		SL_HilliardLyonsAccountHandler h = new SL_HilliardLyonsAccountHandler();
		h.onAfterUpdate(hMap,hMap);
	}
	
	/*
        * MethodName   : updateFinancialAccount
        * Param        : new and old map of financial account records
        * Description  : This method is used to update the Group Accounts
    */
	
	private void updateFinancialAccount(Map<Id, Financial_Account__c> oldMap, Map<Id, Financial_Account__c> newMap)
	{
		Map <Id, Id>  mapFAIdToRepId= new Map <Id, Id>(); 
		List <Group_Account__c> lstGAToBeUpdated = new List <Group_Account__c>(); 
		for(Financial_Account__c objFA : newMap.values())
		{
			Financial_Account__c objOldFA = oldMap.get(objFA.Id);
			if(objFA.Rep_Code__c != objOldFA.Rep_Code__c)
			{
				mapFAIdToRepId.put(objFA.Id,objOldFA.Rep_Code__c);
			}
		}
		
		if(!mapFAIdToRepId.isEmpty())
		{
			for(Group_Account__c objGA : [SELECT Id, Financial_Account__c,Relationship_Group__r.Rep_Code__c, Relationship_Group__c FROM Group_Account__c WHERE Financial_Account__c IN:mapFAIdToRepId.keySet() AND Relationship_Group__c !=null
											AND Relationship_Group__r.Rep_Code__c IN: mapFAIdToRepId.values()])
			{
				lstGAToBeUpdated.add(new Group_Account__c(Id = objGA.Id,Relationship_Group__c = null, Financial_Account__c = null ));
			}
		}
		update lstGAToBeUpdated;
	}
	
	
	/*
        * MethodName   : onBeforeDelete
        * Param        : old map of financial account records
        * Description  : This method is used to update the Hilliard Lyons Account records corresponding to financial accounts, which in turn updates the group member records
    */
	public void onBeforeDelete(Map<Id, Financial_Account__c> mapOldIdToFinAccount)
	{		
		//storing the ids of group member records in global set so that they can be utilized in after update method to update the corresponding group members.
		//setGMIdsToUpdate = updateHLAccounts(mapOldIdToFinAccount.keyset());
		
		setAccountIdToUpdate = getAccountIds(mapOldIdToFinAccount.keyset());
		setFinanicalAccountIdDeleted = mapOldIdToFinAccount.keyset();
	}
	
	/*
        * MethodName   : onAfterDelete
        * Param        : -
        * Description  : This method is used to update the Hilliard Lyons Account records corresponding to financial accounts, which in turn updates the group member records
    */
	public void onAfterDelete()
	{		
		if(!setGMIdsToUpdate.isEmpty())
			SL_UpdateGroupMemberController.updateGroupMembers(setGMIdsToUpdate);//calling method to update group member records
		if(!setAccountIdToUpdate.isEmpty())
			SL_Util_UpdateAccountController.updateAccount(setAccountIdToUpdate);//calling method to update the Account records.
			
		if(!setFinanicalAccountIdDeleted.isEmpty())
			removeFinancialAccountsFromHousehold();
	}
	
	private void removeFinancialAccountsFromHousehold()
	{
		List <Group_Account__c>lstGAToBeUpdated = new List <Group_Account__c>();
		for(Group_Account__c objGA : [SELECT Id, Financial_Account__c,Relationship_Group__r.Rep_Code__c, Relationship_Group__c FROM Group_Account__c 
										WHERE Financial_Account__c IN:setFinanicalAccountIdDeleted AND Relationship_Group__c !=null
									])
		{
			lstGAToBeUpdated.add(new Group_Account__c(Id = objGA.Id,Relationship_Group__c = null, Financial_Account__c = null ));
		}
		update lstGAToBeUpdated;
	}
	
	
	private void updateSharing(map<Id,Financial_Account__c> newMap)
	{
		map<Id,Id> finAcctRepMap = new map<Id,Id>();

		for(Financial_Account__c f : newMap.values())
		{
			if(f.Rep_Code__c != null)
			{
				finAcctRepMap.put(f.Id,f.Rep_Code__c);
			}
		}

		Financial_Account__Share[] fShare = new Financial_Account__Share[]{};
		fShare = [Select Id
				  From Financial_Account__Share
				  WHERE ParentId IN: finAcctRepMap.keyset() AND RowCause = 'Manual'];

		delete fShare;

		SL_Util_SharingController.RepCodeType[] shareList = new SL_Util_SharingController.RepCodeType[] {};

        if(finAcctRepMap != null && !finAcctRepMap.isEmpty())
        {
            for(Id i : finAcctRepMap.keySet())
            {
                shareList.add(new SL_Util_SharingController.RepCodeType(i, finAcctRepMap.get(i)));
            }
        }

        fShare = SL_Util_SharingController.createSharingRecords(shareList, 'Edit');

        Database.insert(fShare,false);
	}
	
	/*
        * MethodName   : updateHLAccounts
        * Param        : set of updated financial account ids
        * Description  : This method is used to update the Hilliard Lyons Account records corresponding to financial accounts.
    */
	/*private Set<Id> updateHLAccounts(Set<Id> setFinancialAccountIds)
	{
		List<Hilliard_Lyons_Account__c> lstHLAccount = new List<Hilliard_Lyons_Account__c>();//list to hold the hl account records that need to be updated
		Set<Id> setAccountId = new Set<Id>();//set of related account ids
		Set<Id> setGMIds = new Set<Id>();// set to hold the ids of group member records corresponding to Account records that need to be updated.
		
		//Iterating over HL account object to assign formula field values to corresponding place holder field values.
		for(Hilliard_Lyons_Account__c objHLA : [SELECT Id, Asset_Value__c, Cash_Available__c, Money_Market__c, Revenue_Value__c, Client__c, Financial_Account__c FROM Hilliard_Lyons_Account__c WHERE Financial_Account__c IN : setFinancialAccountIds])
		{
			lstHLAccount.add(new Hilliard_Lyons_Account__c(Id = objHLA.Id, Asset_Value_RU__c = objHLA.Asset_Value__c, Money_Market_RU__c = objHLA.Money_Market__c, Revenue_Value_RU__c = objHLA.Revenue_Value__c, Cash_Available_RU__c = objHLA.Cash_Available__c));
			setAccountId.add(objHLA.Client__c);
		}
		
		if(Trigger.isUpdate && !setAccountId.isEmpty())
			SL_Util_UpdateAccountController.updateAccount(setAccountId);
		
		if(!lstHLAccount.isEmpty())
		{
            System.debug(lstHLAccount);
			update lstHLAccount;
			setGMIds = new Map<Id, Group_Member__c>([SELECT Id FROM Group_Member__c WHERE Client_Prospect__c IN : setAccountId]).keyset();
		}
		return setGMIds;
	}*/
	
	/*
        * MethodName   : getAccountIds
        * Param        : set of updated financial account ids
        * Description  : This method returns the Account ids corresponding to the HL account records related to the deleted financial account records.
    */
	private Set<Id> getAccountIds(Set<Id> setFinancialAccountIds)
	{
		Set<Id> setAccountId = new Set<Id>();//set of related account ids
		
		//Iterating over HL account object to assign formula field values to corresponding place holder field values.
		for(Hilliard_Lyons_Account__c objHLA : [SELECT Client__c FROM Hilliard_Lyons_Account__c WHERE Financial_Account__c IN : setFinancialAccountIds])
		{
			setAccountId.add(objHLA.Client__c);
		}
		
		return setAccountId;
	}	
}