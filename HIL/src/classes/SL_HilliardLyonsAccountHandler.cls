/**
* \arg ClassName      : SL_HilliardLyonsAccountHandler
* \arg JIRATicket     : HIL-7
* \arg CreatedOn      : 20/FEB/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
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
	public void onAfterInsert(List<Hilliard_Lyons_Account__c> lstHLAccount)
	{
		updateGroupMemberRecords(lstHLAccount);
	}
	
	/*
        * MethodName   : onAfterUpdate
        * Param        : new and old map of financial account records
        * Description  : This method is used to update the Hilliard Lyons Account records corresponding to financial accounts, which in turn updates the group member records
    */
	public void onAfterUpdate(Map<Id,Hilliard_Lyons_Account__c> newMap, Map<Id,Hilliard_Lyons_Account__c> oldMap)
	{
		Set<String> setChkFields = new Set<String>{'Role__c'};// set to contain the fields we need to check for
		Map<Id, Sobject> mapIdToHLAccount = new Map<Id, Sobject>();// map to updated hl account records
		mapIdToHLAccount = SL_DiffRecordUtil.getRecordsWithDiff(oldMap, newMap, setChkFields);//calling util class method to compare the values of old map and new map.
		
		if(!mapIdToHLAccount.isEmpty())
		{
			updateGroupMemberRecords(mapIdToHLAccount.values());
		}
	}
	
	/*
        * MethodName   : onAfterDelete
        * Param        : new and old map of financial account records
        * Description  : This method is used to update the Hilliard Lyons Account records corresponding to financial accounts, which in turn updates the group member records
    */
	public void onAfterDelete(List<Hilliard_Lyons_Account__c> lstHLAccount)
	{
		updateGroupMemberRecords(lstHLAccount);
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
		}
	}
}