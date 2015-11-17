trigger MakeCheckboxLikeStatus on CampaignMember (before insert, before update) {
	for(CampaignMember CM : trigger.new){
		if(CM.Status == 'RSVP - Attending'){
			CM.RSVP_Attending__c = true;
		}
		if(CM.Status == 'Attended'){
			CM.Attended__c = true;
		}
	}
}