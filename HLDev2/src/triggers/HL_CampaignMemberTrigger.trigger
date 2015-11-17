trigger HL_CampaignMemberTrigger on CampaignMember (after insert, after update) {    
	if(!System.IsFuture())    
    	HL_CampaignMemberHandler.SynchronizeParentCampaignMembers(Trigger.newMap.keySet());
}