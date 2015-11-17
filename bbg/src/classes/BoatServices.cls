/*
Developer   : Poundarik, Shruti
Company     : Bluewolf LLC
*/ 
public without sharing class BoatServices {    
    public static boolean disableTriggerProcessing = false;
    private static Id ownerRecordTypeId = [select Id from recordtype where developerName='Owner'].Id;
    private static Id dealerContactRecordTypeId = [select Id from recordtype where developerName='Dealer' and SobjectType = 'Contact'].Id;
    public static final string ENTRY_SOURCE_SROC = 'SROC';
	public static final string ENTRY_SOURCE_OBMS = 'OBMS';
    
    /* Jahmaal */
    
    public static List<Boat__c> filterBoatsNoDealerBrand(List<Boat__c> trig)
    {
    	List<Boat__c> filteredBoats = new List<Boat__c>();
    	
    	for(Boat__c boat : trig)
    	{
    		if(boat.Dealer_Brand_Lookup__c == null)
    			filteredBoats.add(boat);
    	}
    	
    	return filteredBoats;
    }
    
    // Return Boat.Dealer__c to List of Dealer Brands
    public static Map<Id, List<Dealer_Brand__c>> findPossibleDealerBrand(List<Boat__c> boats)
    {
    	// Gets a set of Ids from the List of Boats.
    	Set<Id> boatDealerIds = new Set<Id>(); 
    	for(Boat__c boat : boats)
    	{
    		if(boat.Dealer__c != null){
    			boatDealerIds.add(boat.Dealer__c);
    		}
    	}
    		
    	// Query to get the Dealer information based on the Account.
    	List<Dealer_Brand__c> query = [SELECT Id, Brand__c, Name, Dealer__c FROM Dealer_Brand__c Where Dealer__c in :boatDealerIds];
    	Map<Id, List<Dealer_Brand__c>> dealerBrandGroup = (Map<Id, List<Dealer_Brand__c>>) GroupBy.ids('Dealer__c', query);
    	
    	return dealerBrandGroup;
    }
    
    // Stamps Dealer Brand on Boat.
    public static void stampBoatDealerBrand(List<Boat__c> trig, Map<Id, List<Dealer_Brand__c>> mapping)
    {
    	for(Boat__c boat : trig)
    	{
    		if (mapping.containsKey(boat.Dealer__c)){
    			
    			Map<String, List<Dealer_Brand__c>> brandTodbrands = (Map<String, List<Dealer_Brand__c>>) GroupBy.strings('Brand__c', mapping.get(boat.Dealer__c));
	    		
	    		if (brandTodbrands.containsKey(boat.Brand_del__c)){
	    			system.debug('Stamping boat dealer brand - ' + boat.Name);
	    			boat.Dealer_Brand_Lookup__c = brandTodbrands.get(boat.Brand_del__c)[0].Id;
	    			
	    		}
	    		
    		}
    		
    	}
    	
    }
    
    /* */
    
    public static void AddDealer(list<Boat__c> boatRecords){
        set<String> dealerNumLocations = new set<String>();
        map<String,Id> dealerNumToId = new map<String,Id>();
        
        for(Boat__c boatRecord : boatRecords){
        	if(boatRecord.DealerNumLoc__c != null)
            dealerNumLocations.add(boatRecord.DealerNumLoc__c);
        }
        
        for(Account rec : [Select 
                             Id,
                             Dealer_Number__c
                           from Account
                           where 
                           Dealer_Number__c IN:dealerNumLocations]){
            dealerNumToId.put(rec.Dealer_Number__c,rec.Id);
        }
        for(Boat__c boatRecord : boatRecords){
            boatRecord.Dealer__c = dealerNumToId.get(boatRecord.DealerNumLoc__c);
        }
    }
    
    
    // On insert always create a new Owner,
    // then create a  new Boat Ownership record. 
    public static Boolean isWorkFlowRunning = false;    
    
    private static String getCoowner(Boat__c boatRecord) {      
        String coOwner = '';
        if(!String.isBlank(boatRecord.Owner_co_owner_first_name__c)) {
            coOwner = boatRecord.Owner_co_owner_first_name__c + ' ';
        }           
        if(!String.isBlank(boatRecord.Owner_co_owner_last_name__c)) {
            coOwner += boatRecord.Owner_co_owner_last_name__c;
        }
        return coOwner;
    }
    
    private static list<Owner_Boat_Relationship__c> findOwnerBoatRelationships(Account owner, Boat__c boat) {
    	list<Owner_Boat_Relationship__c> ownerRels = [select Id, Status__c, HIN_Number__c, Purchase_Date__c from Owner_Boat_Relationship__c where HIN_Number__c=:boat.Id and Owner__c=:owner.Id];
    	return ownerRels;
    }
    
    // Attempts to find an existing owner record so as to reduce duplicates. Will match on relationship first and last
    private static Account findExistingOwner(Boat__c boat, list<Owner_Boat_Relationship__c> rels) {
    	Account owner = null;
    	
    	// Attempt to match on the relationship
    	if (rels != null && rels.size() > 0) {
    		if (boat.Owner_FirstName__c != null && boat.Owner_LastName__c != null) {
	    		for (Owner_Boat_Relationship__c rel : rels) {
	    			if (rel.Owner__r.FirstName == boat.Owner_FirstName__c && rel.Owner__r.LastName == boat.Owner_LastName__c) {
	    				owner = rel.Owner__r;
	    				break;
	    			}	
	    		}	
    		}
    	}
    	return owner;
    }
    
    // Attempts to find an existing owner record so as to reduce duplicates
    private static Account findExistingOwner(Boat__c boat) {
   		list<Account> owners = [select Id, FirstName, LastName, Brand__c, Entry_Source__c from Account where FirstName=:boat.Owner_FirstName__c and LastName=:boat.Owner_LastName__c and PersonEmail=:boat.Owner_Email__c];
   		if (owners != null && owners.size() > 0) {
   			return owners[0];
   		}
   		return null;
    }
    
    // Attempts to find an owner match for the given boat using a list of potential owners
    public static Account findOwnerMatchForNewBoat(Boat__c boat, list<Account> potentialOwners) {
    	Account owner = null;
    	
    	for (Account potentialOwner : potentialOwners) {
    		if ((potentialOwner.FirstName != null && potentialOwner.FirstName.length() > 0 && potentialOwner.LastName != null &&  potentialOwner.LastName.length() > 0 && potentialOwner.PersonMailingStreet != null && potentialOwner.PersonMailingStreet.length() > 0) &&
    			(potentialOwner.FirstName == boat.Owner_FirstName__c && potentialOwner.LastName == boat.Owner_LastName__c && potentialOwner.PersonMailingStreet == boat.owner_Street__c) && potentialOwner.brand__c == boat.brand_del__c) {
    			system.debug('Found owner match of ' + potentialOwner);
				owner = potentialOwner;
				break;    			
    		}
    	}
    	return owner;	
    }
    
    public static void createBoatAndBoatOwnerShip(list<Boat__c> boats) {    
    	system.debug('createBoatAndBoatOwnerShip - enter');
    	
    	BoatServices.disableTriggerProcessing = true;
    	try {
	    	list<Owner_Boat_Relationship__c> boatOwnerRelationshipsToInsert = new list<Owner_Boat_Relationship__c>();
	        list<Account> ownersToInsert = new list<Account>();
	        map<Id,Account> ownersToUpdate = new map<Id, Account>();
	        map<string, Boat__c> hinToBoatMap = new map<string, Boat__c>();
	        map<Account, list<Boat__c>> ownersToUpdateBoatMap = new map<Account, list<Boat__c>>();
	        
	        // Build a set of owner names so we can try and find existing owner matches for these boats efficiently
	        set<string> ownerNames = new set<string>();
	        for (Boat__c boat : boats) {
	        	hinToBoatMap.put(boat.Name, boat);
	        	// Make sure we have a last name with characters and not strange characters - OBMS has some strange data that can result
	        	// in too many results being returned - MTR
	        	if (!String.isBlank(boat.Owner_LastName__c) && boat.Owner_LastName__c != '.') {
	        		string ownerName = '';
	        		if (!String.isEmpty(boat.Owner_FirstName__c)) {
	        			ownerName = boat.Owner_FirstName__c + ' ' + boat.Owner_LastName__c;
	        		}
	        		else {
	        			ownerName = boat.Owner_LastName__c;
	        		}
	        		system.debug('Adding owner name of ' + ownerName);
	        		ownerNames.add(ownerName);
	        	}	
	        }
	        
	        if (!ownerNames.isEmpty()) {
		        // Query for all potential owner matches
		        system.debug('Searching for potential owners');
		        list<Account> potentialOwners = [select Id, FirstName, LastName, PersonMailingStreet, Entry_Source__c, brand__c from Account where RecordTypeId=:ownerRecordTypeId and Name in :ownerNames];
		        
		        // Iterate through all the boats and try to find an existing owner record. If not we will need to create one
		        for(Boat__c boat : boats) {    
		        	// No point continuing if there is no last name since this is required
		        	if (!String.isBlank(boat.Owner_LastName__c) && boat.Owner_LastName__c != '.') {
		        		system.debug('Looking for an owner match for boat ' + boat.Name);
			        	Account owner = findOwnerMatchForNewBoat(boat, potentialOwners);
			        	if (owner == null) {
			        		// Since there is no owner we need to create one
			        		system.debug('Did not find a match for the boat. Will create a new owner');
			        		owner = createOwner(boat);
			        		ownersToInsert.add(owner);
			        	}
			        	else {
			        		// Found an existing owner without an existing relationship
			        		system.debug('Found owner ' + owner + ' so will create new relationship');
			        		
			        		// Update the owner with the boat data
			        		if (boat.Brand_del__c != 'SR' || owner.Entry_Source__c != ENTRY_SOURCE_SROC) {
	       						Account ownerToUpdate = new Account(Id=owner.Id);
		        				ownerToUpdate = getAccountInformation(ownerToUpdate, boat);
		        				ownersToUpdate.put(ownerToUpdate.Id, ownerToUpdate);
	       					}
			        		
			        		// We need to create a relationship as well
			        		list<Boat__c> ownerBoats = ownersToUpdateBoatMap.get(owner);
			        		if (ownerBoats == null) {
			        			ownerBoats = new list<Boat__c>();
			        			ownersToUpdateBoatMap.put(owner, ownerBoats);
			        		}
			        		ownerBoats.add(boat);
			        	}
		        	}
		        }  
		        
		        // Handle new owners
		        if (!ownersToInsert.isEmpty()) {  
		        	// Create the owners
		        	system.debug('Inserting owners ' + ownersToInsert);
		        	insert ownersToInsert;
		            
		            // Now create the relationships. This is easy since it is a new boat and a new owner
		        	for (Account owner : ownersToInsert) {
		        		Boat__c boat = hinToBoatMap.get(owner.HIN_Number__c);
		        		if (boat != null) {
		        			Owner_Boat_Relationship__c ownerBoatRel = createOwnerBoatRelationship(owner, boat);	 
		        			boatOwnerRelationshipsToInsert.add(ownerBoatRel);
		        		}
		        	}
		        }
		        
		        // Update existing owners
		        if (!ownersToUpdate.isEmpty()) {
		        	system.debug('Updating owners ' + ownersToUpdate.size());
		        	update ownersToUpdate.values();
		        }
		        
		        // Handle already existing owner relationships
		        if (!ownersToUpdateBoatMap.isEmpty()) {
		        	for (Account owner : ownersToUpdateBoatMap.keySet()) {
		        		list<Boat__c> ownerBoats = ownersToUpdateBoatMap.get(owner);	
		        		if (ownerBoats != null && ownerBoats.size() > 0) {
		        			for (Boat__c boat : ownerBoats) {
		        				Owner_Boat_Relationship__c ownerBoatRel = createOwnerBoatRelationship(owner, boat);	 
		        				boatOwnerRelationshipsToInsert.add(ownerBoatRel);
		        			}	
		        		}
		        	}
		        }
		        
		        // Insert the owner boat relationships. The trigger will take care of setting the active one correctly
		        if (!boatOwnerRelationshipsToInsert.isEmpty()) {
		        	system.debug('Inserting new boat owner relationships ' + boatOwnerRelationshipsToInsert);
		        	isWorkFlowRunning = true; 
		        	insert boatOwnerRelationshipsToInsert;
		        }
	        }
    	}
    	finally {
    		BoatServices.disableTriggerProcessing = false;
    	}
    }
    
    public static void createBoatAndBoatOwnerShip2(list<Boat__c> boatRecords){       
        set<String>boatName = new set<String>();
        list<Boat__c> newBoatRecords = new list<Boat__c>();
        set<String> existingBoatNames = new set<String>();
        map<String,Account> uniqueKeyToOwner = new map<String,Account>();   
                        
        list<Boat__c> boatsToInsert = new list<Boat__c>();
        list<Account> ownersToInsert = new list<Account>();
        set<String> hinNumbers = new set<String>();
        set<String> ownerUniqueIds = new set<String>();
                    
        for(Boat__c boatRecord : boatRecords){          
            
                        
            // Used to retrieve boats for creating Boat Owner          
            hinNumbers.add(boatRecord.Name);            
            
            if (boatRecord.Owner_LastName__c != null) {
	            Account o = new Account();
	            o.RecordTypeId = ownerRecordTypeId;
	            o.LastName = boatRecord.Owner_LastName__c;
	            o.FirstName = boatRecord.Owner_FirstName__c;
	            o.PersonMailingStreet  = boatRecord.owner_Street__c;
	            o.PersonMailingState = boatRecord.owner_State__c;
	            o.PersonMailingCity = boatRecord.owner_City__c;
	            o.PersonMailingCountry = boatRecord.owner_Country__c;
	            o.PersonMailingPostalCode = boatRecord.owner_zip__c;
	            o.OwnerId = Configuration__c.getInstance('BoatOwner').RecordId__c;//'005c0000000FaEPAA0';
	            if(boatRecord.owner_Email_opt_out__c == 'NO') {
					o.PersonHasOptedOutOfEmail = true;
				}
				else {
					o.PersonHasOptedOutOfEmail = false;
				} 
	            /*if(boatRecord.owner_Email_opt_out__c == 'NO')
	                o.Email_Opt_Out__c = false;
	            else
	                o.Email_Opt_Out__c = true;*/
	            o.Work_Phone__pc = boatRecord.owner_Work_Phone__c;
	            o.HIN_Number__c = boatRecord.Name;
	            o.Home_Address_ISO_Code__c = boatRecord.Owner_ISO_Code__c;
	            o.Co_Owner__c = getCoowner(boatRecord);         
	            o.Spouse__c = boatRecord.Owner_Spouse__c;
	            o.PersonHomePhone = boatRecord.Owner_Home_Phone__c;
	            o.PersonEmail= boatRecord.Owner_Email__c;    
	            o.Primary_Language__c = boatRecord.Owner_Primary_Language__c;         
	            
	            ownersToInsert.add(o);
	            String accName = o.FirstName+' '+o.LastName;  
	           // ownerUniqueIds.add(accName);     
            }                
            
        }
                
        if(!ownersToInsert.isEmpty()){  
            insert ownersToInsert;           
        }
                
        map<String,Id> ownerNameToId = new map<String,Id>();
        for(Account acc : ownersToInsert){
            String boatOwner = acc.FirstName+' '+acc.LastName;
            ownerNameToId.put(boatOwner,acc.Id);
        }
                        
        // Each Boat has boat ownerships which has a reference to a boat and and owner(account)
        // that also holds the purchase date and status of boat
        list<Owner_Boat_Relationship__c> bo = new list<Owner_Boat_Relationship__c>();
        for(Boat__c rec :boatRecords){ 
        	 if (rec.Owner_LastName__c != null) {
	            String boatOwner = rec.Owner_FirstName__c+' '+rec.Owner_LastName__c;
	            
	            Owner_Boat_Relationship__c  boatOwnerShip = new Owner_Boat_Relationship__c();
	            boatOwnerShip.HIN_Number__c = rec.Id;
	            system.debug('ownerNameToId ='+ownerNameToId.get(boatOwner));
	            boatOwnerShip.Owner__c = ownerNameToId.get(boatOwner);
	            boatOwnerShip.Status__c = 'Active';
	            boatOwnerShip.Purchase_Date__c = rec.Purchase_Date__c;          
	            bo.add(boatOwnerShip);   
        	 }                  
        }
        
        if(!bo.IsEmpty()){  
           isWorkFlowRunning = true;    
                              
            insert bo;  
        }
    }
    
    public static void updateBoatOwner(list<Boat__c> boats){
    	system.debug('updateBoatOwner - enter');
    	map<string, Boat__c> hinToBoatMap = new map<string, Boat__c>();
    	list<Account> ownersToInsert = new list<Account>();
        map<Account, list<Boat__c>> ownersToUpdateBoatMap = new map<Account, list<Boat__c>>();
    	list<Owner_Boat_Relationship__c> ownerRelsToInsert = new list<Owner_Boat_Relationship__c>();
    	list<Owner_Boat_Relationship__c> ownerRelsToUpdate = new list<Owner_Boat_Relationship__c>();
    	list<Account> ownersToUpdate = new list<Account>();
    	
    	// Build a set of the owner names for the boats. This will be used to try and find matches for existing owner
    	// accounts not already tied to the boat, in the event that these are new owners
    	set<string> ownerNames = new set<string>();
        for (Boat__c boat : boats) {
        	hinToBoatMap.put(boat.Name, boat);
        	if (!String.isBlank(boat.Owner_LastName__c) && boat.Owner_LastName__c != '.') {
        		string ownerName = '';
        		if (!String.isEmpty(boat.Owner_FirstName__c)) {
        			ownerName = boat.Owner_FirstName__c + ' ' + boat.Owner_LastName__c;
        		}
        		else {
        			ownerName = boat.Owner_LastName__c;
        		}
        		system.debug('Adding owner name of ' + ownerName);
        		ownerNames.add(ownerName);
        	}	
        }
        
        // Perform the search for potential owners now so we can use it later if needed
        system.debug('Searching for potential owners');
	    list<Account> potentialOwners = [select Id, FirstName, LastName, PersonMailingStreet, Entry_Source__c, brand__c from Account where RecordTypeId=:ownerRecordTypeId and Name in :ownerNames];
    	
       	// Get a map of HIN to owner relationships
       	map<string, list<Owner_Boat_Relationship__c>> hinToOwnerMap = new map<string, list<Owner_Boat_Relationship__c>>();
       	set<Id> boatIds = Pluck.ids(boats);
       	list<Owner_Boat_Relationship__c> allOwnerRelationships = [Select Id, Owner__c, HIN_Number__c, Purchase_Date__c, Status__c, HIN_Number__r.Name, Owner__r.Id, Owner__r.Entry_Source__c, Owner__r.Firstname, Owner__r.LastName, Owner__r.PersonMailingStreet, Owner__r.Name
                                             				  	  from Owner_Boat_Relationship__c 
                                             				  	  where HIN_Number__c IN : boatIds];
		for (Owner_Boat_Relationship__c rel : allOwnerRelationships) {
       		list<Owner_Boat_Relationship__c> ownerRels = hinToOwnerMap.get(rel.HIN_Number__r.Name);
       		if (ownerRels == null) {
       			ownerRels = new list<Owner_Boat_Relationship__c>();
       			hinToOwnerMap.put(rel.HIN_Number__r.Name, ownerRels);
       		}
       		ownerRels.add(rel);
       	}
       
        // Iterate over the boats and see if we can find the owner specified in the boat or not
       	for (Boat__c boat : boats) {
       		list<Owner_Boat_Relationship__c> boatOwnerRels = hinToOwnerMap.get(boat.Name);
       		
       		if (!String.isBlank(boat.Owner_LastName__c) && boat.Owner_LastName__c != '.') {
       			// Look for an existing owner match
       			system.debug('Looking for an existing owner for boat ' + boat.Name);
       			Account boatOwner = findExistingOwner(boat, boatOwnerRels);	
       			if (boatOwner == null) {
       				// We did not find a match with an existing relationship. See if we can find a match with any 
       				// owner matching on the name
       				system.debug('Did not find an existing owner with an existing relationship to the boat. Checking all potential owners');
       				boatOwner = findOwnerMatchForNewBoat(boat, potentialOwners);
       				if (boatOwner == null) {
	       				// This is a new owner, so we need to create the relationship. 
	       				// TODO: Improve this to try and find an existing owner in the system
	       				system.debug('Did not find any owner matches. Will create a new owner');
	       				boatOwner = createOwner(boat);
	       				ownersToInsert.add(boatOwner);
	       				
	       				// Set all existing relationships to inactive
	       				if (boatOwnerRels != null && boatOwnerRels.size() > 0) {
	       					for (Owner_Boat_Relationship__c boatOwnerRel : boatOwnerRels) {
	       						boatOwnerRel.Status__c = 'Inactive';
	       						ownerRelsToUpdate.add(boatOwnerRel);	
	       					}
	       				}
       				}
       				else {
       					system.debug('Found an existing owner in the system. A new relationship will be created - ' + boatOwner);
       					// We found a matching owner without an existing relationship. We should update the owners info from the boat
       					// as long as they are not SR or have not been updated last by the owners club 
       					// We need to create a relationship
       					if (boat.Brand_del__c != 'SR' || boatOwner.Entry_Source__c != ENTRY_SOURCE_SROC) {
       						Account owner = new Account(Id=boatOwner.Id);
	        				owner = getAccountInformation(owner, boat);
	        				ownersToUpdate.add(owner);
       					}
       					
       					// Now set things up so the new relationship will be created
       					list<Boat__c> ownerBoats = ownersToUpdateBoatMap.get(boatOwner);
       					if (ownerBoats == null) {
       						ownerBoats = new list<Boat__c>();
       						ownersToUpdateBoatMap.put(boatOwner, ownerBoats);
       					}
       					ownerBoats.add(boat);
       					
       					// Set all existing relationships to inactive
	       				if (boatOwnerRels != null && boatOwnerRels.size() > 0) {
	       					for (Owner_Boat_Relationship__c boatOwnerRel : boatOwnerRels) {
	       						boatOwnerRel.Status__c = 'Inactive';
	       						ownerRelsToUpdate.add(boatOwnerRel);	
	       					}
	       				}
       				}
       			}
       			else {
       				// We found an existing owner through the relationship. We can update the owner info from the boat but only
       				// if the owner is not SR or if the owner record was not updated by the owners club
       				if (boat.Brand_del__c != 'SR' || boatOwner.Entry_Source__c != ENTRY_SOURCE_SROC) {
       					Account owner = new Account(Id=boatOwner.Id);
	        			owner = getAccountInformation(owner, boat);
	        			ownersToUpdate.add(owner);
       				}
       			}
       		}
       	}
       	
       	try {
       		isWorkFlowRunning = true;
	       	// Handle new owners
	       	if (!ownersToInsert.isEmpty()) {
	       		system.debug('Inserting new owners');
	       		insert ownersToInsert;
	       		
	       		// We need to create the relationships now
	       		for (Account owner : ownersToInsert) {
	       			system.debug('Create a new relationship for new owner ' + owner + ' and boat ' + owner.HIN_Number__c);
	       			Owner_Boat_Relationship__c ownerRel = createOwnerBoatRelationship(owner, hinToBoatMap.get(owner.HIN_Number__c));
	       			ownerRelsToInsert.add(ownerRel);
	       		}	
	       	}
	       	
	       	if (!ownersToUpdate.isEmpty()) {
	       		system.debug('Updating existing owners');
	       		update ownersToUpdate;	
	       	}
	       	
	       	// Handle updates to existing owners that did not already have an existing owner boat relationship
	       	if (!ownersToUpdateBoatMap.isEmpty()) {
	       		system.debug('Creating new relationships for existing owners');
	       		// We need to create the relationships now
	       		for (Account owner : ownersToUpdateBoatMap.keySet()) {
	       			list<Boat__c> ownerBoats = ownersToUpdateBoatMap.get(owner);
	       			for (Boat__c ownerBoat : ownerBoats) {
	       				system.debug('Create a new relationship for existing owner ' + owner + ' and boat ' + ownerBoat);
	       				Owner_Boat_Relationship__c ownerRel = createOwnerBoatRelationship(owner, ownerBoat);
	       				ownerRelsToInsert.add(ownerRel);
	       			}
	       		}	
	       	}
	       
	        // Insert any new relationships
	       	if (ownerRelsToInsert.size() > 0) {
	       		system.debug('Inserting new owner boat relationships');
	       		insert ownerRelsToInsert;
	       	}
	       	
	       	// Update any relationships
	       	if (ownerRelsToUpdate.size() > 0) {
	       		system.debug('Update owner boat relationships');
	       		update ownerRelsToUpdate;
	       	}
       	}
       	finally {
       		isWorkFlowRunning = false;	
       	}
	}
    
    
    // Each update :
    //1. Existing HIN with different Owner Name : 
    //   Create new Owner record and Create new boat ownership record
    //   which includes HIN, Owner Name, Status, Purchase Date
    //   update existing boat ownership status to inactive
    // 2.Existing HIN with existing Owner Name :
    //   Update the Owner record only
     
    public static void updateBoatOwner2(list<Boat__c> boatRecords){
    	map<string, Boat__c> hinToBoatMap = new map<string, Boat__c>();
        list<Account> ownersToInsert = new list<Account>();
        list<Account> ownersToUpdate = new list<Account>();
        list<Owner_Boat_Relationship__c> ownerRelsToUpdate = new list<Owner_Boat_Relationship__c>();
        list<Owner_Boat_Relationship__c> ownerRelsToInsert = new list<Owner_Boat_Relationship__c>();         
              
        Set<Id> boatRecordIds = Pluck.ids(boatRecords);
        
        // When a new owner is tied to the boat 
        // we need to set the status of the existing Boat OwnerShip to inactive
        // since only one boat can be active at a given time
        // using the map we collect all the Boat Ownership tied to each boats               
        map<String,list<Owner_Boat_Relationship__c>> boatHINToBoatOwnership = new map<String,list<Owner_Boat_Relationship__c>>();
        for(Owner_Boat_Relationship__c rec :[Select
                                              Id, 
                                              Owner__c,
                                              HIN_Number__c,
                                              Purchase_Date__c,
                                              Status__c,
                                              HIN_Number__r.Name,
                                              Owner__r.Id,
                                              Owner__r.Name,
                                              Owner__r.FirstName,
                                              Owner__r.LastName
                                             from 
                                             Owner_Boat_Relationship__c 
                                             where 
                                             HIN_Number__c IN :boatRecordIds]){
            
            list<Owner_Boat_Relationship__c> boatOwerships;
            if(!boatHINToBoatOwnership.containsKey(rec.HIN_Number__r.Name)){
                boatOwerships = new list<Owner_Boat_Relationship__c>();     
                boatOwerships.add(rec);     
            }else{
                boatOwerships = boatHINToBoatOwnership.get(rec.HIN_Number__r.Name);
                boatOwerships.add(rec);
            }                                               
            boatHINToBoatOwnership.put(rec.HIN_Number__r.Name,boatOwerships);
        }
             
        for(Boat__c boat : boatRecords){    
        	hinToBoatMap.put(boat.Name, boat);
        	if (boat.Owner_LastName__c != null) {   
        		// We need to determine if a new owner should be created, or an existing one updated
        		list<Owner_Boat_Relationship__c> boatOwners = boatHINToBoatOwnership.get(boat.Name);
        		Owner_Boat_Relationship__c existingOwnerBoatRelationship = null;
        		if (boatOwners != null && boatOwners.size() > 0) {
        			// We need to try and find a match by first and last name
        			for (Owner_Boat_Relationship__c ownerBoatRel : boatOwners) {
        				if (((ownerBoatRel.Owner__r.FirstName == null && boat.Owner_FirstName__c == null) || (ownerBoatRel.Owner__r.FirstName != null && ownerBoatRel.Owner__r.FirstName.equalsIgnoreCase(boat.Owner_FirstName__c))) && ownerBoatRel.Owner__r.LastName.equalsIgnoreCase(boat.Owner_LastName__c)) {
        					// We found a match
        					existingOwnerBoatRelationship = ownerBoatRel;
        					break;
        				}
        			}
        		}
        		
        		if (existingOwnerBoatRelationship == null) {
        			// We need to create a new relationship
        			Account owner = new Account();
                	owner.RecordTypeId = ownerRecordTypeId;
                	owner.LastName = boat.Owner_LastName__c;
                	owner.FirstName = boat.Owner_FirstName__c;                         
                	owner = getAccountInformation(owner, boat);
                	ownersToInsert.add(owner);
                	
                	// Do we also need to update the existing relationships to inactive
                	if (boatOwners != null && boatOwners.size() > 0) {
                		for (Owner_Boat_Relationship__c ownerBoatRel : boatOwners) {
                			ownerBoatRel.Status__c = 'Inactive';
                			ownerRelsToUpdate.add(ownerBoatRel);	
                		}
                	}
        		}
        		else {
        			// Update the account with the info on the boat, but only if it was not last updated by the SROC or is not a SR
        			// We will create the owner relationship later after this is inserted
        			// We also dont want to overwrite the owner info if this is SR and the owner was updated by the owners club data
        			if (boat.Brand_del__c != 'SR' || existingOwnerBoatRelationship.Entry_Source__c != ENTRY_SOURCE_SROC) {
	        			Account owner = new Account(Id=existingOwnerBoatRelationship.Owner__r.Id);
	        			owner = getAccountInformation(owner, boat);
	        			ownersToUpdate.add(owner);
	        		}
        		}
        	}
        }
        
        try {
        	 isWorkFlowRunning = true;
	        // Insert owners
	        if (ownersToInsert.size() > 0) {
	        	insert ownersToInsert;
	        	
	        	// Now add the owner rels for these owners to the upsert
	       		for (Account owner : ownersToInsert) {
	       			system.debug('Create a new relationship for new owner ' + owner + ' and boat ' + owner.HIN_Number__c);
	       			Owner_Boat_Relationship__c ownerRel = createOwnerBoatRelationship(owner, hinToBoatMap.get(owner.HIN_Number__c));
	       			ownerRelsToInsert.add(ownerRel);
	       		}	
	        }
	        
	        // Update owners
	        if (ownersToUpdate.size() > 0) {
	        	update ownersToUpdate;
	        }
	        
	        // Add owner rels to insert
	        if (ownerRelsToInsert.size() > 0) {
	        	insert ownerRelsToInsert;
	        }
	        
	        // Add owner rels to update
	        if (ownerRelsToUpdate.size() > 0) {
	        	insert ownerRelsToUpdate;
	        }
        }
        finally {
        	isWorkFlowRunning = false;
        }
    }
    
     // Creates an owner boat relationship for the given owner and boat
    public static Owner_Boat_Relationship__c createOwnerBoatRelationship(Account owner, Boat__c boat) {
    	Owner_Boat_Relationship__c  boatOwnership = new Owner_Boat_Relationship__c();
		boatOwnership.HIN_Number__c = boat.Id;
		boatOwnership.Owner__c = owner.Id;
		boatOwnership.Status__c = 'Active';
		boatOwnership.Purchase_Date__c = boat.Purchase_Date__c;     
		
		return boatOwnership;     
    }
    
    // Creates a new owner for a given boat
    public static Account createOwner(Boat__c boat) {
    	Account owner = new Account();
    	owner.Brand__c = boat.Brand_del__c;
    	owner.RecordTypeId = ownerRecordTypeId;
        owner.LastName = boat.Owner_LastName__c;
        owner.FirstName = boat.Owner_FirstName__c;
        owner.PersonMailingStreet  = boat.owner_Street__c;
        owner.PersonMailingState = boat.owner_State__c;
        owner.PersonMailingCity = boat.owner_City__c;
        owner.PersonMailingCountry = boat.owner_Country__c;
        owner.PersonMailingPostalCode = boat.owner_zip__c;
        owner.OwnerId = Configuration__c.getInstance('BoatOwner').RecordId__c;
        if(boat.owner_Email_opt_out__c == 'NO' || boat.owner_Email_opt_out__c == 'No') {
	     	owner.PersonHasOptedOutOfEmail = true;
	  	}
	  	else {
	     	owner.PersonHasOptedOutOfEmail = false;
	  	} 
        owner.Work_Phone__pc = boat.owner_Work_Phone__c;
        owner.HIN_Number__c = boat.Name;
        owner.Home_Address_ISO_Code__c = boat.Owner_ISO_Code__c;
        owner.Co_Owner__c = getCoowner(boat);         
        owner.Spouse__c = boat.Owner_Spouse__c;
        owner.PersonHomePhone = boat.Owner_Home_Phone__c;
        owner.PersonEmail= boat.Owner_Email__c;    
        owner.Primary_Language__c = boat.Owner_Primary_Language__c;	
        
        return owner;
    }
    
    private static Account getAccountInformation(Account ac,Boat__c rec){
      ac.PersonMailingStreet  = rec.owner_Street__c;
      ac.PersonMailingState = rec.owner_State__c;
      ac.PersonMailingCity = rec.owner_City__c;
      ac.PersonMailingCountry = rec.owner_Country__c;
      ac.PersonMailingPostalCode = rec.owner_zip__c;
      
      if (ac.brand__c == null) {
         ac.brand__c = rec.brand_del__c;
      }
      
      if(rec.owner_Email_opt_out__c == 'NO' || rec.owner_Email_opt_out__c == 'No') {
	     ac.PersonHasOptedOutOfEmail = true;
	  }
	  else {
	     ac.PersonHasOptedOutOfEmail = false;
	  } 
      
      /*if(rec.owner_Email_opt_out__c == 'No')
         ac.Email_Opt_Out__c = false;
      else
         ac.Email_Opt_Out__c = true;*/
           
      ac.Work_Phone__pc = rec.owner_Work_Phone__c;
      ac.HIN_Number__c = rec.Name;
      ac.Home_Address_ISO_Code__c = rec.Owner_ISO_Code__c;
      ac.Co_Owner__c = getCoowner(rec);          
      ac.Spouse__c = rec.Owner_Spouse__c;
      ac.PersonEmail = rec.Owner_Email__c;   
      ac.PersonHomePhone = rec.Owner_Home_Phone__c;
      ac.Primary_Language__c = rec.Owner_Primary_Language__c;
      ac.OwnerId = rec.OwnerId;
      return ac;
    }
        
    // Only create Contact for Dealers with Salesperson name when one does not already exist 
    
    public static void createContact(list<Boat__c> boatRecords){
        system.debug('Creating contacts from boatRecords...');
        set<Id> dealers = new set<Id>();
        list<Boat__c> boatsWithDealers = new list<Boat__c>(); 
        list<Contact> conList = new list<Contact>();
        
        for(Boat__c rec : boatRecords){
        	system.debug('rec.Dealer__c: ' + rec.Dealer__c);
			if(rec.Dealer__c != null){          
				dealers.add(rec.Dealer__c);
				boatsWithDealers.add(rec);
            }
        }
        
        Set<Contact> existingDealerContacts = getExistingContactsForDealer(dealers);  
        system.debug('existingDealerContacts has size: ' + existingDealerContacts.size());
        map<Id,Account> idToDealer = getDealerInformation(dealers);
        system.debug('Boatswithdealers has size: ' + boatsWithDealers.size());
        for(Boat__c rec : boatsWithDealers){
        	if (String.isNotBlank(rec.Dealer_Salesperson_First_Name__c)
				&& String.isNotBlank(rec.Dealer_Salesperson_Last_Name__c)) {
        		// then create or update the contact
        		String firstName = rec.Dealer_Salesperson_First_Name__c.toLowerCase();
        		String lastName = rec.Dealer_Salesperson_Last_Name__c.toLowerCase();
        		boolean contactFound = false;
        		for (Contact dealerContact : existingDealerContacts) {
        			boolean firstNameMatches = firstName.equalsIgnoreCase(dealerContact.firstName);
        			boolean lastNameMatches = lastName.equalsIgnoreCase(dealerContact.lastName);
        			boolean accountMatches = (rec.Dealer__c == dealerContact.AccountId);
        			system.debug('rec.Dealer__c: ' + rec.Dealer__c);
        			system.debug('dealerContact.AccountId: ' + dealerContact.AccountId);
        			system.debug('accountMatches: ' +  accountMatches);
        			system.debug('firstNameMatches: ' +  lastNameMatches);
        			system.debug('lastNameMatches: ' +  lastNameMatches);
        			if (firstNameMatches && lastNameMatches && accountMatches) {
        				system.debug('Contact found... updating salesperson');
        				updateContact(dealerContact, rec, idToDealer);
        				conList.add(dealerContact);
        				contactFound = true;
        				break;
        			}
        		}
        		if (!contactFound) {
        			// look through the contacts that are going to be created too...
        			boolean newContactFound = false;
        			for (Contact dealerContact : conList) {
        				boolean firstNameMatches = firstName.equalsIgnoreCase(dealerContact.firstName);
        				boolean lastNameMatches = lastName.equalsIgnoreCase(dealerContact.lastName);
        				boolean accountMatches = (rec.Dealer__c == dealerContact.AccountId);
	        			if (firstNameMatches && lastNameMatches && accountMatches) {
	        				system.debug('Contact found... updating salesperson');
	        				updateContact(dealerContact, rec, idToDealer);
	        				conList.add(dealerContact);
	        				newContactFound = true;
	        				break;
	        			}
        			}
        			if (!newContactFound) {
        				system.debug('No existing contact found... creating contact for salesperson');
        				conList.add(createContact(rec, idToDealer));
        			}
        		}

        	}
        }
        
		if(!conList.isEmpty()) {
			system.debug('Upserting ' + conList.size() + ' salesperson contacts');
			upsert conList; 
		}
            
    }
    
    private static Contact createContact(Boat__c rec, map<Id,Account> idToDealer){
        Contact con = new Contact();
        con.LastName = rec.Dealer_Salesperson_Last_Name__c;   
        con.FirstName = rec.Dealer_Salesperson_First_Name__c;
        updateContact(con, rec, idToDealer);
        return con;
    }
    
     private static void updateContact(Contact con, Boat__c rec, map<Id,Account> idToDealer){
        con.RecordTypeId = dealerContactRecordTypeId;
        if (String.isNotBlank(rec.Dealer_Salesperson_Email__c)) {
        	con.email = rec.Dealer_Salesperson_Email__c;
        }
        con.AccountId = rec.Dealer__c;
        con.OwnerId = Configuration__c.getInstance('BoatOwner').RecordId__c;//'005c0000000FaEPAA0';
        if (idToDealer.containsKey(rec.Dealer__c)) {
        	con.Fax = idToDealer.get(rec.Dealer__c).fax;
	        con.Phone =idToDealer.get(rec.Dealer__c).Phone;
	        con.MailingCity =idToDealer.get(rec.Dealer__c).ShippingCity;
	        con.MailingState =idToDealer.get(rec.Dealer__c).ShippingState;
	        con.MailingStreet =idToDealer.get(rec.Dealer__c).ShippingStreet;
	        con.MailingPostalCode =idToDealer.get(rec.Dealer__c).ShippingPostalCode;
	        con.MailingCountry =idToDealer.get(rec.Dealer__c).ShippingCountry;
        }
        
    }
    
    private static  map<Id,Account> getDealerInformation(set<Id> dealers){    	
       map<Id,Account> idToDealer = new map<Id,Account>();
        for(Account rec :[select 
                            Id,
                            Phone,
                            fax,
                            ShippingCity,
                            ShippingCountry,
                            ShippingPostalCode,
                            ShippingState,
                            ShippingStreet
                          from Account 
                          where Id IN :dealers]){
			system.debug('rec ='+ rec);                          	
            idToDealer.put(rec.Id,rec);                   
        }
        return idToDealer;
    }
    
    private static Set<Contact> getExistingContactsForDealer(set<Id> dealers){    	
        Set<Contact> dealerContacts = new set<Contact>();
        for(Contact rec :[select 
                            Id,
                            LastName,
                            FirstName,
                            Email,
                            AccountId
                          from Contact 
                          where AccountId IN :dealers
                          and RecordTypeId = : dealerContactRecordTypeId]){
			system.debug('rec ='+ rec.LastName);                          	
            dealerContacts.add(rec);                   
        }
        return dealerContacts;
    }
     
    

}