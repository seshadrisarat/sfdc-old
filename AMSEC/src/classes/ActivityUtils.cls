public with sharing class ActivityUtils {
	// TODO: Migrate the call sync logic into this class from the CallSyncUtility class
	
	public static void updateIndustryGroupCoverages(List<Event> events) {
		Set<Id> userIds = new Set<Id>();
		Set<Id> whoIds = new Set<Id>();
		List<Event> updateEvents = new List<Event>();
		Map<String, List<Industry_Group_Coverage__c>> coverageMap = new Map<String, List<Industry_Group_Coverage__c>>();
		
		for(Event e : events) {
			e.Ind_Grp_Coverage_ID1__c = null;
			e.Ind_Grp_Coverage_ID2__c = null;
			e.Ind_Grp_Coverage_ID3__c = null;
			
			if(e.WhoId != null) {
				userIds.add(e.OwnerId);
				whoIds.add(e.WhoId);
				updateEvents.add(e);
			}
		}
		
		if(!updateEvents.isEmpty()) {
			for(Industry_Group_Coverage__c coverage : [SELECT Id, Primary_Coverage_User_ID__c, Company_Contact__c FROM Industry_Group_Coverage__c WHERE Primary_Coverage_User_ID__c IN :userIds AND Company_Contact__c IN :whoIds AND Inactive__c = false]) {
				String key = '' + coverage.Primary_Coverage_User_ID__c + coverage.Company_Contact__c;
				List<Industry_Group_Coverage__c> coverages = coverageMap.containsKey(key) ? coverageMap.get(key) : new List<Industry_Group_Coverage__c>();
				coverages.add(coverage);
				coverageMap.put(key, coverages);
			}
			
			for(Event e : events) {
				String key = '' + e.OwnerId + e.WhoId;
				
				if(coverageMap.containsKey(key)) {
					List<Industry_Group_Coverage__c> coverages = coverageMap.get(key);
					
					for(Integer i = 1; i <= Math.min(3, coverages.size()); i++) {
						Industry_Group_Coverage__c coverage = coverages.get(i - 1);
						e.put('Ind_Grp_Coverage_ID' + i + '__c', coverage.Id);
					}
				}
			}
		}
	}
}