/**
*  ClassName      : SL_BatchToUpdateOpportunityFields
*  JIRATicket     : THOR-62
*  CreatedOn      : 26/MAR/2015
*  ModifiedBy     : Sanath Kumar
*  Description    : This is a one time batch to update different Opportunity fields based on related parent records
*/
global  class SL_BatchToUpdateOpportunityFields implements Database.Batchable<Sobject>
{
	public string strQuery = '';
    
    /* Start : Constructor */
    public SL_BatchToUpdateOpportunityFields(String strQuery)
    {
    	this.strQuery = strQuery;
    }
    /* End : Constructor */
    
    
    /*
    	* MethodName   : start
        * Param        : Database.BatchableContext BC
        * Description  : This method returns Opportunity records 
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
    	Id PersonAccountRecordTypeId = [SELECT Id FROM Recordtype WHERE SobjectType='Account' AND IsPersonType=True].Id;
    	List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
    	
    	
    	///Create data for opportunity
    	for(Opportunity objOpportunity:lstOpportunity)
    	{
    		if(objOpportunity.Account != null && objOpportunity.Account.RecordTypeId == PersonAccountRecordTypeId)
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
	    		
	    		if(objOpportunity.Apartment__c != null && objOpportunity.Apartment__r.Building__c != null && objOpportunity.Apartment__r.Building__r.Building_Manager__c != null)
					objOpportunity.Property_Manager_Email__c = objOpportunity.Apartment__r.Building__r.Building_Manager__r.Email;
				if(objOpportunity.Leasing_Agent__c != null)
					objOpportunity.Leasing_Agent_Title__c = objOpportunity.Leasing_Agent__r.Title;
					
	    		lstOpportunityToUpdate.add(objOpportunity);
    		}
    	}
    	
    	if(!lstOpportunityToUpdate.isEmpty())
    		database.update(lstOpportunityToUpdate,false);
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