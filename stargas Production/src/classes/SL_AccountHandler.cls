/**
* \arg ClassName      : SL_Account
* \arg JIRATicket     : STARGAS-25
* \arg CreatedOn      : 29/Aug/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This trigger is used to associate all service contract records related to source client account with inserted Account where record type is Prospect
*/
public without sharing class SL_AccountHandler 
{
	/* Start - Variables */
	private static final String strProspectRecordType = [SELECT Id FROM RecordType WHERE DeveloperName =:'Prospect' AND SobjectType =:'Account' AND IsPersonType = true LIMIT 1].Id;
	/* End - Variables */
	
	/* Start - Constructor */ 
	public SL_AccountHandler()
	{
		//Do Nothing
	}
	/* End - Constructor */ 
	
	/*
        * MethodName        : onAfterInsert
        * param             : list of the Opportunity records that are going to be inserted
        * Description       : This function will be called on before insert of opportunity.
    */
    public void onAfterInsert(List<Account> lstAccount)
    {
    	List<Service_Contract__c> lstServiceContract = new List<Service_Contract__c>();//list of service contract records to be updated
    	Map<Id,Id> mapSourceClientIdToAccountId = new Map<Id,Id>(); //map of account id to source client account id
    	
    	//Iterating over account object to filter the records based upon 'Prospect' record type
    	for(Account objAccount : lstAccount)
    	{
    		if(objAccount.RecordTypeId == strProspectRecordType && objAccount.Source_Client_Account__c!=null)
    			mapSourceClientIdToAccountId.put(objAccount.Source_Client_Account__c,objAccount.Id);
    	}
    	
    	
    	//Iterating over service contract object to fill the mapSourceClientTolstOfServiceContract with client prospect and corresponding list of service contracts
    	for(Service_Contract__c objServiceContract : [SELECT Id, Associated_Prospect__c, Client_Prospect__c 
    												  FROM Service_Contract__c 
    												  WHERE Client_Prospect__c 
    												  IN : mapSourceClientIdToAccountId.keyset()])
    	{
    		lstServiceContract.add(new Service_Contract__c(Id = objServiceContract.Id, Associated_Prospect__c = mapSourceClientIdToAccountId.get(objServiceContract.Client_Prospect__c)));
    	}
    	
    	update lstServiceContract;
    }
}