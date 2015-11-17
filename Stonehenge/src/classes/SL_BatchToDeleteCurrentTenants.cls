/**
*  ClassName      : SL_BatchToDeleteCurrentTenants
*  JIRATicket     : STONEPII-132
*  CreatedOn      : 28/JAN/2015
*  ModifiedBy     : Sanath Kumar
*  Description    : This is a one time batch to delete current records which are also listed in previous tenants section
*/
global class SL_BatchToDeleteCurrentTenants implements Database.Batchable<Sobject>
{
    public string strQuery = '';
	
	/* Start : Constructor */
    public SL_BatchToDeleteCurrentTenants(String strQuery)
    {
    	this.strQuery = strQuery;
    }
    /* End : Constructor */
    
        
    /*
    	* MethodName   : start
        * Param        : Database.BatchableContext BC
        * Description  : This method returns Property records
    */
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
    	return Database.getQueryLocator(strQuery);
    }
    
    
    /*
    	* MethodName   : execute
        * Param        : Database.BatchableContext BC, List<Property__c> lstProperty
        * Description  : Processes Property records returned by start method
    */
    global void execute(Database.BatchableContext BC, List<Property__c> lstProperty)
    {
    	Set<String> setPreviousTenantData = new Set<String>();
    	List<Current_Tenant__c> lstCurrentTenantToDelete = new List<Current_Tenant__c>();
    	
    	///Create a set with data of previous tenant records
    	for(Previous_Tenant__c objPreviousTenant:[SELECT Id,Property__c,Contact__c,Role__c,Lease_End_Date__c,Lease_Start_Date__c
    	                                          FROM Previous_Tenant__c
    	                                          WHERE Property__c IN:lstProperty])
    	{
    		setPreviousTenantData.add(objPreviousTenant.Property__c + '-' +   objPreviousTenant.Contact__c + '-' + objPreviousTenant.Role__c + '-' +objPreviousTenant.Lease_End_Date__c + '-' +objPreviousTenant.Lease_Start_Date__c);
    	}
    	
    	///Create a list of Current tenant records that need to be deleted
    	for(Current_Tenant__c objCurrentTenant:[SELECT Id,Property__c,Contact__c,Role__c,Lease_End_Date__c,Lease_Start_Date__c
    	                                        FROM Current_Tenant__c
    	                                        WHERE Property__c IN:lstProperty])
    	{
    		if(setPreviousTenantData.contains(objCurrentTenant.Property__c + '-' +   objCurrentTenant.Contact__c + '-' + objCurrentTenant.Role__c + '-' +objCurrentTenant.Lease_End_Date__c + '-' +objCurrentTenant.Lease_Start_Date__c))
    		{
    			lstCurrentTenantToDelete.add(objCurrentTenant);
    		}
    	}
    	
    	if(!lstCurrentTenantToDelete.isEmpty())
			delete lstCurrentTenantToDelete;    	
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