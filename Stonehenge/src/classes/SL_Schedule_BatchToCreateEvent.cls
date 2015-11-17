/**
@ClassName   : SL_Schedule_BatchToCreateEvent 
@JIRATicket  : STONEPIII-7
@CreatedOn   : 22/SEP/2014
@ModifiedBy  : Pankaj Ganwani
@Description : Schedular for Batch SL_BatchToCreateEventInMyBuilding
*/

public with sharing class SL_Schedule_BatchToCreateEvent implements Schedulable 
{
    // Global variables
    public static final String MOVEIN_CASE_RECORDTYPE_ID = [Select Id From RecordType Where SobjectType='Case' AND DeveloperName =: 'Move_In_Process'].Id;
    public static final String MOVEOUT_CASE_RECORDTYPE_ID = [Select Id From RecordType Where SobjectType='Case' AND DeveloperName =: 'Move_Out_Process'].Id;
    
    // Constructor
    public SL_Schedule_BatchToCreateEvent() 
    {
    }
    
    /*
        @MethodName : execute 
        @param      : SchedulableContext SC
        @Description: This method schedules the respective batch class based on given cron expression
    */
    public void execute(SchedulableContext SC) 
    {
        list<Case> lstCasesForWhichEventsneedToCreate = new list<Case>();
        
        // Querying Case records whose Event Id is blank to Create Event for that case in MyBuilding.
        
        for(Case objCaseRecord : [ Select Mybuilding_Event_Id__c, Subject, Description, Lease_Start_Date__c, RecordTypeId, Move_In_Date__c, Move_Out_Date__c
                                   from Case
                                   Where (RecordTypeId =: MOVEIN_CASE_RECORDTYPE_ID OR RecordTypeId =: MOVEOUT_CASE_RECORDTYPE_ID) AND 
                                   Mybuilding_Event_Id__c = null AND Make_Call_out__c = false AND
                                   Subject != null AND 
                                   Community_ID__c != null 
                                   ])
        {
            // Checking all the required parameters are not blank
            if(!string.isBlank(objCaseRecord.Description) && 
              ((objCaseRecord.RecordTypeId == MOVEOUT_CASE_RECORDTYPE_ID && objCaseRecord.Move_Out_Date__c != null) || 
               (objCaseRecord.RecordTypeId == MOVEIN_CASE_RECORDTYPE_ID && objCaseRecord.Move_In_Date__c != null)))
            {
                lstCasesForWhichEventsneedToCreate.add(objCaseRecord);
            }
        }        
        // Performing callout
        if(!lstCasesForWhichEventsneedToCreate.isEmpty())
        {                          
            // Calling the batch
            SL_BatchToCreateEventInMyBuilding objBatchCreateEvent = new SL_BatchToCreateEventInMyBuilding(lstCasesForWhichEventsneedToCreate);
            Database.executeBatch(objBatchCreateEvent,1);
        }   
    }
}