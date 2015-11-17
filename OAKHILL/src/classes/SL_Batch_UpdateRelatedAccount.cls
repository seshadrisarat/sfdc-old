/**  
* \arg ClassName      : SL_Batch_UpdateRelatedAccount
* \arg JIRATicket     : OAKHILL-15
* \arg CreatedOn      : 24/OCT/2014
* \arg LastModifiedOn : 24/OCT/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as batch class for updating related account records based on most recent month end balance record.
*/
global with sharing class SL_Batch_UpdateRelatedAccount implements Database.Batchable<Sobject>
{
	//start method
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
     	 return Database.getQueryLocator('SELECT Name, Related_Account__c, Commitment_Funded_c__c, Net_Balance__c FROM Month_End_Balance__c ORDER BY Name, LastModifiedDate');
    }
	
	//execute method
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	Map<Id, Related_Account__c> mapIdToRelatedAccount = new Map<Id, Related_Account__c>();// map of related account id and related account record to update the related account records
    	List<Month_End_Balance__c> lstMonthEndBalance = new List<Month_End_Balance__c>();//list to hold month end balance records fetched from the batch query
    	lstMonthEndBalance.addAll((List<Month_End_Balance__c>)scope);
    	
    	//Iterating over month end balance object to update the related account records.
    	for(Month_End_Balance__c objMonthEndBalance : lstMonthEndBalance)
    	{
    		mapIdToRelatedAccount.put(objMonthEndBalance.Related_Account__c, new Related_Account__c(Id = objMonthEndBalance.Related_Account__c, Commitment_Funded__c = objMonthEndBalance.Commitment_Funded_c__c, Current_NAV__c = objMonthEndBalance.Net_Balance__c));
    	}
    	
    	if(!mapIdToRelatedAccount.isEmpty())
    		update mapIdToRelatedAccount.values();//updating the related account records
    }
	
	//finish method
    global void finish(Database.BatchableContext BC)
    {
   		//Do Nothing
    }
}