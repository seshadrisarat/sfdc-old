/**
*  Class Name     : SL_CaseTriggerHandler
*  JIRATicket     : STONEPIII-7
*  CreatedOn      : 19/SEP/2014
*  ModifiedBy     : Pankaj Ganwani
*  Description    : Create Events in Mybuilding when case is inserted with recordtype 'Move In Process' or 'Move Out Process'.
*/
public with sharing class SL_CaseTriggerHandler 
{
    // Global variables
    public static final String MOVEIN_CASE_RECORDTYPE_ID = [Select Id From RecordType Where SobjectType='Case' AND DeveloperName =: 'Move_In_Process'].Id;
    public static final String MOVEOUT_CASE_RECORDTYPE_ID = [Select Id From RecordType Where SobjectType='Case' AND DeveloperName =: 'Move_Out_Process'].Id;

    // Constructor
    public SL_CaseTriggerHandler()
    {
    
    }
       
    // Method called on after insert
    public void onAfterInsert(List<Case> lstNewCases)
    {
        updateCases(null,lstNewCases);//calling method to update case records
    }
    
    //Method called on after update
    public void onAfterUpdate(Map<Id,Case> mapNewIdToCase, Map<Id,Case> mapOldIdToCase)
    {
        updateCases(mapOldIdToCase, mapNewIdToCase.values());//calling method to update case records
    }
    
    //Method to update case records
    private void updateCases(Map<Id, Case> mapOldIdToCase, List<Case> lstCase)
    {
        List<Case> lstCasesForValidEvent = new List<Case>();
        List<Case> lstCasesForErrorEvent = new List<Case>();
        
        for(Case objCase : lstCase)
        {
            // Filter valid case records for which events can be created - Firstly we check the recordtypes
            if(objCase.RecordTypeId == MOVEOUT_CASE_RECORDTYPE_ID || objCase.RecordTypeId == MOVEIN_CASE_RECORDTYPE_ID)
            {
                // Check for common conditions for insert and update
                if(objCase.Community_ID__c != null &&
                   objCase.Subject != null && 
                   objCase.Description != null && 
                   ((objCase.RecordTypeId == MOVEOUT_CASE_RECORDTYPE_ID && objCase.Move_Out_Date__c !=null) || 
                    (objCase.RecordTypeId == MOVEIN_CASE_RECORDTYPE_ID && objCase.Move_In_Date__c !=null)))
                {
                    if(Trigger.isInsert)
                    {
                        lstCasesForValidEvent.add(objCase);
                    }
                    
                    // Additional conditions to check for update case
                    if(Trigger.isUpdate && !objCase.Make_Call_out__c && ((objCase.Move_Out_Date__c != mapOldIdToCase.get(objCase.Id).Move_Out_Date__c) || (objCase.Move_In_Date__c!=mapOldIdToCase.get(objCase.Id).Move_In_Date__c)))
                    {                  
                         lstCasesForValidEvent.add(objCase);
                    }
                }
            }
        }
        //Checking if list is empty
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
    }
}