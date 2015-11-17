/**
* \arg ClassName      : SL_CampaignMember
* \arg JIRATicket     : OAKHILL-26
* \arg CreatedOn      : 18/JUNE/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This trigger is employed for rolling up the campaign email addresses to related campaign.
*/
trigger SL_CampaignMember on CampaignMember (after delete, after insert) 
{
	if(Trigger.isAfter)
	{
		if(Trigger.isInsert)
			SL_CampaignMemberHandler.onAfterInsert(Trigger.new);
		if(Trigger.isDelete)
			SL_CampaignMemberHandler.onAfterDelete(Trigger.old);
	}
}