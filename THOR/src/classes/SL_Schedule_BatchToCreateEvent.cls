/**
@ClassName   : SL_Schedule_BatchToCreateEvent 
@JIRATicket  : THOR-29
@CreatedOn   : 22/SEP/2014
@ModifiedBy  : SANATH
@Description : Schedular for Batch SL_BatchToCreateEventInMyBuilding
*/

public with sharing class SL_Schedule_BatchToCreateEvent implements Schedulable 
{
    // Global variables
    public static final String MOVEIN_CASE_RECORDTYPE_ID = [Select Id From RecordType Where SobjectType='Case' AND DeveloperName = 'Move_In_Process'].Id;
    public static final String MOVEOUT_CASE_RECORDTYPE_ID = [Select Id From RecordType Where SobjectType='Case' AND DeveloperName = 'Move_Out_Process'].Id;
    
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
        for(Case objCaseRecord : [ Select Subject,Description,Lease_Start_Date__c,RecordTypeId ,Mybuilding_Event_Id__c
                                   from Case
                                   where (RecordTypeId =: MOVEIN_CASE_RECORDTYPE_ID OR RecordTypeId =: MOVEOUT_CASE_RECORDTYPE_ID) 
                                   AND Mybuilding_Event_Id__c = null AND Subject != null AND Lease_Start_Date__c != null ])
        {
            // Checking all the required parameters are not blank
            if(!string.isBlank(objCaseRecord.Description))
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