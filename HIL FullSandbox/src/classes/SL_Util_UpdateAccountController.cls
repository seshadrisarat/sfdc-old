/**
* \arg ClassName      : SL_Util_UpdateAccountController
* \arg JIRATicket     : HIL-12
* \arg CreatedOn      : 6/APR/2015
* \arg LastModifiedOn : 7/APR/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as the utility class which contains the methods to update the Account records corresponding to the HLAccount records for doing rollup of Rep Code field values.
*/
public with sharing class SL_Util_UpdateAccountController 
{	
	/*
        * MethodName   : updateAccount
        * Param        : set of Account ids which are associated with the updated Financial Account records via HLAccount records.
        * Description  : This method is used to update the Account records with the roll up of Rep codes corresponding to their HLAccount records.
    */
	public static void updateAccount(Set<Id> setClientIds)
	{
		Map<Id, Set<String>> mapAccIdToSetOfRepCode = new Map<Id, Set<String>>();
		List<Account> lstAccountToUpdate = new List<Account>();
		
		for(Hilliard_Lyons_Account__c objHLA : [SELECT Id, Rep_Code__c, Client__c FROM Hilliard_Lyons_Account__c WHERE Client__c IN : setClientIds AND Rep_Code__c!=null])
		{
			if(!mapAccIdToSetOfRepCode.containskey(objHLA.Client__c))
				mapAccIdToSetOfRepCode.put(objHLA.Client__c, new Set<String>{objHLA.Rep_Code__c});
			else
				mapAccIdToSetOfRepCode.get(objHLA.Client__c).add(objHLA.Rep_Code__c);
		}
		
		for(id clientId : setClientIds)
		{
			if(mapAccIdToSetOfRepCode.containskey(clientId))
			{
				List<String> lstTemp = new List<String>();
				lstTemp.addAll(mapAccIdToSetOfRepCode.get(clientId));
				lstAccountToUpdate.add(new Account(Id = clientId, Rep_Code_Rollup__c = String.join(lstTemp,', ')));
			}
			else
				lstAccountToUpdate.add(new Account(Id = clientId, Rep_Code_Rollup__c = NULL));
		}
		
		if(!lstAccountToUpdate.isEmpty())
			try
			{
				update lstAccountToUpdate;
			}catch(DmlException e)
			{
				System.debug(LoggingLevel.ERROR,e);
			}
	}
}