trigger PEDealTeamMemberList on PE_Deal_Team_Member__c (after delete, after insert, after update) {
	Set<ID> dealIDs = new Set<ID>();
	if(Trigger.isDelete){
		for (PE_Deal_Team_Member__c dtm: Trigger.old){
			dealIDs.add(dtm.PE_Deals__c);
		}
	}
	else{
		for (PE_Deal_Team_Member__c dtm: Trigger.new){
			dealIDs.add(dtm.PE_Deals__c);
		}
	}
	
	for (List<PE_Deals__c> deals : [Select id, (Select Employee__r.Name From PE_Deal_Team_Members__r) FROM PE_Deals__c WHERE id in :dealIDs]){
		List<PE_Deals__c> updatedDeals = new List<PE_Deals__c>();
		for (PE_Deals__c deal : deals){
			PE_Deals__c newDeal = new PE_Deals__c (id = deal.Id, Deal_Team_Members__c = '');
			String members = '';
			for(PE_Deal_Team_Member__c dtm: deal.PE_Deal_Team_Members__r){
				members += dtm.Employee__r.name + '; ';
			}
			if (members.length() > 2){
				members = members.substring(0, members.length() - 2);
			}
			newDeal.Deal_Team_Members__c = members;
			updatedDeals.add(newDeal);
		}
		update updatedDeals;
	}
}