public class OwnerBoatRelationshipServices {
	public static boolean disableTriggerProcessing = false;
	
	// Makes sure the correct owner boat relationship is active for each boat and that the brand relationships are set correctly
	// for the affected owners
	public static void setActiveOwnerBoatRelationshipsForBoatsAndUpdateOwnerBrandRelationships(list<Owner_Boat_Relationship__c> ownerBoatRels) {
		system.debug('setActiveOwnerBoatRelationshipsForBoats');
		set<Id> boatIds = Pluck.ids('HIN_Number__c', ownerBoatRels);
		list<Boat__c> boatsWithRelationships = getBoatsWithOwnerBoatRelationships(boatIds);
		
		// Iterate through each boat and set the best relationship as active
		map<Id, Owner_Boat_Relationship__c> ownerBoatRelsToUpdate = new map<Id, Owner_Boat_Relationship__c>();
		set<Id> ownersUpdated = new set<Id>();
		for (Boat__c boat : boatsWithRelationships)	{
			system.debug('Processing relationships for boat ' + boat.Name);
			
			if (boatHasMultipleActiveRelationships(boat)) {
				setAllBoatRelationshipsToInactive(boat, ownerBoatRelsToUpdate, ownersUpdated);
				setActiveBoatRelationship(boat, ownerBoatRelsToUpdate, ownersUpdated);
			}
			else {
				addOwnersToBrandRelationshipCheck(boat, ownersUpdated);
			}
		}
		
		updateOwnerBoatRelationships(ownerBoatRelsToUpdate);
		updateOwnerBrandRelationships(ownersUpdated);
	}
	
	private static void addOwnersToBrandRelationshipCheck(Boat__c boat, set<Id> ownersUpdated) {
		if (boat.Owner_Boat_Relationships__r != null && boat.Owner_Boat_Relationships__r.size() > 0) {
			for (Owner_Boat_Relationship__c boatOwnerRel : boat.Owner_Boat_Relationships__r) {
				ownersUpdated.add(boatOwnerRel.Owner__c);			
			}
		}
	}
	
	private static boolean boatHasMultipleActiveRelationships(Boat__c boat) {
		integer numberOfActiveRelationships = 0;
		
		if (boat.Owner_Boat_Relationships__r != null && boat.Owner_Boat_Relationships__r.size() > 0) {
			for (Owner_Boat_Relationship__c boatOwnerRel : boat.Owner_Boat_Relationships__r) {
				if (boatOwnerRel.Status__c == 'Active') {
					++numberOfActiveRelationships;	
				}
			}
		}
		return numberOfActiveRelationships >= 2;
	}
	
	private static void setActiveBoatRelationship(Boat__c boat, map<Id, Owner_Boat_Relationship__c> ownerBoatRelsToUpdate, set<Id> ownersUpdated) {
		system.debug('setActiveBoatRelationship for ' + boat.Name);
		if (boat.Owner_Boat_Relationships__r != null && boat.Owner_Boat_Relationships__r.size() > 0) {
			system.debug('Boat ' + boat.Name + ' has ' + boat.Owner_Boat_Relationships__r.size() + ' relationships');
			Owner_Boat_Relationship__c activeBoatOwnerRel = boat.Owner_Boat_Relationships__r[0];
			for (Owner_Boat_Relationship__c boatOwnerRel : boat.Owner_Boat_Relationships__r) {
				// If the next relationship is SROC then take this first
				if (boatOwnerRel.Entry_Source__c == BoatServices.ENTRY_SOURCE_SROC && activeBoatOwnerRel.Entry_Source__c != BoatServices.ENTRY_SOURCE_SROC) {
					system.debug('Relationship source is SROC and active is not');
					system.debug('Setting active boat owner relationship to ' + boatOwnerRel.Id);
					activeBoatOwnerRel = boatOwnerRel;	
				}
				// If both relationships are SROC
				else if (boatOwnerRel.Entry_Source__c == BoatServices.ENTRY_SOURCE_SROC && activeBoatOwnerRel.Entry_Source__c == BoatServices.ENTRY_SOURCE_SROC) {
					// If we have a join date and the active does not 
					if (boatOwnerRel.SROC_Join_Date__c != null && activeBoatOwnerRel.SROC_Join_Date__c == null) {
						system.debug('Relationship source is SROC and has a join date');
						system.debug('Setting active boat owner relationship to ' + boatOwnerRel.Id);
						activeBoatOwnerRel = boatOwnerRel;	
					}
					// If we have 2 join dates
					else if (boatOwnerRel.SROC_Join_Date__c != null && activeBoatOwnerRel.SROC_Join_Date__c != null) {
						// If the join date is more recent
						if (boatOwnerRel.SROC_Join_Date__c > activeBoatOwnerRel.SROC_Join_Date__c) {
							system.debug('Relationship source is SROC and has a more recent join date');
							system.debug('Setting active boat owner relationship to ' + boatOwnerRel.Id);
							activeBoatOwnerRel = boatOwnerRel;	
						}
						// If the join dates are the same
						else if (boatOwnerRel.SROC_Join_Date__c == activeBoatOwnerRel.SROC_Join_Date__c) {
							// Which is more recent
							if (boatOwnerRel.CreatedDate > activeBoatOwnerRel.CreatedDate) {
								system.debug('Relationship source is SROC as has same join date and created more recent');
								system.debug('Setting active boat owner relationship to ' + boatOwnerRel.Id);
								activeBoatOwnerRel = boatOwnerRel;			
							}
						}
					}
					// We have no join dates
					else if (activeBoatOwnerRel.SROC_Join_Date__c == null) {
						// Which one was created more recent	
						if (boatOwnerRel.CreatedDate > activeBoatOwnerRel.CreatedDate) {
							system.debug('Relationship source is SROC as was created more recent');
							system.debug('Setting active boat owner relationship to ' + boatOwnerRel.Id);
							activeBoatOwnerRel = boatOwnerRel;			
						}
					}
				}
				// If no relationships are SROC
				else if (activeBoatOwnerRel.Entry_Source__c != BoatServices.ENTRY_SOURCE_SROC) {
					// If we have a more recent relationship use this
					if (boatOwnerRel.CreatedDate > activeBoatOwnerRel.CreatedDate) {
						system.debug('Relationship is more recent');
						system.debug('Setting active boat owner relationship to ' + boatOwnerRel.Id);
						activeBoatOwnerRel = boatOwnerRel;		
					}
				}
			}
			system.debug('Setting relationship ' + activeBoatOwnerRel.Id + ' as active');
			activeBoatOwnerRel.Status__c = 'Active';
			ownerBoatRelsToUpdate.put(activeBoatOwnerRel.Id, activeBoatOwnerRel);
			ownersUpdated.add(activeBoatOwnerRel.Owner__c);
		}
		else {
			system.debug('No existing relationships for boat');
		}
	}
	
	private static void setAllBoatRelationshipsToInactive(Boat__c boat, map<Id, Owner_Boat_Relationship__c> ownerBoatRelsToUpdate, set<Id> ownersUpdated) {
		system.debug('setActiveBoatRelationship for ' + boat.Name);
		if (boat.Owner_Boat_Relationships__r != null && boat.Owner_Boat_Relationships__r.size() > 0) {
			for (Owner_Boat_Relationship__c boatOwnerRel : boat.Owner_Boat_Relationships__r) {	
				if (boatOwnerRel.Status__c != 'Inactive') {
					system.debug('Setting relationship ' + boatOwnerRel.Id + ' to inactive');
					boatOwnerRel.Status__c = 'Inactive';
					ownerBoatRelsToUpdate.put(boatOwnerRel.Id, boatOwnerRel);
					ownersUpdated.add(boatOwnerRel.Owner__c);
				}	
			}
		}
		else {
			system.debug('No existing relationships for boat');
		}
	}
	
	private static void updateOwnerBoatRelationships(map<Id, Owner_Boat_Relationship__c> ownerBoatRelsToUpdate) {
		if (ownerBoatRelsToUpdate != null && !ownerBoatRelsToUpdate.isEmpty()) {
			boolean originalBoatTriggerProcessing = BoatServices.disableTriggerProcessing;
			boolean originalOwnerBoatTriggerProcessing = OwnerBoatRelationshipServices.disableTriggerProcessing;
			try {
				BoatServices.disableTriggerProcessing = true;
				OwnerBoatRelationshipServices.disableTriggerProcessing = true;
				system.debug('Updating ' + ownerBoatRelsToUpdate.size() + ' owner boat relationships');
				update ownerBoatRelsToUpdate.values();	
			}
			finally {
				BoatServices.disableTriggerProcessing = originalBoatTriggerProcessing;
				OwnerBoatRelationshipServices.disableTriggerProcessing = originalOwnerBoatTriggerProcessing;	
			}	
		}
		else {
			system.debug('No relationships to update');
		}
	}
	
	private static void updateOwnerBrandRelationships(set<Id> ownersUpdated) {
		system.debug('updateOwnerBrandRelationships');
		if (ownersUpdated != null && !ownersUpdated.isEmpty()) {
			map<Id, Account> ownersToUpdate = new map<Id, Account>();
			list<Account> ownersWithRelationships = getOwnersAndOwnerBoatRelationships(ownersUpdated);
			if (ownersWithRelationships != null && !ownersWithRelationships.isEmpty()) {
				for (Account ownerWithRelationships : ownersWithRelationships) {
					set<string> activeOwnerBrands = new set<string>();	
					
					if (ownerWithRelationships.Owner_Boat_Relationships__r != null && ownerWithRelationships.Owner_Boat_Relationships__r.size() > 0) {
						for (Owner_Boat_Relationship__c ownerRel : ownerWithRelationships.Owner_Boat_Relationships__r) {
							if (ownerRel.Status__c == 'Active' && !String.isEmpty(ownerRel.HIN_Number__r.Brand_del__c)) {
								activeOwnerBrands.add(ownerRel.HIN_Number__r.Brand_del__c);
							}
						}
					}
					
					string brandRelationships = '';
					if (!activeOwnerBrands.isEmpty()) {
						brandRelationships = String.join(new list<string>(activeOwnerBrands), ';');
					}
					
					system.debug('Updating owner ' + ownerWithRelationships.Id + ' brands to ' + brandRelationships);
					Account ownerToUpdate = new Account(Id=ownerWithRelationships.Id, Brand_Relationships__c=brandRelationships);
					ownersToUpdate.put(ownerToUpdate.Id, ownerToUpdate);
				}
			}
			
			if (!ownersToUpdate.isEmpty()) {
				system.debug('Updating ' + ownersToUpdate.size() + ' owners');
				update ownersToUpdate.values();
			}
		}
	}
	
	
	
	
	
	
	
	/*
	public static void updateOwnerBoatRelationships(list<Owner_Boat_Relationship__c> ownerBoatRels) {
		system.debug('updateOwnerBoatRelationships - enter');
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		set<Id> ownersUpdated = new set<Id>();
		try {
			// For each boat referenced set all the relationships to inactive that are active
			system.debug('Setting all active owner relationships to Inactive');
			list<Owner_Boat_Relationship__c> activeOwnerBoatRels = getActiveOwnerBoatRelationshipsForAllBoats(ownerBoatRels);
			if (activeOwnerBoatRels != null && activeOwnerBoatRels.size() > 0) {
				for (Owner_Boat_Relationship__c rel : activeOwnerBoatRels) {
					system.debug('Setting status to inactive - ' + rel.Id);
					rel.Status__c = 'Inactive';
					ownersUpdated.add(rel.Owner__c);
				}
				system.debug('Updating owner boat relationships');
				update activeOwnerBoatRels;
			}
			else {
				system.debug('No active owner boat relationships found');
			}
			
			// Get all the boats and owner relationships. Everything should be inactive at this point
			system.debug('Getting all boats and owner boat relationships');
			list<Boat__c> boats = getBoatsAndOwnerBoatRelationships(ownerBoatRels);		
			if (boats != null && boats.size() > 0) {
				// Find the active relationship for each boat
				system.debug('Finding the relationship to set as Active for each boat');
				list<Owner_Boat_Relationship__c> boatOwnerRelsToUpdate = new list<Owner_Boat_Relationship__c>();
				for (Boat__c boat : boats) {
					system.debug('Processing boat ' + boat.Id);
					if (boat.Owner_Boat_Relationships__r != null && boat.Owner_Boat_Relationships__r.size() > 0) {
						// The first one should be set as active by default. This will be the last one created
						Owner_Boat_Relationship__c activeBoatOwnerRel = boat.Owner_Boat_Relationships__r[0];
						for (Owner_Boat_Relationship__c boatOwnerRel : boat.Owner_Boat_Relationships__r) {
							// If we have SROC data then evaluate that
							if (boatOwnerRel.SROC_Join_Date__c != null && boatOwnerRel.SROC_Ownership_Status__c != null) {
								if (boatOwnerRel.SROC_Join_Date__c > activeBoatOwnerRel.SROC_Join_Date__c &&
						 		   (boatOwnerRel.SROC_Ownership_Status__c == 'OWNED' || activeBoatOwnerRel.SROC_Ownership_Status__c != 'OWNED')) {
						 		   	// A more recent owned boat should be active
						 		   	system.debug('Setting active boat owner relationship to ' + boatOwnerRel);
									activeBoatOwnerRel = boatOwnerRel;
								}
								else if (boatOwnerRel.SROC_Ownership_Status__c == 'OWNED' && activeBoatOwnerRel.SROC_Ownership_Status__c != 'OWNED') {
									// Anything owned should take precedence
									activeBoatOwnerRel = boatOwnerRel;
									system.debug('Setting active boat owner relationship to ' + boatOwnerRel);
								}
							}
						}
						system.debug('Setting relationship ' + activeBoatOwnerRel + ' as active');
						activeBoatOwnerRel.Status__c = 'Active';
						ownersUpdated.add(activeBoatOwnerRel.Owner__c);
						boatOwnerRelsToUpdate.add(new Owner_Boat_Relationship__c(Id=activeBoatOwnerRel.Id, Status__c='Active'));
					}
				}
			
				if (!boatOwnerRelsToUpdate.isEmpty()) {
					system.debug('Updating relationships');
					update boatOwnerRelsToUpdate;
				}
			}
			else {
				system.debug('Did not find any boats');
			}
				
			// Now we have fixed all the active and inactive relationships for each boat. We need to turn our attention to the owner 
			// side and update each owner account with the correct brands and SROC data
			list<Account> ownersToUpdate = new list<Account>();
			system.debug('Getting all owners and owner boat relationships to determine which boat to set as active');
			list<Account> owners = getOwnersAndOwnerBoatRelationships(ownersUpdated);
			if (owners != null && owners.size() > 0) {
				system.debug('Found a total of ' + owners.size() + ' owners');
				for (Account owner : owners) {
					system.debug('Processing owner ' + owner + ' to find active brands and which SROC data to copy to the owner');
					set<string> activeOwnerBrands = new set<string>();
					if (owner.Owner_Boat_Relationships__r != null && owner.Owner_Boat_Relationships__r.size() > 0) {
						Owner_Boat_Relationship__c ownerBoatRelToSetOnOwner = owner.Owner_Boat_Relationships__r[0];
						system.debug('Iterating over owner relationships');
						for (Owner_Boat_Relationship__c ownerBoatRel : owner.Owner_Boat_Relationships__r) {	
							// Only SR should evaluate the SROC
							if (ownerBoatRel.HIN_Number__r.Brand_del__c == 'SR') {
								if (ownerBoatRel.SROC_Join_Date__c != null && ownerBoatRel.SROC_Ownership_Status__c != null) {
									// Try to find the relationship to copy over to the owner
									if (ownerBoatRel.SROC_Join_Date__c > ownerBoatRelToSetOnOwner.SROC_Join_Date__c &&
							 		   (ownerBoatRel.SROC_Ownership_Status__c == 'OWNED' || ownerBoatRelToSetOnOwner.SROC_Ownership_Status__c != 'OWNED')) {
							 		   	// A more recent owned boat should be active
							 		   	system.debug('Setting owner rel ' + ownerBoatRel + ' as active');
										ownerBoatRelToSetOnOwner = ownerBoatRel;
									}
									else if (ownerBoatRel.SROC_Ownership_Status__c == 'OWNED' && ownerBoatRelToSetOnOwner.SROC_Ownership_Status__c != 'OWNED') {
										// Anything owned should take precedence
										system.debug('Setting owner rel ' + ownerBoatRel + ' as active');
										ownerBoatRelToSetOnOwner = ownerBoatRel;
									}	
								}
							}
							
							// If the relationship is active we need to capture it to build the active owner brands
							if (ownerBoatRel.Status__c == 'Active') {
								system.debug('Adding brand ' + ownerBoatRel.HIN_Number__r.Brand_del__c + ' to the active owner brands');
								activeOwnerBrands.add(ownerBoatRel.HIN_Number__r.Brand_del__c);	
							}
						}
						
						// Now we need to copy the relationship SROC data to the owner
						if (ownerBoatRelToSetOnOwner != null && ownerBoatRelToSetOnOwner.HIN_Number__r.Brand_del__c == 'SR') {
							system.debug('Setting owner SROC data for owner ' + owner + ' and relationship ' + ownerBoatRelToSetOnOwner);
							setOwnerSROCData(owner, ownerBoatRelToSetOnOwner);
						}
					}
					else {
						system.debug('No owner boat relationships were found for owner ' + owner);
					}
					
					// Now set the brands for the owner
					if (activeOwnerBrands.size() > 0) {
						owner.Brand_Relationships__c = String.join(new list<string>(activeOwnerBrands), ';');
					}
					else {
						owner.Brand_Relationships__c = '';
					}
					system.debug('Updating owner brands to ' + owner.Brand_Relationships__c + ' for owner ' + owner);
					ownersToUpdate.add(owner);
				}
				
				if (!ownersToUpdate.isEmpty()) {
					system.debug('Updating owners');
					update ownersToUpdate;
				}
			}
			else {
				system.debug('Did not find any owners');
			}
		}
		finally {
			OwnerBoatRelationshipServices.disableTriggerProcessing = false;	
		}
	}
	
	private static list<Owner_Boat_Relationship__c> getActiveOwnerBoatRelationshipsForAllBoats(list<Owner_Boat_Relationship__c> ownerBoatRels) {
		set<Id> boatIds = new set<Id>();
		for (Owner_Boat_Relationship__c rel : ownerBoatRels) {
			boatIds.add(rel.HIN_Number__c);
		}
		system.debug('Looking for all active owner boat relationships for ' + boatIds);
		list<Owner_Boat_Relationship__c> activeOwnerBoatRels = [select Id, Status__c, Owner__c, HIN_Number__c from Owner_Boat_Relationship__c where HIN_Number__c in :boatIds and Status__c = 'Active'];
		return activeOwnerBoatRels;
	}*/
	
	private static list<Boat__c> getBoatsWithOwnerBoatRelationships(set<Id> boatIds) {
		system.debug('getAllBoatsWithOwnerBoatRelationships for ' + boatIds.size() + ' boats');
		list<Boat__c> boats = [Select b.Id, b.Name, b.Status__c, b.Brand_del__c, (Select Id, CreatedDate, Owner__c, HIN_Number__c, Purchase_Date__c, Status__c, Entry_Source__c, NCOA_Address_Status__c, NCOA_Status__c, NCOA_Validation_Date__c, 
												 New_or_Used__c, SROC_Cancellation_Date__c, SROC_Comments__c, SROC_Enrollment_Level__c, SROC_Enrollment_Status__c, SROC_Join_Date__c, SROC_Member_ID__c, SROC_Membership_Status__c, 
												 SROC_Ownership_Status__c, SROC_Points_Total__c, SROC_Purchase_Date__c, SROC_Purchased_Dealer_Name__c, SROC_Purchased_Dealer_Number__c, SROC_Sales_Total__c, 
												 SROC_Welcome_Kit_Status__c, Email_Opt_in__c From Owner_Boat_Relationships__r order by SROC_Join_Date__c desc, CreatedDate desc) 
								From Boat__c b where b.Id in :boatIds];
		
		return boats;
	}
	
	/*
	private static list<Boat__c> getBoatsAndOwnerBoatRelationships(list<Owner_Boat_Relationship__c> ownerBoatRels) {
		set<Id> boatIds = new set<Id>();
		for (Owner_Boat_Relationship__c rel : ownerBoatRels) {
			boatIds.add(rel.HIN_Number__c);
		}
		
		return getBoatsWithOwnerBoatRelationships(boatIds);
	}*/
	
	private static list<Account> getOwnersAndOwnerBoatRelationships(set<Id> ownerIds) {
		system.debug('Looking for all owners and relationships for ' + ownerIds);
		list<Account> owners = [Select a.Id, a.Brand_Relationships__c, a.Purchase_Date__c, a.SROC_Welcome_Kit_Status__c, a.SROC_Sales_Total__c, a.SROC_Referral_Source__c, a.SROC_Purchased_Dealer_Number__c, a.SROC_Purchased_Dealer_Name__c, 
						a.SROC_Purchase_Date__c, a.SROC_Points_Total__c, a.SROC_Ownership_Status__c, a.SROC_Membership_Status__c, a.SROC_Member_ID__c, a.SROC_Join_Date__c, 
						a.SROC_Enrollment_Status__c, a.SROC_Enrollment_Level__c, a.SROC_Cancellation_Date__c, a.New_or_Used__c, a.NCOA_Validation_Date__c, 
						a.NCOA_Status__c, a.NCOA_Address_Status__c, (Select Id, CreatedDate, Owner__c, HIN_Number__c, Purchase_Date__c, Status__c, Entry_Source__c, NCOA_Address_Status__c, NCOA_Status__c, NCOA_Validation_Date__c, 
												 New_or_Used__c, SROC_Cancellation_Date__c, SROC_Comments__c, SROC_Enrollment_Level__c, SROC_Enrollment_Status__c, SROC_Join_Date__c, SROC_Member_ID__c, SROC_Membership_Status__c, 
												 SROC_Ownership_Status__c, SROC_Points_Total__c, SROC_Purchase_Date__c, SROC_Purchased_Dealer_Name__c, SROC_Purchased_Dealer_Number__c, SROC_Sales_Total__c, 
												 SROC_Welcome_Kit_Status__c, Email_Opt_in__c, HIN_Number__r.Brand_del__c From Owner_Boat_Relationships__r order by SROC_Join_Date__c desc, CreatedDate desc) 
								From Account a where a.Id in :ownerIds];
		
		return owners;
	}
	
	
	
	public static List<Boat__c> filterBoats(List<Boat__c> boats, Map<Id, Boat__c> oldBoats){
		List<Boat__c> filteredBoats = new List<Boat__c>();

		for(Boat__c boat: boats){
			if(boat.Brand_del__c !=oldBoats.get(boat.Id).Brand_del__c){
				filteredBoats.add(boat);
			}
		}
		return filteredBoats;
	}

	public static Map<Id, Set<String>> getParentObject(List<Owner_Boat_Relationship__c> ownerBoat){
		Set<Id> acctsIds= Pluck.ids('Owner__c', ownerBoat);
		Map<Id, Set<String>> accountsToBrandsMap= new Map<Id, Set<String>>();

		for(Id acctId: acctsIds){
			accountsToBrandsMap.put(acctId, new Set<String>());
		}

		for( Owner_Boat_Relationship__c owner :[SELECT Id, HIN_Number__r.Brand_del__c, Owner__r.Id, Status__c from Owner_Boat_Relationship__c 
												where Owner__c IN :acctsIds AND Status__c='Active']){
			
			accountsToBrandsMap.get(owner.Owner__c).add(owner.HIN_Number__r.Brand_del__c);
		}

		return accountsToBrandsMap;
	}
	
	public static Map<Id, Set<String>> getParentObject(List<Owner_Boat_Relationship__c> ownerBoat, List<Owner_Boat_Relationship__c> oldOwnerBoat){
		List<Owner_Boat_Relationship__c> ownerBoats = new List<Owner_Boat_Relationship__c>();
		ownerBoats.addAll(ownerBoat);
		ownerBoats.addAll(oldOwnerBoat);
		return getParentObject(ownerBoats);
	}
	
	public static Map<Id, set<string>> getDealerToBrandMap(list<Dealer_Brand__c> dealerBrands) {
		map<Id, set<string>> dealerToBrandMap = new map<Id, set<string>>();
		
		if (!dealerBrands.isEmpty()) {
			system.debug('************* dealerBrands is not empty');
			for (Dealer_Brand__c db : dealerBrands) {
				system.debug('************* dealerBrand:' + db);
				set<string> brands = dealerToBrandMap.get(db.Dealer__c);
				system.debug('************* brands: ' + brands);
				if (brands == null) {
					brands = new set<string>();
					dealerToBrandMap.put(db.Dealer__c, brands);
				}	
				
				system.debug('************* brand status: ' + db.Status__c);
				system.debug('************* brand__c: ' + db.Brand__c);
				if (db.Status__c == 'Active' && !String.isEmpty(db.Brand__c)) {
					brands.add(db.Brand__c);	
				}
			}
		}
		return dealerToBrandMap;
	}
	
	public static map<Id, set<string>> getDealerToBrandMapForChangedBrands(map<Id, Dealer_Brand__c> dealerBrandsMap, map<Id, Dealer_Brand__c> oldDealerBrandsMap) {
		list<Dealer_Brand__c> dealerBrandsList = new list<Dealer_Brand__c>();
		
		for (Id dealerBrandId : dealerBrandsMap.keySet()) {
			system.debug('************* Dealer brand id: ' + dealerBrandId);
			Dealer_Brand__c newDealerBrand = dealerBrandsMap.get(dealerBrandId);
			Dealer_Brand__c oldDealerBrand = oldDealerBrandsMap.get(dealerBrandId);
			system.debug('************* New dealer brand: ' + newDealerBrand != null ? newDealerBrand.Brand__c : 'null');
			system.debug('************* Old dealer brand: ' + oldDealerBrand != null ? oldDealerBrand.Brand__c : 'null');
			if (newDealerBrand != null && oldDealerBrand != null) {
				if ((newDealerBrand.Brand__c == null && oldDealerBrand.Brand__c != null) ||
					(newDealerBrand.Brand__c != null && oldDealerBrand.Brand__c == null) ||
					(newDealerBrand.Brand__c != oldDealerBrand.Brand__c) ||
					(newDealerBrand.Status__c != oldDealerBrand.Status__c)) {
					system.debug('************* Added new dealer brand: ' + newDealerBrand.Brand__c);
					dealerBrandsList.add(newDealerBrand);	
				}	
			}
		}
		return getDealerToBrandMap(dealerBrandsList);
	}

	public static Map<Id, Set<String>> getParentObject(List<Dealer_Brand__c> dealerBoats){
		Set<Id> acctsIds= Pluck.ids('Dealer__c', dealerBoats);
		Map<Id, Set<String>> accountsToBrandsMap= new Map<Id, Set<String>>();
		
		for(Id acctId: acctsIds){
			accountsToBrandsMap.put(acctId, new Set<String>());
		}

		for( Dealer_Brand__c dealer :[SELECT Id, Dealer__c, Brand__c from Dealer_Brand__c 
										where Dealer__c IN :acctsIds AND Status__c='Active']){
			
			accountsToBrandsMap.get(dealer.Dealer__c).add(dealer.Brand__c);
		}
		return accountsToBrandsMap;
	}
	
	public static Map<Id, Set<String>> getParentObject(List<Dealer_Brand__c> dealerBoat, List<Dealer_Brand__c> oldDealerBoat){
		List<Dealer_Brand__c> dealerBoats = new List<Dealer_Brand__c>();
		dealerBoats.addAll(dealerBoat);
		dealerBoats.addAll(oldDealerBoat);
		return getParentObject(dealerBoats);
	}
	
	public static Map<Id, Set<String>> getParentObject(List<Boat__c> boats){
		Set<Id> boatIds= Pluck.ids(boats);
		Map<Id, Set<String>> accountsToBrandsMap= new Map<Id, Set<String>>();
		for( Owner_Boat_Relationship__c owner :[SELECT Id, HIN_Number__r.Brand_del__c, Owner__r.Id from Owner_Boat_Relationship__c 
												where HIN_Number__c IN :boatIds AND Status__c='Active']){
			Id acctId=owner.Owner__c;
			if(!accountsToBrandsMap.containskey(acctId)){
				accountsToBrandsMap.put(acctId, new Set<String>());
			}
			accountsToBrandsMap.get(acctId).add(owner.HIN_Number__r.Brand_del__c);
		}
		return accountsToBrandsMap;
	}
	
	public static list<Account> updateOwnerBrandRelationships(map<Id, set<string>> ownerIdToBrandMap) {
		return processAccountBrands(ownerIdToBrandMap);
	}

	public static List<Account> processAccountBrands(Map<Id, Set<String>> accountsToBrandsMap){
		List<Account> accountsToUpdate = new List<Account>();
		for(Id acctId: accountsToBrandsMap.keySet()){
			
			accountsToUpdate.add(new Account(
										Id=acctId,
										Brand_Relationships__c=String.join(new List<String>(accountsToBrandsMap.get(acctId)), ';')
										));
		}
		return accountsToUpdate;
	}

	public static void updateAccounts(List<Account> accountsToUpdate, Map<Id,SObject> childObjects){
		try{
			update accountsToUpdate;
		} catch (DmlException e){
			Map<Id, List<SObject>> childObjectsMap=linkParentAndChildAccounts(accountsToUpdate, childObjects);
			for(Integer i=0; i<e.getNumDml(); i++){
				for(SObject childObject: childObjectsMap.get(e.getDmlId(i))){
					childObject.addError('Error trying to update the brands on the account '+ e.getDmlId(i) + ':' + e.getDmlMessage(i));
				}
			}
		}
		
		//Process the contacts and update the 'other active brands' - BS-289
		Set<Id> accountIds = new Map<Id,SObject>(accountsToUpdate).keySet();
		ContactServices.updateContactOtherBrandsByAccount(accountIds);
	}
	
	public static void deleteChildJunctionObjects(Map<Id, Boat__c> boatsToDeleteMap){
		List<Owner_Boat_Relationship__c> junctionObjectsToDelete = new List<Owner_Boat_Relationship__c>();
		Set<Id> boatsToDelete = Pluck.ids(new List<Boat__c>(boatsToDeleteMap.values()));
		try{
			
			junctionObjectsToDelete = [SELECT Id, HIN_Number__c from Owner_Boat_Relationship__c Where HIN_Number__c IN :boatsToDelete];
			delete junctionObjectsToDelete;
			
		} catch (DmlException e){
			for(Integer i=0; i<e.getNumDml(); i++){
				boatsToDeleteMap.get(junctionObjectsToDelete[e.getDmlIndex(i)].HIN_number__c)
					.addError('Error trying to update the brands on the account '+ e.getDmlId(i) + ':' + e.getDmlMessage(i));
			}
		}
	}

	public static Map<Id, List<SObject>> linkParentAndChildAccounts(List<Account> accountsToUpdate, Map<Id, SObject> childObjects){
		Map<Id, List<SObject>> childObjectsMap= new Map<Id, List<SObject>>();
		if(!childObjects.isEmpty()){
			if(childObjects.values()[0].getSObjectType()==Owner_Boat_Relationship__c.SObjectType){
				childObjectsMap= GroupBy.ids('Owner__c', childObjects.values());
			} else if(childObjects.values()[0].getSObjectType()==Dealer_Brand__c.SObjectType){
				childObjectsMap= GroupBy.ids('Dealer__c', childObjects.values());
			} else if(childObjects.values()[0].getSObjectType()==Boat__c.SObjectType){
				List<Account> childAccountsToUpdate = [SELECT Id, (SELECT HIN_Number__c from Owner_Boat_Relationships__r) from Account where Id IN :accountsToUpdate];
				for(Account a: childAccountsToUpdate){
					childObjectsMAp.put(a.Id, new List<SObject>());
					for(Owner_Boat_Relationship__c obr: a.Owner_Boat_Relationships__r){
						if(childObjects.containsKey(obr.HIN_Number__c)){
							childObjectsMap.get(a.Id).add(childObjects.get(obr.HIN_Number__c));
						}	
					}
				}
			}
		}
		
		return childObjectsMap;
	}
	
	private static set<string> getOwnerBrands(Account owner) {
		set<string> brands = new set<string>();
		list<Owner_Boat_Relationship__c> boatRels = [SELECT Id, HIN_Number__r.Brand_del__c from Owner_Boat_Relationship__c where Owner__c = :owner.Id AND Status__c='Active'];
		if (boatRels != null) {
			for (Owner_Boat_Relationship__c boatRel : boatRels) {
				brands.add(boatRel.HIN_Number__r.Brand_del__c);		
			}
		}
		system.debug('Brand relationships=' + brands);
		return brands;
	}
	
	public static void updateOwnerSROCData(List<Owner_Boat_Relationship__c> newOwnerBoats) {
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		try {
			list<Account> ownersToUpdate = new list<Account>();
			list<Owner_Boat_Relationship__c> obrsToUpdate = new list<Owner_Boat_Relationship__c>();
			
			// For each owner boat relationship find the owner and see if we need to update the owner record with this data
			for (Owner_Boat_Relationship__c obr : newOwnerBoats) {
				// Get the owner and all relationships
				Account owner = [Select a.Brand_Relationships__c, a.SROC_Welcome_Kit_Status__c, a.SROC_Sales_Total__c, a.SROC_Referral_Source__c, a.SROC_Purchased_Dealer_Number__c, a.SROC_Purchased_Dealer_Name__c, 
								a.SROC_Purchase_Date__c, a.SROC_Points_Total__c, a.SROC_Ownership_Status__c, a.SROC_Membership_Status__c, a.SROC_Member_ID__c, a.SROC_Join_Date__c, 
								a.SROC_Enrollment_Status__c, a.SROC_Enrollment_Level__c, a.SROC_Cancellation_Date__c, a.New_or_Used__c, a.NCOA_Validation_Date__c, 
								a.NCOA_Status__c, a.NCOA_Address_Status__c,
								(Select Id, Owner__c, HIN_Number__c, Purchase_Date__c, Status__c, Entry_Source__c, NCOA_Address_Status__c, NCOA_Status__c, NCOA_Validation_Date__c, 
														 New_or_Used__c, SROC_Cancellation_Date__c, SROC_Comments__c, SROC_Enrollment_Level__c, SROC_Enrollment_Status__c, SROC_Join_Date__c, SROC_Member_ID__c, SROC_Membership_Status__c, 
														 SROC_Ownership_Status__c, SROC_Points_Total__c, SROC_Purchase_Date__c, SROC_Purchased_Dealer_Name__c, SROC_Purchased_Dealer_Number__c, SROC_Sales_Total__c, 
														 SROC_Welcome_Kit_Status__c, Email_Opt_in__c From Owner_Boat_Relationships__r order by SROC_Join_Date__c desc) From Account a where Id=:obr.Owner__c];
								
				Owner_Boat_Relationship__c activeObr = obr;
				if (owner.Owner_Boat_Relationships__r.size() > 1) {
					// Find the relationship that should be active
					list<Owner_Boat_Relationship__c> allObrs = owner.Owner_Boat_Relationships__r;
					
					// Find the best active relationship
					activeObr = allObrs[0];
					for (Owner_Boat_Relationship__c obr2 : allObrs) {
						if (obr2.Status__c == 'Active') {
							activeObr = obr2;
							break;	
						}	
					}
					
					for (Owner_Boat_Relationship__c obr2 : allObrs) {
						if (obr2.SROC_Join_Date__c > activeObr.SROC_Join_Date__c &&
        		 		   (obr2.SROC_Ownership_Status__c == 'OWNED' || activeObr.SROC_Ownership_Status__c != 'OWNED')) {
        					activeObr = obr2;
        				}
        				else if (obr2.SROC_Ownership_Status__c == 'OWNED' && activeObr.SROC_Ownership_Status__c != 'OWNED') {
        					activeObr = obr2;
        				}
					}
					
					// Update all the other obrs to inactive
					for (Owner_Boat_Relationship__c obr3 : allObrs) {
						if (obr3.Id != activeObr.Id) {
							if (obr3.Status__c == 'Active') {
								Owner_Boat_Relationship__c obrToUpdate = [Select Id, Status__c from Owner_Boat_Relationship__c where Id=:obr3.Id];
								obrToUpdate.Status__c = 'Inactive';
								obrsToUpdate.add(obrToUpdate);
							}
						}
					}
				}
				
				// Make sure the active obr has the right status
				if (activeObr.Status__c != 'Active') {
					Owner_Boat_Relationship__c obrToUpdate = [Select Id, Status__c from Owner_Boat_Relationship__c where Id=:activeObr.Id];
					obrToUpdate.Status__c = 'Active';
					obrsToUpdate.add(obrToUpdate);
				}
				
				// If the SROC Ownership status changed then we need to recalculate the owner brands
				setOwnerSROCData(owner, activeObr);
				ownersToUpdate.add(owner);
			}	
			
			if (obrsToUpdate.size() > 0) {
				system.debug('Updating owner boat relationships');
				update obrsToUpdate;
			}
			
			if (ownersToUpdate.size() > 0) {
				system.debug('Updating owners with SROC data');
				update ownersToUpdate;
			}	
		}
		finally {
			OwnerBoatRelationshipServices.disableTriggerProcessing = false;	
		}
	}
	
	private static void setOwnerSROCData(Account owner, Owner_Boat_Relationship__c obr) {
        owner.NCOA_Address_Status__c = obr.NCOA_Address_Status__c;
        owner.NCOA_Status__c = obr.NCOA_Status__c;
        owner.NCOA_Validation_Date__c = obr.NCOA_Validation_Date__c;
        owner.New_or_Used__c = obr.New_or_Used__c;
        owner.SROC_Cancellation_Date__c = obr.SROC_Cancellation_Date__c;
        owner.SROC_Enrollment_Level__c = obr.SROC_Enrollment_Level__c;
        owner.SROC_Enrollment_Status__c = obr.SROC_Enrollment_Status__c;
        owner.SROC_Join_Date__c = obr.SROC_Join_Date__c;
        owner.SROC_Member_ID__c = obr.SROC_Member_ID__c;
        owner.SROC_Membership_Status__c = obr.SROC_Membership_Status__c;
        owner.SROC_Ownership_Status__c = obr.SROC_Ownership_Status__c;
        owner.SROC_Points_Total__c = obr.SROC_Points_Total__c;
        owner.SROC_Purchase_Date__c = obr.SROC_Purchase_Date__c;
        owner.SROC_Purchased_Dealer_Name__c = obr.SROC_Purchased_Dealer_Name__c;
        owner.SROC_Purchased_Dealer_Number__c = obr.SROC_Purchased_Dealer_Number__c;
        owner.SROC_Sales_Total__c = obr.SROC_Sales_Total__c;
        owner.SROC_Welcome_Kit_Status__c = obr.SROC_Welcome_Kit_Status__c;
        
        if (obr.Email_Opt_In__c == 'Y' || obr.Email_Opt_In__c == 'Yes') {
        	 owner.PersonHasOptedOutOfEmail = false;
        }
        else {
        	owner.PersonHasOptedOutOfEmail = true;
        }
        
        if (owner.Comments__c == null) {
        	owner.Comments__c = obr.SROC_Comments__c;
        }	
	}
	
}