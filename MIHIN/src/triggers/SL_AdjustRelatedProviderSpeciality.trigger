/*
*Trigger: SL_AdjustRelatedProviderSpeciality
*Description: Implement a trigger on insert of Contact to perform functionality as per MIHIN-33
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
trigger SL_AdjustRelatedProviderSpeciality on Contact (after update, after insert) 
{
	SL_AdjustProviderSpecialityHandler objHandler = new SL_AdjustProviderSpecialityHandler();
	
	if(Trigger.isAfter && Trigger.isUpdate)
	{
		objHandler.onAfterUpdate(trigger.new, trigger.oldMap);
	}
	
	if(Trigger.isAfter && Trigger.isInsert)
	{
		objHandler.onAfterInsert(trigger.new);
	}
}