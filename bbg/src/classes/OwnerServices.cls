public with sharing class OwnerServices {
	final static String CLASSNAME = '\n\n**** OwnerServices.METHODNAME()';
	final static String UNITED_STATES = 'US';
    final static String UNITED_STATES_OF_AMERICA = 'USA';
    final static String CANADA = 'CA';
    
    public static integer ACCOUNT_SCORE_THRESHOLD = 50;
    public static Boolean isApexTest= false;
    final static set<string> legacyBrandCodes = new set<string>{'TR','BL','MX'}; 
    public static boolean legacyOwnerRouting = true;
    public static Boolean ownerRoutingIsRunning = false;
    public static Boolean populateOwnerGeoFieldsIsRunning = false;
    public static boolean disablePardotLogCheck = false;
    private static Map<Id, String> ownerStateCodeMap = new Map<Id, String>();
    private static RecordType ownerRecordType = [select Id from RecordType where SobjectType='Account' and Name='Owner'][0];
    private static set<Id> ownerIdsAddedToPardotChangeLog = new set<Id>();
    
    public static Id getOwnerRecordTypeId() {
    	return ownerRecordType.Id;
    }
    
    public static void assignDealersToOwnersIfNotGeocodingButAssignmentDataOrScoreHasChanged(map<Id, Account> oldMap, map<Id, Account> newMap) {
   		set<Id> ownerIdsToRoute = new set<Id>();
    	
    	OwnerRouter ownerRouter = new OwnerRouter();
    	
    	for (Id ownerId : newMap.keySet()) {
    		Account newOwner = newMap.get(ownerId);
    		Account oldOwner = oldMap.get(ownerId);
    		
    		// Only consider leads that have not been marked for geocoding or that do not need to be geocoded
    		if (!newOwner.Geonames_Retry__c && !ownerAddressHasChanged(oldOwner, newOwner)) {
    			if (ownerScoreHasChangedEnoughToRequireRouting(oldOwner, newOwner) || ownerRouter.objectDataChangeRequiresRouting(oldOwner, newOwner)) {
    				system.debug('owner ' + newOwner.Id + ' has data that has changed in a way to require routing');
    				// If we have legacy routing enabled then we have a different set of rules to consider
    				if (!legacyOwnerRouting || !legacyBrandCodes.contains(newOwner.Brand__c)) {
    					ownerIdsToRoute.add(newOwner.Id);
    				}
    			}	
    			else {
    				system.debug('Owner score has not changed enough or owner data has not changed to require routing');
    			}
    		}
    		else {
    			system.debug('Owner geonames retry is true or owner address has changed so owner will not get immediately routed');
    		}
    	}
    	
    	if (!ownerIdsToRoute.isEmpty()) {
    		boolean oldDoNotSendEmail = DealerRouter.doNotSendEmail;
    		
    		// If the current user is not a pardot user then we want to disable sending of email and 
    		// footsteps
    		if (!PardotAssignment.currentUserIsPardotUser() && !DealerRouter.currentUserIsRoutingIntegrationUser()) {
    			system.debug('Disabling sending of email and footsteps because the current user is not a pardot user or a routing integration user');
    			DealerRouter.doNotSendEmail = true;	
    		}
    		
    		routeOwners(getOwnerAccountsForRouting(ownerIdsToRoute));	
    		
    		system.debug('Setting router doNotSendEmail back to ' + oldDoNotSendEmail);
    		DealerRouter.doNotSendEmail = oldDoNotSendEmail;
    	}
   	}
   	
   	public static list<Account> getOwnerAccountsForRouting(set<Id> accountIds) {
    	return [Select Id, 
    				   PersonMailingState,
    				   PersonMailingCity,
    				   PersonMailingPostalCode,
    				   Home_Address_ISO_Code__c,
    				   ShippingPostalCode, 
    				   shippingcity, 
    				   shippingCountry, 
    				   Country_ISO_Code__c, 
    				   county__c, 
    				   latitude__c, 
    				   longitude__c,
    				   GeoLocation__Latitude__s,
    				   GeoLocation__Longitude__s,
    				   PersonLeadSource,
    				   Brand__c,
    				   Lead_Form_Name__pc,
    				   CreatedDate,
    				   Previous_Boat_Owner__pc,
                	   Current_Owned_Brand__pc,
                	   Current_Owned_Boat_Class__pc,
                	   Currently_Owned_Year__pc,
                	   Boat_Model_Interest__pc,
                	   Boat_Class_Interest__pc,
               	 	   Boat_Category_of_Interest__pc,
                	   Boat_Year_of_Interest__pc,
                	   Buying_horizon__pc,
    				   GeoNames_WebService_Error__c,
    				   Notes__pc,
                	   Geonames_Retry__c,
                	   pi__score__pc,
                	   (Select CreatedDate, Dealer__c, Pardot_Score__c From Assigned_Dealers__r order by CreatedDate desc)
    				   from Account where id in: accountIds];
    }
   	
   	private static boolean ownerAddressHasChanged(Account oldAccount, Account newAccount) {
        if (StringUtils.isNotEqualIgnoreCase(oldAccount.PersonMailingPostalCode, newAccount.PersonMailingPostalCode) ||
    		StringUtils.isNotEqualIgnoreCase(oldAccount.Home_Address_ISO_Code__c, newAccount.Home_Address_ISO_Code__c) ||
    		StringUtils.isNotEqualIgnoreCase(oldAccount.PersonMailingCity, newAccount.PersonMailingCity)) {
        	return true;
        } 
        return false;
    }
    
    /*
    * Checks if the pardot score has changed enough to enable routing to dealers
    */
    private static boolean ownerScoreHasChangedEnoughToRequireRouting(Account oldAccount, Account newAccount) {
    	double oldScore = (oldAccount.pi__score__pc == null) ? 0 : oldAccount.pi__score__pc;
    	double newScore = (newAccount.pi__score__pc == null) ? 0 : newAccount.pi__score__pc;
        decimal scoreDiff = newScore - oldScore;
        return (scoreDiff >= ACCOUNT_SCORE_THRESHOLD);
    }
    
    public static void writeNewOwnerAccountsToPardotObjectChangeLog(list<Account> newAccounts) {
    	if (!OwnerServices.disablePardotLogCheck && newAccounts != null && !newAccounts.isEmpty()) {	
    		String ownerRecTypeId = OwnerServices.getOwnerRecordTypeId();
    		
    		list<pi__ObjectChangeLog__c> objectChangeLogsToInsert = new list<pi__ObjectChangeLog__c>(); 
    		
    		for (Account account : newAccounts) {
    			boolean isOwnerAccount = account.recordTypeId.equals(ownerRecTypeId);
    			
    			if (isOwnerAccount) {
    				boolean hasEmail = !String.isEmpty(account.PersonEmail);
    				boolean emailVerified = 'Yes'.equalsIgnoreCase(account.Email_Verified__pc);
    				
    				if (hasEmail && emailVerified) {
    					if (!ownerIdsAddedToPardotChangeLog.contains(account.Id)) {
    						pi__ObjectChangeLog__c log = createObjectChangeLogForNewAccount(account);
							objectChangeLogsToInsert.add(log);
							
							ownerIdsAddedToPardotChangeLog.add(account.Id);
    					}
    				}
    			}
    		}
    		
    		if (!objectChangeLogsToInsert.isEmpty()) {
    			insert objectChangeLogsToInsert;
    		}
    	}
    }
    
    public static void writeUpdatedOwnerAccountsToPardotObjectChangeLog(list<Account> updatedAccounts) {
   		if (!OwnerServices.disablePardotLogCheck && updatedAccounts != null && !updatedAccounts.isEmpty()) {	
    		String ownerRecTypeId = OwnerServices.getOwnerRecordTypeId();
    		
    		list<pi__ObjectChangeLog__c> objectChangeLogsToInsert = new list<pi__ObjectChangeLog__c>(); 
    		
    		for (Account account : updatedAccounts) {
    			boolean isOwnerAccount = account.recordTypeId.equals(ownerRecTypeId);
    			
    			if (isOwnerAccount) {
    				boolean hasEmail = !String.isEmpty(account.PersonEmail);
    				boolean emailVerified = 'Yes'.equalsIgnoreCase(account.Email_Verified__pc);
    				boolean existsInPardot = !String.isEmpty(account.pi__url__pc);
    				
    				if (hasEmail && emailVerified && !existsInPardot) {
    					if (!ownerIdsAddedToPardotChangeLog.contains(account.Id)) {
    						pi__ObjectChangeLog__c log = createObjectChangeLogForNewAccount(account);
							objectChangeLogsToInsert.add(log);
							
							ownerIdsAddedToPardotChangeLog.add(account.Id);
    					}
    				}
    			}
    		}
    		
    		if (!objectChangeLogsToInsert.isEmpty()) {
    			insert objectChangeLogsToInsert;
    		}
    	} 	
    }
    
    public static void writeDeletedOwnerAccountsToPardotObjectChangeLog(list<Account> deletedAccounts) {
    	if (!OwnerServices.disablePardotLogCheck && deletedAccounts != null && !deletedAccounts.isEmpty()) {	
    		String ownerRecTypeId = OwnerServices.getOwnerRecordTypeId();
    		
    		list<pi__ObjectChangeLog__c> objectChangeLogsToInsert = new list<pi__ObjectChangeLog__c>(); 
    		
    		for (Account account : deletedAccounts) {
    			boolean isOwnerAccount = account.recordTypeId.equals(ownerRecTypeId);
    			
    			if (isOwnerAccount) {
    				boolean hasEmail = !String.isEmpty(account.PersonEmail);
    				boolean existsInPardot = !String.isEmpty(account.pi__url__pc);
    				
    				if (hasEmail && existsInPardot) {
    					pi__ObjectChangeLog__c log = createObjectChangeLogForDeletedAccount(account);
						objectChangeLogsToInsert.add(log);
						
						ownerIdsAddedToPardotChangeLog.add(account.Id);
    				}
    			}
    		}
    		
    		if (!objectChangeLogsToInsert.isEmpty()) {
    			insert objectChangeLogsToInsert;
    		}
    	}	
    }
    
    public static void writeUnDeletedOwnerAccountsToPardotObjectChangeLog(list<Account> deletedAccounts) {
    	if (!OwnerServices.disablePardotLogCheck && deletedAccounts != null && !deletedAccounts.isEmpty()) {	
    		String ownerRecTypeId = OwnerServices.getOwnerRecordTypeId();
    		
    		list<pi__ObjectChangeLog__c> objectChangeLogsToInsert = new list<pi__ObjectChangeLog__c>(); 
    		
    		for (Account account : deletedAccounts) {
    			boolean isOwnerAccount = account.recordTypeId.equals(ownerRecTypeId);
    			
    			if (isOwnerAccount) {
    				boolean hasEmail = !String.isEmpty(account.PersonEmail);
    				boolean emailVerified = 'Yes'.equalsIgnoreCase(account.Email_Verified__pc);
    				
    				if (hasEmail && emailVerified) {
    					pi__ObjectChangeLog__c log = createObjectChangeLogForUnDeletedAccount(account);
						objectChangeLogsToInsert.add(log);
						
						ownerIdsAddedToPardotChangeLog.add(account.Id);
    				}
    			}
    		}
    		
    		if (!objectChangeLogsToInsert.isEmpty()) {
    			insert objectChangeLogsToInsert;
    		}
    	}	
    }
    
    private static pi__ObjectChangeLog__c createObjectChangeLogForNewAccount(Account account) {
    	pi__ObjectChangeLog__c log = createObjectChangeLog(account);
		log.pi__ObjectState__c = 1;
		
		return log;
    }
    
    private static pi__ObjectChangeLog__c createObjectChangeLogForDeletedAccount(Account account) {
    	pi__ObjectChangeLog__c log = createObjectChangeLog(account);
		log.pi__ObjectState__c = 2;
		
		return log;
    }
    
    private static pi__ObjectChangeLog__c createObjectChangeLogForUnDeletedAccount(Account account) {
    	pi__ObjectChangeLog__c log = createObjectChangeLog(account);
		log.pi__ObjectState__c = 3;
		
		return log;
    }
	
    
    private static pi__ObjectChangeLog__c createObjectChangeLog(Account account) {
    	pi__ObjectChangeLog__c log = new pi__ObjectChangeLog__c();
		log.pi__ObjectFid__c = account.PersonContactId;
		log.pi__ObjectType__c = 1;
		log.pi__ObjectEmail__c = account.PersonEmail;
		log.bbg_ObjectParentFId__c = account.id;
		
		return log;	
    }
    
    // method to call GeoWebService and populate Geo fields on Owner Account. 
    @future (callout = true)        
    public static void populateOwnerGeoFieldsFuture(Set<ID> AccountIDs, boolean disableEmail) {
    	if (disableEmail) {
    		DealerRouter.doNotSendEmail = true;
    	}
    	populateOwnerGeoFields(AccountIDs);
    }
    
    // this method is used to set populateOwnerGeoFieldsIsRunning true so you know it's been scheduled to run
    public static void schedulePopulateOwnerGeoFields(Set<ID> AccountIDs) {
    	OwnerServices.populateOwnerGeoFieldsIsRunning = true;
    	
    	boolean disableEmail = (!PardotAssignment.currentUserIsPardotUser() && !DealerRouter.currentUserIsRoutingIntegrationUser());
    	populateOwnerGeoFieldsFuture(AccountIDs, disableEmail);
    }
    
    // this method is used to set populateOwnerGeoFieldsIsRunning true so you know it's been scheduled to run
    public static void schedulePopulateOwnerGeoFieldsNoEmail(Set<ID> AccountIDs) {
    	OwnerServices.populateOwnerGeoFieldsIsRunning = true;
    	populateOwnerGeoFieldsFuture(AccountIDs, true);
    }
    

	// method to call GeoWebService and populate Geo fields on Owner Account.     
    public static void populateOwnerGeoFields(Set<ID> AccountIDs)
    {
    	OwnerServices.populateOwnerGeoFieldsIsRunning = true;
    	try {
	        String METHODNAME = CLASSNAME.replace('METHODNAME', 'populateOwnerGeoFields');
	        system.debug(LoggingLevel.DEBUG, METHODNAME.replace('**** ', '**** Inside ') + ' \n\n');
	        // list to store account records which needs to be updated.        
	        list<Account> AccountUpdateList = new list<Account>();   
	        //AccountList will store all account records whose id is in AccountIDs
	        list<Account> AccountList = [Select Id, 
	                							Boat_Category_of_Interest__pc,
	        									RecordTypeId, 
	        									PersonMailingPostalCode, 
	        									PersonMailingCity, 
	        									PersonMailingCountry, 
	        									Home_Address_ISO_Code__c, 
	        									county__c, latitude__c, 
	        									longitude__c, 
	        									Brand__c,
	        									GeoNames_WebService_Error__c ,
	        									pi__score__pc,
	        									(Select CreatedDate, Dealer__c, Pardot_Score__c From Assigned_Dealers__r order by CreatedDate desc)
	        									from Account 
	        									where id in: AccountIDs];               
	        // Loop thorugh each account record
	        for(Account acc : AccountList) { 
	            acc.Latitude__c = null;
	            acc.Longitude__c = null;           
	            map<String, String> AccountFieldsMap = new Map<String, String>();          
	            AccountFieldsMap.clear();  
	            
	            system.debug('Home_Address_ISO_Code__c = ' + acc.Home_Address_ISO_Code__c);
	            system.debug('PersonMailingPostalCode = ' + acc.PersonMailingPostalCode);
	            system.debug('PersonMailingCity = ' + acc.PersonMailingCity);
	            
	            if(acc.Home_Address_ISO_Code__c != null && acc.PersonMailingPostalCode != null) {
	                   String cleanedPostalCode = ''; 
	                   if(acc.PersonMailingPostalCode.Contains('-')){
	                       cleanedPostalCode = acc.PersonMailingPostalCode.subString(0,5);
	                   }else{
	                       cleanedPostalCode = acc.PersonMailingPostalCode; 	
	                   }
	                   AccountFieldsMap = GeoNamesWebService.getLocationInfo(EncodingUtil.urlEncode(cleanedPostalCode,'UTF-8'), acc.Home_Address_ISO_Code__c,null, false);
	            }   
	            
	           
	            if(AccountFieldsMap.values().isEmpty() && acc.PersonMailingCity != null){  
	                AccountFieldsMap = GeoNamesWebService.getLocationInfo(null, acc.Home_Address_ISO_Code__c, EncodingUtil.urlEncode(acc.PersonMailingCity,'UTF-8'),false);
	            }   
	            
	            system.debug(LoggingLevel.DEBUG, METHODNAME + ' :: Map value***'+AccountFieldsMap );  
	            Boolean updFlag = False;        
	            system.debug(LoggingLevel.DEBUG, METHODNAME + ' :: AccountFieldsMap '+AccountFieldsMap);         
	            
	            if(AccountFieldsMap.isEmpty()) {
	                acc.Latitude__c = null;
	                acc.Longitude__c = null;
	                acc.GeoLocation__Latitude__s = null;
	                acc.GeoLocation__Longitude__s = null;
	                updFlag = True;
	            }  
	            
	            if(AccountFieldsMap.get('adminName2') != null) {      
	                acc.county__c = AccountFieldsMap.get('adminName2').contains('County') ?  AccountFieldsMap.get('adminName2').remove('County').trim() : AccountFieldsMap.get('adminName2');            	       
	                acc.GeoNames_WebService_Error__c = '';       
	                updFlag = True;                     
	            }            
	            if(AccountFieldsMap.get('lat') != null) {   
	                acc.latitude__c = decimal.valueOf(AccountFieldsMap.get('lat'));   
	                acc.GeoLocation__Latitude__s = decimal.valueOf(AccountFieldsMap.get('lat'));   
	                acc.GeoNames_WebService_Error__c = '';             
	                updFlag = True;     
	            }            
	            if(AccountFieldsMap.get('lng') != null) {  
	                acc.longitude__c = decimal.valueOf(AccountFieldsMap.get('lng')); 
	                acc.GeoLocation__Longitude__s = decimal.valueOf(AccountFieldsMap.get('lng')); 
	                acc.GeoNames_WebService_Error__c = '';
	                updFlag = True;    
	            }   
	            if(AccountFieldsMap.get('WebService Exception: ') != null) {    
	                acc.GeoNames_WebService_Error__c = AccountFieldsMap.get('WebService Exception: ');
	                updFlag = True;     
	            } else {
	            	updFlag = True;
	            	acc.Geonames_Retry__c = false;
	            }
	                
	            if(AccountFieldsMap.get('XML Parsing Exception: ') != null)
	            { 
	                if(AccountFieldsMap.get('WebService Exception: ') != null) {    
	                    acc.GeoNames_WebService_Error__c += AccountFieldsMap.get('XML Parsing Exception: ');   
	                } else {                 
	                    acc.GeoNames_WebService_Error__c += AccountFieldsMap.get('XML Parsing Exception: ');  
	                }
	                updFlag = True;  
	            }  
	            if(updFlag == True) {      
	                AccountUpdateList.add(acc);   
	            } 
	        } 
	        // Update AccountUpdateList list if it has atleast 1 record    
	        if(AccountUpdateList.size() > 0) {     
	            system.debug(LoggingLevel.DEBUG, METHODNAME + ' :: AccountUpdateList '+AccountUpdateList); 
	            try {
	                update AccountUpdateList; 
	            } 
	            catch(DMLException ex) {      
	                system.debug(LoggingLevel.DEBUG, METHODNAME + ' :: update exception '+ ex);   
	            }
	            
	            // We now need to separate out owner records and perform lead type routing to dealers
	            list<Account> ownerUpdateList = getOwnerAccounts(AccountUpdateList);
	            
	            if (ownerUpdateList.size() > 0) {
	            	routeOwners(ownerUpdateList);
	            }
	            else {
	            	system.debug('No owners found to route');
	            }
	        }
	        else {
	        	system.debug('No accounts to update');
	        }
    	}
    	finally {
    		//OwnerServices.populateOwnerGeoFieldsIsRunning = false;
    	}
    }
    
    // Returns a list of owner accounts from a list of accounts
    public static list<Account> getOwnerAccounts(list<Account> accountList) {
    	list<Account> ownerList = new list<Account>();
    	
    	for (Account account : accountList) {
    		if (ownerRecordType.Id == account.recordTypeId) {	
    			string brand = account.Brand__c;
				if (brand != null) { 
					ownerList.add(account);
				}
    		}	
    	}	
    	
    	system.debug('Found ' + ownerList.size() + ' owners');
    	
    	return ownerList;
    } 
    
     
    public static void routeOwners(final List<Account> ownerUpdateList){
    	routeOwners(ownerUpdateList, new List<Account>());
    }
    
    public static void routeOwners(final List<Account> ownerUpdateList, final List<Account> resultsNotFoundOwnerList) {
    	if (ownerUpdateList != null && ownerUpdateList.size() > 0) {
    		if (!OwnerServices.legacyOwnerRouting) {
    			// We are using the new SR combined type of owner routing
    			system.debug('Using new combined owner routing');
		        OwnerServices.ownerRoutingIsRunning = true;
		       	try {
		       		OwnerRouter router = new OwnerRouter(); 
			        router.routeToDealers(ownerUpdateList);
		       	}
		       	finally {
		        	OwnerServices.ownerRoutingIsRunning = false;
		       	}
    		}
    		else {
    			// We need to use the old legacy BL type	
    			system.debug('Using legacy owner routing');
    			routeOwnersLegacy(ownerUpdateList, resultsNotFoundOwnerList);
    		}
    	}
    }
    
    public static void routeOwnersLegacy(final List<Account> ownerUpdateList, final List<Account> resultsNotFoundOwnerList){
        final List<Account> legacyOwnerTypes = new list<Account>();
        final List<Account> AllOtherOwners = new list<Account>();
        map<string, Dealer_Routing_Test_Mode__c> dealerRoutingTestModes = Dealer_Routing_Test_Mode__c.getAll();
        Dealer_Routing_Test_Mode__c routingTestMode = dealerRoutingTestModes.get('Owner');
        
        system.debug('legacyBrandCodes'+ legacyBrandCodes);
        system.debug('AllOtherOwners'+AllOtherOwners);
            
        for(Account o : ownerUpdateList){
            if(legacyBrandCodes.contains(o.Brand__c)){
                legacyOwnerTypes.add(o);
            }
            else {
                system.debug('other owner <><>'+ o);
                AllOtherOwners.add(o);
            }
        }
        
        
        Set<Id> ownerIDsToSendToFootsteps_Input = new Set<Id>();
        
        
        //the following if block is legacy code that needs to remain intact for Bayliner, Maxum, and Trophy leads.
        if(!legacyOwnerTypes.isEmpty()){
            system.debug('Legacy owners <><>'+ legacyOwnerTypes);
            final List<Account> ownersWithUpdatedDealers = routeOwnersToAppropriateDealers(ownerUpdateList);
            
            if (routingTestMode == null || (routingTestMode.Test_Mode__c && routingTestMode.Process_Footsteps__c) || !routingTestMode.Test_Mode__c) {
           		routeOwnerToMarineMaxDealer(ownersWithUpdatedDealers, routingTestMode);
            }
            
            //Also have to update leads that didn't find results
            ownersWithUpdatedDealers.addAll(resultsNotFoundOwnerList);
            if(!ownersWithUpdatedDealers.isEmpty()) {
                update ownersWithUpdatedDealers;   
                
                ownerIDsToSendToFootsteps_Input.addAll(Pluck.ids(ownersWithUpdatedDealers));
            
            }
            
             if (!ownerIDsToSendToFootsteps_Input.isEmpty() && 
             	(routingTestMode == null || routingTestMode.Test_Mode__c == false)){
             		/*
	            String scheduleTime = Datetime.now().addSeconds( 60 ).format( 'ss mm HH dd MM ? yyyy' );
	            String scheduleId = String.valueOf(Datetime.now().getTime());
	            String jobId = System.schedule( 'footstepsIntegration'+scheduleId, scheduleTime, new ScheduleHandler(ownerIDsToSendToFootsteps_Input, true) );
	            */
				OwnerRouter router = new OwnerRouter();
				router.sendToFootsteps(ownerIDsToSendToFootsteps_Input);
	        }
        }
        
        if(!AllOtherOwners.isEmpty()){
            system.debug('All Other owners <><>'+ AllOtherOwners);
            // make the magic happen.
            OwnerServices.ownerRoutingIsRunning = true;
            try {
            	OwnerRouter router = new OwnerRouter(); 
			    router.routeToDealers(AllOtherOwners);
            }
            finally {
            	 OwnerServices.ownerRoutingIsRunning = false;
            }
        }
    }
    
     // method to route Leads to the appropriate Dealers
    public static List<Account> routeOwnersToAppropriateDealers(list<Account> ownerList) {
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'routeOwnersToAppropriateDealers');
        
        List<Account> ownerListFiltered = ownerList;
        list<Account> ownerUpdateList = new list<Account>();
        if(ownerListFiltered != null && !ownerListFiltered.isEmpty()) {
            String brandInterest = [Select Brand__c from Account where id =:ownerListFiltered[0].Id].Brand__c;
            for(Account l : ownerListFiltered) {                   
                Boolean countyMatchFound;
                system.debug('COunty ='+l.County__c);
                map<String, list<Id>> CountiesToDealersMap = TerritoryServices.getCountiesToDealersMap(l.Brand__c, ownerStateCodeMap.get(l.Id), l.County__c);              
                if(l.Home_Address_ISO_Code__c == UNITED_STATES) 
                {
                    if(CountiesToDealersMap.containsKey(l.county__c)){
                        system.debug('CountiesToDealersMap ='+CountiesToDealersMap);
                        list<Id> dealerList = uniqueIds(CountiesToDealersMap.get(l.county__c));
                        if(dealerList != null && dealerList.size()>0){
                            // update Lead fields with Dealer IDs - workflow will notify the dealers
                            l.Assigned_Dealer_1__c = dealerList[0];
                            if(dealerList.size()>= 2)
                                l.Assigned_Dealer_2__c = dealerList[1];
                            if(dealerList.size()>= 3)
                                l.Assigned_Dealer_3__c = dealerList[2];                          
                            ownerUpdateList.add(l);
                            
                            countyMatchFound = true;
                        }
                    }else{
                        countyMatchFound = false;
                    }
                }else if(l.Home_Address_ISO_Code__c == CANADA){
                    list<Territory__c> territoryList = TerritoryServices.findTerritoriesForCanada(l.PersonMailingPostalCode, l.Brand__c, l.Home_Address_ISO_Code__c);
                    list<Id> territoryNames = new list<Id>();
                    for(Territory__c eachTerritoryList :territoryList) {
                        territoryNames.add(eachTerritoryList.Dealer_Name__c);   
                    }
                    list<Id> uniqueDealerIds = uniqueIds(territoryNames);
                    if(uniqueDealerIds != null && uniqueDealerIds.size()>0) {                        
                        l.Assigned_Dealer_1__c = uniqueDealerIds[0];                         
                        if(uniqueDealerIds.size() >= 2)
                            l.Assigned_Dealer_2__c = uniqueDealerIds[1];
                        if(uniqueDealerIds.size() >= 3) 
                            l.Assigned_Dealer_3__c = uniqueDealerIds[2];
                    }else{                       // find by distance                       
                        TerritoryServices.MatchedDealers md = OwnerServices.FindDealersByDistance(l, brandInterest);                        
                        if(md != null){
                            // update Lead fields with Dealer IDs - workflow will notify the dealers
                            l.Assigned_Dealer_1__c = md.DealerOneId;
                            l.Assigned_Dealer_2__c = md.DealerTwoId;
                            l.Assigned_Dealer_3__c = md.DealerThreeId;      
                            // add this Lead to the list to update
                            
                        }
                    } 
                    ownerUpdateList.add(l);
                }
                system.debug('countyMatchFound ='+CountiesToDealersMap);
                if(( l.Home_Address_ISO_Code__c != CANADA && l.Home_Address_ISO_Code__c != UNITED_STATES) ||
                   (l.Home_Address_ISO_Code__c == UNITED_STATES && countyMatchFound == false))
                {
                    system.debug('IN International');
                    // all other countries are by distance within the same country
                    TerritoryServices.MatchedDealers md = OwnerServices.FindDealersByDistance(l, l.Brand__c);
                    if(md != null){
                        system.debug('md ='+md);
                        // update Lead fields with Dealer IDs - workflow will notify the dealers
                        l.Assigned_Dealer_1__c = md.DealerOneId;
                        l.Assigned_Dealer_2__c = md.DealerTwoId;
                        l.Assigned_Dealer_3__c = md.DealerThreeId;                    
                        ownerUpdateList.add(l);
                    }
                }
            }
        }
        return ownerUpdateList; 
    }
    
    private static void routeOwnerToMarineMaxDealer(list<Account> ownerRecords, Dealer_Routing_Test_Mode__c testMode){
        set<Id> assignedDealerId = new set<Id>();
        
        for(Account ld : ownerRecords){
            if(ld.Assigned_Dealer_1__c != null)
                assignedDealerId.add(ld.Assigned_Dealer_1__c);
            if(ld.Assigned_Dealer_2__c != null)
                assignedDealerId.add(ld.Assigned_Dealer_2__c);
            if(ld.Assigned_Dealer_3__c != null)
                assignedDealerId.add(ld.Assigned_Dealer_3__c);           
        }
        
        map<Id,Account> idToDealer = getDetailsForAssignedDealer(assignedDealerId);
        //map<Id,list<Boat__c>> accountIdToListOfBoats = getAllBoatsTiedToAssignedDealer(assignedDealerId);
        
        if (!DealerRouter.doNotSendEmail) {
            system.debug('doNotSendEmail = false so dealer routing emails will be sent');
	        for(Account ld : ownerRecords){    
	            //BS-192 - XML Dealer Routing needs to account for Do Not Send custom settings
	            if (isOwnerSendable(ld.Brand__c, ld.Lead_Form_Name__pc) && !isUserLoadingBatch) {  
	                for(Account rec :idToDealer.values()){
	                    if(ld.Owner_Emails_Sent__c == null || !ld.Owner_Emails_Sent__c) {             
	                        String result = getXml(rec,ld);             
	                        Messaging.Emailfileattachment attachment = new Messaging.Emailfileattachment();
	                        attachment.setContentType('application/xml');
	                        attachment.setFileName('Bayliner Owner');
	                        attachment.setBody(Blob.valueOf(result));                        
	                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailmessage();
	                        String[] toAddresses = new String[] {rec.CRM_System_Email__c};
	                        
	                        if (testMode != null && testMode.Test_Mode__c) {
	                        	toAddresses = new String[] {testMode.Test_CRM_Email__c};
	                        }
	                        
	                        mail.setToAddresses(toAddresses);            
	                        mail.setPlainTextBody('bayliner dealer xml');
	                        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});
	                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});     
	                    }           
	                }  
	            }          
	        }
        }      
    }
    
    public static TerritoryServices.MatchedDealers FindDealersByDistance(Account l, String brand){
        return TerritoryServices.findByDistance(l.Longitude__c, l.Latitude__c, brand, l.Home_Address_ISO_Code__c);
    } 
    
    public static List<Id> uniqueIds(final List<Id> ids) {
        final List<Id> uniqueIds = new List<Id>();
        for(Id eachId :ids) {
            if(uniqueIds.isEmpty()) uniqueIds.add(eachId);
            else {
                Boolean flag = false;
                for(Id eachUniqueId :uniqueIds) {
                    flag = (eachUniqueId == eachId);
                    if(flag) break;
                }
                if(!flag) uniqueIds.add(eachId);
            }
        }
        return uniqueIds;
    }
    
    public static boolean isOwnerSendable(String brandCode, String leadFormName) {
        for(Lead_Routing_Do_Not_Send__c dns : LEAD_DO_NOT_SEND.values()){
            if(brandCode == dns.get('Brand_Code__c') && leadFormName == dns.get('Lead_Form_Name__c')){
                system.debug('Lead routing do not send for brand code: ' + brandCode + ' and form name: ' + leadFormName + ' = NOT SENDABLE');
                return false;
            }
        }
        system.debug('Lead routing do not send for brand code: ' + brandCode + ' and form name: ' + leadFormName + ' = SENDABLE');
        return true;
    }
    
    
    public static set<Id> getOwnerAccountIds (list<Account> accRecords){
    	set<Id> ownerAccountIds = new set<Id>();
    	for(Account rec: accRecords) {
        	if(ownerRecordType.Id == rec.recordTypeId){
             	ownerAccountIds.add(rec.Id);
            }
        }
        return ownerAccountIds;
    }
    
    
    //BS-267 - New Lead - Do Not Send Emails to Dealers
    private static boolean isUserLoadingBatch {
    	get {
    		if (isUserLoadingBatch == null) {
    			isUserLoadingBatch = [Select Importing_Leads__c From User Where id = :UserInfo.getUserId()].Importing_Leads__c;
    			
    			if (isUserLoadingBatch == null) {
    				isUserLoadingBatch = false;
    			}
    		}
    		return isUserLoadingBatch;
    	}
    	set;
    }
    
    public static string getXML (Account marineMaxDealer , Account ld){
    	
    	List<Task> tasks = ld.getSObjects('tasks');
    	
        XmlStreamWriter w = new XmlStreamWriter();  
        w.writeStartDocument(null, '1.0');
        w.writeStartElement('', 'Lead',''); 
        //w.writeNamespace('xsi','http://www.w3.org/2001/XMLSchema-instance');  
        //w.writeNamespace('xsd','http://www.w3.org/2001/XMLSchema');
        w.writeStartElement(null, 'customername', null);        
        w.writeCharacters(getValue(ld.name));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customeraddress', null);
        w.writeCharacters(getValue(ld.PersonMailingStreet));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customercity', null); 
        w.writeCharacters(getValue(ld.PersonMailingCity));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customerState', null);
        w.writeCharacters(getValue(ld.PersonMailingState));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customerzip', null);
        w.writeCharacters(getValue(ld.PersonMailingPostalCode));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customercountry', null);
        w.writeCharacters(getValue(ld.PersonMailingCountry));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customerhomephone', null);       
        w.writeCharacters(getValue(ld.Phone));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customeremail1', null);
        w.writeCharacters(getValue(ld.PersonEmail));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customeremail2', null);
        w.writeCharacters(getValue(ld.Alternate_Email_Address__c));
        w.writeEndElement(); 
        w.writeStartElement(null, 'dealerid', null);
        w.writeCharacters(getValue(marineMaxDealer.Id));
        w.writeEndElement(); 
        w.writeStartElement(null, 'leadformname', null);
        w.writeCharacters(getValue(ld.Lead_Form_Name__pc));
        w.writeEndElement();
        //w.writeStartElement(null, 'typeofinquiry', null);
        //w.writeCharacters(getValue(ld.Type_of_inquiry__c));
        w.writeEndElement(); 
        /*w.writeStartElement(null, 'priority', null);
w.writeCharacters('');
w.writeEndElement();*/ 
        w.writeStartElement(null, 'createddate', null);
        w.writeCharacters(getValue(String.valueOf(ld.CreatedDate)));
        w.writeEndElement(); 
        //w.writeStartElement(null, 'previousboatowner', null);
       // w.writeCharacters(getValue(String.valueOf(ld.Previous_Boat_Owner__c)));
       // w.writeEndElement();
       /* w.writeStartElement(null, 'currentownedbrand', null);
        w.writeCharacters(getValue(ld.Current_Owned_Brand__c));
        w.writeEndElement();
        w.writeStartElement(null, 'currentownedmodel', null);
        w.writeCharacters(getValue(ld.Current_Owned_Model__c));
        w.writeEndElement();
        w.writeStartElement(null, 'currentownedboatclass', null);
        w.writeCharacters(getValue(ld.Current_Owned_Boat_Class__c));
        w.writeEndElement();
        w.writeStartElement(null, 'currentownedyear', null);
        w.writeCharacters(getValue(ld.Currently_Owned_Year__c));
        w.writeEndElement();*/
        //w.writeStartElement(null, 'currentownedidnumber', null);
       // w.writeCharacters(getValue(ld.Current_Owned_ID_Number__c));
       // w.writeEndElement();
        w.writeStartElement(null, 'boatmodelinterest', null);
        w.writeCharacters(getValue(ld.Boat_Model_Interest__pc));
        w.writeEndElement();
        w.writeStartElement(null, 'boatclassinterest', null);
        w.writeCharacters(getValue(ld.Boat_Class_Interest__pc));
        w.writeEndElement();
        //w.writeStartElement(null, 'boatyearinterest', null);
        //w.writeCharacters(getValue(ld.Boat_Year_Interest__c));
        //w.writeEndElement();
       // w.writeStartElement(null, 'interestedinstocknumber', null);
        //w.writeCharacters(getValue(ld.Interested_in_Stock_Number__c));
       // w.writeEndElement();
        //w.writeStartElement(null, 'interestedinlength', null);
        //w.writeCharacters(getValue(ld.Interested_in_length__c));
       // w.writeEndElement();
       // w.writeStartElement(null, 'interestedinidnumber', null);
        //w.writeCharacters(getValue(ld.Interested_in_ID_Number__c));
       // w.writeEndElement();
        w.writeStartElement(null, 'purchasetimeframe', null);
        w.writeCharacters(getValue(ld.Buying_horizon__pc));
        w.writeEndElement();
        w.writeStartElement(null, 'comments', null);
        
        String comments = getValue(ld.Notes__pc);
        
        //Get the Pardot Score Increase Trigger Custom Setting accumulated point total for the lead's brand
    	/*Pardot_Score_Increase_Trigger__c psit = LeadServices.pardotScoreIncreaseTriggers.get(ld.Brand_Code__c);
    			
		if (psit != null) {
			if (!tasks.isEmpty()) {
				comments += '\nLead Activities:\n';
				for (Integer x = 0; x < Math.min(tasks.size(), psit.Days_Of_Activities__c.intValue()); x++) {
					Task task = tasks[x];
					comments += task.LastModifiedDate.format() + ' - ' + task.Subject + ' \n';
				}
			}
		}*/
				
        w.writeCharacters(comments);
        
        w.writeEndElement();        
        /*
w.writeStartElement(null, 'leadsourcetype', null);
w.writeCharacters('');
w.writeEndElement();        
w.writeStartElement(null, 'leadsourcedetail', null);
w.writeCharacters('');
w.writeEndElement();        
w.writeStartElement(null, 'leadsource', null);
w.writeCharacters(getValue(ld.LeadSource));
w.writeEndElement(); 
w.writeStartElement(null, 'leadsourcevendor', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'leadwebsourcepage', null);
w.writeCharacters(getValue(ld.Website));
w.writeEndElement(); 
w.writeStartElement(null, 'boatunittype', null);
w.writeCharacters(getValue(ld.Boat_Class_Interest__c));
w.writeEndElement(); 
w.writeStartElement(null, 'boattype', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'boatbrand', null);
w.writeCharacters(getValue(ld.Brand_Interest__c));
w.writeEndElement(); 
w.writeStartElement(null, 'boatstocknumber', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'boatmodel', null);
w.writeCharacters(getValue(ld.Boat_Model_Interest__c));
w.writeEndElement(); 
w.writeStartElement(null, 'boathin', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'tradeinhorsepower', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'tradehours', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'tradetrailerincluded', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'cashdown', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'rentorown', null);
w.writeCharacters('');
w.writeEndElement();*/ 
        w.writeEndDocument();
        String xmlOutput = w.getXmlString();
        w.close();
        return xmlOutput;
    }
    // email not required
    
    private static string getValue(String fieldValue){
        String newValue;
        if(String.isBlank(fieldValue))
            newValue = '';
        else
            newValue = fieldValue;
        return newValue;
    }
    
     public static Map<String,Lead_Routing_Do_Not_Send__c> LEAD_DO_NOT_SEND {
        // get the custom settings that dictate whether a lead should be sent to a dealer or not
        get {
            if (LEAD_DO_NOT_SEND == null) {
                LEAD_DO_NOT_SEND = Lead_Routing_Do_Not_Send__c.getAll();
            }
            return LEAD_DO_NOT_SEND;
        }
        set;
    }
    
    private static map<Id,Account> getDetailsForAssignedDealer(set<Id> assignedDealerId){
        return new map<Id,Account>([select 
                                    Id,                   
                                    CRM_System_Email__c
                                    from Account
                                    where Id IN :assignedDealerId
                                    and CRM_System__c ='Microsoft Dynamics']);
    }
    
    @future (callout = true)  
    public static void sendFootstepsOwners(Set<ID> ownerIds)
    {
        //FootstepsIntegrationServices.footstepsFieldsMakeCalloutOwners(ownerIds);
        // TODO
    }
}