/**
@ ClassName    : SL_CallScheduleTimeCardsOwnerUpdate 
@ JIRATicket   : PWP-192
@ CreatedOn    : 20/August/2015
@ ModifiedBy   : Sathya
@ Description  : This class will schedule the batch "SL_Batch_UpdateTimeCardOwner" to run at 11:59 PM every friday
*/
public with sharing class SL_CallScheduleTimeCardsOwnerUpdate 
{
	public SL_CallScheduleTimeCardsOwnerUpdate()
	{
		SL_ScheduleTimeCardsOwnerUpdate  s = new SL_ScheduleTimeCardsOwnerUpdate();
        String sch =  '0 59 23 ? * FRI';
        System.schedule('Update Owner on Time cards', sch, s); 
	}
}