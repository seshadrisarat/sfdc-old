trigger DealAfterInsertAfterUpdate on Deal__c (after insert, after update) {
	//Commenting out Funnel related code 12/29/14
	/*if(Flags.UpdatingInvOppColumns) {
		return;
	}*/

	General_Settings__c settings = General_Settings__c.getOrgDefaults();
	//Set<String> stageYears = new Set<String>();
	//Set<String> fcYears = new Set<String>();
	Set<String> aliases = new Set<String>();
	Map<Id, Deal__c> chatterDealMap = new Map<Id, Deal__c>();
	//Integer curYear = System.today().year();

	for(Deal__c d : trigger.new) {
		Deal__c old = trigger.isInsert ? d : trigger.oldMap.get(d.Id);

		/*if(trigger.isUpdate) {
			Boolean launchYearChanged = d.Inv_Opp_Launch_Year__c != old.Inv_Opp_Launch_Year__c;

			if((d.Include_In_Funnel_Stage__c && (launchYearChanged || d.Stage_Column__c == null)) || d.Include_In_Funnel_Stage__c != old.Include_In_Funnel_Stage__c) {
				stageYears.add(d.Inv_Opp_Launch_Year__c);
				stageYears.add(old.Inv_Opp_Launch_Year__c);
			}

			if((d.Include_In_Funnel_FC__c && (launchYearChanged || d.FC_Column__c == null)) || d.Include_In_Funnel_FC__c != old.Include_In_Funnel_FC__c) {
				fcYears.add(d.Inv_Opp_Launch_Year__c);
				fcYears.add(old.Inv_Opp_Launch_Year__c);
			}
		}*/

		if(d.AS_Team__c != null) {
			for(String alias : d.AS_Team__c.split(';')) {
				aliases.add(alias.trim());
			}
		}

		if(!trigger.isInsert && old.AS_Team__c != null) {
			for(String alias : old.AS_Team__c.split(';')) {
				aliases.add(alias.trim());
			}
		}

		if(trigger.isInsert || d.AS_Team__c != old.AS_Team__c) {
			chatterDealMap.put(d.Id, d);
		}
	}

	aliases.remove(null);

	if(settings != null && settings.Auto_Follow_Deals__c && !aliases.isEmpty()) {
		Map<String, User> userMap = new Map<String, User>();
		Map<String, EntitySubscription> entSubMap = new Map<String, EntitySubscription>();
		List<EntitySubscription> newEntSubs = new List<EntitySubscription>();
		List<EntitySubscription> delEntSubs = new List<EntitySubscription>();

		for(EntitySubscription entSub : [SELECT Id, ParentId, SubscriberId FROM EntitySubscription WHERE ParentId IN :chatterDealMap.keySet()]) {
			entSubMap.put('' + entSub.ParentId + entSub.SubscriberId, entSub);
		}

		for(User u : [SELECT Id, Alias FROM User WHERE Alias IN :aliases AND IsActive = true]) {
			userMap.put(u.Alias.toLowerCase(), u);
		}

		for(Deal__c d : chatterDealMap.values()) {
			Set<String> curAliases = new Set<String>();

			if(d.AS_Team__c != null) {
				for(String alias : d.AS_Team__c.toLowerCase().split(';')) {
					curAliases.add(alias.trim());
					if(userMap.containsKey(alias.trim())) {
						User u = userMap.get(alias.trim());
						String key = '' + d.Id + u.Id;

						if(!entSubMap.containsKey(key)) {
							newEntSubs.add(new EntitySubscription(
								ParentId = d.Id,
								SubscriberId = u.Id
							));
						}
					}
				}
			}

			if(trigger.isUpdate) {
				Deal__c old = trigger.oldMap.get(d.Id);

				if(old.AS_Team__c != null) {
					for(String alias : old.AS_Team__c.toLowerCase().split(';')) {
						if(!curAliases.contains(alias.trim()) && userMap.containsKey(alias.trim())) {
							User u = userMap.get(alias.trim());
							String key = '' + old.Id + u.Id;

							if(entSubMap.containsKey(key)) {
								delEntSubs.add(entSubMap.get(key));
							}
						}
					}
				}
			}
		}

		if(!newEntSubs.isEmpty()) {
			insert newEntSubs;
		}

		if(!delEntSubs.isEmpty()) {
			delete delEntSubs;
		}
	}

	//stageYears.remove(null);
	//fcYears.remove(null);

	/*if(!stageYears.isEmpty() || !fcYears.isEmpty()) {
		List<Deal__c> deals = [SELECT Id, Name, Inv_Opp_Launch_Year__c, Include_In_Funnel_Stage__c, Include_In_Funnel_FC__c, Final_AS_Stage__c FROM Deal__c WHERE (Inv_Opp_Launch_Year__c IN :stageYears AND Include_In_Funnel_Stage__c = true) OR (Inv_Opp_Launch_Year__c IN :fcYears AND Include_In_Funnel_FC__c = true) ORDER BY Name, Inv_Opp_Launch_Year__c];
		Map<String, Map<String, List<Deal__c>>> stageDealsMap = new Map<String, Map<String, List<Deal__c>>>();
		Map<String, List<Deal__c>> fcDealsMap = new Map<String, List<Deal__c>>();

		for(Deal__c d : deals) {
			if(stageYears.contains(d.Inv_Opp_Launch_Year__c) && d.Include_In_Funnel_Stage__c && String.isNotBlank(d.Final_AS_Stage__c)) {
				Map<String, List<Deal__c>> yearDealsMap = stageDealsMap.containsKey(d.Inv_Opp_Launch_Year__c) ? stageDealsMap.get(d.Inv_Opp_Launch_Year__c) : new Map<String, List<Deal__c>>();
				String stage = d.Final_AS_Stage__c.toLowerCase();
				List<Deal__c> stageDeals = yearDealsMap.containsKey(stage) ? yearDealsMap.get(stage) : new List<Deal__c>();
				stageDeals.add(d);
				yearDealsMap.put(stage, stageDeals);
				stageDealsMap.put(d.Inv_Opp_Launch_Year__c, yearDealsMap);
			}

			if(fcYears.contains(d.Inv_Opp_Launch_Year__c) && d.Include_In_Funnel_FC__c) {
				List<Deal__c> yearDeals = fcDealsMap.containsKey(d.Inv_Opp_Launch_Year__c) ? fcDealsMap.get(d.Inv_Opp_Launch_Year__c) : new List<Deal__c>();
				yearDeals.add(d);
				fcDealsMap.put(d.Inv_Opp_Launch_Year__c, yearDeals);
			}
		}

		if(!stageDealsMap.isEmpty()) {
			for(String year : stageDealsMap.keySet()) {
				Map<String, List<Deal__c>> yearDealsMap = stageDealsMap.get(year);

				if(!yearDealsMap.isEmpty()) {
					for(String stage : yearDealsMap.keySet()) {
						List<Deal__c> stageDeals = yearDealsMap.get(stage);
						Integer midOrd = Math.ceil(stageDeals.size() / 2.0).intValue();

						for(Integer i = 0; i < stageDeals.size(); i++) {
							Deal__c d = stageDeals.get(i);
							d.Stage_Column__c = i < midOrd ? 1 : 2;
						}
					}
				}
			}
		}

		if(!fcDealsMap.isEmpty()) {
			for(String year : fcDealsMap.keySet()) {
				List<Deal__c> yearDeals = fcDealsMap.get(year);
				Integer midOrd = Math.ceil(yearDeals.size() / 2.0).intValue();

				for(Integer i = 0; i < yearDeals.size(); i++) {
					Deal__c d = yearDeals.get(i);
					d.FC_Column__c = i < midOrd ? 1 : 2;
				}
			}
		}

		Flags.UpdatingInvOppColumns = true;
		try {
			update deals;
		} finally {
			Flags.UpdatingInvOppColumns = false;
		}
	}*/
}