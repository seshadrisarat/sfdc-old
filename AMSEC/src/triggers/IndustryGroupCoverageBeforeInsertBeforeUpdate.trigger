trigger IndustryGroupCoverageBeforeInsertBeforeUpdate on Industry_Group_Coverage__c (before insert, before update) {
	if(Flags.RefreshIndustryGroupCoverageLastAction) {
		Set<Id> coverageContIds = new Set<Id>();
		Set<Id> contIds = new Set<Id>();
		List<Industry_Group_Coverage__c> coverages = new List<Industry_Group_Coverage__c>();
		
		for(Industry_Group_Coverage__c coverage : trigger.new) {
			if(!coverage.Inactive__c) {
				coverage.Last_Action_Date__c = null;
				coverage.Last_Action__c = null;
				coverage.Last_Action_Type__c = null;
				coverageContIds.add(coverage.Primary_Coverage_Person__c);
				contIds.add(coverage.Company_Contact__c);
				coverages.add(coverage);
			}
		}
		
		if(trigger.isUpdate && !coverages.isEmpty()) {
			Map<Id, DateTime> coverageDtMap = new Map<Id, DateTime>();
			
			for(AggregateResult ar : [SELECT MAX(StartDateTime) maxStart, Ind_Grp_Coverage_ID1__c coverageId FROM Event WHERE Ind_Grp_Coverage_ID1__c IN :trigger.newMap.keySet() GROUP BY Ind_Grp_Coverage_ID1__c]) {
				Industry_Group_Coverage__c coverage = trigger.newMap.get((Id) ar.get('coverageId'));
				DateTime maxStart = (DateTime) ar.get('maxStart');
				coverageDtMap.put(coverage.Id, maxStart);
			}
			
			for(AggregateResult ar : [SELECT MAX(StartDateTime) maxStart, Ind_Grp_Coverage_ID2__c coverageId FROM Event WHERE Ind_Grp_Coverage_ID2__c IN :trigger.newMap.keySet() GROUP BY Ind_Grp_Coverage_ID2__c]) {
				Industry_Group_Coverage__c coverage = trigger.newMap.get((Id) ar.get('coverageId'));
				DateTime maxStart = (DateTime) ar.get('maxStart');
				DateTime lastActionDt = coverageDtMap.get(coverage.Id);
				lastActionDt = lastActionDt != null && lastActionDt > maxStart ? lastActionDt : maxStart;
				coverageDtMap.put(coverage.Id, lastActionDt);
			}
			
			for(AggregateResult ar : [SELECT MAX(StartDateTime) maxStart, Ind_Grp_Coverage_ID3__c coverageId FROM Event WHERE Ind_Grp_Coverage_ID3__c IN :trigger.newMap.keySet() GROUP BY Ind_Grp_Coverage_ID3__c]) {
				Industry_Group_Coverage__c coverage = trigger.newMap.get((Id) ar.get('coverageId'));
				DateTime maxStart = (DateTime) ar.get('maxStart');
				DateTime lastActionDt = coverageDtMap.get(coverage.Id);
				lastActionDt = lastActionDt != null && lastActionDt > maxStart ? lastActionDt : maxStart;
				coverageDtMap.put(coverage.Id, lastActionDt);
			}
			
			contIds = new Set<Id>();
			Set<Id> userIds = new Set<Id>();
			Set<DateTime> startTimes = new Set<DateTime>();
			Map<Id, Contact> coverageContMap = new Map<Id, Contact>([SELECT Id, Salesforce_User__c FROM Contact WHERE Id IN :coverageContIds AND Salesforce_User__c != null]);
			Map<String, List<Industry_Group_Coverage__c>> coverageMap = new Map<String, List<Industry_Group_Coverage__c>>();
			
			for(Industry_Group_Coverage__c coverage : coverages) {
				DateTime lastActionDt = coverageDtMap.get(coverage.Id);
				
				if(coverage.Company_Contact__c != null && coverage.Primary_Coverage_Person__c != null && coverageContMap.containsKey(coverage.Primary_Coverage_Person__c) && lastActionDt != null) {
					contIds.add(coverage.Company_Contact__c);
					Id userId = coverageContMap.get(coverage.Primary_Coverage_Person__c).Salesforce_User__c;
					userIds.add(userId);
					startTimes.add(lastActionDt);
					String key = '' + coverage.Company_Contact__c + userId + lastActionDt.format();
					List<Industry_Group_Coverage__c> keyCoverages = coverageMap.containsKey(key) ? coverageMap.get(key) : new List<Industry_Group_Coverage__c>();
					keyCoverages.add(coverage);
					coverageMap.put(key, keyCoverages);
				}
			}
			
			userIds.remove(null);
			startTimes.remove(null);
			
			if(!coverageMap.isEmpty()) {
				for(Event e : [SELECT Id, OwnerId, WhoId, Subject, StartDateTime, Event_Type__c FROM Event WHERE OwnerId = :userIds AND WhoId IN :contIds AND StartDateTime IN :startTimes]) {
					String key = '' + e.WhoId + e.OwnerId + e.StartDateTime.format();
					
					if(coverageMap.containsKey(key)) {
						for(Industry_Group_Coverage__c coverage : coverageMap.get(key)) {
							coverage.Last_Action__c = e.Subject;
							coverage.Last_Action_Date__c = e.StartDateTime.date();
							coverage.Last_Action_Type__c = e.Event_Type__c;
						}
					}
				}
			}
		}
	}
}