/**
* Abstract class for routing Leads, Owners(Account), and Contacts to dealers
*
* @author Mike Regan
*/
public with sharing virtual class DealerRouter {
	// The default maximum routing rules
	public static final integer MAX_ROUTING_RULES = 5;
	
	public static final decimal SCORE_THRESHOLD = 50;
	
	// The default email fields
	private static final string[] EMAIL_FIELDS = new list<String>{'Dealer_CRM_Email__c','Dealer_Primary_Email__c','Dealer_Secondary_Email_1__c','Dealer_Secondary_Email_2__c','Dealer_Secondary_Email_3__c','Dealer_Secondary_Email_4__c','Dealer_Secondary_Email_5__c'};
	
	private static map<string, Dealer_Routing_Test_Mode__c> dealerRoutingTestModes = Dealer_Routing_Test_Mode__c.getAll();
	
	// Should emails be sent as part of routing?
	public static boolean doNotSendEmail = false;
	
	public static set<Id> routingIntegrationUserIds {
		get {
			if (routingIntegrationUserIds == null) {
				routingIntegrationUserIds = new set<Id>();
				map<string, Routing_Integration_Users__c> rius = Routing_Integration_Users__c.getAll();	
				for (string key : rius.keySet()) {
					Routing_Integration_Users__c riu  = rius.get(key);
					if (riu != null && !String.isBlank(riu.User_ID__c)) {
						routingIntegrationUserIds.add(Id.valueOf(riu.User_ID__c));
					}
				}
			}	
			return routingIntegrationUserIds;
		}
	}
	
	public static boolean currentUserIsRoutingIntegrationUser() {
		return routingIntegrationUserIds.contains(UserInfo.getUserId());
	}
	
	public boolean objectDataChangeRequiresRouting(sobject oldObject, sobject newObject) {
		DealerRoutingModel oldModel = convertToModel(oldObject);
		DealerRoutingModel newModel = convertToModel(newObject);
		
		return isDifferent(oldModel.PostalCode, newModel.PostalCode) ||
				isDifferent(oldModel.ProductCategory, newModel.ProductCategory) ||
				isDifferent(oldModel.State, newModel.State) ||
				isDifferent(oldModel.CountryISO, newModel.CountryISO) ||
				isDifferent(oldModel.County, newModel.County);
	}

	// Routes a list of objects to dealers based on matching rule criteria
	public void routeToDealers(list<sobject> objects) {
		system.debug('routeToDealers - enter');
		list<sobject> objectsToUpdate = new list<sobject>();
		map<sobject, list<Assigned_Dealer__c>> objectAssignedDealerMap = new map<sobject, list<Assigned_Dealer__c>>();
		
		for (sobject obj : objects) {
			list<Assigned_Dealer__c> assignedDealers = routeObjectToDealers(obj);		
			if (assignedDealers != null && !assignedDealers.isEmpty()) {
				objectsToUpdate.add(obj);
				
				objectAssignedDealerMap.put(obj, assignedDealers);
			}	
		}
		
		if (!objectsToUpdate.isEmpty()) {
     		try {
        		system.debug('Objects For Update - ' + objectsToUpdate);
           	 	Database.update(objectsToUpdate);
            }
            catch(Exception exp) {
                system.debug('Exception on object Update' + exp);
            }
            
            if (!DealerRouter.doNotSendEmail) {
            	system.debug('doNotSendEmail = false so dealer routing emails will be sent');
            	
            	list<sobject> sendableObjects = filterSendableObjects(objectsToUpdate);
            	
            	if (!sendableObjects.isEmpty()) {
            		system.debug('there are sendable objects');
            		
            		map<Id, set<Id>> objectIdToDealerIdMap = new map<Id, set<Id>>();
            		for (sobject sendableObject : sendableObjects) {
            			list<Assigned_Dealer__c> assignedDealers = 	objectAssignedDealerMap.get(sendableObject);
            			if (assignedDealers != null && !assignedDealers.isEmpty()) {
            				set<Id> dealerIds = getDealerIdsThatAreSendable(assignedDealers);
            				if (!dealerIds.isEmpty()) {
            					objectIdToDealerIdMap.put(sendableObject.Id, dealerIds);
            				}	
            			}
            		}
            		
            		if (!objectIdToDealerIdMap.isEmpty()) {
            			sendToFootSteps(objectIdToDealerIdMap);
            		}
            		
			        // Bayliner leads were also emailed to the CRM System email if footsteps
			        //emailObjectsToDealerCRMSystem(sendableObjects);
			            
			       /* set<Id> idsToSendToFootsteps_Input = new set<Id>();    
			        idsToSendToFootsteps_Input.addAll(Pluck.ids(sendableObjects));
			        
			        if (!idsToSendToFootsteps_Input.isEmpty()){
			        	system.debug('sending ' + idsToSendToFootsteps_Input + ' to CRM systems');
						sendToFootSteps(idsToSendToFootsteps_Input);
			        }*/
            	}
            	else {
            		system.debug('There are no sendable objects so nothing will be sent to footsteps');
            	}
            }
            else {
            	system.debug('Not sending dealer routing emails because doNotSendEmail=true');
            }
     	}
	}
	
	// Routes an individual object to a dealer
	private list<Assigned_Dealer__c> routeObjectToDealers(sobject obj) {
		list<Assigned_Dealer__c> assignedDealers = null;
		DealerRoutingModel model = convertToModel(obj);
		if (model != null) {
			// Remember the assigned dealers
			list<Assigned_Dealer__c> oldAssignedDealers = getExistingAssignedDealers(obj);
			if (oldAssignedDealers.isEmpty()) {
				system.debug('Did not find any old assigned dealers');
			}
			else {
				system.debug('Found ' + oldAssignedDealers.size() + ' assigned dealers');
			}
			
			// Clear the existing assigned dealers
			clearExistingAssignedDealers(obj, model);
			
			sobject rule = getDealerRoutingRule(model);
			if (rule != null) {
				// Iterate over each of the defined rules and try to find a dealer match
				for(integer i=1; i!=getMaxRoutingRules() && !model.HasBeenAssigned; i++) {
					string ruleName = getRuleName(rule, i);	
					if (ruleName != null) {
						integer maxNumberOfDealers = getRuleNumberOfDealers(rule, i);
						system.debug('Found rule name of ' + ruleName + ' with max number of dealers ' + maxNumberOfDealers);
						
						list<DealerRoutingAssignedDealer> dealersToRouteTo = null;
						if (DealerRoutingConstants.zipAndProductRuleName == ruleName) {
							dealersToRouteTo = getRouteToDealersByZipAndProduct(model, maxNumberOfDealers);	
						}
						else if (DealerRoutingConstants.zipOnlyRuleName == ruleName) {
							dealersToRouteTo = getRouteToDealersByZip(model, maxNumberOfDealers);	
						}
						else if (DealerRoutingConstants.latLonRuleName == ruleName) {
							dealersToRouteTo = getRouteToDealersByLatLon(model, maxNumberOfDealers);	
						}
						else if (DealerRoutingConstants.stateRuleName == ruleName) {
							dealersToRouteTo = getRouteToDealersByStateAndProduct(model, maxNumberOfDealers);	
						}
						else if (DealerRoutingConstants.countryWithProductRuleName == ruleName) {
							dealersToRouteTo = getRouteToDealersByCountryAndProduct(model, maxNumberOfDealers);
						}
						else if (DealerRoutingConstants.countryWithoutProductRuleName == ruleName) {
							dealersToRouteTo = getRouteToDealersByCountry(model, maxNumberOfDealers);
						}
						else if (DealerRoutingConstants.regionalOfficeRuleName == ruleName) {
							dealersToRouteTo = getRouteToDealersByRegionalOffice(model, maxNumberOfDealers);
						}
						else if (DealerRoutingConstants.countyWithCountryWithProductRuleName == ruleName) {
							dealersToRouteTo = getRouteToDealersByCountyAndStateAndCountryAndProduct(model, maxNumberOfDealers);
						}
						else if (DealerRoutingConstants.countyWithCountryRuleName == ruleName) {
							dealersToRouteTo = getRouteToDealersByCountyAndStateAndCountry(model, maxNumberOfDealers);
						}
						else if (DealerRoutingConstants.canadianTerritoriesRuleName == ruleName) {
							dealersToRouteTo = getRouteToCanadianTerritories(model, maxNumberOfDealers);
						}
						else {
							system.debug('Unknown rule type of ' + ruleName);
						}
						
						if (dealersToRouteTo != null && !dealersToRouteTo.isEmpty()) {
							for (DealerRoutingAssignedDealer ad : dealersToRouteTo) {
								system.debug('Will route to dealer ' + ad.Id + ' - ' + ad.DealerNumber);
							}
							assignedDealers = assignDealers(obj, model, dealersToRouteTo, oldAssignedDealers);
							system.debug('Dealers have been assigned to object = ' + model.HasBeenAssigned);
						}
						else {
							system.debug('No dealer matches were found for rule ' + ruleName);
						}
					}
					else {
						system.debug('No rule setup for number ' + i);
					}
				}
				
				system.debug('Object has been assigned = ' + model.HasBeenAssigned);
			}
			else {
				system.debug('No routing rule found');
			}
			
			if (!model.HasBeenAssigned) {
				if (hasCustomRoutingExceptions(model)) {
					system.debug('There is a custom routing exception.');
					list<DealerRoutingAssignedDealer> dealersToRouteTo = getRouteToByRoutingException(model); 
					if (dealersToRouteTo != null && dealersToRouteTo.size() > 0) {
						system.debug('Found dealers to assign - ' + dealersToRouteTo);
						assignedDealers = assignDealers(obj, model, dealersToRouteTo, oldAssignedDealers);
						system.debug('Dealers have been assigned to object = ' + model.HasBeenAssigned);
					}
					else {
						system.debug('No dealer matches were found for custom routing exception');
					}
				}	
				
			}
		}
		else {
			system.debug('Object was not converted into a model');
		}
		return assignedDealers;
	}
	
	// Gets a list of dealer Ids that should be routed by zip and product category
	protected list<DealerRoutingAssignedDealer> getRouteToDealersByZipAndProduct(DealerRoutingModel model, integer maxDealersToAssign) {
		system.debug('getRouteToDealersByZipAndProduct');
		
		double latitude = model.Latitude;
	    double longitude = model.Longitude;
		string postalCode = model.PostalCode != null ? String.escapeSingleQuotes(model.PostalCode) : null;
	    string countryISOCode = model.CountryISO;
	    string county = model.County;
	    string state = model.State != null ? String.escapeSingleQuotes(model.State) : null;
	    string brand = model.Brand;
	    string productCategory = model.ProductCategory;
	    
	    boolean hasLatLon = (latitude != null && longitude !=null);
	    boolean hasProductCategory = !String.isBlank(productCategory);
	    boolean postalCodeSearch = !String.isBlank(postalCode) && !String.isBlank(countryISOCode);
	    boolean countryStateCountySearch = (!String.isBlank(countryISOCode) && !String.isBlank(state) && !String.isBlank(county));
	    
	    if ( hasLatLon && hasProductCategory && (postalCodeSearch || countryStateCountySearch)) {
	        string qry = getTerritoryQuerySelect();
	        String zipComparator = getPostalCodeComparator(countryISOCode, postalCode);

	        if (postalCodeSearch && countryStateCountySearch) {
            	qry += ' ((Zipcode_Postal_Code__c '+zipComparator+':postalCode' + ' AND ISO_Code__c = :countryISOCode)';
            	qry += ' OR(Zipcode_Postal_Code__c = \'All\' AND ISO_Code__c =  :countryISOCode AND State_Province__c = :state AND County__c = :county))';
	        }
	        else if (postalCodeSearch) {
	        	qry += '(Zipcode_Postal_Code__c '+zipComparator+':postalCode' + ' AND ISO_Code__c = :countryISOCode)';
	        }
	        else if (countryStateCountySearch) {
	        	qry += '(Zipcode_Postal_Code__c = \'All\' AND ISO_Code__c =  :countryISOCode AND State_Province__c = :state AND County__c = :county)';	
	        }
	        else {
	        	return null;
	        }
            qry += ' AND Dealer_Brand__r.Brand__c = :brand AND Dealer_Brand__r.Status__c = \'Active\'';
            qry += ' AND Boat_Class__c INCLUDES (:productCategory)';
            qry += ' AND Dealer_Brand__r.Dealer__r.GeoLocation__Latitude__s != null';
            qry += ' AND Dealer_Brand__r.Dealer__r.GeoLocation__Longitude__s != null';
            qry += ' AND Dealer_Brand__r.Dealer__r.Dealer_Type__c NOT IN ' + BluewolfDevUtils.flattenListForQuery(new List<String>(EXCLUDED_DEALER_TYPES));
            qry += ' ORDER By DISTANCE(Dealer_Brand__r.Dealer__r.GeoLocation__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\')';
            qry += ' LIMIT 100';
            
            system.debug('getRouteToDealersByZipAndProduct query = ' + qry);    
	        list<Territory__c> territories = Database.query(qry);
	        
	        return getDealersToAssignByTerritory(territories, model, maxDealersToAssign);
        }
        else {
        	system.debug('Missing one or both latitude and longitude so rule will not be executed');
        }
        return null;
	}
	
	// Gets a list of dealer Ids that should be routed to by zip
	protected list<DealerRoutingAssignedDealer> getRouteToDealersByZip(DealerRoutingModel model, integer maxDealersToAssign) {
		system.debug('getRouteToDealersByZip');
		
		double latitude = model.Latitude;
	    double longitude = model.Longitude;
		string postalCode = model.PostalCode != null ? String.escapeSingleQuotes(model.PostalCode) : null;
	    string countryISOCode = model.CountryISO;
	    string county = model.County;
	    string state = model.State != null ? String.escapeSingleQuotes(model.State) : null;
	    string brand = model.Brand;
	    
	    boolean hasLatLon = (latitude != null && longitude !=null);
	    boolean postalCodeSearch = !String.isBlank(postalCode) && !String.isBlank(countryISOCode);
	    boolean countryStateCountySearch = (!String.isBlank(countryISOCode) && !String.isBlank(state) && !String.isBlank(county));
	    
		if ( hasLatLon && (postalCodeSearch || countryStateCountySearch)) {
	        string qry = getTerritoryQuerySelect();
	        String zipComparator = getPostalCodeComparator(countryISOCode, postalCode);

	        if (postalCodeSearch && countryStateCountySearch) {
            	qry += ' ((Zipcode_Postal_Code__c '+zipComparator+':postalCode' + ' AND ISO_Code__c = :countryISOCode)';
            	qry += ' OR(Zipcode_Postal_Code__c = \'All\' AND ISO_Code__c =  :countryISOCode AND State_Province__c = :state AND County__c = :county))';
	        }
	        else if (postalCodeSearch) {
	        	qry += '(Zipcode_Postal_Code__c '+zipComparator+':postalCode' + ' AND ISO_Code__c = :countryISOCode)';
	        }
	        else if (countryStateCountySearch) {
	        	qry += '(Zipcode_Postal_Code__c = \'All\' AND ISO_Code__c =  :countryISOCode AND State_Province__c = :state AND County__c = :county)';	
	        }
	        else {
	        	return null;
	        }
            qry += ' AND Dealer_Brand__r.Brand__c = :brand';
            qry += ' AND Dealer_Brand__r.Dealer__r.GeoLocation__Latitude__s != null';
            qry += ' AND Dealer_Brand__r.Dealer__r.GeoLocation__Longitude__s != null';
            qry += ' AND Dealer_Brand__r.Dealer__r.Dealer_Type__c NOT IN ' + BluewolfDevUtils.flattenListForQuery(new List<String>(EXCLUDED_DEALER_TYPES));
            qry += ' ORDER By DISTANCE(Dealer_Brand__r.Dealer__r.GeoLocation__c, GEOLOCATION(' + latitude + ',' + longitude + '), \'mi\')';
            qry += ' LIMIT 100';
	         
	        system.debug('getRouteToDealersByZip query = ' + qry);    
	        list<Territory__c> territories = Database.query(qry);
	        
	        return getDealersToAssignByTerritory(territories, model, maxDealersToAssign);
		}
		else {
        	system.debug('Missing one or both latitude and longitude and required rule criteria so rule will not be executed');
        }
		return null;
	}
	
	// Gets a list of dealer Ids that should be routed to by lat and lon
	protected list<DealerRoutingAssignedDealer> getRouteToDealersByLatLon(DealerRoutingModel model, integer maxDealersToAssign) {
		system.debug('getRouteToDealersByLatLon');
		
		double latitude = model.Latitude;
	    double longitude = model.Longitude;
		string brand = model.Brand;
		
		if (model.Latitude !=null && model.Longitude !=null) {  
			string qry = getDealerBrandQuerySelect();    
	    	qry += ' Brand__c = :brand AND Status__c = \'Active\'';
            qry += ' AND Dealer__r.GeoLocation__Latitude__s != null';
            qry += ' AND Dealer__r.GeoLocation__Longitude__s != null';
            qry += ' AND Dealer__r.Dealer_Type__c NOT IN ' + BluewolfDevUtils.flattenListForQuery(new List<String>(EXCLUDED_DEALER_TYPES));
            qry += ' ORDER By DISTANCE(Dealer__r.GeoLocation__c, GEOLOCATION(' + latitude + ',' + longitude + '), \'mi\')';
            qry += ' LIMIT 100';
            
            system.debug('getRouteToDealersByLatLon query = ' + qry);    
	        list<Dealer_Brand__c> dealerBrands = Database.query(qry);
	         
	        return getDealersToAssignByDealerBrand(dealerBrands, model, maxDealersToAssign);   
        }
        else {
        	system.debug('Missing one or both latitude and longitude so rule will not be executed');
        }
        return null;
	}
	
	// Gets a list of dealer Ids that should be routed to by state and product category
	protected list<DealerRoutingAssignedDealer> getRouteToDealersByStateAndProduct(DealerRoutingModel model, integer maxDealersToAssign) {
		system.debug('getRouteToDealersByStateAndProduct');
		
		double latitude = model.Latitude;
	    double longitude = model.Longitude;
	    string countryISOCode = model.CountryISO;
	    string state = model.State != null ? String.escapeSingleQuotes(model.State) : null;
	    string brand = model.Brand;
	    string productCategory = model.ProductCategory;
	    
	    boolean hasLatLon = (latitude != null && longitude !=null);
	    boolean hasProductCategory = !String.isBlank(productCategory);
	    boolean hasCountryAndState = !String.isBlank(countryISOCode) && !String.isBlank(state);
	    
	    if ( hasLatLon && hasProductCategory && hasCountryAndState) {
	        string qry = getTerritoryQuerySelect();
	        
	        qry += ' ISO_Code__c = :countryISOCode AND State_Province__c =:state';
            qry += ' AND Dealer_Brand__r.Status__c = \'Active\'';
            qry += ' AND Dealer_Brand__r.Brand__c = :brand';
            qry += ' AND Boat_Class__c INCLUDES (:productCategory)';
            qry += ' AND Dealer_Brand__r.Dealer__r.GeoLocation__Latitude__s != null';
            qry += ' AND Dealer_Brand__r.Dealer__r.GeoLocation__Longitude__s != null';
            qry += ' AND Dealer_Brand__r.Dealer__r.Dealer_Type__c NOT IN ' + BluewolfDevUtils.flattenListForQuery(new List<String>(EXCLUDED_DEALER_TYPES));
            qry += ' ORDER By DISTANCE(Dealer_Brand__r.Dealer__r.GeoLocation__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\')';
            qry += ' LIMIT 100';
            
           	system.debug('getRouteToDealersByStateAndProduct query = ' + qry);    
	        list<Territory__c> territories = Database.query(qry);
	        
	        return getDealersToAssignByTerritory(territories, model, maxDealersToAssign);
        }
        else {
        	system.debug('Missing one or both latitude and longitude and required parameters so rule will not be executed');
        }
        return null;
	}
	
	// Gets a list of dealer Ids that should be routed to by country and product category
	protected list<DealerRoutingAssignedDealer> getRouteToDealersByCountryAndProduct(DealerRoutingModel model, integer maxDealersToAssign) {
		system.debug('getRouteToDealersByCountryAndProduct');
		
		double latitude = model.Latitude;
	    double longitude = model.Longitude;
	    string countryISOCode = model.CountryISO;
	    string brand = model.Brand;
	    string productCategory = model.ProductCategory;
	    
	    boolean hasLatLon = (latitude != null && longitude !=null);
	    boolean hasProductCategory = !String.isBlank(productCategory);
	    boolean hasCountry = !String.isBlank(countryISOCode);
	    
	    if ( hasLatLon && hasProductCategory && hasCountry) {
	        string qry = getTerritoryQuerySelect();
			
            qry += ' ISO_Code__c = :countryISOCode';
            qry += ' AND Dealer_Brand__r.Status__c = \'Active\'';
            qry += ' AND Dealer_Brand__r.Brand__c = :brand';
            qry += ' AND Boat_Class__c INCLUDES (:productCategory)';
            qry += ' AND Dealer_Brand__r.Dealer__r.GeoLocation__Latitude__s != null';
            qry += ' AND Dealer_Brand__r.Dealer__r.GeoLocation__Longitude__s != null';
            qry += ' AND Dealer_Brand__r.Dealer__r.Dealer_Type__c NOT IN ' + BluewolfDevUtils.flattenListForQuery(new List<String>(EXCLUDED_DEALER_TYPES));
            qry += ' ORDER By DISTANCE(Dealer_Brand__r.Dealer__r.GeoLocation__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\')';
            qry += ' LIMIT 100';
            
            system.debug('getRouteToDealersByCountryAndProduct query = ' + qry);    
	        list<Territory__c> territories = Database.query(qry);
	        
	        return getDealersToAssignByTerritory(territories, model, maxDealersToAssign);
        }
        else {
        	system.debug('Missing one or both latitude and longitude and required parameters so rule will not be executed');
        }
        return null;
	}
	
	// Gets a list of dealer Ids that should be routed to by country
	protected list<DealerRoutingAssignedDealer> getRouteToDealersByCountry(DealerRoutingModel model, integer maxDealersToAssign) {
		system.debug('getRouteToDealersByCountry');
		
		double latitude = model.Latitude;
	    double longitude = model.Longitude;
	    string countryISOCode = model.CountryISO;
	    string brand = model.Brand;
	    
	    boolean hasLatLon = (latitude != null && longitude !=null);
	    boolean hasCountry = !String.isBlank(countryISOCode);
	    
	    if ( hasLatLon && hasCountry) {
	        string qry = getDealerBrandQuerySelect();
			qry += ' Dealer__r.Country_ISO_Code__c = :countryISOCode';
            qry += ' AND Brand__c = :brand AND Status__c = \'Active\'';
            qry += ' AND Dealer__r.GeoLocation__Latitude__s != null';
            qry += ' AND Dealer__r.GeoLocation__Longitude__s != null';
            qry += ' AND Dealer__r.Dealer_Type__c NOT IN ' + BluewolfDevUtils.flattenListForQuery(new List<String>(EXCLUDED_DEALER_TYPES));
            qry += ' ORDER By DISTANCE(Dealer__r.GeoLocation__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\')';
            qry += ' LIMIT 100';
            
            system.debug('getRouteToDealersByCountry query = ' + qry);    
	        list<Dealer_Brand__c> dealerBrands = Database.query(qry);
	         
	        return getDealersToAssignByDealerBrand(dealerBrands, model, maxDealersToAssign);   
        }
        else {
        	system.debug('Missing one or both latitude and longitude so rule will not be executed');
        }
        return null;
	}
	
	// Returns a list of dealer Ids that should be routed by regional office
	protected list<DealerRoutingAssignedDealer> getRouteToDealersByRegionalOffice(DealerRoutingModel model, integer maxDealersToAssign) {
		 // to do: determine how Regional Offices will be designated in SFDC.
        system.debug('getRouteToDealersByRegionalOffice');
        
        double latitude = model.Latitude;
	    double longitude = model.Longitude;
	    string countryISOCode = model.CountryISO;
	    string brand = model.Brand;
	    
	    boolean hasLatLon = (latitude != null && longitude !=null);
	    boolean hasCountry = !String.isBlank(countryISOCode);
	    
	    if ( hasLatLon && hasCountry) {
	        string qry = getTerritoryQuerySelect();
			qry += ' Regional_Office_Country__c = :countryISOCode';
            qry += ' AND Dealer_Brand__r.Brand__c = :brand AND Dealer_Brand__r.Status__c = \'Active\'';
            qry += ' AND Dealer_Brand__r.Dealer__r.GeoLocation__Latitude__s != null';
            qry += ' AND Dealer_Brand__r.Dealer__r.GeoLocation__Longitude__s != null';
            qry += ' ORDER By DISTANCE(Dealer_Brand__r.Dealer__r.GeoLocation__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\')';
            qry += ' LIMIT 100';
            
            system.debug('getRouteToDealersByRegionalOffice query = ' + qry);    
	        list<Territory__c> territories = Database.query(qry);
	        
	        return getDealersToAssignByTerritory(territories, model, maxDealersToAssign);
            
        }
        else {
        	system.debug('Missing one or both latitude and longitude so rule will not be executed');
        }
        return null;
	}
	
	// Returns a list of dealer Ids that should be routed by county and country
	protected list<DealerRoutingAssignedDealer> getRouteToDealersByCountyAndStateAndCountry(DealerRoutingModel model, integer maxDealersToAssign) {
		system.debug('getRouteToDealersByCountyAndStateAndCountry');
		
		double latitude = model.Latitude;
	    double longitude = model.Longitude;
	    string countryISOCode = model.CountryISO;
	    string county = model.County;
	    string brand = model.Brand;
	    string state = model.State != null ? String.escapeSingleQuotes(model.State) : null;
	    
	    boolean hasLatLon = (latitude != null && longitude !=null);
	    boolean hasCountryAndStateAndCounty = !String.isBlank(countryISOCode) && !String.isBlank(state) && !String.isBlank(county);
	    
		if ( hasLatLon && hasCountryAndStateAndCounty) {
	        string qry = getTerritoryQuerySelect();
		
			qry += ' ISO_Code__c = :countryISOCode';
	        qry += ' AND County__c = :county';
	        qry += ' AND State_Province__c = :state';
	        qry += ' AND Dealer_Brand__r.Status__c = \'Active\'';
	        qry += ' AND Dealer_Brand__r.Brand__c = :brand';
	        qry += ' AND Dealer_Brand__r.Dealer__r.GeoLocation__Latitude__s != null';
	        qry += ' AND Dealer_Brand__r.Dealer__r.GeoLocation__Longitude__s != null';
	        qry += ' AND Dealer_Brand__r.Dealer__r.Dealer_Type__c != \'Regional Office\'';
	        qry += ' AND Dealer_Brand__r.Dealer__r.Dealer_Type__c NOT IN ' + BluewolfDevUtils.flattenListForQuery(new List<String>(EXCLUDED_DEALER_TYPES));
	       	qry += ' ORDER By DISTANCE(Dealer_Brand__r.Dealer__r.GeoLocation__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\')';
	        qry += ' LIMIT 100';
	        
	       	system.debug('getRouteToDealersByCountyAndStateAndCountry query = ' + qry);    
	        list<Territory__c> territories = Database.query(qry);
	        
	        return getDealersToAssignByTerritory(territories, model, maxDealersToAssign);
      	}
      	else {
        	system.debug('Missing one or both latitude and longitude so rule will not be executed');
        }
      	return null;
	}
	
	// Returns a list of dealer Ids that should be routed by county and country and product category
	protected list<DealerRoutingAssignedDealer> getRouteToDealersByCountyAndStateAndCountryAndProduct(DealerRoutingModel model, integer maxDealersToAssign) {
		system.debug('getRouteToDealersByCountyAndCountryAndProduct');
		
		double latitude = model.Latitude;
	    double longitude = model.Longitude;
	    string countryISOCode = model.CountryISO;
	    string county = model.County;
	    string brand = model.Brand;
	    string productCategory = model.ProductCategory;
	    string state = model.State != null ? String.escapeSingleQuotes(model.State) : null;
	    
	    boolean hasLatLon = (latitude != null && longitude !=null);
	    boolean hasCountryAndStateAndCountyAndProduct = !String.isBlank(countryISOCode) && !String.isBlank(state) && !String.isBlank(county) && !String.isBlank(productCategory);
	    
		if ( hasLatLon && hasCountryAndStateAndCountyAndProduct) {
	        string qry = getTerritoryQuerySelect();
			qry += ' ISO_Code__c = :countryISOCode';
	        qry += ' AND County__c = :county';
	        qry += ' AND State_Province__c = :state';
	        qry += ' AND Dealer_Brand__r.Status__c = \'Active\'';
	        qry += ' AND Dealer_Brand__r.Brand__c = :brand';
	        qry += ' AND Boat_Class__c INCLUDES (:productCategory)';
	        qry += ' AND Dealer_Brand__r.Dealer__r.GeoLocation__Latitude__s != null';
	        qry += ' AND Dealer_Brand__r.Dealer__r.GeoLocation__Longitude__s != null';
	        qry += ' AND Dealer_Brand__r.Dealer__r.Dealer_Type__c != \'Regional Office\'';
	       	qry += ' ORDER By DISTANCE(Dealer_Brand__r.Dealer__r.GeoLocation__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\')';
	        qry += ' LIMIT 100';
	        
	       	system.debug('getRouteToDealersByCountyAndCountryAndProduct query = ' + qry);    
	        list<Territory__c> territories = Database.query(qry);
	        
	        return getDealersToAssignByTerritory(territories, model, maxDealersToAssign);
      	}
      	else {
        	system.debug('Missing one or both latitude and longitude so rule will not be executed');
        }
      	return null;
	}
	
	protected list<DealerRoutingAssignedDealer> getRouteToCanadianTerritories(DealerRoutingModel model, integer maxDealersToAssign) {
		system.debug('getRouteToCanadianTerritories');
		
		double latitude = model.Latitude;
	    double longitude = model.Longitude;
	    string countryISOCode = model.CountryISO;
	    string county = model.County;
	    string brand = model.Brand;
	    string productCategory = model.ProductCategory;
	    
	    boolean hasLatLon = (latitude != null && longitude !=null);
	    boolean hasCountryAndCounty = !String.isBlank(countryISOCode) && !String.isBlank(county);
	    boolean isCanadianCountry = !String.isBlank(countryISOCode) && countryISOCode == 'CA';
	    
		if ( hasLatLon && hasCountryAndCounty && isCanadianCountry) {
	        string qry = getTerritoryQuerySelect();
			qry += ' ISO_Code__c = :countryISOCode';
	        qry += ' AND County__c = :county';
	        qry += ' AND Dealer_Brand__r.Status__c = \'Active\'';
	        qry += ' AND Dealer_Brand__r.Brand__c = :brand';
	        qry += ' AND Dealer_Brand__r.Dealer__r.GeoLocation__Latitude__s != null';
	        qry += ' AND Dealer_Brand__r.Dealer__r.GeoLocation__Longitude__s != null';
	        qry += ' AND Dealer_Brand__r.Dealer__r.Dealer_Type__c != \'Regional Office\'';
			qry += ' AND Dealer_Brand__r.Dealer__r.Dealer_Type__c NOT IN ' + BluewolfDevUtils.flattenListForQuery(new List<String>(EXCLUDED_DEALER_TYPES));
	       	qry += ' ORDER By DISTANCE(Dealer_Brand__r.Dealer__r.GeoLocation__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\')';
	        qry += ' LIMIT 100';
	        
	       	system.debug('getRouteToDealersByCountyAndCountry query = ' + qry);    
	        list<Territory__c> territories = Database.query(qry);
	        
	        return getDealersToAssignByTerritory(territories, model, maxDealersToAssign);
      	}
      	else {
        	system.debug('Missing one or both latitude and longitude so rule will not be executed');
        }
      	return null;	
	}
	
	
	public void sendToFootSteps(Set<Id> idsToSendToFootsteps) {
		if (!DealerRouter.doNotSendEmail) {
            system.debug('doNotSendEmail = false so dealer routing emails will be sent');
			Dealer_Routing_Test_Mode__c testMode = getDealerRoutingTestMode();
			if (testMode != null && testMode.Test_Mode__c) {
				if (testMode.Process_Footsteps__c) {
					sendToFootStepsInternal(idsToSendToFootsteps);
				}
				else {
					system.debug('Not processing footsteps');
				}
			}
			else {
				sendToFootStepsInternal(idsToSendToFootsteps);
			}
		}
	}
	
	public void sendToFootsteps(map<Id, set<Id>> objectIdToDealerIdMap) {
		if (!DealerRouter.doNotSendEmail && !objectIdToDealerIdMap.isEmpty()) {
			Dealer_Routing_Test_Mode__c testMode = getDealerRoutingTestMode();
			if (testMode != null && testMode.Test_Mode__c) {
				if (testMode.Process_Footsteps__c) {
					sendToFootStepsInternal(objectIdToDealerIdMap);
				}
				else {
					system.debug('Not processing footsteps');
				}
			}
			else {
				sendToFootStepsInternal(objectIdToDealerIdMap);
			}	
		}
	}
	
	protected virtual void sendToFootStepsInternal(Set<Id> idsToSendToFootsteps){
	}
	
	protected virtual void sendToFootstepsInternal(map<Id, set<Id>> objectIdToDealerIdMap) {
	}
	
	protected string getPostalCodeComparator(string countryISOCode, string postalCode) {
		string postalCodeComparator = '=';
        if (countryISOCode == 'CA') {
        	if (!String.isBlank(postalCode)) {
        		postalCode = postalCode.subString(0,3);
            	system.debug('CA Postal Code = '+postalCode);
        	}
            postalCodeComparator = 'LIKE';
        }
        return postalCodeComparator;
	}
	
	protected string getTerritoryQuerySelect() {
		string emailFieldString = '';
	        
        for (string em: getEmailFields()) {
            emailFieldString+=',Dealer_Brand__r.'+em;
        }
		string qry = 'SELECT Id'+emailFieldString+',Dealer_Brand__r.Dealer_Number__c, Dealer_Brand__r.Dealer__c,Dealer_Brand__r.Dealer__r.GeoLocation__Latitude__s,Dealer_Brand__r.Dealer__r.GeoLocation__Longitude__s';
	    qry += ' FROM Territory__c';
	    qry += ' WHERE';
        return qry;
	}
	
	protected string getDealerBrandQuerySelect() {
		string emailFieldString = string.join(getEmailFields(),',');
            
        string qry = 'SELECT Id,'+emailFieldString+',Dealer_Number__c,Dealer__c,Dealer__r.GeoLocation__Latitude__s,Dealer__r.GeoLocation__Longitude__s';
        qry += ' FROM Dealer_Brand__c WHERE ';
        return qry;
	}
	
	// Returns of list of dealer Ids to assign by territory
	protected list<DealerRoutingAssignedDealer> getDealersToAssignByTerritory(list<Territory__c> territories, DealerRoutingModel model, integer maxDealersToAssign) {
    	list<DealerRoutingAssignedDealer> dealers = new list<DealerRoutingAssignedDealer>();
    	
    	if (territories != null && territories.size() > 0) {
	    	set<Id> dealerIdsUsed = new set<Id>();
	    	
	    	integer i = 1;
	        for (Territory__c territory : territories) {
	        	if (i <= maxDealersToAssign && 
	        		territory.Dealer_Brand__r.Dealer__r.GeoLocation__Latitude__s != null && 
	        		territory.Dealer_Brand__r.Dealer__r.GeoLocation__Longitude__s != null) {
	            	if (!dealerIdsUsed.contains(territory.Dealer_Brand__r.Dealer__c)) {
	                	system.debug('Territory returned: ' + territory);
	                   	system.debug('Territories Dealers'+ territory.Dealer_Brand__r.Dealer__c);
	                    dealers.add(createDealerRoutingAssignedDealer(model, territory.Dealer_Brand__r));
	                    dealerIdsUsed.add(territory.Dealer_Brand__r.Dealer__c);
	                    i++;
	               	}
	            }
	        }
    	}
    	else {
    		system.debug('There are no territories, so no dealers could be found');
    	}
    	
    	system.debug('Found dealers from territory - ' + dealers);
        
	   	return dealers;
	}
	
	// Returns of list of dealer Ids to assign by dealer brand
	protected list<DealerRoutingAssignedDealer> getDealersToAssignByDealerBrand(list<Dealer_Brand__c> dealerBrands, DealerRoutingModel model, integer maxDealersToAssign) {
    	list<DealerRoutingAssignedDealer> dealers = new list<DealerRoutingAssignedDealer>();
    	
    	if (dealerBrands != null && dealerBrands.size() > 0) {
    		set<Id> dealerIdsUsed = new set<Id>();
    	
	    	integer i = 1;
	    	for (Dealer_Brand__c dealerBrand : dealerBrands) {
		    	if (i <= maxDealersToAssign && 
		    		dealerBrand.Dealer__r.GeoLocation__Latitude__s != null && 
		    		dealerBrand.Dealer__r.GeoLocation__Longitude__s != null) {
		    		if (!dealerIdsUsed.contains(dealerBrand.Dealer__c)) {
	               		system.debug('Account returned: ' + dealerBrand);
		                system.debug('Dealer'+ dealerBrand.Dealer__c);
	                    dealers.add(createDealerRoutingAssignedDealer(model, dealerBrand));
	                    dealerIdsUsed.add(dealerBrand.Dealer__c);
	                    i++;
	               	}
		    	}
	    	}
    	}
    	else {
    		system.debug('There are no dealer brands, so no dealers could be found');
    	}
    	
    	system.debug('Found dealers from dealer brand - ' + dealers);
	    
	   	return dealers;
	}
	
	// Returns the max number of routing rules
	protected virtual integer getMaxRoutingRules() {
		return MAX_ROUTING_RULES;
	}
	
	// Returns the email fields
	protected virtual string[] getEmailFields() {
		return EMAIL_FIELDS;
	}
	
	// Returns the rule name for the given rule and rule number
	protected virtual string getRuleName(sobject rule, integer ruleNumber) {
		return null;
	}
	
	// Returns the rule number of dealers
	protected virtual integer getRuleNumberOfDealers(sobject rule, integer ruleNumber) {
		return 0;
	}
	
	// Converts an object into a model
	protected virtual DealerRoutingModel convertToModel(sobject obj) {
		return null;
	}
	
	protected virtual list<Assigned_Dealer__c> getExistingAssignedDealers(sobject obj) {
		list<Assigned_Dealer__c> existingAssignedDealers = new list<Assigned_Dealer__c>();
		
		list<Assigned_Dealer__c> assignedDealers = null;
		
		try {
			assignedDealers = (list<Assigned_Dealer__c>)obj.get('Assigned_Dealers__r');
		}
		catch(Exception exp) {
		}
		if (assignedDealers != null) {
			for (Assigned_Dealer__c ad : assignedDealers) {
				existingAssignedDealers.add(ad);
			}
		}
		
		return existingAssignedDealers;
	}
	 
	// Clears the existing assigned dealer fields of the object represented by the model
	protected virtual void clearExistingAssignedDealers(sobject obj, DealerRoutingModel model) {
        system.debug('clearExistingAssignedDealers - ' + model.Id);
        
        for(integer i=1;i<11;i++){
            obj.put('Assigned_Dealer_'+i+'__c',null);
        }
	}
	
	// Returns the rule for the given model
	protected virtual sobject getDealerRoutingRule(DealerRoutingModel model) {
		return null;
	}
	
	protected Dealer_Routing_Test_Mode__c getDealerRoutingTestMode() {
		return dealerRoutingTestModes.get(getRoutingType());
	}
	
	protected virtual DealerRoutingAssignedDealer createDealerRoutingAssignedDealer(DealerRoutingModel model, Dealer_Brand__c dealerBrand) {
		DealerRoutingAssignedDealer assignedDealer = new DealerRoutingAssignedDealer(model, dealerBrand);
		
		Dealer_Routing_Test_Mode__c testMode = getDealerRoutingTestMode();
		if (testMode != null && testMode.Test_Mode__c) {
			assignedDealer.CRMEmail = testMode.Test_CRM_Email__c;
			assignedDealer.PrimaryEmail = testMode.Test_Primary_Email__c;
			assignedDealer.SecondaryEmail1 = testMode.Test_Secondary_Email1__c;	
			assignedDealer.SecondaryEmail2 = testMode.Test_Secondary_Email2__c;
			assignedDealer.SecondaryEmail3 = testMode.Test_Secondary_Email3__c;
			assignedDealer.SecondaryEmail4 = testMode.Test_Secondary_Email4__c;
			assignedDealer.SecondaryEmail5 = testMode.Test_Secondary_Email5__c;
		}
		return assignedDealer;
	}
	
	protected virtual set<Id> getDealerIdsThatAreSendable(list<Assigned_Dealer__c> assignedDealers) {
		set<Id> dealerIds = new set<Id>();
		
		for (Assigned_Dealer__c ad : assignedDealers) {
			if (ad.Is_Sendable__c) {
				dealerIds.add(ad.Dealer__c);
			}
		}
		
		return dealerIds;
	}
	
	protected virtual Assigned_Dealer__c createAssignedDealer(sobject obj, DealerRoutingModel model, DealerRoutingAssignedDealer dealer, list<Assigned_Dealer__c> oldAssignedDealers) {
		Assigned_Dealer__c a = new Assigned_Dealer__c();
        a.Dealer__c = dealer.Id;
        a.Subject_Line__c = model.LeadSource + ' : ' + model.LeadFormName;
        
        //Added for BS-123
        a.put('Pardot_Score__c', model.PardotScore);
        a.put('CRM_Email__c', dealer.CRMEmail);
        a.put('Primary_Email__c', dealer.PrimaryEmail);
        a.put('Secondary_Email_1__c', dealer.SecondaryEmail1);
        a.put('Secondary_Email_2__c', dealer.SecondaryEmail2);
        a.put('Secondary_Email_3__c', dealer.SecondaryEmail3);
        a.put('Secondary_Email_4__c', dealer.SecondaryEmail4);
        a.put('Secondary_Email_5__c', dealer.SecondaryEmail5);
        
        // If we already assigned to this dealer before then we dont want to email them, unless the score has changed enough
        Assigned_Dealer__c ad = getMostRecentAssignedDealer(dealer, oldAssignedDealers);
        if (ad != null && !scoreHasChangedEnoughToRequireRouting(model, ad)) {
        	system.debug('Found a prior assigned dealer where the score has not changed enough, so emails will not be sent');
        	a.Is_Sendable__c = false;
        }
        else {
        	a.Is_Sendable__c = isSendable(obj);
        }
        
        return a;
	}
	
	private list<sobject> filterSendableObjects(list<sobject> objects) {
		list<sobject> sendableObjects = new list<sobject>();
		
		for (sobject obj : objects) {
			if (isSendable(obj)) {
				sendableObjects.add(obj);
			}
		}
		
		return sendableObjects;
	}
	
    protected virtual boolean scoreHasChangedEnoughToRequireRouting(DealerRoutingModel model, Assigned_Dealer__c assignedDealer) {
    	double oldScore = (assignedDealer.Pardot_Score__c == null) ? 0 : assignedDealer.Pardot_Score__c;
    	double newScore = (model.PardotScore == null) ? 0 : model.PardotScore;
        decimal scoreDiff = newScore - oldScore;
        return (scoreDiff >= SCORE_THRESHOLD);
    }
	
	protected virtual Assigned_Dealer__c getMostRecentAssignedDealer(DealerRoutingAssignedDealer dealer, list<Assigned_Dealer__c> oldAssignedDealers) {
		if (!oldAssignedDealers.isEmpty()) {
			for (Assigned_Dealer__c ad : oldAssignedDealers) {
				if (ad.Dealer__c == dealer.Id) {
					return ad;
				}
			}	
		}
		return null;
	}
	
	// Assigns the list of dealers to the object
	protected virtual list<Assigned_Dealer__c> getAssignedDealers(sobject obj, DealerRoutingModel model, list<DealerRoutingAssignedDealer> dealersToRouteTo, list<Assigned_Dealer__c> oldAssignedDealers) {
		system.debug('getAssignedDealers - ' + obj.Id);
		
		list<Assigned_Dealer__c> assignedDealers = new list<Assigned_Dealer__c>();
		if (dealersToRouteTo != null && dealersToRouteTo.size() > 0) {
			for (integer i=1; i<=dealersToRouteTo.size(); i++) {
				DealerRoutingAssignedDealer dealer = dealersToRouteTo.get(i-1);
				obj.put('Assigned_Dealer_' + i + '__c', dealer.Id);
				
				Assigned_Dealer__c a = createAssignedDealer(obj, model, dealer, oldAssignedDealers);
                assignedDealers.add(a);
			}
		}
       	
       	return assignedDealers;
	}
	
	protected virtual list<Assigned_Dealer__c> assignDealers(sobject obj, DealerRoutingModel model, list<DealerRoutingAssignedDealer> dealersToRouteTo, list<Assigned_Dealer__c> oldAssignedDealers) {
		list<Assigned_Dealer__c> assignedDealers = getAssignedDealers(obj, model, dealersToRouteTo, oldAssignedDealers);
		if (!assignedDealers.isEmpty()) {
			system.debug('Inserting ' + assignedDealers.size() + ' assigned dealers');
			insert assignedDealers;
		}
		else {
			system.debug('No assigned dealers');	
		}
		model.HasBeenAssigned = !assignedDealers.isEmpty();
		return assignedDealers;
	}
	
	protected virtual void emailObjectsToDealerCRMSystem(list<sobject> objects) {
    	list<sobject> objectsToEmail = new list<sobject>();
    	
    	for (sobject obj : objects) {
    		string brandCode = getObjectBrand(obj);
    		if (brandCode == 'BL' ||
    			brandCode == 'TR' ||
    			brandCode == 'MX') {
    			objectsToEmail.add(obj);	
    		}
    	}	
    	
    	if (objectsToEmail.size() > 0) {
    		system.debug('objectsToEmail = ' + objectsToEmail);
    		routeObjectToMarineMaxDealer(objectsToEmail);
    	}
    	else {
    		system.debug('No objects will be emailed to marine max dealers');
    	}
    }
    
    protected virtual void routeObjectToMarineMaxDealer(list<sobject> objectRecords){
        set<Id> assignedDealerIds = new set<Id>();
        
        for (sobject obj : objectRecords) {
            if (obj.get('Assigned_Dealer_1__c') != null) {
                assignedDealerIds.add((Id)obj.get('Assigned_Dealer_1__c'));
            }
            if (obj.get('Assigned_Dealer_2__c') != null) {
                assignedDealerIds.add((Id)obj.get('Assigned_Dealer_2__c'));
            }
            if (obj.get('Assigned_Dealer_3__c') != null) {
                assignedDealerIds.add((Id)obj.get('Assigned_Dealer_3__c'));  
            }         
        }
        
        map<Id, Account> idToDealerMap = getDetailsForAssignedDealer(assignedDealerIds);
        for (sobject obj : objectRecords){      
            for (Account dealer : idToDealerMap.values()) {
            	boolean emailSent = isMarineMaxDealerEmailSent(obj);
                if (!emailSent) {             
                    String result = getXml(dealer, obj);             
                    
                    Messaging.Emailfileattachment attachment = new Messaging.Emailfileattachment();
                    attachment.setContentType('application/xml');
                    attachment.setFileName(getMarineMaxDealerFilename(obj));
                    attachment.setBody(Blob.valueOf(result));                        
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailmessage();
                    mail.setToAddresses(new String[] {dealer.CRM_System_Email__c});            
                    mail.setPlainTextBody(getMarineMaxDealerPlainTextBody(obj));
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});     
                }           
            }            
        }       
    }
    
    protected virtual map<Id, Account> getDetailsForAssignedDealer(set<Id> assignedDealerId) {
        return new map<Id,Account>([select 
                                    Id,                   
                                    CRM_System_Email__c
                                    from Account
                                    where Id IN :assignedDealerId
                                    and CRM_System__c ='Microsoft Dynamics']);
    }
    
    protected string getValue(String fieldValue) {
        String newValue;
        if(String.isBlank(fieldValue)) {
            newValue = '';
        }
        else {
            newValue = fieldValue;
        }
        return newValue;
    }
    
    public static Set<String> EXCLUDED_DEALER_TYPES {
        get {
            if( EXCLUDED_DEALER_TYPES == null ) {
           		EXCLUDED_DEALER_TYPES = new Set<String>();
           		
           		if(Test.isRunningTest()) {
           			Map<String, Dealer_Types_to_Exclude_from_Locator__c> excludeDealerTypesCS = new Map<String, Dealer_Types_to_Exclude_from_Locator__c>();
           			Dealer_Types_to_Exclude_from_Locator__c dealerTypeExclusion = new Dealer_Types_to_Exclude_from_Locator__c(Name = 'Regional Office', Dealer_Type__c = 'Regional Office');
           			EXCLUDED_DEALER_TYPES.add(dealerTypeExclusion.Dealer_Type__c);
           		} else {
	           		Map<String, Dealer_Types_to_Exclude_from_Locator__c> excludeDealerTypesCS = Dealer_Types_to_Exclude_from_Locator__c.getAll();
					for (Dealer_Types_to_Exclude_from_Locator__c cs : excludeDealerTypesCS.values()) { 
						EXCLUDED_DEALER_TYPES.add(cs.Dealer_Type__c);
					}
           		}
            }
            
            return EXCLUDED_DEALER_TYPES;
        }
        private set;
    }
    
    protected virtual string getXml(Account dealer, sobject obj) {
    	return '';
    }
    
    protected virtual boolean isMarineMaxDealerEmailSent(sobject obj) {
    	return false;
    }
    
    protected virtual string getMarineMaxDealerFilename(sobject obj) {
    	return null;
    }
    
    protected virtual string getMarineMaxDealerPlainTextBody(sobject obj) {
    	return null;
    }
    
    protected virtual string getObjectBrand(sobject obj) {
    	return null;
    }
	
	// Checks if there are custom routing exceptions
	protected virtual boolean hasCustomRoutingExceptions(DealerRoutingModel model) {
		return false;
	}
	
	// Gets a list of Dealer Ids for a custom routing exception
	protected virtual list<DealerRoutingAssignedDealer> getRouteToByRoutingException(DealerRoutingModel model) {
		return null;
	}
	
	// Should email be sent as part of dealer assignment
	protected virtual boolean isSendable(sobject obj) {
		return !doNotSendEmail;	
	}
	
	protected virtual string getRoutingType() {
		return '';
	}
	
	
	private boolean isDifferent(string oldValue, string newValue) {
		if (oldValue != null) {
			return !oldValue.equals(newValue);
		}
		else if (newValue != null) {
			return !newValue.equals(oldValue);
		}
		return false;
	}
}