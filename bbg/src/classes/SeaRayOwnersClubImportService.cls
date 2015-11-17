public class SeaRayOwnersClubImportService {
	private static final integer NUMBER_OF_DEALER_DIGITS = 5;
	private static final integer NUMBER_OF_LOCATION_DIGITS = 3;
	public static final string BRAND = 'SR';
	public static final string US_ISO = 'US';
	public static final string CA_ISO = 'CA';
	public static final string ENTRY_SOURCE_SROC = 'SROC';
	public static final string ENTRY_SOURCE_OBMS = 'OBMS';
	private static Id OWNER_RECORD_TYPE_ID = [select Id from recordtype where developerName='Owner'].Id;
	
	public void processOwnersClubData(SROC__c ocData) {
		try {
			system.debug('Looking for matching boat for HIN ' + ocData.HIN__c);
			Boat__c boat = getBoat(ocData.HIN__c);
			if (boat == null) {
				system.debug('Updating processing error to true. Did not find a matching boat for HIN ' + ocData.HIN__c);
				ocData.Is_Processing_Error__c = true;
				ocData.Processing_Error_Message__c = 'Boat ' + ocData.HIN__c + ' was not found';
				ocData.Is_Processed__c = true;
			}	
			else {
				system.debug('Found a matching boat for HIN ' + ocData.HIN__c);
				
				// See if we have a matching owner
				system.debug('Looking for a matching owner for boat ' + ocData.HIN__c);
				Account owner = findMatchingOwnerByBoat(ocData);
				if (owner == null) {
					system.debug('Did not find matching owner by boat');
					// No existing owner so we need to create one. First we need to set all existing owner relationships as 
					// inactive IF the new owner is set to the active one
					if ('OWNED'.equalsIgnoreCase(ocData.SROC_Ownership_Status__c)) {
						system.debug('New owner is Active so setting old boat owners to inactive');
						setAllExistingOwnerRelationshipsToInactive(boat);
					}
					else {
						setAllExistingOwnerRelationshipsToInactiveIfOlderThanSROC(boat, ocData);
					}
					
					// We could not find an owner by boat, so try just by person
					system.debug('Looking for existing owner account, perhaps from another boat');
					owner = findExistingOwner(ocData);
					
					if (owner == null) {
						// Now create the new owner and relationship
						system.debug('Creating new owner and relationship');
						owner = createOwnerAccount(ocData);
						createOwnerBoatRelationship(ocData, boat, owner);
					}
					else {
						system.debug('Looking for an existing owner boat relationship');
						Owner_Boat_Relationship__c obr = findOwnerBoatRelationship(owner, boat);
						if (obr == null) {
							system.debug('Creating new owner boat relationship');
							createOwnerBoatRelationship(ocData, boat, owner);
						}
						else {
							system.debug('Updating existing owner boat relationship');
							obr = updateOwnerBoatRelationship(ocData, obr);
						}	
						
						system.debug('Updating existing owner account');
						owner = updateExistingOwner(ocData, owner);
					}
				}
				else {
					system.debug('Found matching owner - ' + owner.Id);
					// Set all existing relationships to inactive
					if ('OWNED'.equalsIgnoreCase(ocData.SROC_Ownership_Status__c)) {
						system.debug('Matching owner is Active so setting all relationships to inactive');
						setAllExistingOwnerRelationshipsToInactive(boat);
					}
					else {
						setAllExistingOwnerRelationshipsToInactiveIfOlderThanSROC(boat, ocData);
					}
					
					// Update the owner with this data
					system.debug('Updating existing owner and relationship');
					updateExistingOwnerRelationship(ocData, owner, boat);
					owner = updateExistingOwner(ocData, owner);
				}
				system.debug('Updating processed to success');
				ocData.Is_Processing_Error__c = false;
				ocData.Processing_Error_Message__c = null;
				ocData.Is_Processed__c = true;
			}
			
			update ocData;
		}
		catch(Exception exp) {
			system.debug('Owners Club data failure');
			system.debug('Exception: ' + exp.getMessage());
			ocData.Is_Processed__c = true;
			ocData.Is_Processing_Error__c = true;
			ocData.Processing_Error_Message__c = exp.getMessage();
			
			system.debug('Updating processing to failed');
			update ocData;
		}
		
		
	}
	
	// Sets all existing owner relationships to inactive if the PurchaseDate <= SROC PurchaseDate
	private void setAllExistingOwnerRelationshipsToInactiveIfOlderThanSROC(Boat__c boat, SROC__c ocData) {
		list<Owner_Boat_Relationship__c> ownerRels = [select Id, Status__c, HIN_Number__c, Purchase_Date__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id and Status__c != 'Inactive'];	
		if (ownerRels != null) {
			list<Owner_Boat_Relationship__c> ownerRelsToUpdate = new list<Owner_Boat_Relationship__c>();
			
			// Sometimes the SROC Purchase Date is null. In this case we will use the Join Date
			Date srocDateToCompare = ((ocData.SROC_Purchase_Date__c != null) ? ocData.SROC_Purchase_Date__c : ocData.SROC_Join_Date__c);
			for (Owner_Boat_Relationship__c ownerRel : ownerRels) {
				if (ownerRel.Purchase_Date__c <= srocDateToCompare) {
					system.debug('Setting owner relationship ' + ownerRel.Id + ' to inactive');
					ownerRel.Status__c = 'Inactive';
					ownerRelsToUpdate.add(ownerRel);
				}
			}
			
			if (ownerRelsToUpdate.size() > 0) {
				system.debug('Updating owner relationships to inactive - ' + ownerRelsToUpdate);
				update ownerRelsToUpdate;
			}
			else {
				system.debug('No owner relationships were found that needed to be set to inactive');
			}
		}
		else {
			system.debug('Found no existing owner relationships with status not inactive');
		}		
	}
	
	// Tries to find an existing owner account by firstname, lastname, and street
	private Account findExistingOwner(SROC__c ocData) {
		// only do the search if we have a first, last, and street. Otherwise it would be difficult to find a match
		if (ocData.First_Name__c != null && ocData.Last_Name__c != null && ocData.Address__c != null &&
			ocData.First_Name__c.length() > 0 && ocData.Last_Name__c.length() > 0 && ocData.Address__c.length() > 0) {
			string firstNameLike = ocData.First_Name__c + '%';
			string firstNameMiddleLike = ocData.Middle_Initial__c + '. ' + ocData.First_Name__c + '%';
			string lastNameLike = ocData.Last_Name__c + '%';
			string lastNameSuffixLike = ocData.Last_Name__c + ' ' + ocData.Name_Suffix__c + '%';
			string addressLike = ocData.Address__c + '%';
			// Do a like search on each field to find records in a case-insensitive way
			list<Account> owners = [select Id, FirstName, LastName, PersonMailingStreet from Account where RecordTypeId=:OWNER_RECORD_TYPE_ID and (FirstName LIKE :firstNameLike or FirstName LIKE :firstNameMiddleLike) and (LastName LIKE :lastNameLike or LastName LIKE :lastNameSuffixLike) and PersonMailingStreet LIKE :addressLike];
			if (owners.size() > 0) {
				// Use code to try and find a case insensitive match on first, last, and address
				Account ownerMatch = null;
				for (Account owner : owners) {
					if (((owner.FirstName == null && ocData.First_Name__c == null) || (owner.FirstName != null && (owner.FirstName.equalsIgnoreCase(ocData.First_Name__c) || owner.FirstName.equalsIgnoreCase(ocData.Middle_Initial__c + '. ' + ocData.First_Name__c)))) && 
						((owner.PersonMailingStreet == null && ocData.Address__c == null) || (owner.PersonMailingStreet != null && owner.PersonMailingStreet.equalsIgnoreCase(ocData.Address__c))) && 
						(owner.LastName.equalsIgnoreCase(ocData.Last_Name__c) || owner.LastName.equalsIgnoreCase(ocData.Last_Name__c + ' ' + ocData.Name_Suffix__c))) {
						ownerMatch = owner;
						break;
					}
				}
				if (ownerMatch != null) {
					return loadOwnerAccount(ownerMatch.Id);
				}
			}
		}
		return null;
	}
	
	private void setAllExistingOwnerRelationshipsToInactive(Boat__c boat) {
		list<Owner_Boat_Relationship__c> ownerRels = [select Id, Status__c, HIN_Number__c, Purchase_Date__c From Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id and Status__c != 'Inactive'];	
		if (ownerRels != null) {
			for (Owner_Boat_Relationship__c ownerRel : ownerRels) {
				system.debug('Setting owner relationship ' + ownerRel.Id + ' to inactive');
				ownerRel.Status__c = 'Inactive';
			}
			
			system.debug('Updating owner relationships for - ' + ownerRels);
			try {
				update ownerRels;
			}
			catch(Exception exp) {
				system.debug('Failed to update owner relationships');
				system.debug('Exception - ' + exp);
				throw exp;
			}
		}
		else {
			system.debug('Found no existing owner relationships with status not inactive');
		}
	}
	
	private Account updateExistingOwner(SROC__c ocData, Account owner) {
		owner.Birthday__pc = ocData.Birth_Date__c;
        owner.Middle_Initial__c = ocData.Middle_Initial__c;
        owner.Name_Suffix__c = ocData.Name_Suffix__c;
        owner.PersonMailingStreet  = ocData.Address__c;
        owner.PersonMailingState = ocData.State__c;
        owner.PersonMailingCity = ocData.City__c;
        owner.PersonMailingCountry = ocData.Country_Name__c;
        owner.PersonMailingPostalCode = ocData.Zip_Code__c;
        owner.Work_Phone__pc = ocData.Work_Phone__c;
        owner.Home_Address_ISO_Code__c = getCountry(ocData);
        owner.Co_Owner__c = ocData.Co_Owner__c;       
        owner.PersonHomePhone = ocData.Home_Phone__c;
        owner.PersonEmail= ocData.Email__c;    
        // Even if we are updating OBMS we want to use the OC Data
        owner.Entry_Source__c = ENTRY_SOURCE_SROC;
        
        // If the boat is owned then this will be the active boat for this owner. We need to update the HIN
        if (ocData.SROC_Ownership_Status__c == 'OWNED') {
       		owner.HIN_Number__c = ocData.HIN__c;
        }
        
        // For the SROC data we only want to put the most recent one if there are 
        // more than one
        boolean updateSROC = false;
        if (owner.SROC_Join_Date__c == null) {
        	// Update if no existing join date
        	updateSROC = true;
        }
        else if (owner.SROC_Member_ID__c == ocData.SROC_Member_ID__c) {
        	// Update if the same member id
        	updateSROC = true;
        }
        else if (ocData.SROC_Join_Date__c > owner.SROC_Join_Date__c &&
        		 (ocData.SROC_Ownership_Status__c == 'OWNED' || owner.SROC_Ownership_Status__c != 'OWNED')) {
        	// Update if a more recent join date
        	updateSROC = true;
        }
        else if (ocData.SROC_Ownership_Status__c == 'OWNED' && owner.SROC_Ownership_Status__c != 'OWNED') {
        	// Update if this boat is owned and the current one is not
        	updateSROC = true;
        }
       
       	if (updateSROC) {
       		if (ocData.Customer_Wants_Mailings__c == 'y' || ocData.Customer_Wants_Mailings__c == 'Y' || ocData.Customer_Wants_Mailings__c == 'Yes' || ocData.Customer_Wants_Mailings__c == 'YES') {
       			owner.Customer_Wants_Mailings__c = true;	
       		}
       		else {
       			owner.Customer_Wants_Mailings__c = false;
       		}
	        owner.Opt_Out_of_Sea_Ray_Living__c = ocData.Opt_Out_of_Sea_Ray_Living__c;
	        owner.NCOA_Address_Status__c = ocData.NCOA_Address_Status__c;
	        owner.NCOA_Status__c = ocData.NCOA_Status__c;
	        owner.NCOA_Validation_Date__c = ocData.NCOA_Validation_Date__c;
	        owner.New_or_Used__c = ocData.New_or_Used__c;
	        owner.SROC_Cancellation_Date__c = ocData.SROC_Cancellation_Date__c;
	        owner.SROC_Enrollment_Level__c = ocData.SROC_Enrollment_Level__c;
	        owner.SROC_Enrollment_Status__c = ocData.SROC_Enrollment_Status__c;
	        owner.SROC_Join_Date__c = ocData.SROC_Join_Date__c;
	        owner.SROC_Member_ID__c = ocData.SROC_Member_ID__c;
	        owner.SROC_Membership_Status__c = ocData.SROC_Membership_Status__c;
	        owner.SROC_Ownership_Status__c = ocData.SROC_Ownership_Status__c;
	        owner.SROC_Points_Total__c = ocData.SROC_Points_Total__c;
	        owner.SROC_Purchase_Date__c = ocData.SROC_Purchase_Date__c;
	        owner.SROC_Purchased_Dealer_Name__c = ocData.SROC_Purchased_Dealer_Name__c;
	        owner.SROC_Purchased_Dealer_Number__c = ocData.SROC_Purchased_Dealer_Number__c;
	        owner.SROC_Sales_Total__c = ocData.SROC_Sales_Total__c;
	        owner.SROC_Welcome_Kit_Status__c = ocData.SROC_Welcome_Kit_Status__c;
	        
	        if (ocData.Email_Opt_In__c == 'Y' || ocData.Email_Opt_In__c == 'Yes') {
	        	owner.PersonHasOptedOutOfEmail = false;
	        	 //owner.Email_Opt_in__c = 'Yes';
	        }
	        else {
	        	owner.PersonHasOptedOutOfEmail = true;
	        	//owner.Email_Opt_in__c = 'No';
	        }
	        
	        if (owner.Comments__pc == null) {
	        	owner.Comments__pc = ocData.Comments__c;
	        }
       	}
        
        
        
        set<string> brands = getOwnerBrands(owner);
        if (brands != null && brands.size() > 0) {
        	list<string> brandList = new list<string>(brands);
        	owner.Brand_Relationships__c = String.join(brandList, ';');
        }
		
		update owner;
		
		return owner;
	}
	
	private set<string> getOwnerBrands(Account owner) {
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
	
	private Owner_Boat_Relationship__c updateOwnerBoatRelationship(SROC__c ocData, Owner_Boat_Relationship__c ownerRel) {
		system.debug('Updating owner relationship - ' + ownerRel.Id);
		ownerRel.Status__c = 'OWNED'.equalsIgnoreCase(ocData.SROC_Ownership_Status__c) ? 'Active' : 'Inactive';
   		
   		// We dont want to overwrite the purchase date if there is one
   		if (ocData.SROC_Purchase_Date__c != null) {
   			ownerRel.Purchase_Date__c = ocData.SROC_Purchase_Date__c;    
   		}   
   		
   		ownerRel.Customer_Wants_Mailings__c = ocData.Customer_Wants_Mailings__c;	
   		ownerRel.Entry_Source__c = ENTRY_SOURCE_SROC;
        ownerRel.NCOA_Address_Status__c = ocData.NCOA_Address_Status__c;
        ownerRel.NCOA_Status__c = ocData.NCOA_Status__c;
        ownerRel.NCOA_Validation_Date__c = ocData.NCOA_Validation_Date__c;
        ownerRel.New_or_Used__c = ocData.New_or_Used__c;
        ownerRel.SROC_Cancellation_Date__c = ocData.SROC_Cancellation_Date__c;
        ownerRel.SROC_Enrollment_Level__c = ocData.SROC_Enrollment_Level__c;
        ownerRel.SROC_Enrollment_Status__c = ocData.SROC_Enrollment_Status__c;
        ownerRel.SROC_Join_Date__c = ocData.SROC_Join_Date__c;
        ownerRel.SROC_Member_ID__c = ocData.SROC_Member_ID__c;
        ownerRel.SROC_Membership_Status__c = ocData.SROC_Membership_Status__c;
        ownerRel.SROC_Ownership_Status__c = ocData.SROC_Ownership_Status__c;
        ownerRel.SROC_Points_Total__c = ocData.SROC_Points_Total__c;
        ownerRel.SROC_Purchase_Date__c = ocData.SROC_Purchase_Date__c;
        ownerRel.SROC_Purchased_Dealer_Name__c = ocData.SROC_Purchased_Dealer_Name__c;
        ownerRel.SROC_Purchased_Dealer_Number__c = ocData.SROC_Purchased_Dealer_Number__c;
        ownerRel.SROC_Sales_Total__c = ocData.SROC_Sales_Total__c;
        ownerRel.SROC_Welcome_Kit_Status__c = ocData.SROC_Welcome_Kit_Status__c;
        ownerRel.SROC_Comments__c = ocData.Comments__c;
        ownerRel.Opt_Out_of_Sea_Ray_Living__c = ocData.Opt_Out_of_Sea_Ray_Living__c;
        
        if (ocData.Email_Opt_In__c == 'Y' || ocData.Email_Opt_In__c == 'Yes') {
        	 ownerRel.Email_Opt_in__c = 'Yes';
        }
        else {
        	ownerRel.Email_Opt_in__c = 'No';
        }
   		
   		update ownerRel;	
   		
   		return ownerRel;
	}
	
	private Owner_Boat_Relationship__c findOwnerBoatRelationship(Account owner, Boat__c boat) {
		list<Owner_Boat_Relationship__c> ownerRels = [select Id, Status__c, HIN_Number__c, Purchase_Date__c from Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id and Owner__c=:owner.Id];
		if (ownerRels.size() > 0) {
			return ownerRels[0];
		}
		return null;		
	}
	
	private void updateExistingOwnerRelationship(SROC__c ocData, Account owner, Boat__c boat) {
		Owner_Boat_Relationship__c ownerRel = findOwnerBoatRelationship(owner, boat);		
		if (ownerRel != null) {
			system.debug('Found owner relationship - ' + ownerRel.Id);
			ownerRel = updateOwnerBoatRelationship(ocData, ownerRel);
		}
		else {
			system.debug('Did not find existing owner relationship');
		}
	}
	
	// Loads all the fields we need for the owner account
	private Account loadOwnerAccount(Id ownerId) {
		list<Account> owners = [select Id, Customer_Wants_Mailings__c, PersonHasOptedOutOfEmail, FirstName, LastName, PersonEmail, Entry_Source__c, Brand_Relationships__c, Co_Owner__c, Date_of_Birth__c, Middle_Initial__c, Name_Suffix__c, NCOA_Address_Status__c, NCOA_Status__c,
								New_Or_Used__c, SROC_Cancellation_Date__c, SROC_Enrollment_Level__c, SROC_Enrollment_Status__c, SROC_Join_Date__c, SROC_Member_ID__c, SROC_Membership_Status__c, SROC_Ownership_Status__c,
								SROC_Points_Total__c, SROC_Purchase_Date__c, SROC_Purchased_Dealer_Name__c, SROC_Purchased_Dealer_Number__c, SROC_Referral_Source__c, SROC_Sales_Total__c, SROC_Welcome_Kit_Status__c, Comments__pc, Work_Phone__pc, Opt_Out_of_Sea_Ray_Living__c from Account where Id=:ownerId];
		
		if (owners.size() > 0) {
			return owners[0];
		}
		return null;
	}
	
	private Account findMatchingOwnerByBoat(SROC__c ocData) {
		list<Owner_Boat_Relationship__c> ownerRels = [select Id, Name, Status__c, Purchase_Date__c, Owner__c, Owner__r.FirstName, Owner__r.LastName From Owner_Boat_Relationship__c where HIN_Number__r.Name=:ocData.HIN__c];
		if (ownerRels != null && ownerRels.size() > 0) {
			system.debug('Found some owner relationships');
			// If an existing owner matches on the first, last, and purchase date then this is the same person
			for (Owner_Boat_Relationship__c ownerRel : ownerRels) {
				Account owner = ownerRel.Owner__r;
				if (((owner.FirstName == null && ocData.First_Name__c == null) || (owner.FirstName != null && (owner.FirstName.equalsIgnoreCase(ocData.First_Name__c) || owner.FirstName.equalsIgnoreCase(ocdata.Middle_Initial__c + '. ' + ocData.First_Name__c)))) && 
				(owner.LastName.equalsIgnoreCase(ocData.Last_Name__c) || owner.LastName.equalsIgnoreCase(ocData.Last_Name__c + ' ' + ocData.Name_Suffix__c))) {
					system.debug('Found a matching owner - ' + owner.Id);
					return loadOwnerAccount(owner.Id);
				}
			}	
		}
		else {
			system.debug('Did not find any owner relationships');
		}
		return null;
	}
	
	private Owner_Boat_Relationship__c createOwnerBoatRelationship(SROC__c ocData, Boat__c boat, Account owner) {
		system.debug('createOwnerBoatRelationship');
       	Owner_Boat_Relationship__c  boatOwnerShip = new Owner_Boat_Relationship__c();
        boatOwnerShip.HIN_Number__c = boat.Id;
        boatOwnerShip.Owner__c = owner.Id;
        boatOwnerShip.Status__c = 'OWNED'.equalsIgnoreCase(ocData.SROC_Ownership_Status__c) ? 'Active' : 'Inactive';
        boatOwnerShip.Purchase_Date__c = ocData.SROC_Purchase_Date__c; 
        boatOwnerShip.Entry_Source__c = ENTRY_SOURCE_SROC;      
        
   		boatOwnerShip.Customer_Wants_Mailings__c = ocData.Customer_Wants_Mailings__c;	
        boatOwnerShip.NCOA_Address_Status__c = ocData.NCOA_Address_Status__c;
        boatOwnerShip.NCOA_Status__c = ocData.NCOA_Status__c;
        boatOwnerShip.NCOA_Validation_Date__c = ocData.NCOA_Validation_Date__c;
        boatOwnerShip.New_or_Used__c = ocData.New_or_Used__c;
        boatOwnerShip.SROC_Cancellation_Date__c = ocData.SROC_Cancellation_Date__c;
        boatOwnerShip.SROC_Enrollment_Level__c = ocData.SROC_Enrollment_Level__c;
        boatOwnerShip.SROC_Enrollment_Status__c = ocData.SROC_Enrollment_Status__c;
        boatOwnerShip.SROC_Join_Date__c = ocData.SROC_Join_Date__c;
        boatOwnerShip.SROC_Member_ID__c = ocData.SROC_Member_ID__c;
        boatOwnerShip.SROC_Membership_Status__c = ocData.SROC_Membership_Status__c;
        boatOwnerShip.SROC_Ownership_Status__c = ocData.SROC_Ownership_Status__c;
        boatOwnerShip.SROC_Points_Total__c = ocData.SROC_Points_Total__c;
        boatOwnerShip.SROC_Purchased_Dealer_Name__c = ocData.SROC_Purchased_Dealer_Name__c;
        boatOwnerShip.SROC_Purchased_Dealer_Number__c = ocData.SROC_Purchased_Dealer_Number__c;
        boatOwnerShip.SROC_Purchase_Date__c = ocData.SROC_Purchase_Date__c;
        boatOwnerShip.SROC_Sales_Total__c = ocData.SROC_Sales_Total__c;
        boatOwnerShip.SROC_Welcome_Kit_Status__c = ocData.SROC_Welcome_Kit_Status__c;
        boatOwnerShip.SROC_Comments__c = ocData.Comments__c;
        boatOwnerShip.Opt_Out_of_Sea_Ray_Living__c = ocData.Opt_Out_of_Sea_Ray_Living__c;
        if (ocData.Email_Opt_In__c == 'Y' || ocData.Email_Opt_In__c == 'Yes') {
        	 boatOwnerShip.Email_Opt_in__c = 'Yes';
        }
        else {
        	boatOwnerShip.Email_Opt_in__c = 'No';
        }   
        
        insert boatOwnerShip;  
        
        return boatOwnerShip;
	}
	
	private Account createOwnerAccount(SROC__c ocData) {
		system.debug('createOwnerAccount');
		Account owner = new Account();
		owner.OwnerId = Configuration__c.getInstance('BoatOwner').RecordId__c;
        owner.RecordTypeId = OWNER_RECORD_TYPE_ID;
        owner.LastName = ocData.Last_Name__c;
        owner.FirstName = ocData.First_Name__c;
        owner.Entry_Source__c = ENTRY_SOURCE_SROC;
        owner.Middle_Initial__c = ocData.Middle_Initial__c;
        owner.PersonMailingStreet  = ocData.Address__c;
        owner.PersonMailingState = ocData.State__c;
        owner.PersonMailingCity = ocData.City__c;
        owner.PersonMailingCountry = ocData.Country_Name__c;
        owner.PersonMailingPostalCode = ocData.Zip_Code__c;
        owner.Work_Phone__pc = ocData.Work_Phone__c;
        owner.HIN_Number__c = ocData.HIN__c;
        owner.Home_Address_ISO_Code__c = getCountry(ocData);
        owner.Co_Owner__c = ocData.Co_Owner__c;       
        owner.PersonHomePhone = ocData.Home_Phone__c;
        owner.PersonEmail= ocData.Email__c;    
        owner.Birthday__pc = ocData.Birth_Date__c;
        owner.Name_Suffix__c = ocData.Name_Suffix__c;
        
        // Only set brand relationship if owned
        if ('OWNED'.equalsIgnoreCase(ocData.SROC_Ownership_Status__c)) {
        	owner.Brand_Relationships__c = 'SR';
        }
        
        // Set all the SROC data since this is new
        if (ocData.Customer_Wants_Mailings__c == 'y' || ocData.Customer_Wants_Mailings__c == 'Y' || ocData.Customer_Wants_Mailings__c == 'Yes' || ocData.Customer_Wants_Mailings__c == 'YES') {
   			owner.Customer_Wants_Mailings__c = true;	
   		}
   		else {
   			owner.Customer_Wants_Mailings__c = false;
   		}
        owner.Comments__pc = ocData.Comments__c;
        owner.NCOA_Address_Status__c = ocData.NCOA_Address_Status__c;
        owner.NCOA_Status__c = ocData.NCOA_Status__c;
        owner.NCOA_Validation_Date__c = ocData.NCOA_Validation_Date__c;
        owner.New_or_Used__c = ocData.New_or_Used__c;
        owner.SROC_Cancellation_Date__c = ocData.SROC_Cancellation_Date__c;
        owner.SROC_Enrollment_Level__c = ocData.SROC_Enrollment_Level__c;
        owner.SROC_Enrollment_Status__c = ocData.SROC_Enrollment_Status__c;
        owner.SROC_Join_Date__c = ocData.SROC_Join_Date__c;
        owner.SROC_Member_ID__c = ocData.SROC_Member_ID__c;
        owner.SROC_Membership_Status__c = ocData.SROC_Membership_Status__c;
        owner.SROC_Ownership_Status__c = ocData.SROC_Ownership_Status__c;
        owner.SROC_Points_Total__c = ocData.SROC_Points_Total__c;
        owner.SROC_Purchased_Dealer_Name__c = ocData.SROC_Purchased_Dealer_Name__c;
        owner.SROC_Purchased_Dealer_Number__c = ocData.SROC_Purchased_Dealer_Number__c;
        owner.SROC_Purchase_Date__c = ocData.SROC_Purchase_Date__c;
        owner.SROC_Sales_Total__c = ocData.SROC_Sales_Total__c;
        owner.SROC_Welcome_Kit_Status__c = ocData.SROC_Welcome_Kit_Status__c;
        owner.Opt_Out_of_Sea_Ray_Living__c = ocData.Opt_Out_of_Sea_Ray_Living__c;
        owner.Brand__c = 'SR';
        
        if (ocData.Email_Opt_In__c == 'Y' || ocData.Email_Opt_In__c == 'Yes') {
        	owner.PersonHasOptedOutOfEmail = false;
        	// owner.Email_Opt_in__c = 'Yes';
        }
        else {
        	owner.PersonHasOptedOutOfEmail = true;
        	//owner.Email_Opt_in__c = 'No';
        }
        
        insert owner;
        
        return owner;
	}
	
	private string getCountry(SROC__c ocData) {
		if (ocData.Country__c == 'USA' || ocData.Country__c == null) {
			return US_ISO;
		}
		else if (ocData.Country__c == 'CAN') {
			return CA_ISO;
		}
		return ocData.Country__c;
	}
	
	private Boat__c getBoat(string HIN) {
		Boat__c[] boats = [select Id from Boat__c where External_HIN_Number__c = :HIN];
		if (boats.size() > 0) {
			return boats[0];
		}
		return null;
	}
}