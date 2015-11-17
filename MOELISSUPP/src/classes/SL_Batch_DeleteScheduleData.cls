/**
*  ClassName      : SL_Batch_DeleteScheduleData
*  JIRATicket     : MOELISSUPP-30
*  CreatedOn      : 18/AUG/2014
*  ModifiedBy     : Pankaj Ganwani
*  Description    : This class serves as batch process to delete the data of Schedule_Data__c object.
*/
global class SL_Batch_DeleteScheduleData implements Database.Batchable<Id>
{
    public List<Id> lstScheduleDataId{get;set;}
    
    public SL_Batch_DeleteScheduleData(List<Id> tmp_list)
    {
        lstScheduleDataId = tmp_list;
    }
    
    global List<Id> start(Database.BatchableContext BC)
    {
        return lstScheduleDataId;
    }
    
    global void execute(Database.BatchableContext BC, List<Id> scope) 
    {
        //Querying the Schedule_Data__c object data to delete the records
        List<Schedule_Data__c> lstScheduleData = [SELECT Id FROM Schedule_Data__c WHERE Id IN:scope];
        if(lstScheduleData!=null)
            delete lstScheduleData;
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        
    }
}