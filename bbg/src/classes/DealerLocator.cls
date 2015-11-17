global class DealerLocator {

    static final String ACTIVE = 'Active'; 
    static list<Id>  salesforceDealers = new list<Id>(); 
    static final String CANADA = 'CA';
    static final String UNITED_STATES = 'US';
    static final String CANADA_FULL = 'Canada';
    static final String UNITED_STATES_FULL = 'United States';
    static Boolean countyMatchFound;
    static final String EMPTY_STRING = '';
    static final String LON = 'lng';
    static final String LAT = 'lat';
    static final String COUNTYCD = 'countryCode';
    static final String STATECD = 'adminCode1';
    static final String ADMINNAME2 = 'adminName2';
    static final String DOMESTIC = 'Domestic';
    static final String WEBSERVICE_EXCEPTION = 'WebService Exception: ';
    static final String XML_PARSING_EXCEPTION = 'XML Parsing Exception: ';
   
    webservice static list<DealerInfo> getDealerInfoV2(String postalCode, 
                                                            String countryName, 
                                                            String brandCode, 
                                                            String domesticOrInternational, 
                                                            String website)
    {
        System.debug('DealerLocatorDebug: RawSoapRequest: ' + hashDealerLocatorParams(new List<String>{postalCode, countryName, 
                                                        brandCode, domesticOrInternational, 
                                                        website}));
                                                                            
        final String filteredPostalCode = !String.isEmpty(postalCode) ? String.escapeSingleQuotes(postalCode) : '';
        final String filteredCountryName = !String.isEmpty(countryName) ? String.escapeSingleQuotes(countryName) : '';
        final String filteredBrandCode = !String.isEmpty(brandCode) ? String.escapeSingleQuotes(brandCode) : '';
        final String filteredDomesticOrInternational = !String.isEmpty(domesticOrInternational) ? String.escapeSingleQuotes(domesticOrInternational) : '';
        final String filteredWebsite = !String.isEmpty(website) ? String.escapeSingleQuotes(website) : '';
        
        System.debug('DealerLocatorDebug: SoapRequest: ' + hashDealerLocatorParams(new List<String>{filteredPostalCode, filteredCountryName, 
                                                        filteredBrandCode, filteredDomesticOrInternational, 
                                                        filteredWebsite}));
        
        List<DealerInfo> dealerResults = new List<DealerInfo>();
        
        //BS-186
        //David Hickman - 03.30.15 - ISO code by alternate country name
        final String COUNTRY_ISO_CODE = DealerLocatorServices.countryISOLookup.containsKey(filteredCountryName) ? 
                DealerLocatorServices.countryISOLookup.get(filteredCountryName) : DealerLocatorServices.altCountryISOLookup.containsKey(filteredCountryName) ? 
                DealerLocatorServices.altCountryISOLookup.get(filteredCountryName) : null;
        System.debug('DealerLocatorDebug: COUNTRY_ISO_CODE: ' + COUNTRY_ISO_CODE + ' : for : ' + filteredCountryName);  
        
        if (COUNTRY_ISO_CODE != null) {
            Country_ISO_Code_Lookup__c countryISO = Country_ISO_Code_Lookup__c.getInstance(COUNTRY_ISO_CODE); 
        
            System.debug('Looking for dealer locator rule for country: ' + countryISO.Country__c + ', brand code: ' + filteredBrandCode + ', int / dom: ' + filteredDomesticOrInternational + ', and website: ' + filteredWebsite);
        
            Dealer_Locator_Rule__c locatorRule = DealerLocatorRuleServices.getDealerLocatorRule(countryISO.Country__c, 
                                                                                            filteredBrandCode, 
                                                                                            filteredDomesticOrInternational, 
                                                                                            filteredWebsite);
            System.debug('DealerLocatorDebug: locatorRuleFound: ' + locatorRule);
        
            if (locatorRule != null){
        
                if(String.isEmpty(filteredPostalCode) && String.isEmpty(countryISO.Country__c)) {
                    return getDealerInfoMessage( dealerResults, 'Postal code and Country code are missing.');
                }
                
                String geoNamesWebServiceError;
                String county = EMPTY_STRING;
                String country = EMPTY_STRING;
                String stateCode = EMPTY_STRING;
                decimal latitude;
                decimal longitude;
                
                if(COUNTRY_ISO_CODE != null && 
                    (locatorRule.Assigned_Dealer_Functionality__c == DealerLocatorRuleServices.ASSIGNED_DEALERS_BY_STATE_CODE || 
                    locatorRule.Assigned_Dealer_Functionality__c == DealerLocatorRuleServices.ASSIGNED_DEALERS_BY_COUNTY_CODE || 
                    locatorRule.No_Assigned_Dealer_Functionality__c == DealerLocatorRuleServices.NON_ASSIGNED_DEALERS_BY_POSTAL_CODE)
                ) 
                {
                    
                    // Only parse the first returned result  
                    map<String, String> fieldsMap = new map<String, String>();
                    fieldsMap = GeoNamesWebService.getLocationInfo(filteredPostalCode, COUNTRY_ISO_CODE, '', true);
                    
                    System.debug('DealerLocatorDebug: GoeNamesWebService fieldsMap: ' + fieldsMap);
                    
                    if(fieldsMap.isEmpty()) {
                        return getDealerInfoMessage( dealerResults, 'Webservice did not find a match for ' + filteredPostalCode + ' and ' + countryISO.Country__c);
                    }
                    if(fieldsMap.get(ADMINNAME2) != null) {       
                        county = fieldsMap.get(ADMINNAME2);       
                    }
                    if(fieldsMap.get(LAT) != null) {   
                        latitude = decimal.valueOf(fieldsMap.get(LAT));       
                    }            
                    if(fieldsMap.get(LON) != null) {  
                        longitude = decimal.valueOf(fieldsMap.get(LON));     
                    }
                    if(fieldsMap.get(COUNTYCD) != null) {        
                        country = fieldsMap.get(COUNTYCD);        
                    }
                    if(fieldsMap.get(STATECD) != null) {
                        stateCode = fieldsMap.get(STATECD);
                    }
                    if(fieldsMap.get(WEBSERVICE_EXCEPTION) != null) {    
                        geoNamesWebServiceError = fieldsMap.get(WEBSERVICE_EXCEPTION);
                    }
                    if(fieldsMap.get(XML_PARSING_EXCEPTION) != null) { 
                        if(fieldsMap.get(WEBSERVICE_EXCEPTION) != null) {    
                            geoNamesWebServiceError += fieldsMap.get(XML_PARSING_EXCEPTION);   
                        } else {
                            geoNamesWebServiceError += fieldsMap.get(XML_PARSING_EXCEPTION);  
                        }
                    } 
                }
                
                List<DealerLocatorServices.DealerFound> foundDealers = new List<DealerLocatorServices.DealerFound>();
                
                Integer ASSIGNED_DEALER_LIMIT = Integer.valueOf(locatorRule.Max_Assigned_Dealers_to_Return__c);
                Integer NON_ASSIGNED_DEALER_LIMIT = Integer.valueOf(locatorRule.Max_Non_Assigned_Dealers_to_Return__c);
                
                // Assigned Dealer Functionality
                
                if (locatorRule.Assigned_Dealer_Functionality__c == DealerLocatorRuleServices.ASSIGNED_DEALERS_BY_POSTAL_CODE && String.isNotBlank(filteredPostalCode)){
                    foundDealers.addAll(DealerLocatorServices.searchAssignedDealersByPostalCode(filteredBrandCode, filteredPostalCode, countryISO.Country__c, ASSIGNED_DEALER_LIMIT));
                }
                else if (locatorRule.Assigned_Dealer_Functionality__c == DealerLocatorRuleServices.ASSIGNED_DEALERS_BY_FSA_CODE && String.isNotBlank(filteredPostalCode)){
                    foundDealers.addAll(DealerLocatorServices.searchAssignedDealersByFSACode(filteredBrandCode, filteredPostalCode, countryISO.Country__c, ASSIGNED_DEALER_LIMIT));
                }
                else if (locatorRule.Assigned_Dealer_Functionality__c == DealerLocatorRuleServices.ASSIGNED_DEALERS_BY_COUNTRY_CODE){
                    foundDealers.addAll(DealerLocatorServices.searchAssignedDealersByCountryCode( filteredBrandCode, countryISO.Country__c, ASSIGNED_DEALER_LIMIT));
                }
                else if (locatorRule.Assigned_Dealer_Functionality__c == DealerLocatorRuleServices.ASSIGNED_DEALERS_BY_STATE_CODE){
                    foundDealers.addAll(DealerLocatorServices.searchAssignedDealersByState( filteredBrandCode, stateCode, countryISO.Country__c, ASSIGNED_DEALER_LIMIT));
                }
                else if (locatorRule.Assigned_Dealer_Functionality__c == DealerLocatorRuleServices.ASSIGNED_DEALERS_BY_COUNTY_CODE){
                    foundDealers.addAll(DealerLocatorServices.searchAssignedDealersByCounty( filteredBrandCode, county, stateCode, ASSIGNED_DEALER_LIMIT));
                }
                
                System.debug('DealerLocatorDebug: Assigned_Dealer_Functionality__c: ' + foundDealers);
                
                // Non Assigned Dealer Functionality 
                
                if (foundDealers.isEmpty()){
                    
                    if (locatorRule.No_Assigned_Dealer_Functionality__c == DealerLocatorRuleServices.NON_ASSIGNED_DEALERS_BY_POSTAL_CODE){
                        if (latitude != null && longitude != null){
                            foundDealers.addAll(DealerLocatorServices.searchClosestNonAssignedDealersByDistance( filteredBrandCode, countryISO.Country__c, latitude, longitude, NON_ASSIGNED_DEALER_LIMIT));
                        }
                        else {
                            return getDealerInfoMessage( dealerResults, 'GeoWebServiceLocation Info Not Found: Cannot find closest dealers ' + 
                                hashDealerLocatorParams(new List<String>{filteredPostalCode, countryISO.Country__c}));
                        }
                    }
                    else if (locatorRule.No_Assigned_Dealer_Functionality__c == DealerLocatorRuleServices.NON_ASSIGNED_DEALERS_BY_COUNTRY_CODE){
                        foundDealers.addAll(DealerLocatorServices.searchNonAssignedDealersByCountryCode( filteredBrandCode, countryISO.Country__c, NON_ASSIGNED_DEALER_LIMIT));
                    }
                    
                    System.debug('DealerLocatorDebug: No_Assigned_Dealer_Functionality__c: ' + foundDealers);
                    
                    
                    // No Assigned or Non-Assigned Dealers found
                    
                    if (foundDealers.isEmpty()){
                        
                        if (locatorRule.Final_No_Results_Functionality__c == DealerLocatorRuleServices.NO_DEALERS_COUNTRY_REGIONAL_OFFICE_LOOKUP){
                            if (COUNTRY_ISO_CODE != null){
                                foundDealers.addAll(DealerLocatorServices.getRegionalOfficeByCountryCode( filteredBrandCode, COUNTRY_ISO_CODE ));
                                return getDealerInfoFromRegionalOfficesFound(foundDealers);
                            }
                            else {
                                return getDealerInfoMessage( dealerResults, 'No Custom Setting Set Up to Lookup Country ISO Code.');
                            }
                            
                        }
                        
                        System.debug('DealerLocatorDebug: Final_No_Results_Functionality__c: ' + foundDealers);
                        
                    }
                }
                
                System.debug('DealerLocatorDebug: DealersFound: ' + foundDealers);
                
                if(!foundDealers.isEmpty()){
                    dealerResults = getDealerInfoFromDealersFound(locatorRule, foundDealers);
                }
                else {
                    getDealerInfoMessage( dealerResults, 'Please accept our apologies, as we do not currently have a dealer for the Postal Code or Country entered.');
                }
                
            }
            else {
                getDealerInfoMessage( dealerResults, 'No Dealer Locator Rule found: ' + 
                    hashDealerLocatorParams(new List<String>{filteredPostalCode, countryISO.Country__c, 
                                                            filteredBrandCode, filteredDomesticOrInternational, 
                                                            filteredWebsite}));
            }
        } else {
            getDealerInfoMessage( dealerResults, 'No ISO Country found: ' + 
                    hashDealerLocatorParams(new List<String>{filteredPostalCode, filteredCountryName, 
                                                            filteredBrandCode, filteredDomesticOrInternational, 
                                                            filteredWebsite}));
        }
        return dealerResults;
    }
    
    @testVisible
    private static List<DealerInfo> getDealerInfoFromDealersFound(Dealer_Locator_Rule__c locatorRule, 
                                                                List<DealerLocatorServices.DealerFound> foundDealers)
    {
        Set<String> dealerInfoHashSet = new Set<String>();
        List<DealerInfo> dealerInfoObjs = new List<DealerInfo>();
        for(DealerLocatorServices.DealerFound dealer : foundDealers ){
            DealerInfo dealerInfoObj = new DealerInfo(dealer.account, dealer.dealerBrand);
            if (locatorRule.Include_Product_Category__c && 
                dealer.otherDealerInfo.containsKey(DealerLocatorServices.DEALER_INFO_PRODUCT_CATEGORY_KEY))
            {
                dealerInfoObj.dealerProductCategory = String.valueOf(dealer.otherDealerInfo.get(DealerLocatorServices.DEALER_INFO_PRODUCT_CATEGORY_KEY));
            }
            
            if (!dealerInfoHashSet.contains(dealerInfoObj.getHashKey())){
                dealerInfoHashSet.add(dealerInfoObj.getHashKey());
                dealerInfoObjs.add(dealerInfoObj);
            }
        }
        return dealerInfoObjs;
    }
    
    @testVisible
    private static List<DealerInfo> getDealerInfoFromRegionalOfficesFound(List<DealerLocatorServices.DealerFound> foundDealers)
    {
        Set<String> dealerInfoHashSet = new Set<String>();
        List<DealerInfo> dealerInfoObjs = new List<DealerInfo>();
        for(DealerLocatorServices.DealerFound dealer : foundDealers ){
            DealerInfo dealerInfoObj = new DealerInfo(dealer.account, dealer.dealerBrand);
            dealerInfoObj.exceptionMessage = 'No Dealers Found: Regional Office Location Returned.';
            if (!dealerInfoHashSet.contains(dealerInfoObj.getHashKey())){
                dealerInfoHashSet.add(dealerInfoObj.getHashKey());
                dealerInfoObjs.add(dealerInfoObj);
            }
        }
        return dealerInfoObjs;
    }
    
    @testVisible 
    private static String hashDealerLocatorParams(List<String> params){
        return String.join(params, ':');
    }
    
    @testVisible 
    private static list<DealerInfo> getDealerInfoMessage(list<DealerInfo> dealers, String msg) {
        dealers.add(new DealerInfo(msg));
        return dealers;
    }
    
    
    
    // --------------------------- OLD BAYLINER DEALER LOCATOR FUNCTIONALITY ------------------------
    
    
     
    public static list<DealerInfo> getDealers(list<DealerInfo> dealers, String msg) {
        dealers.add(new DealerInfo(msg));
        return dealers;
    }
    
    
    webservice static list<DealerInfo> getDealerInfo(String postalCode, String countryCode) {
        // A DealerInfo maps to the Account object in salesforce.com.
        list<DealerInfo> dealers = new list<DealerInfo>();
        set<Id> dealersForMatchinPostalCode  = new set<Id>();
        Set<Id> dealerIdSet = new Set<Id> ();
        TerritoryServices.MatchedDealers md;
        
        if(String.isEmpty(postalCode) && String.isEmpty(countryCode)) {
            return getDealers(dealers, 'Postal code and Country code are missing.');
        }
        
        if(!String.isEmpty(countryCode) && 
            String.isEmpty(postalCode) && 
            (countryCode == UNITED_STATES || countryCode == CANADA)) {
                return getDealers(dealers, 'Postal code for US and Canada is mandatory.');
        } 

        final String filteredPostalCode = !String.isEmpty(postalCode) ? String.escapeSingleQuotes(postalCode) : '';
        final String filteredCountryCode = !String.isEmpty(countryCode) ? String.escapeSingleQuotes(countryCode) : '';
        
        final String brand = 'BL';
        String geoNamesWebServiceError;
        String county = EMPTY_STRING;
        String country = EMPTY_STRING;
        String stateCode = EMPTY_STRING;
        decimal latitude;
        decimal longitude;

        if(countryCode == UNITED_STATES || countryCode == CANADA) {
            map<String, String> fieldsMap = new map<String, String>();
            // Only parse the first returned result       
            fieldsMap = GeoNamesWebService.getLocationInfo(filteredPostalCode, filteredCountryCode, '', true);        

            if(fieldsMap.isEmpty()) {
                return getDealers(dealers, 'Webservice did not find a match for ' + filteredPostalCode + ' and ' + filteredCountryCode);
            }
            
            if(fieldsMap.get(ADMINNAME2) != null) {       
                county = fieldsMap.get(ADMINNAME2);       
            }
            if(fieldsMap.get(LAT) != null) {   
                latitude = decimal.valueOf(fieldsMap.get(LAT));       
            }            
            if(fieldsMap.get(LON) != null) {  
                longitude = decimal.valueOf(fieldsMap.get(LON));     
            }
            if(fieldsMap.get(COUNTYCD) != null) {        
                country = fieldsMap.get(COUNTYCD);        
            }
            if(fieldsMap.get(STATECD) != null) {
                stateCode = fieldsMap.get(STATECD);
            }
            if(fieldsMap.get(WEBSERVICE_EXCEPTION) != null) {    
                geoNamesWebServiceError = fieldsMap.get(WEBSERVICE_EXCEPTION);
            }
            if(fieldsMap.get(XML_PARSING_EXCEPTION) != null) { 
                if(fieldsMap.get(WEBSERVICE_EXCEPTION) != null) {    
                    geoNamesWebServiceError += fieldsMap.get(XML_PARSING_EXCEPTION);   
                } else {
                    geoNamesWebServiceError += fieldsMap.get(XML_PARSING_EXCEPTION);  
                }
            } 
        }

        if(country == UNITED_STATES) { 
            if(county != EMPTY_STRING){
                map<String, list<Id>> CountiesToDealersMap = TerritoryServices.getCountiesToDealersMap(brand, stateCode, county);
                if(CountiesToDealersMap.containsKey(county)){ 
                    list<Id> dealerList = CountiesToDealersMap.get(county);
                    if(dealerList != null && dealerList.size()>0){ 
                        dealerIdSet.addall(dealerList);
                        countyMatchFound = true;
                    }
                } else{
                    // find by distance
                    if( latitude != null && longitude != null ){
                        collectDealers(dealerIdSet, TerritoryServices.findByDistance(longitude, latitude, brand, country));
                    }
                }
            } 
        }else if(country == CANADA){
            // routed by 1st 3 digits of postal code, then by distance
            if(!String.isEmpty(postalCode)){
                list<Territory__c> territoryList = TerritoryServices.findTerritoriesForCanada(filteredPostalCode, brand, country);
                if(!territoryList.isEmpty()){
                    dealerIdSet.add(territoryList[0].Dealer_Name__c);
                    if(territoryList.size() >= 2){
                        dealerIdSet.add(territoryList[1].Dealer_Name__c);
                    }
                    if(territoryList.size() >= 3) {
                        dealerIdSet.add(territoryList[2].Dealer_Name__c);
                    }                        
                } else{
                    // find by distance
                    if( latitude != null && longitude != null ){
                        collectDealers(dealerIdSet, TerritoryServices.findByDistance(longitude, latitude, brand, country));
                    }
                }
            }
        }
        
        if((country != CANADA && country != UNITED_STATES)){
            for(Dealer_Brand__c dealerBrand :[
                Select 
                    Dealer__c
                From Dealer_Brand__c
                Where Dealer__r.Country_ISO_Code__c = :filteredCountryCode
                And Status__c = 'Active'
                And Brand__c = :brand
            ]) {
                dealerIdSet.add(dealerBrand.Dealer__c);
            }
        }
        
        if(!dealerIdSet.isEmpty()){
            for(Account dealer : [
                SELECT 
                    Name, 
                    Id, 
                    Website, 
                    Phone, 
                    ShippingStreet, 
                    ShippingState, 
                    ShippingPostalCode, 
                    ShippingCountry,
                    ShippingCity 
                FROM Account 
                WHERE Id IN :dealerIdSet
                    AND Dealer_Type__c NOT IN :TerritoryServices.EXCLUDED_DEALER_TYPES]){
                dealers.add(new DealerInfo(dealer, null));
            }
        } else {
            dealers.add(new DealerInfo(System.Label.No_Dealers));
        }

        return dealers; 
    }
     
    public static void collectDealers(final Set<Id> dealerIdSet, final TerritoryServices.MatchedDealers md) {
        if(md != null && dealerIdSet != null) {
            dealerIdSet.add(md.DealerOneId);
            dealerIdSet.add(md.DealerTwoId);
            dealerIdSet.add(md.DealerThreeId);
        }
    }    
}