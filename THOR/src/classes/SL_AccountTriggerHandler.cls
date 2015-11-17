/**
*  ClassName      : SL_AccountTriggerHandler
*  JIRATicket     : THOR-62
*  CreatedOn      : 25/03/2015
*  ModifiedBy     : Sanath
*  Description    : This is the handler class for Account trigger
*/
public with sharing class SL_AccountTriggerHandler 
{
	/*
        * MethodName   : onAfterUpdate
        * param        : trigger.oldMap,trigger.newMap
        * Description  : Will invoke on After Update of Account record
    */
	public void onAfterUpdate(map<Id,Account> mapOldAccount,map<Id,Account> mapNewAccount)
	{
		Set<Id> setAccountId = new Set<Id>();
		
		for(Id objAccountId:mapNewAccount.keyset())
		{
			///Check if shipping address or person email of account has been changed
			if(mapOldAccount.get(objAccountId).ShippingStreet != mapNewAccount.get(objAccountId).ShippingStreet 
			   || mapOldAccount.get(objAccountId).ShippingCity  != mapNewAccount.get(objAccountId).ShippingCity
			   || mapOldAccount.get(objAccountId).ShippingState  != mapNewAccount.get(objAccountId).ShippingState
			   || mapOldAccount.get(objAccountId).ShippingPostalCode != mapNewAccount.get(objAccountId).ShippingPostalCode 
			   || mapOldAccount.get(objAccountId).ShippingCountry != mapNewAccount.get(objAccountId).ShippingCountry
			   || mapOldAccount.get(objAccountId).PersonEmail != mapNewAccount.get(objAccountId).PersonEmail)
			{
				setAccountId.add(objAccountId);
			}
		}
		
		if(!setAccountId.isEmpty())
			updateRelatedOpportunityBasedOnAccount(setAccountId);
	}
	
	
	/*
        * MethodName   : updateRelatedOpportunityBasedOnAccount
        * param        : Set<Id> setAccountId
        * Description  : Method to update Account_Current_Address__c, Person_Account_Email__c fields on Opportunity
    */
	private void updateRelatedOpportunityBasedOnAccount(Set<Id> setAccountId)
	{
		List<Opportunity> lstOpportunity = new List<Opportunity>();
		
		///Create data for opportunity to be updated
		for(Opportunity objOpportunity:[SELECT Id,AccountId,Account_Current_Address__c,Person_Account_Email__c,
		                                Account.ShippingStreet, Account.ShippingCity , Account.ShippingState,
		                                Account.ShippingPostalCode  , Account.ShippingCountry,Account.PersonEmail
		                                FROM Opportunity
		                                WHERE AccountId IN:setAccountId])
		{
		    String strAddress = '';
    		
    		strAddress = (objOpportunity.Account.ShippingStreet == null?'': objOpportunity.Account.ShippingStreet + ',') + 	
    		             (objOpportunity.Account.ShippingCity == null?'': objOpportunity.Account.ShippingCity + ',') + 	
			             (objOpportunity.Account.ShippingState == null?'': objOpportunity.Account.ShippingState + ',') + 
			             (objOpportunity.Account.ShippingPostalCode == null?'': objOpportunity.Account.ShippingPostalCode + ',') + 	
			             (objOpportunity.Account.ShippingCountry == null?'': objOpportunity.Account.ShippingCountry + ',') ;
			
			if(strAddress != '')
    			strAddress = strAddress.Substring(0,strAddress.length()-1);
    				
    		if(objOpportunity.Account.PersonEmail == null)
    			objOpportunity.Account.PersonEmail = '';
    		
    		objOpportunity.Account_Current_Address__c = strAddress;
    		objOpportunity.Person_Account_Email__c = objOpportunity.Account.PersonEmail;
    		lstOpportunity.add(objOpportunity);
		}
		
		if(!lstOpportunity.isEmpty())
			update lstOpportunity;
		
	}
}