/*
Developer   : Daniel Hughes
Company     : Bluewolf LLC
Date : 10/01/2012 
*/
public with sharing class TerritoryServices
{
	public static boolean disableTriggerProcessing = false;
    public static Set<String> EXCLUDED_DEALER_TYPES
    {
        get
        {
            if( EXCLUDED_DEALER_TYPES == null )
            {
           		EXCLUDED_DEALER_TYPES = new Set<String>();
           		
           		 Map<String, Dealer_Types_to_Exclude_from_Locator__c> excludeDealerTypesCS = Dealer_Types_to_Exclude_from_Locator__c.getAll();
				for (Dealer_Types_to_Exclude_from_Locator__c cs : excludeDealerTypesCS.values()){
					EXCLUDED_DEALER_TYPES.add(cs.Dealer_Type__c);
				}
            }
            
            return EXCLUDED_DEALER_TYPES;
        }
        private set;
    }
    
    final static String CLASSNAME = '\n\n**** TerritoryServices.METHODNAME()';
     
    public class MatchedDealers{
        public Id DealerOneId{
            get;
            private set;
        }
        public Id DealerTwoId{
            get;
            private set;
        }
        public Id DealerThreeId{
            get;
            private set;
        }
         
        public MatchedDealers(Id firstMatch, Id secondMatch, Id thirdMatch){
            DealerOneId = firstMatch;
            DealerTwoId = secondMatch;
            DealerThreeId = thirdMatch;
        }
    }

    public static MatchedDealers findByDistance(decimal longitude, decimal latitude, String brand, String countryCode)
    {
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'findByDistance');
        system.debug(LoggingLevel.DEBUG, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');
        MatchedDealers md;
        Boolean found = false;
		Integer dealersLimit = 3;
		
        // Dealer > DealerBrand > Territory
        list<Territory__c> territoryList;
       //list<Account> internationalDealers;
      map<Id,Account> internationalDealers = new map<Id,Account>();
      list<FilteredDealer> dealers = new list<FilteredDealer>();
      set<Id> uniqueDealers = new set<Id>();
      Integer counter = 0;
        // have to find the closest dealer
        // start with a radius of 1 mile, incrementing by 1 up to 5 miles...
        // then incrementing by 5 up to 50 miles...
        // then incrementing by 10 up to 100 miles...
        // then incrementing by 50 above 100 miles
        for(Integer iLoop=1;iLoop<=5;iLoop++){
           // territoryList = TerritoryServices.findTerritories(Decimal.valueof(iLoop), longitude, latitude, brand, countryCode);
           internationalDealers.putAll(GetDealerList(Decimal.valueof(iLoop), longitude, latitude, countryCode, brand));
         system.debug('internationalDealers = '+internationalDealers.size());  
                       
            for(Id rec : internationalDealers.keySet()){
              system.debug('rec = '+rec);
               addDealers(rec, dealers, uniqueDealers, ++counter);
               /*if(!uniqueDealers.contains(rec)) {
                 uniqueDealers.add(rec);
                 dealers.add(new FilteredDealer(rec, ++counter));
               }*/             
            }  
           
        }
        if(dealers.size() < dealersLimit){
            for(Integer jLoop=5;jLoop<=50;jLoop+=5){
              //  territoryList = TerritoryServices.findTerritories(Decimal.valueof(jLoop), longitude, latitude, brand, countryCode);
                internationalDealers.putAll(GetDealerList(Decimal.valueof(jLoop), longitude, latitude, countryCode, brand));
           system.debug('2. internationalDealers = '+internationalDealers.size());
                         
              for(Id rec : internationalDealers.keySet()){
                system.debug('rec = '+rec); 
                addDealers(rec, dealers, uniqueDealers, ++counter);
                /*if(!uniqueDealers.contains(rec)) {
                 uniqueDealers.add(rec);
                 dealers.add(new FilteredDealer(rec, ++counter));
               }*/
                             
              }            
            }
        }
        if(dealers.size() < dealersLimit){
            for(Integer kLoop=50;kLoop<=100;kLoop+=10){
               // territoryList = TerritoryServices.findTerritories(Decimal.valueof(kLoop), longitude, latitude, brand, countryCode);
                 internationalDealers = GetDealerList(Decimal.valueof(kLoop), longitude, latitude, countryCode, brand);
             for(Id rec : internationalDealers.keySet()){
              system.debug('rec = '+rec);
               addDealers(rec, dealers, uniqueDealers, ++counter);
               /*if(!uniqueDealers.contains(rec)) {
                 uniqueDealers.add(rec);
                 dealers.add(new FilteredDealer(rec, ++counter));
               }*/             
             } 
            }
        }
        if(dealers.size() < dealersLimit){
            for(Integer mLoop=100;mLoop<=1000;mLoop+=50){
              //  territoryList = TerritoryServices.findTerritories(Decimal.valueof(mLoop), longitude, latitude, brand, countryCode);
                 internationalDealers = GetDealerList(Decimal.valueof(mLoop), longitude, latitude, countryCode, brand);
                for(Id rec : internationalDealers.keySet()){
              system.debug('rec = '+rec);
               addDealers(rec, dealers, uniqueDealers, ++counter);
               /*if(!uniqueDealers.contains(rec)) {
                 uniqueDealers.add(rec);
                 dealers.add(new FilteredDealer(rec, ++counter));
               }*/             
              } 
                
            }
        } 
        
        if(dealers.size() != 0) {
            system.debug('intDealers ='+dealers);
            system.debug('intDealers ='+dealers);
            Id Dealer1Id = null;
            Id Dealer2Id = null; 
            Id Dealer3Id = null;
            
            dealers.sort(); //sorts on FilteredDealer.index
             system.debug('records ='+dealers.get(0).Id);
            Dealer1Id = dealers.get(0).Id;
            if(dealers.size() > = 2)
               Dealer2Id = dealers.get(1).Id;
            if(dealers.size() > = 3)
              Dealer3Id = dealers.get(2).Id;
                        
            md = new MatchedDealers(Dealer1Id, Dealer2Id, Dealer3Id);
        }
         system.debug('md ='+md);
        return md;
    } 
    
    private static void addDealers(Id rec, list<FilteredDealer> dealers, set<Id> uniqueDealers, Integer counter) {
    	if(!uniqueDealers.contains(rec)) {
                 uniqueDealers.add(rec);
                 dealers.add(new FilteredDealer(rec, counter));
               }  
    }  
    
    // Commented out by Mike Regan for BS-270 
    /*public static void updateCountryName(list<Territory__c> territories) {
    	map<string, string> countryLookup = LeadServices.countryISOLookupByCode;
    	for (Territory__c territory : territories) {
    		if (!String.isEmpty(territory.Country_ISO_Code__c)) {
    			// We have a code so look up the country name
    			territory.Country_Name__c = countryLookup.get(territory.Country_ISO_Code__c);
    		}
    		else {
    			// We don't have an ISO code so make sure the name is null
    			territory.Country_Name__c = null;
    		}
    	}
    }
    
    public static void insertCountryName(list<Territory__c> territories) {
    	map<string, string> countryLookup = LeadServices.countryISOLookupByCode;
    	set<Id> dealerBrandIdsToQuery = new set<Id>();
    	for (Territory__c territory : territories) {
    		if (!String.isEmpty(territory.Country_ISO_Code__c)) {
    			// We have a code so look up the country name
    			territory.Country_Name__c = countryLookup.get(territory.Country_ISO_Code__c);
    		}
    		else {
    			// We will need to lookup the dealer country code
    			system.debug('Adding dealer brand ' + territory.Dealer_Brand__c + ' to lookup since there is no ISO code specified');
    			dealerBrandIdsToQuery.add(territory.Dealer_Brand__c);
    		}
    	}
    	
    	if (dealerBrandIdsToQuery.size() > 0) {
    		map<ID, Dealer_Brand__c> dealerBrandsMap = new map<ID, Dealer_Brand__c>([select Id, Dealer__r.Country_ISO_Code__c from Dealer_Brand__c where Id in : dealerBrandIdsToQuery]);
    		if (dealerBrandsMap.size() > 0) {
    			system.debug('Found a total of ' + dealerBrandsMap.size() + ' dealer brands');
    			for (Territory__c territory : territories) {
    				if (String.isEmpty(territory.Country_ISO_Code__c)) {
    					Dealer_Brand__c db = dealerBrandsMap.get(territory.Dealer_Brand__c);
    					if (db != null && !String.isEmpty(db.Dealer__r.Country_ISO_Code__c)) {
    						system.debug('Setting country ISO code to ' + db.Dealer__r.Country_ISO_Code__c);
    						territory.Country_ISO_Code__c = db.Dealer__r.Country_ISO_Code__c;
    						territory.Country_Name__c = countryLookup.get(territory.Country_ISO_Code__c);
    						system.debug('Country name for ISO code ' + territory.Country_ISO_Code__c + ' = ' + territory.Country_Name__c);
    					}
    				}
    			}		
    		}
    	}
    }*/
    
    public static list<Territory__c> findTerritoriesForCanada(String postalCode, String BrandCode, String countryCode) {
        // we will only get the first 3 digits for the Territory object, we need to match on the first 3 characters only
        final String firstThreeCharactersOfPostalCode = (postalCode != null) ? postalCode.substring(0,3) : postalCode;        
        return [
        	SELECT 
        		Id
                ,Dealer__c
				, Dealer_Name__c
                , Dealer_Brand__c
                , State_Province_formula__c  
                , Dealer_Brand__r.Brand__c
                , Country_formula__c
                , Dealer_Brand__r.Dealer__c
            FROM Territory__c
			WHERE Zipcode_Postal_Code__c = :firstThreeCharactersOfPostalCode
			AND Dealer_Brand__r.Brand__c = :BrandCode
			AND Dealer_Brand__r.Dealer__c != null
			AND Dealer_Brand__r.Status__c ='Active'
			AND Dealer_Brand__r.Dealer__r.Dealer_Type__c NOT IN :EXCLUDED_DEALER_TYPES];
    }
    
    public static set<Id> getDealers(String postalCode){            
       set<Id> dealerIds = new set<Id>();
       for(Account rec : [SELECT Id FROM Account where  ShippingPostalCode = :postalCode]){
       	 dealerIds.add(rec.Id);
       } 	
       return dealerIds;
    }
    
    public static list<Territory__c> getCountyForTerritory(Set<Id> dealers){
    	return [SELECT
    	         County__c ,                 
                 Dealer_Brand__r.Dealer__r.Id,               
                 Dealer_Brand__c
    	        FROM Territory__c
    	        WHERE Dealer_Brand__r.Status__c ='Active'
    	        AND Dealer_Brand__r.Dealer__r.Id IN :dealers];
    }
    /* 
    public static map<String, list<Id>> getCountiesToDealersMap(String county)
    {          
        map<String, list<Id>> CountiesToDealersMap = new map<String, list<Id>> ();
        for(Territory__c t : [SELECT 
                                  Id,
                                  Dealer_Name__c,
                                  Dealer_Brand__c,
                                  State_Province_formula__c,
                                  City__c, Country_formula__c,
                                  County__c 
                              FROM Territory__c 
                              WHERE Dealer_Brand__r.Status__c ='Active'
                              AND County__c =:county limit 3]) 
        {  
          if(t.county__c != null) { 
            if(CountiesToDealersMap.containsKey(t.county__c)){
                CountiesToDealersMap.get(t.county__c).add(t.Dealer_Name__c);
            }else{
                CountiesToDealersMap.put(t.county__c,new Id[]{t.Dealer_Name__c});
            }
          }            
        }
        return CountiesToDealersMap;
    }*/
 
  public static map<String, list<Id>> getCountiesToDealersMap(String brand, String leadState, String leadCounty )
    {            
        system.debug('**state ='+leadCounty+','+leadState+ ','+ brand);
        map<String, list<Id>> CountiesToDealersMap = new map<String, list<Id>> ();     
       
   
         for(Territory__c t : [SELECT 
                                Id,
                                Dealer_Name__c,
                               // Dealer__c,
                                Dealer_Brand__c,
                                Dealer_Brand__r.Status__c ,
                                State_Province__c,
                                Dealer_Brand__r.Brand__c ,
                                State_Province_formula__c,
                                City__c,
                                Country_formula__c,
                                County__c 
                               FROM Territory__c
                               WHERE Dealer_Brand__r.Brand__c =:brand
                               AND County__c =:leadCounty
                               AND State_Province__c =:leadState
                               AND  Dealer_Brand__r.Status__c ='Active'
                               AND Dealer_Brand__r.Dealer__r.Dealer_Type__c NOT IN :EXCLUDED_DEALER_TYPES])
        {      
          if(t.county__c != null) {
            if(CountiesToDealersMap.containsKey(t.county__c)){
                CountiesToDealersMap.get(t.county__c).add(t.Dealer_Name__c);
            }else{
                CountiesToDealersMap.put(t.county__c,new Id[]{t.Dealer_Name__c});
            }
          }                  
        }           
        return CountiesToDealersMap;
    }
    private static final double pi = 3.14159;
    private static final double pi_180 = pi/180;//.0174532
    private static final double LatDegreesPerMile = 0.0145;        

     private static  map<Id,Account> GetDealerList(decimal radius, decimal longitude, decimal latitude, String countryCode, String brand)
    {
        system.debug('values ='+longitude); 
        system.debug('latitude ='+latitude);
        system.debug('countryCode ='+countryCode);
        system.debug('brand ='+brand);
        system.debug('radius ='+radius);
        
        
        map<Id,Account> matchedidToDealers = new map<Id,Account>();
        list<Account> matchedDealers = new list<Account>();
        if(radius != null && longitude != null && latitude != null)
        {
            String METHODNAME = CLASSNAME.replace('METHODNAME', 'GetZipCodeList');
                        
            //1 degree of longitude in the continental US averages 52.7 miles
            //1 degree of latitude = 69.1 miles
            //1 mile = .0189 longitude degrees (x)
            //1 mile = .0145 latitude degrees (y) 
            if(radius > 0)
            {
                double yDeviation = radius * LatDegreesPerMile;
                //double xDeviation = radius * LongMileConv;
                double xDeviation = yDeviation/Math.cos(latitude * pi_180);
             
                //create 4-point polygon
                double northBound = latitude + yDeviation;
                double southBound = latitude - yDeviation;
                double eastBound = longitude + xDeviation;
                double westBound = longitude - xDeviation;
              
               // select zipcodes that are inside the polygon AND the same country   
         
                for(Dealer_Brand__c  rec :[Select       
                                           Id,
                                           Brand__c,
                                           Dealer__c,
                                           Status__c,
                                           Dealer__r.Longitude__c,
                                           Dealer__r.Latitude__c,
                                           Dealer__r.Country_ISO_Code__c,
                                           Dealer__r.Id
                                          from Dealer_Brand__c
                                          where Dealer__r.Longitude__c > :westBound
                                          and Dealer__r.Longitude__c < :eastBound 
                                          and Dealer__r.Latitude__c > :southBound 
                                          and Dealer__r.Latitude__c < :northBound
                                          and Dealer__r.Country_ISO_Code__c = :countryCode
                                          and Brand__c = :brand
                                          and Status__c ='Active'
                                          AND Dealer__r.Dealer_Type__c NOT IN :EXCLUDED_DEALER_TYPES]){                    
                     
                   matchedidToDealers.put(rec.Dealer__r.Id, rec.Dealer__r);                        
                
                }
            }
        }
       
        return matchedidToDealers;
    }  
    
    public static set<Id> getTerritoryIds (list<Territory__c> territories){
        Set<Id> territoryIds = (new Map<Id,SObject>(territories)).keySet();	
        return territoryIds;
    } 
    
    @future (callout = false)
    /*
    *Iterates through all of the territories assocaited with the dealer id on the updated territory.  Needed to handle territory deletes and category changes.  A delete, or
    *a catgory change, may result in the last category associated with a dealer being removed.  Need to check all just to be sure
    */
    public static void rewriteSRDealerBoatCategories(Set<Id> territoryIds) {
    	
    	Map<Id, Territory__c> territoryToTerritoryAccountIdMap = new Map<Id, Territory__c>([Select t.Id, t.Dealer_Brand__r.Dealer__r.Id From Territory__c t Where t.Id = :territoryIds]);
		system.debug('**************** territoryToTerritoryAccountIdMap: ' + territoryToTerritoryAccountIdMap);
		
		Set<Id> accountSet = new Set<Id>();
		for (Id territoryId : territoryToTerritoryAccountIdMap.keySet()) {
    		accountSet.add(territoryToTerritoryAccountIdMap.get(territoryId).Dealer_Brand__r.Dealer__r.Id);
    	}
		system.debug('**************** accountSet: ' + accountSet);
		
		//Get all of the territories for a dealer (account)
		List<Territory__c> territoryCategories = [Select t.Id, t.Dealer_Brand__c, t.Boat_Class__c, t.Dealer_Brand__r.Dealer__r.Id From Territory__c t Where Dealer_Brand__r.Brand__c = 'SR' And Dealer_Brand__r.Status__c ='Active' And Dealer_Brand__r.Dealer__c != null And Dealer_Brand__r.Status__c ='Active' And Dealer_Brand__r.Dealer__r.Id In :accountSet Order By Dealer_Brand__r.Dealer__r.Id];
    	system.debug('**************** total number of territories: ' + territoryCategories.size());
    	
    	//SOQL does not have a distinct clause.  Need to come up with a distinct list of boat categories, for each account id
    	Map<Id, String> dealerBoatCategories = new Map<Id, String>();
    	Id currentDealerId = null;
    	Set<String> boatCategories = new Set<String>();
    	
    	for (Territory__c territoryCategory : territoryCategories) {
    		
    		if (currentDealerId == null) {
    			currentDealerId = territoryCategory.Dealer_Brand__r.Dealer__r.Id;
    		}
    		if (currentDealerId != territoryCategory.Dealer_Brand__r.Dealer__r.Id) {
    			dealerBoatCategories.put(currentDealerId, String.join(new List<String>(boatCategories), ', '));
    			currentDealerId = territoryCategory.Dealer_Brand__r.Dealer__r.Id;
    			boatCategories = new Set<String>();
    		}
			
			boatCategories.addAll(territoryCategory.Boat_Class__c.split(';'));

    	}
    	
    	dealerBoatCategories.put(currentDealerId, String.join(new List<String>(boatCategories), ', '));

    	List<Account> accounts = [Select a.Id, a.Sea_Ray_Boat_Categories__c From Account a Where a.Id In :dealerBoatCategories.keySet()];
    	
    	for (Account account : accounts) {
    		account.Sea_Ray_Boat_Categories__c = dealerBoatCategories.get(account.id);
    	}
    	
    	update accounts;
    }
  
    @future (callout = false)
    /*
    *Just need to update the territories associated account with the boat category on the territory
    */
    public static void addSRDealerBoatCategories(Set<Id> territoryIds) {
    	
    	Map<Id, Territory__c> territoryIdToTerritoryMap = new Map<Id, Territory__c>([Select t.Id, t.Boat_Class__c, t.Dealer_Brand__r.Dealer__r.Id From Territory__c t Where t.Id = :territoryIds And t.Dealer_Brand__r.Brand__c = 'SR' And Dealer_Brand__r.Status__c ='Active' ]);
		system.debug('**************** territoryIdToTerritoryMap: ' + territoryIdToTerritoryMap);
		
		Set<Id> accountSet = new Set<Id>();
		for (Id territoryId : territoryIdToTerritoryMap.keySet()) {
    		accountSet.add(territoryIdToTerritoryMap.get(territoryId).Dealer_Brand__r.Dealer__r.Id);
    	}
		system.debug('**************** accountSet: ' + accountSet);
		
		//Get all of the accounts
		Map<Id, Account> accounts = new Map<Id, Account>([Select a.Id, a.Sea_Ray_Boat_Categories__c From Account a Where a.Id In :accountSet]);
		
		//Iterate through each territory, check the boat category on the associated account, and update as needed
		Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
		
		for (Id territoryId : territoryIdToTerritoryMap.keySet()) {
			Territory__c territory = territoryIdToTerritoryMap.get(territoryId);
			
			Set<String> boatCategories;
			
			if (territory.Boat_Class__c == null) {
				boatCategories = new Set<String>();
			} else {
				boatCategories = new Set<String>(territory.Boat_Class__c.split(';'));
			}
			
			Account account = accounts.get(territory.Dealer_Brand__r.Dealer__r.Id);
			system.debug('************* account id: ' + account.Id);
			
			if (account !=null) {
				for (String boatCategory : boatCategories) {
					system.debug('************* territory boat category: ' + boatCategory);
					system.debug('************* account boat category: ' + account.Sea_Ray_Boat_Categories__c);
					if (account.Sea_Ray_Boat_Categories__c == null || !account.Sea_Ray_Boat_Categories__c.contains(boatCategory)) {
						if (String.isEmpty(account.Sea_Ray_Boat_Categories__c)) {
							account.Sea_Ray_Boat_Categories__c = boatCategory;
						} else {
							account.Sea_Ray_Boat_Categories__c += ', ' + boatCategory;
						}
						if (accountsToUpdate.get(account.Id) != null) {
							//Remove the existing value so that we can replace it with the new one
							accountsToUpdate.remove(account.Id);
						}
						accountsToUpdate.put(account.Id, account);
					}
				}
			}
		}
		
    	if (!accountsToUpdate.isEmpty()) {
    		update new List<Account>(accountsToUpdate.values());
    	}
    }  
}