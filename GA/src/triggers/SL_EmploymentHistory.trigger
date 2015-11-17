/**
@Trigger Name  : SL_EmploymentHistory
@JIRA Ticket   : GA-24
@Created on    : 05/05/2015
@Modified by   : Sanath Kumar
@Description   : Trigger on insert, update and delete of ts2__Employment_History__c, This trigger will update Contact records
*/
trigger SL_EmploymentHistory on ts2__Employment_History__c (after insert , after update , after delete) 
{
    //// initialize the handler class SL_SalesOrdersTrigger
    SL_EmploymentHistoryHandler objHandler = new SL_EmploymentHistoryHandler();
    
    //Called on After insert of ts2__Employment_History__c record
    if(trigger.isAfter && trigger.isInsert)
    {
        objHandler.onAfterInsert(trigger.new);
    }
    
    //Called on After Update of ts2__Employment_History__c record
    if(trigger.isAfter && trigger.isUpdate)
    {
        objHandler.onAfterUpdate(trigger.new);
    }
    
    //Called on After delete of ts2__Employment_History__c record
    if(trigger.isAfter && trigger.isDelete)
    {
        objHandler.onAfterDelete(trigger.old);
    }
    
}