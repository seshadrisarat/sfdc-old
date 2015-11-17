/**
* \arg ClassName      : SL_Batch_UpdateTimeTrackingRecords
* \arg JIRATicket     : CAINSUPP-13
* \arg CreatedOn      : 15/DEC/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This batch script is used to update the existing Time tracking records with the Contact Id.
*/
global class SL_Batch_UpdateTimeTrackingRecords implements Database.Batchable<sobject>
{
	
	/* Start - Constructor */
    global SL_Batch_UpdateTimeTrackingRecords()
    {
        // Do Nothing       
    }
    /* End - Constructor */
	
	/*
        * MethodName   : start
        * Param        : Database.BatchableContext BC
        * Description  : This method returns Time Tracking records of the org
    */
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator('SELECT Id, OwnerId, Owner.Email FROM Time_Tracking__c');
    }
    
    /*
        * MethodName   : execute
        * Param        : Database.BatchableContext BC, List<Time_Tracking__c> lstTimeTracking
        * Description  : Processes Time Tracking records records returned by the start method.
    */
    global void execute(Database.BatchableContext BC, List<Time_Tracking__c> lstTimeTracking)
    {
    	List<Time_Tracking__c> lstTimeTrackingToUpdate = new List<Time_Tracking__c>();// list to hold the time tracking records which has to be updated
    	Set<String> setOwnerEmail = new Set<String>();//set to hold email address of owner
    	Map<String,String> mapEmailToContactId = new Map<String,String>();//map to hold email address and its corresponding contact id
    	
    	//iterating over records to hold the email addresses of owners
    	for(Time_Tracking__c objTimeTracking : lstTimeTracking)
    	{
    		setOwnerEmail.add(objTimeTracking.Owner.Email);
    	}
    	
    	//fetching contacts corresponding to the emails
    	for(Contact objContact : [SELECT Email, Id FROM Contact WHERE Email IN : setOwnerEmail])
    	{
    		mapEmailToContactId.put(objContact.Email,objContact.Id);
    	}
    	
    	//updating employee records
    	for(Time_Tracking__c objTimeTracking : lstTimeTracking)
    	{
    		lstTimeTrackingToUpdate.add(new Time_Tracking__c(Id = objTimeTracking.Id, Employee__c = mapEmailToContactId.containskey(objTimeTracking.Owner.Email) ? mapEmailToContactId.get(objTimeTracking.Owner.Email) : NULL));
    	}
    	
    	update lstTimeTrackingToUpdate;
    	
    }
    
    /*
        * MethodName   : finish
        * Param        : Database.BatchableContext BC
        * Description  : Performs necessary post-execution steps
    */
    global void finish(Database.BatchableContext BC)
    {
        //Do Nothing
    }     
}