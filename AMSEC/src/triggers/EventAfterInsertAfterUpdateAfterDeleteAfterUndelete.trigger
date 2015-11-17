trigger EventAfterInsertAfterUpdateAfterDeleteAfterUndelete on Event (after insert, after update, after delete, after undelete) {
	Set<Id> coverageIds = new Set<Id>();
	
	if(trigger.new != null) {
		for(Event evnt : trigger.new) {
			coverageIds.add(evnt.Ind_Grp_Coverage_ID1__c);
			coverageIds.add(evnt.Ind_Grp_Coverage_ID2__c);
			coverageIds.add(evnt.Ind_Grp_Coverage_ID3__c);
		}
	}
	
	if(trigger.old != null) {
		for(Event evnt : trigger.old) {
			coverageIds.add(evnt.Ind_Grp_Coverage_ID1__c);
			coverageIds.add(evnt.Ind_Grp_Coverage_ID2__c);
			coverageIds.add(evnt.Ind_Grp_Coverage_ID3__c);
		}
	}
	
	coverageIds.remove(null);
	
	if(!coverageIds.isEmpty()) {
		List<Industry_Group_Coverage__c> coverages = [SELECT Id FROM Industry_Group_Coverage__c WHERE Id IN :coverageIds AND Inactive__c = false];
		System.debug(System.LoggingLevel.INFO, 'coverages.size(): ' + coverages.size());
		
		if(!coverages.isEmpty()) {
			Flags.RefreshIndustryGroupCoverageLastAction = true;
			update coverages;
			Flags.RefreshIndustryGroupCoverageLastAction = false;
		}
	}
}