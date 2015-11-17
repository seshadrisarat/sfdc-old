/*
*Trigger: SL_PortalBranding
*Description: This trigger is used to update the contact records with correct portal URL corresponding to its organization portal
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
trigger SL_PortalBranding on Portal__c (after update) 
{
	SL_PortalBrandinHandler objPortalBrandinHandler = new SL_PortalBrandinHandler();
	
	if(Trigger.isAfter && Trigger.isUpdate)
	{
		objPortalBrandinHandler.onAfterUpdate(Trigger.newMap,Trigger.oldMap);
	}
}