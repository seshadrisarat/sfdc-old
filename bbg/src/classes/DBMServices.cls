public class DBMServices {
	public static boolean disableTriggerProcessing = false;
	private static Profile FRESHWATER_DBM_PROFILE = [select Id from Profile where name = 'Freshwater DBM User' limit 1];
	private static String DBM_DEALER_ACCESS = 'Read';
	private static String DBM_BOAT_SHARE_REASON = 'DBM Access';
	private static String DBM_BOAT_ACCESS = 'Read';
	
	public static void setDisableTriggerProcessing() {
		DBMServices.disableTriggerProcessing = true;	
	}
	
	// Makes sure that sharing rules exist for boat specified. Boats that are for non FW brands will be filtered out
	public void createApexSharingRules(list<Boat__c> boats) {
		system.debug('Filtering freshwater boats');
		// We only want to work with freshwater dealer brands
		set<string> freshwaterBrands = getFreshwaterBrands();
		list<Boat__c> freshwaterBoats = filterFreshwaterBoats(freshwaterBrands,boats);	
		
		if (!freshwaterBoats.isEmpty()) {
			createBoatAndBoatOwnerShares(freshwaterBoats);
		}
		else {
			system.debug('No freshwater boats were found.');
		}
	}
	
	// Makes sure that sharing rules exist for territory specified. Boats that are for non FW brands will be filtered out
	public void createApexSharingRules(list<Territory__c> territories) {
		system.debug('Filtering freshwater boats');
		// We only want to work with freshwater dealer brands
		set<string> freshwaterBrands = getFreshwaterBrands();
		list<Territory__c> freshwaterTerritories = filterFreshwaterTerritories(freshwaterBrands, territories);	
		
		if (!freshwaterTerritories.isEmpty()) {
			system.debug('Found territories for freshwater brands');
			list<Territory__Share> territorySharesToUpsert = new list<Territory__Share>();
			map<Dealer_Brand__c, list<Territory__c>> dealerBrandToTerritoryMap = getDealerBrandToTerritoryMap(freshwaterBrands, territories);
			
			// We need to get the owners for the dealer brands to make sure they are active
			set<Id> ownerIds = getOwnerIds(dealerBrandToTerritoryMap.keySet());
			map<Id, User> ownerIdToUserMap = getOwnerIdToUserMap(ownerIds);
			
			for (Dealer_Brand__c db : dealerBrandToTerritoryMap.keySet()) {
				if (isDealerBrandOwnerActive(db, ownerIdToUserMap)) {
					list<Territory__c> dbTerritories = dealerBrandToTerritoryMap.get(db);
					if (dbTerritories != null && dbTerritories.size() > 0) {
						for (Territory__c territory : dbTerritories) {
							Territory__Share territoryShare = createTerritoryShare(db, territory);
							territorySharesToUpsert.add(territoryShare);
						}	
					}
				}
				else {
					system.debug('Not setting owner shared for dealer brand ' + db.Id + ' because it is not active');
				}
			}
			
			if (!territorySharesToUpsert.isEmpty()) {
				system.debug('Upserting territory shares');
				try {
					TerritoryServices.disableTriggerProcessing = true;
					upsert territorySharesToUpsert;
				}
				finally {
					TerritoryServices.disableTriggerProcessing = false;	
				}
			}
			else {
				system.debug('No territory shares to upsert');
			}
		}
		else {
			system.debug('No freshwater territories were found.');
		}
	}
	
	
	/****************************
	 *
	 * When promoting this it requires the 'DBM Boat Access' apex sharing reason defined on Boat object.
	 */
	 
	 /**
	 * Create Apex managed sharing permissions for the DBM. The DBM is the owner of the Dealer_Brand record.
	 * The following permissions will be set.
	 * 1. The DBM will get view access to the dealer
	 * 2. The DBM will get view access to all the boats assigned to the dealer
	 */
	public void createApexSharingRules(List<Dealer_Brand__c> dealerBrands) {
		// We only want to work with freshwater dealer brands
		set<string> freshwaterBrands = getFreshwaterBrands();
		list<Dealer_Brand__c> freshwaterDealerBrands = filterFreshwaterDealerBrands(dealerBrands, freshwaterBrands);
		freshwaterDealerBrands = filterActiveOwnerDealerBrands(freshwaterDealerBrands);
		
		if (!freshwaterDealerBrands.isEmpty()) {
			system.debug('Found freshwater dealer brands');
			List<AccountShare> dealerAccountShares = createDealerAccountShares(freshwaterDealerBrands);
			if (!dealerAccountShares.isEmpty()) {
				AccountServices.disableTriggerProcessing = true;
				try {
					upsert dealerAccountShares;
				}
				finally {
					AccountServices.disableTriggerProcessing = false;
				}
			}
			
			// Create the boat and boat owner shares
			createBoatAndBoatOwnerShares(freshwaterDealerBrands);
			
			List<Territory__Share> territoryShares = createTerritoryShares(freshwaterDealerBrands);
			if (!territoryShares.isEmpty()) {
				system.debug('Creating territory sharing rules');
				try {
					TerritoryServices.disableTriggerProcessing = true;
					upsert territoryShares;
				}
				finally {
					TerritoryServices.disableTriggerProcessing = false;
				}
			}
		}
		else {
			system.debug('No freshwater dealer brands found');
		}
	}
	
	/**
	 * Update Apex managed sharing permissions for the DBM. The DBM is the owner of the Dealer_Brand record.
	 * The following permissions will be set.
	 * 1. Old DBM will be removed from dealer and boats if the owner has changed
	 * 2. The DBM will get view access to the dealer
	 * 3. The DBM will get view access to all the boats assigned to the dealer
	 */
	public void updateApexSharingRules(List<Dealer_Brand__c> dealerBrands, Map<Id, Dealer_Brand__c> oldDealerBrands) {
		// We only want to work with freshwater dealer brands
		set<string> freshwaterBrands = getFreshwaterBrands();
		list<Dealer_Brand__c> freshwaterDealerBrands = filterFreshwaterDealerBrands(dealerBrands, freshwaterBrands);
		if (!freshwaterDealerBrands.isEmpty()) {
		
			system.debug('Looking for all dealer brands where the owner has changed');
			// First find all the dealer brands where the owner has changed
			List<Dealer_Brand__c> dealerBrandsWithUpdatedOwners = new list<Dealer_Brand__c>();
			for (Dealer_Brand__c newDealerBrand : freshwaterDealerBrands) {
				Dealer_Brand__c oldDealerBrand = oldDealerBrands.get(newDealerBrand.Id);
				if (oldDealerBrand != null && newDealerBrand.OwnerId != oldDealerBrand.OwnerId && oldDealerBrand.OwnerId != null) {
					dealerBrandsWithUpdatedOwners.add(oldDealerBrand);	
				}
			}
			
			// If we have changed owners then we need to remove the old owner sharing permissions
			if (!dealerBrandsWithUpdatedOwners.isEmpty()) {
				system.debug('Dealer brands with updated owners');
				set<Id> dealerBrandIds = Pluck.ids(dealerBrandsWithUpdatedOwners);
				
				// Delete all the existing shares
				try {
					AccountServices.disableTriggerProcessing = true;
					BoatServices.disableTriggerProcessing = true;
					TerritoryServices.disableTriggerProcessing = true;
					
					system.debug('Deleting all old dealer sharing rules');
					deleteOldDealerSharingRules(dealerBrandIds);
					system.debug('Deleting all old boat sharing rules');
					deleteOldBoatSharingRules(dealerBrandIds);
					system.debug('Delete all old boat owner sharing rules');
					deleteOldBoatOwnerSharingRules(dealerBrandIds);
					system.debug('Deleting all old territory sharing rules');
					deleteOldTerritorySharingRules(dealerBrandIds);
				}
				finally {
					AccountServices.disableTriggerProcessing = false;
					BoatServices.disableTriggerProcessing = false;
					TerritoryServices.disableTriggerProcessing = false;
				}
			}
			else {
				system.debug('Did not find any dealer brands with updated owners');
			}
			
			// Now we need to create the sharing rules for the new owner if they dont already exist
			system.debug('Making sure sharing rules exist for updated dealer brands');
			freshwaterDealerBrands = filterActiveOwnerDealerBrands(freshwaterDealerBrands);
			if (!freshwaterDealerBrands.isEmpty()) {
				List<AccountShare> dealerAccountShares = createDealerAccountShares(freshwaterDealerBrands);
				if (!dealerAccountShares.isEmpty()) {
					system.debug('Creating dealer sharing rules');
					AccountServices.disableTriggerProcessing = true;
					try {
						upsert dealerAccountShares;
					}
					finally {
						AccountServices.disableTriggerProcessing = false;
					}
				}
				
				// Create the boat and boat owner shares
				createBoatAndBoatOwnerShares(freshwaterDealerBrands);
				
				List<Territory__Share> territoryShares = createTerritoryShares(freshwaterDealerBrands);
				if (!territoryShares.isEmpty()) {
					system.debug('Creating territory sharing rules');
					try {
						TerritoryServices.disableTriggerProcessing = true;
						upsert territoryShares;
					}
					finally {
						TerritoryServices.disableTriggerProcessing = false;
					}
				}
			}
		}
	}
	
	// Removes sharing rules for dealers and boats for deleted dealer brands
	public void removeSharingRules(list<Dealer_Brand__c> deletedDealerBrands) {
		// We only want to work with freshwater dealer brands
		set<string> freshwaterBrands = getFreshwaterBrands();
		list<Dealer_Brand__c> freshwaterDealerBrands = filterFreshwaterDealerBrands(deletedDealerBrands, freshwaterBrands);
		if (freshwaterDealerBrands.size() > 0) {	
			set<Id> dealerBrandIds = Pluck.ids(freshwaterDealerBrands);
				
			// Delete all the existing shares
			try {
				AccountServices.disableTriggerProcessing = true;
				BoatServices.disableTriggerProcessing = true;
				TerritoryServices.disableTriggerProcessing = true;
				
				system.debug('Deleting all old dealer sharing rules');
				deleteOldDealerSharingRules(dealerBrandIds);
				system.debug('Deleting all old boat sharing rules');
				deleteOldBoatSharingRules(dealerBrandIds);
				system.debug('Delete all old boat owner sharing rules');
				deleteOldBoatOwnerSharingRules(dealerBrandIds);
				system.debug('Deleting all old territory sharing rules');
				deleteOldTerritorySharingRules(dealerBrandIds);
			}
			finally {
				AccountServices.disableTriggerProcessing = false;
				BoatServices.disableTriggerProcessing = false;
				TerritoryServices.disableTriggerProcessing = false;
			}
		}
	}
	
	private list<Dealer_Brand__c> filterActiveOwnerDealerBrands(list<Dealer_Brand__c> dealerBrands) {
		list<Dealer_Brand__c> activeDealerBrands = new list<Dealer_Brand__c>();
		set<Id> ownerIds = getOwnerIds(dealerBrands);
		map<Id, User> ownerIdToUserMap = getOwnerIdToUserMap(ownerIds);	
		
		for (Dealer_Brand__c db : dealerBrands) {
			if (isDealerBrandOwnerActive(db, ownerIdToUserMap)) {
				activeDealerBrands.add(db);	
			}
		}
		
		return activeDealerBrands;
	}
	
	
	private boolean isDealerBrandOwnerActive(Dealer_Brand__c db, map<Id, User> ownerIdToUserMap) {
		User user = ownerIdToUserMap.get(db.OwnerId);
		if (user != null) {
			return user.IsActive;
		}	
		
		// If it is not a user then it is a group which should always be active
		return true;
	}
	
	private set<Id> getOwnerIds(list<Dealer_Brand__c> dealerBrands) {
		set<Id> ownerIds = new set<Id>();
		
		for (Dealer_Brand__c db : dealerBrands) {
			ownerIds.add(db.OwnerId);
		}
		return ownerIds;
	}
	
	private set<Id> getOwnerIds(set<Dealer_Brand__c> dealerBrands) {
		set<Id> ownerIds = new set<Id>();
		
		for (Dealer_Brand__c db : dealerBrands) {
			ownerIds.add(db.OwnerId);
		}
		return ownerIds;
	}
	
	private map<Id, User> getOwnerIdToUserMap(set<Id> ownerIds) {
		map<Id, User> ownerIdToUserMap = new map<Id, User>([Select Id, IsActive from User where Id in : ownerIds]);
		return ownerIdToUserMap;
	}
	
	private void deleteOldDealerSharingRules(set<Id> dealerBrandIds) {
		list<AccountShare> accountSharesToDelete = [Select Id from AccountShare where RowCause='Manual' and accountAccessLevel='Read' and AccountId in (select Dealer__c from Dealer_Brand__c where Id in :dealerBrandIds)];
		if (!accountSharesToDelete.isEmpty()) {
			system.debug('Deleting ' + accountSharesToDelete.size() + ' dealer sharing rules');
			delete accountSharesToDelete;
		}
	}
	
	private void deleteOldTerritorySharingRules(set<Id> dealerBrandIds) {
		list<Territory__c> territories = [select Id from Territory__c where Dealer_Brand__r.Id in :dealerBrandIds];
		set<Id> territoryIds = Pluck.ids(territories);
		list<Territory__Share> territorySharesToDelete = [Select Id from Territory__Share where RowCause=:Schema.Territory__Share.rowCause.DBM_Territory_Access__c and accessLevel='Read' and ParentId in :territoryIds];
		if (!territorySharesToDelete.isEmpty()) {
			system.debug('Deleting ' + territorySharesToDelete.size() + ' territory sharing rules');
			delete territorySharesToDelete;
		}
	}
	
	private void deleteOldBoatOwnerSharingRules(set<Id> dealerBrandIds) {
		list<Boat__c> boats = [Select (Select Owner__c From Owner_Boat_Relationships__r) From Boat__c where Dealer_Brand_Lookup__c in :dealerBrandIds];
		set<Id> boatOwnerIds = new set<Id>();
		for (Boat__c boat : boats) {
			for (Owner_Boat_Relationship__c obr : boat.Owner_Boat_Relationships__r) {
				boatOwnerIds.add(obr.Owner__c);	
			}
		}
		list<AccountShare> boatOwnerSharesToDelete = [Select Id from AccountShare where RowCause='Manual' and accountAccessLevel='Read' and AccountId in :boatOwnerIds];
		if (!boatOwnerSharesToDelete.isEmpty()) {
			system.debug('Deleting ' + boatOwnerSharesToDelete.size() + ' boat owner sharing rules');
			delete boatOwnerSharesToDelete;	
		}	
	}
	
	private void deleteOldBoatSharingRules(set<Id> dealerBrandIds) {
		list<Boat__c> boats = [select Id from Boat__c where Dealer_Brand_Lookup__r.Id in :dealerBrandIds];
		set<Id> boatIds = Pluck.ids(boats);
		list<Boat__Share> boatSharesToDelete = [Select Id from Boat__Share where RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c and accessLevel='Read' and ParentId in :boatIds];
		if (!boatSharesToDelete.isEmpty()) {
			system.debug('Deleting ' + boatSharesToDelete.size() + ' boat sharing rules');
			delete boatSharesToDelete;
		}
	}
	
	
	
	private map<Dealer_Brand__c, list<Boat__c>> getDealerBrandToBoatMap(list<Boat__c> boats) {
		set<Id> boatIds = Pluck.ids(boats);
		map<Dealer_Brand__c, list<Boat__c>> dealerBrandToBoatMap = new map<Dealer_Brand__c, list<Boat__c>>();
		
		list<Boat__c> boatsWithDealerBrands = [Select b.Name, b.Id, b.Dealer_Brand_Lookup__r.Dealer_Number__c, 
											   b.Dealer_Brand_Lookup__r.OwnerId, b.Dealer_Brand_Lookup__r.Id, 
											   b.Dealer_Brand_Lookup__r.Brand__c, b.Dealer_Brand_Lookup__c, b.Brand_del__c,
											   (Select Owner__c From Owner_Boat_Relationships__r)
											   From Boat__c b 
											   where b.Id in :boatIds];
		for (Boat__c boat : boatsWithDealerBrands) {
			if (boat.Dealer_Brand_Lookup__c != null && 
				boat.Dealer_Brand_Lookup__r != null && 
				boat.Dealer_Brand_Lookup__r.OwnerId != null) {
				Dealer_Brand__c db = new Dealer_Brand__c(Id=boat.Dealer_Brand_Lookup__r.Id, 
														 OwnerId=boat.Dealer_Brand_Lookup__r.OwnerId,
														 Brand__c=boat.Dealer_Brand_Lookup__r.Brand__c);
				list<Boat__c> dealerBrandBoats = dealerBrandToBoatMap.get(db);
				if (dealerBrandBoats == null) {
					dealerBrandBoats = new list<Boat__c>();
					dealerBrandToBoatMap.put(db, dealerBrandBoats);
				}
				dealerBrandBoats.add(boat);
			}
		}
		return dealerBrandToBoatMap;
	}
	
	private map<Dealer_Brand__c, list<Boat__c>> getDealerBrandToBoatMap(list<Dealer_Brand__c> dealerBrands) {
		map<Dealer_Brand__c, list<Boat__c>> dealerBrandToBoatMap = new map<Dealer_Brand__c, list<Boat__c>>();
		
		if (!dealerBrands.isEmpty()) {
			map<Id, Dealer_Brand__c> dealerBrandMap = new map<Id, Dealer_Brand__c>();
			for (Dealer_Brand__c db : dealerBrands) {
				dealerBrandMap.put(db.Id, db);
			}
			set<Id> dealerBrandIds = Pluck.ids(dealerBrands);
			list<Boat__c> boats = [Select b.Name, b.Id, b.Dealer_Brand_Lookup__r.Dealer_Number__c, b.Dealer_Brand_Lookup__r.OwnerId, 
										  b.Dealer_Brand_Lookup__r.Id, b.Dealer_Brand_Lookup__r.Brand__c, b.Dealer_Brand_Lookup__c, 
										  b.Brand_del__c, (Select Owner__c From Owner_Boat_Relationships__r) 
										  From Boat__c b where b.Dealer_Brand_Lookup__c in :dealerBrandIds];
			for (Boat__c boat : boats) {
				Dealer_Brand__c db = dealerBrandMap.get(boat.Dealer_Brand_Lookup__c);
				if (db != null) {
					list<Boat__c> dealerBrandBoats = dealerBrandToBoatMap.get(db);
					if (dealerBrandBoats == null) {
						dealerBrandBoats = new list<Boat__c>();
						dealerBrandToBoatMap.put(db, dealerBrandBoats);
					}
					dealerBrandBoats.add(boat);	
				}
			}
		}
		
		return dealerBrandToBoatMap;
	}
	
	private map<Dealer_Brand__c, list<Territory__c>> getDealerBrandToTerritoryMap(set<string> freshwaterBrands, list<Territory__c> territories) {
		set<Id> territoryIds = Pluck.ids(territories);
		map<Dealer_Brand__c, list<Territory__c>> dealerBrandToTerritoryMap = new map<Dealer_Brand__c, list<Territory__c>>();
		
		list<Territory__c> territoriesWithDealerBrands = [Select t.Id, t.Dealer_Brand__r.Dealer_Number__c, t.Dealer_Brand__r.OwnerId, t.Dealer_Brand__r.Id, t.Dealer_Brand__r.Brand__c, t.Dealer_Brand__c From Territory__c t where t.Id in :territoryIds];
		for (Territory__c territory : territoriesWithDealerBrands) {
			if (territory.Dealer_Brand__c != null && 
				territory.Dealer_Brand__r != null && 
				freshwaterBrands.contains(territory.Dealer_Brand__r.Brand__c) &&
				territory.Dealer_Brand__r.OwnerId != null) {
				Dealer_Brand__c db = new Dealer_Brand__c(Id=territory.Dealer_Brand__r.Id, 
														 OwnerId=territory.Dealer_Brand__r.OwnerId,
														 Brand__c=territory.Dealer_Brand__r.Brand__c);
				list<Territory__c> dealerBrandTerritories = dealerBrandToTerritoryMap.get(db);
				if (dealerBrandTerritories == null) {
					dealerBrandTerritories = new list<Territory__c>();
					dealerBrandToTerritoryMap.put(db, dealerBrandTerritories);
				}
				dealerBrandTerritories.add(territory);
			}
		}
		return dealerBrandToTerritoryMap;
	}
	
	private list<Dealer_Brand__c> filterFreshwaterDealerBrands(list<Dealer_Brand__c> dealerBrands, set<string> freshwaterBrands) {
		list<Dealer_Brand__c> filteredDealerBrands = new list<Dealer_Brand__c>();
		
		for (Dealer_Brand__c db : dealerBrands) {
			if (freshwaterBrands.contains(db.Brand__c)) {
				filteredDealerBrands.add(db);
			}
		}
		
		return filteredDealerBrands;
	}
	
	private list<Boat__c> filterFreshwaterBoats(set<string> freshwaterBrands, list<Boat__c> boats) {
		list<Boat__c> filteredBoats = new list<Boat__c>();
		
		for (Boat__c boat : boats) {
			if (freshwaterBrands.contains(boat.Brand_del__c)) {
				filteredBoats.add(boat);
			}
		}
		
		return filteredBoats;
	}
	
	private list<Territory__c> filterFreshwaterTerritories(set<string> freshwaterBrands, list<Territory__c> territories) {
		list<Territory__c> filteredTerritories = new list<Territory__c>();
		
		for (Territory__c territory : territories) {
			if (freshwaterBrands.contains(territory.Brand__c)) {
				filteredTerritories.add(territory);
			}
		}
		
		return filteredTerritories;
	}
	
	private static set<string> getFreshwaterBrands() {
		set<string> brands = new set<string>();
		Map<string, Freshwater_Brands__c> freshwaterBrandsCs = Freshwater_Brands__c.getAll();	
		for (Freshwater_Brands__c fb : freshwaterBrandsCs.values()) {
			brands.add(fb.Brand__c);
		}
		return brands;
	}
	
	private list<AccountShare> createDealerAccountShares(list<Dealer_Brand__c> dealerBrands) {
		list<AccountShare> accountShares = new list<AccountShare>();
		map<Id, set<Id>> ownerToDealerMap = new map<Id, set<Id>>();
		
		for (Dealer_Brand__c db : dealerBrands) {
			if (db.ownerId != null) {
				set<Id> dealerSet = ownerToDealerMap.get(db.ownerId);
				if (dealerSet == null) {
					dealerSet = new set<Id>();
					ownerToDealerMap.put(db.ownerId, dealerSet);
				}
				dealerSet.add(db.dealer__c);
			}
		}
		
		for (Id ownerId : ownerToDealerMap.keySet()) {
			set<Id> dealerSet = ownerToDealerMap.get(ownerId);
			if (dealerSet != null && dealerSet.size() > 0) {
				for (Id dealerId : dealerSet) {
					AccountShare dealerShare = new AccountShare();
					dealerShare.accountId = dealerId;
					dealerShare.UserOrGroupId = ownerId;
					dealerShare.accountAccessLevel = DBM_DEALER_ACCESS;
					dealerShare.opportunityAccessLevel = DBM_DEALER_ACCESS;
					dealerShare.caseAccessLevel = DBM_DEALER_ACCESS;
					
					accountShares.add(dealerShare);	
				}
			}
		}
		
		return accountShares;
	}
	
	// Returns a list of dealer brands with the boats included
	private List<Dealer_Brand__c> getDealerBrandsWithBoats(list<Dealer_Brand__c> dealerBrands) {
		List<Dealer_Brand__c> dealerBrandsWithBoats = [select Id, name, ownerId, dealer__c, (select boat__c.id from dealer_brand__c.boats__r) from dealer_brand__c where Id in :dealerBrands];
		return dealerBrandsWithBoats;
	}
	
	
	
	
	// Returns a list of dealer brands with the territories included
	private List<Dealer_Brand__c> getDealerBrandsWithTerritories(list<Dealer_Brand__c> dealerBrands) {
		List<Dealer_Brand__c> dealerBrandsWithTerritories = [select Id, name, ownerId, dealer__c, (select territory__c.id from dealer_brand__c.territories__r) from dealer_brand__c where Id in :dealerBrands];
		return dealerBrandsWithTerritories;
	}
	
	
	// Returns a list of dealer brands with the boats included. This is used on updates and the new dealer brand will 
	// be returned with the old owner rather than the old dealer brand. 
	private List<Dealer_Brand__c> getDealerBrandsWithBoats(list<Dealer_Brand__c> dealerBrands, map<Id, Dealer_Brand__c> oldMap) {
		List<Dealer_Brand__c> dealerBrandsWithBoatsCurrent = [select Id, name, ownerId, dealer__c, (select boat__c.id from dealer_brand__c.boats__r) from dealer_brand__c where Id in :dealerBrands];
		List<Dealer_Brand__c> dealerBrandsWithBoats = new list<Dealer_Brand__c>();
		for (Dealer_Brand__c db : dealerBrandsWithBoatsCurrent) {
			Dealer_Brand__c oldDb = oldMap.get(db.Id);
			if (oldDb != null) {
				// We need to update the owner on this to the old owner
				db.OwnerId = oldDb.OwnerId;
				dealerBrandsWithBoats.add(db);
			}
		}
		return dealerBrandsWithBoats;
	}
	
	// Returns a list of dealer brands with the territories included. This is used on updates and the new dealer brand will 
	// be returned with the old owner rather than the old dealer brand. 
	private List<Dealer_Brand__c> getDealerBrandsWithTerritories(list<Dealer_Brand__c> dealerBrands, map<Id, Dealer_Brand__c> oldMap) {
		List<Dealer_Brand__c> dealerBrandsWithTerritoriesCurrent = [select Id, name, ownerId, dealer__c, (select territory__c.id from dealer_brand__c.territories__r) from dealer_brand__c where Id in :dealerBrands];
		List<Dealer_Brand__c> dealerBrandsWithTerritories = new list<Dealer_Brand__c>();
		for (Dealer_Brand__c db : dealerBrandsWithTerritoriesCurrent) {
			Dealer_Brand__c oldDb = oldMap.get(db.Id);
			if (oldDb != null) {
				// We need to update the owner on this to the old owner
				db.OwnerId = oldDb.OwnerId;
				dealerBrandsWithTerritories.add(db);
			}
		}
		return dealerBrandsWithTerritories;
	}
	
	/**
	 * Creates boat_share records for each boat in each dealer_brand
	 */
	private List<Boat__Share> createBoatShares(List<Dealer_Brand__c> dealerBrands) {
		List<Boat__Share> boatShares = new List<Boat__Share>();
		// there may be a better way to do this, perhaps this doesn't need to be done if the dealerBrands has the boats__r populated from the trigger?
		List<Dealer_Brand__c> dealerBrandsWithBoats = getDealerBrandsWithBoats(dealerBrands);
		
		for (Dealer_Brand__c db : dealerBrandsWithBoats) {
			for (Boat__c  boat : db.boats__r) {
				boatShares.add(createBoatShare(db,boat));
			}
		}
		
		return boatShares;
	}
	
	/**
	 * Creates boat_share and accountshare records for each boat and boat owner in each dealer_brand
	 */
	private void createBoatAndBoatOwnerShares(List<Dealer_Brand__c> dealerBrands) {
		list<Boat__Share> boatSharesToUpsert = new list<Boat__Share>();
		list<AccountShare> ownerSharesToUpsert = new list<AccountShare>();
		
		map<Dealer_Brand__c, list<Boat__c>> dealerBrandToBoatMap = getDealerBrandToBoatMap(filterDealerBrandsWithActiveOwners(dealerBrands));
		
		for (Dealer_Brand__c db : dealerBrandToBoatMap.keySet()) {
			list<Boat__c> dbBoats = dealerBrandToBoatMap.get(db);
			if (dbBoats != null && dbBoats.size() > 0) {
				for (Boat__c boat : dbBoats) {
					boatSharesToUpsert.add(createBoatShare(db, boat));
					
					for (Owner_Boat_Relationship__c obr : boat.Owner_Boat_Relationships__r) {
						ownerSharesToUpsert.add(createOwnerShare(db.OwnerId, obr.Owner__c));
					}
				}	
			}
		}
		
		upsertBoatAndBoatOwnerShares(boatSharesToUpsert, ownerSharesToUpsert);
	}
	
	private void createBoatAndBoatOwnerShares(list<Boat__c> boats) {
		list<Boat__Share> boatSharesToUpsert = new list<Boat__Share>();
		list<AccountShare> ownerSharesToUpsert = new list<AccountShare>();
		
		map<Dealer_Brand__c, list<Boat__c>> dealerBrandToBoatMap = getDealerBrandToBoatMap(boats);
		list<Dealer_Brand__c> dealerBrandsWithActiveOwners = filterDealerBrandsWithActiveOwners(dealerBrandToBoatMap.keySet());
		
		for (Dealer_Brand__c db : dealerBrandsWithActiveOwners) {
			list<Boat__c> dbBoats = dealerBrandToBoatMap.get(db);
			if (dbBoats != null && dbBoats.size() > 0) {
				for (Boat__c boat : dbBoats) {
					boatSharesToUpsert.add(createBoatShare(db, boat));
					
					for (Owner_Boat_Relationship__c obr : boat.Owner_Boat_Relationships__r) {
						ownerSharesToUpsert.add(createOwnerShare(db.OwnerId, obr.Owner__c));
					}
				}	
			}
		}
		
		upsertBoatAndBoatOwnerShares(boatSharesToUpsert, ownerSharesToUpsert);
	}
	
	private void upsertBoatAndBoatOwnerShares(list<Boat__Share> boatSharesToUpsert, list<AccountShare> ownerSharesToUpsert) {
		if (!boatSharesToUpsert.isEmpty()) {
			system.debug('Upserting boat shares');
			BoatServices.disableTriggerProcessing = true;
			try {
				upsert boatSharesToUpsert;
			}
			finally {
				BoatServices.disableTriggerProcessing = false;
			}
		}
		else {
			system.debug('No boat shares to upsert');
		}
		
		if (!ownerSharesToUpsert.isEmpty()) {
			system.debug('Upserting owner shares');
			AccountServices.disableTriggerProcessing = true;
			try {
				upsert ownerSharesToUpsert;
			}
			finally {
				AccountServices.disableTriggerProcessing = false;
			}
		}
		else {
			system.debug('No owner shares to upsert');
		}	
	}
	
	
	/**
	 * Creates boat_share records for each boat in each dealer_brand
	 */
	private List<Territory__Share> createTerritoryShares(List<Dealer_Brand__c> dealerBrands) {
		List<Territory__Share> shares = new List<Territory__Share>();
		// there may be a better way to do this, perhaps this doesn't need to be done if the dealerBrands has the boats__r populated from the trigger?
		List<Dealer_Brand__c> dealerBrandsWithTerritories = getDealerBrandsWithTerritories(dealerBrands);
		
		for (Dealer_Brand__c db : dealerBrandsWithTerritories) {
			for (Territory__c  territory : db.territories__r) {
				Territory__Share share = createTerritoryShare(db, territory);
				shares.add(share);
			}
		}
		
		return shares;
	}
	
	private Boat__Share createBoatShare(Dealer_Brand__c db, Boat__c boat) {
		return createBoatShare(db.ownerId, boat);
	}
	
	private Boat__Share createBoatShare(Id dealerBrandOwnerId, Boat__c boat) {
		Boat__Share boatShare = new Boat__Share();
		boatShare.parentId = boat.id;
		boatShare.userOrGroupId = dealerBrandOwnerId;
		boatShare.accessLevel = DBM_BOAT_ACCESS;
		boatShare.rowCause = Schema.Boat__Share.rowCause.DBM_Boat_Access__c;	
		return boatShare;
	}
	
	private AccountShare createOwnerShare(Dealer_Brand__c db, Account owner) {
		return createOwnerShare(db.OwnerId, owner.Id);
	}
	
	private AccountShare createOwnerShare(Id dealerBrandOwnerId, Id ownerId) {
		AccountShare ownerShare = new AccountShare();
		ownerShare.accountId = ownerId;
		ownerShare.UserOrGroupId = dealerBrandOwnerId;
		ownerShare.accountAccessLevel = DBM_DEALER_ACCESS;
		ownerShare.opportunityAccessLevel = DBM_DEALER_ACCESS;
		ownerShare.caseAccessLevel = DBM_DEALER_ACCESS;	
		
		return ownerShare;
	}
	
	private Territory__Share createTerritoryShare(Dealer_Brand__c db, Territory__c territory) {
		return createTerritoryShare(db.OwnerId, territory);
	}
	
	private Territory__Share createTerritoryShare(Id dealerBrandOwnerId, Territory__c territory) {
		Territory__Share share = new Territory__Share();
		share.parentId = territory.id;
		share.userOrGroupId = dealerBrandOwnerId;
		share.accessLevel = DBM_BOAT_ACCESS;
		share.rowCause = Schema.Territory__Share.rowCause.DBM_Territory_Access__c;	
		return share;
	}
	
	private map<Id, list<Dealer_Brand__c>> getOwnerIdToDealerBrandMap(list<Dealer_Brand__c> dealerBrands) {
		map<Id, list<Dealer_Brand__c>> ownerIdToDealerBrandMap = new map<Id, list<Dealer_Brand__c>>();
		
		for (Dealer_Brand__c db : dealerBrands) {
			list<Dealer_Brand__c> dbList = ownerIdToDealerBrandMap.get(db.ownerId);
			if (dbList == null) {
				dbList = new list<Dealer_Brand__c>();
				ownerIdToDealerBrandMap.put(db.ownerId, dbList);
			}
			dbList.add(db);
		}
		
		return ownerIdToDealerBrandMap;
	}
	
	private List<AccountShare> findDealerAccountShares(List<Dealer_Brand__c> dealerBrands, map<Id, list<Dealer_Brand__c>> ownerIdToDealerBrandMap) {
		list<AccountShare> accountShares = new list<AccountShare>();
		set<Id> ownerIds = Pluck.ids('ownerId', dealerBrands);
		list<AccountShare> potentialAccountShares = [select Id, UserOrGroupId, AccountId from AccountShare where UserOrGroupId in :ownerIds and RowCause='Manual'];
		if (potentialAccountShares != null && potentialAccountShares.size() > 0) {
			system.debug('Found ' + potentialAccountShares.size() + ' potential account share matches. Trying to match on account as well');
			// We know we have a match on the ownerId but we need to make sure we find a match on the actual dealer as well
			for (AccountShare accountShare : potentialAccountShares) {
				list<Dealer_Brand__c> dbList = ownerIdToDealerBrandMap.get(accountShare.userOrGroupId);
				if (dbList != null && dbList.size() > 0) {
					for (Dealer_Brand__c db : dbList) {
						if (db.dealer__c == accountShare.accountId) {
							accountShares.add(accountShare);
						}
					}
				}
			}		
		}
		return accountShares;
	}
	
	private List<Boat__Share> findBoatShares(List<Dealer_Brand__c> dealerBrands, map<Id, list<Dealer_Brand__c>> ownerIdToDealerBrandMap) {
		list<Boat__Share> boatShares = new list<Boat__Share>();
		set<Id> ownerIds = Pluck.ids('ownerId', dealerBrands);
		list<Boat__Share> potentialBoatShares = [select Id, ParentId, UserOrGroupId from Boat__Share where UserOrGroupId in :ownerIds and rowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
		if (potentialBoatShares != null && potentialBoatShares.size() > 0) {
			// We know we have a match on the ownerId but we need to make sure we find a match on the actual boat as well
			for (Boat__Share boatShare : potentialBoatShares) {
				list<Dealer_Brand__c> dbList = ownerIdToDealerBrandMap.get(boatShare.userOrGroupId);
				if (dbList != null && dbList.size() > 0) {
					for (Dealer_Brand__c db : dbList) {
						for (Boat__c  boat : db.boats__r) {
							if (boat.Id == boatShare.parentId) {
								boatShares.add(boatShare);
								break;
							}
						}
					}
				}
			}		
		}
		return boatShares;
	}
	
	private List<Territory__Share> findTerritoryShares(List<Dealer_Brand__c> dealerBrands, map<Id, list<Dealer_Brand__c>> ownerIdToDealerBrandMap) {
		list<Territory__Share> shares = new list<Territory__Share>();
		set<Id> ownerIds = Pluck.ids('ownerId', dealerBrands);
		list<Territory__Share> potentialShares = [select Id, ParentId, UserOrGroupId from Territory__Share where UserOrGroupId in :ownerIds and rowCause=:Schema.Territory__Share.rowCause.DBM_Territory_Access__c];
		if (potentialShares != null && potentialShares.size() > 0) {
			// We know we have a match on the ownerId but we need to make sure we find a match on the actual boat as well
			for (Territory__Share share : potentialShares) {
				list<Dealer_Brand__c> dbList = ownerIdToDealerBrandMap.get(share.userOrGroupId);
				if (dbList != null && dbList.size() > 0) {
					for (Dealer_Brand__c db : dbList) {
						for (Territory__c  territory : db.territories__r) {
							if (territory.Id == share.parentId) {
								shares.add(share);
								break;
							}
						}
					}
				}
			}		
		}
		return shares;
	}
	
	private list<Dealer_Brand__c> filterDealerBrandsWithActiveOwners(set<Dealer_Brand__c> dealerBrands) {
		list<Dealer_Brand__c> dealerBrandsWithActiveOwners = new list<Dealer_Brand__c>();
		set<Id> ownerIds = getOwnerIds(dealerBrands);
		map<Id, User> ownerIdToUserMap = getOwnerIdToUserMap(ownerIds);
			
		for (Dealer_Brand__c db : dealerBrands) {
			if (isDealerBrandOwnerActive(db, ownerIdToUserMap)) {	
				dealerBrandsWithActiveOwners.add(db);	
			}
		}
		return dealerBrandsWithActiveOwners;
	}
	
	private list<Dealer_Brand__c> filterDealerBrandsWithActiveOwners(list<Dealer_Brand__c> dealerBrands) {
		list<Dealer_Brand__c> dealerBrandsWithActiveOwners = new list<Dealer_Brand__c>();
		set<Id> ownerIds = getOwnerIds(dealerBrands);
		map<Id, User> ownerIdToUserMap = getOwnerIdToUserMap(ownerIds);
			
		for (Dealer_Brand__c db : dealerBrands) {
			if (isDealerBrandOwnerActive(db, ownerIdToUserMap)) {	
				dealerBrandsWithActiveOwners.add(db);	
			}
		}
		return dealerBrandsWithActiveOwners;
	}
}