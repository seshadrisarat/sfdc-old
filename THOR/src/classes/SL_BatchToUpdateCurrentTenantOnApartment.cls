/**
*  ClassName      : SL_BatchToUpdateCurrentTenantOnApartment
*  JIRATicket     : THOR-55
*  CreatedOn      : 24/MAR/2015
*  ModifiedBy     : Sanath Kumar
*  Description    : This is a one time batch to update Current_Tenant__c field on Apartment
*/
global  class SL_BatchToUpdateCurrentTenantOnApartment implements Database.Batchable<Sobject>
{
    public string strQuery = '';
    
    /* Start : Constructor */
    public SL_BatchToUpdateCurrentTenantOnApartment(String strQuery)
    {
    	this.strQuery = strQuery;
    }
    /* End : Constructor */
    
    
    /*
    	* MethodName   : start
        * Param        : Database.BatchableContext BC
        * Description  : This method returns Opportunity records with 'Lease Signed By Thor' Stage
    */
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
    	return Database.getQueryLocator(strQuery);
    }
    
    
    /*
    	* MethodName   : execute
        * Param        : Database.BatchableContext BC, List<Opportunity> lstOpportunity
        * Description  : Processes Opportunity records returned by start method
    */
    global void execute(Database.BatchableContext BC, List<Opportunity> lstOpportunity)
    {
    	Map<Id,Id> mapApartmentId_AccountId = new Map<Id,Id>();
    	List<Apartment__c> lstApartmentToUpdate = new List<Apartment__c>();
    	
    	///Create a map of Apartment Id to Account Id
    	for(Opportunity objOpportunity:lstOpportunity)
    	{
    		mapApartmentId_AccountId.put(objOpportunity.Apartment__c, objOpportunity.AccountId);
    	}
    	
    	///Update current tenant field on Apartment
    	for(Apartment__c objApartment:[SELECT Id, Current_Tenant__c
    	                               FROM Apartment__c
    	                               WHERE Id IN:mapApartmentId_AccountId.keyset()])
    	{
    		objApartment.Current_Tenant__c = mapApartmentId_AccountId.get(objApartment.Id);
    		lstApartmentToUpdate.add(objApartment);
    	}
    	
    	if(!lstApartmentToUpdate.isEmpty())
    		update lstApartmentToUpdate;
    }
    
    
    /*
    	* MethodName   : finish
        * Param        : Database.BatchableContext BC
        * Description  : Performs necessary post-execution steps
    */
    global void finish(Database.BatchableContext BC)
    {
        ///Does nothing
    }
}