/*
@ClassName    : SL_ScheduleTimeCardsOwnerUpdate 
@JIRATicket   : PWP-192
@CreatedOn    : 20/August/2015
@ModifiedBy   : Sathya
@Description  : Invokes the "SL_Batch_UpdateTimeCardOwner" batch 
*/
global  with sharing class SL_ScheduleTimeCardsOwnerUpdate implements Schedulable 
{
	global void execute (SchedulableContext SC)
    {
        SL_Batch_UpdateTimeCardOwner objBatch = new SL_Batch_UpdateTimeCardOwner();
        Database.executeBatch(objBatch);
    }
}