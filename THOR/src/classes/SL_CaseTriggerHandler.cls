/**
*  Class Name     : SL_CaseHandler
*  JIRATicket     : THOR-29
*  CreatedOn      : 28/SEP/2014
*  ModifiedBy     : SANATH
*  Description    : Create Events in Mybuilding when case is inserted with recordtype 'Move In Process' or 'Move Out Process'.
*/
public with sharing class SL_CaseTriggerHandler 
{
    // Global variables
    public static final String MOVEIN_CASE_RECORDTYPE_ID = [Select Id From RecordType Where SobjectType='Case' AND DeveloperName = 'Move_In_Process'].Id;
    public static final String MOVEOUT_CASE_RECORDTYPE_ID = [Select Id From RecordType Where SobjectType='Case' AND DeveloperName = 'Move_Out_Process'].Id;

    // Constructor
    public SL_CaseTriggerHandler()
    {
    	
    }
       
    // Method called on after insert
    public void onAfterInsert(List<Case> lstNewCases)
    {
        List<Case> lstCasesForValidEvent = new List<Case>();
        List<Case> lstCasesForErrorEvent = new List<Case>();
        Map<Id,Date> mapLeaseId_MoveOutDate = new Map<Id,Date>();
        
        
        for(Case objCase : [SELECT RecordTypeId, Lease__c,Community_ID__c,Apartment__c ,Apartment__r.Apartment_Number__c,Move_In_Date__c,Move_Out_Date__c,Date_From__c,Date_To__c
                            FROM Case
                            WHERE Id IN:lstNewCases])
        {
            // Filter valid case records for which events can be created
            if((objCase.RecordTypeId == MOVEOUT_CASE_RECORDTYPE_ID || objCase.RecordTypeId == MOVEIN_CASE_RECORDTYPE_ID) && 
                objCase.Community_ID__c != null && objCase.Apartment__c != null &&
                objCase.Apartment__r.Apartment_Number__c != null &&
                objCase.Date_From__c != null && objCase.Date_To__c != null)
            {
            	if((objCase.RecordTypeId == MOVEIN_CASE_RECORDTYPE_ID &&  objCase.Move_In_Date__c != null ) || 
            	  (objCase.RecordTypeId == MOVEOUT_CASE_RECORDTYPE_ID &&  objCase.Move_Out_Date__c != null ))
            	{
                	lstCasesForValidEvent .add(objCase);
            	}
            }
            
            if(objCase.Lease__c != null)
            	mapLeaseId_MoveOutDate.put(objCase.Lease__c,Date.ValueOf(objCase.Move_Out_Date__c));
            	
            // If any of the required fields for integration is blank on case record then updating Case Mybuilding_Event_Creation_Status__c field to 'Error' using Workflow rule.
        }
         
        if(!lstCasesForValidEvent.isEmpty())
        {
            // Call batch to call MyBuilding integration
            SL_BatchToCreateEventInMyBuilding objBatch = new SL_BatchToCreateEventInMyBuilding(lstCasesForValidEvent);
            
            // Checking for number of active jobs in organization.
            if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5)
            {
                Database.executeBatch(objBatch, 1);
            }
        }
        
        if(!mapLeaseId_MoveOutDate.isEmpty())
        	updateLeaseAssociatedToCase(mapLeaseId_MoveOutDate);
    }
    
    
    /*
        * MethodName   : onAfterUpdate
        * param        : trigger.oldMap,trigger.newMap
        * Description  : Will invoke on After Update of Case record
    */
    public void onAfterUpdate(Map<Id,Case> mapOldCase, Map<Id,Case> mapNewCase)
    {
    	Map<Id,Date> mapLeaseId_MoveOutDate = new Map<Id,Date>();
    	Set<Id> setApartmentIdToUpdate = new Set<Id>();
    	
    	for(Id objCaseId:mapNewCase.keyset())
    	{
    		if(mapNewCase.get(objCaseId).Lease__c != null && mapOldCase.get(objCaseId).Move_Out_Date__c != mapNewCase.get(objCaseId).Move_Out_Date__c)
    		{
    			mapLeaseId_MoveOutDate.put(mapNewCase.get(objCaseId).Lease__c,Date.ValueOf(mapNewCase.get(objCaseId).Move_Out_Date__c));
    		}
    		
    		///Check if move case status has been changed to closed
    		if(mapNewCase.get(objCaseId).RecordtypeId == MOVEOUT_CASE_RECORDTYPE_ID && mapNewCase.get(objCaseId).Status == 'Closed'
    		   && (mapNewCase.get(objCaseId).Status != mapOldCase.get(objCaseId).Status) && mapNewCase.get(objCaseId).Apartment__c != null)
    		{
    			setApartmentIdToUpdate.add(mapNewCase.get(objCaseId).Apartment__c);
    		}
    	}
    	
    	 if(!mapLeaseId_MoveOutDate.isEmpty())
        	updateLeaseAssociatedToCase(mapLeaseId_MoveOutDate);
        	
       	 if(!setApartmentIdToUpdate.isEmpty())
       	 	updateApartmentStatusBasedOnCase(setApartmentIdToUpdate);
    }
    
    
    /*
        * MethodName   : updateLeaseAssociatedToCase
        * param        : Filtered List of Cases
        * Description  : Method to update lease asscoiated with move out case
    */
    private void updateLeaseAssociatedToCase(Map<Id,Date> mapLeaseId_MoveOutDate)
    {
    	List<Lease__c> lstLeaseToUpdate = new List<Lease__c>();
    	
    	for(Lease__c objLease:[SELECT Id,Move_Out_Date__c 
    	                       FROM Lease__c 
    	                       WHERE ID IN:mapLeaseId_MoveOutDate.keyset()])
    	{
    		objLease.Move_Out_Date__c = mapLeaseId_MoveOutDate.get(objLease.Id);
    		lstLeaseToUpdate.add(objLease);
    	}
    	
    	if(!lstLeaseToUpdate.isEmpty())
    		update lstLeaseToUpdate;
    }
    
     /*
        * MethodName   : updateApartmentStatusBasedOnCase
        * param        : Set of Apartment id whose status have to be updated
        * Description  : Method to update apartment status when move out case status is closed
    */
    private void updateApartmentStatusBasedOnCase(Set<Id> setApartmentIdToUpdate)
    {
    	List<Apartment__c> lstApartementToUpdate = new List<Apartment__c>();
    	
    	///Update apartment status
    	for(Apartment__c objApartment:[SELECT Id,Apartment_Status__c
    	                               FROM Apartment__c
    	                               WHERE Id IN:setApartmentIdToUpdate])
    	{
    		objApartment.Apartment_Status__c = 'Available - Pending';
    		lstApartementToUpdate.add(objApartment);
    	}
    	
    	if(!lstApartementToUpdate.isEmpty())
    		update lstApartementToUpdate;
    }
}