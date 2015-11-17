public class DealerLocatorServices {
    
    @testVisible
    final private static String REGIONAL_OFFICE_DEALER_TYPE = 'Regional Office';
    final public static String DEALER_INFO_PRODUCT_CATEGORY_KEY = 'productCategory';
    
    public class DealerFound implements Comparable {
        
        public Account account;
        public Dealer_Brand__c dealerBrand;
        public Map<String, Object> otherDealerInfo {
            get {
                if (otherDealerInfo == null){
                    otherDealerInfo = new Map<String, Object>();
                }
                return otherDealerInfo;
            }
            set;
        }
        
        public DealerFound(Account accountInput, Dealer_Brand__c brandInput){
            account = accountInput;
            dealerBrand = brandInput;
        }
        
        public Integer compareTo(Object objectToCompareTo){
            DealerFound accountCompare = (DealerFound) objectToCompareTo;
            return this.equals(accountCompare) ? 0 : 1; 
        }
        
        public Boolean equals(Object objectToCompareTo){
            DealerFound accountCompare = (DealerFound) objectToCompareTo;
            if (accountCompare != null && accountCompare.account != null){
                return (this.account.Id == accountCompare.account.Id && 
                    this.otherDealerInfo == accountCompare.otherDealerInfo) ? true : false;
            }
            return false;
             
        }
        
        public Integer hashCode() {
            return (this.account != null && this.account.Id != null) ? 
                String.valueOf(this.account.Id).hashCode() + otherDealerInfo.hashCode() : 0;
        }
        
    }
    
    public static Map<String, String> countryISOLookup{
        get{
            if (countryISOLookup == null){
                countryISOLookup = new Map<String, String>();
                for (Country_ISO_Code_Lookup__c cs : Country_ISO_Code_Lookup__c.getAll().values()){
                    
                    if (!countryISOLookup.containsKey(cs.Country__c)){
                        countryISOLookup.put(cs.Country__c, cs.Name);
                    }
                    
                }
            }
            return countryISOLookup;
        }
        set;
    }
    
    //BS-186
    //David Hickman - 03.30.15 - ISO code by alternate country name
    public static Map<String, String> altCountryISOLookup{
        get{
            if (altCountryISOLookup == null){
                altCountryISOLookup = new Map<String, String>();
                for (Country_ISO_Code_Lookup__c cs : Country_ISO_Code_Lookup__c.getAll().values()){
                    
                    if (!altCountryISOLookup.containsKey(cs.Alternate_Country_Name__c)){
                        altCountryISOLookup.put(cs.Alternate_Country_Name__c, cs.Name);
                    }
                    
                }
            }
            return altCountryISOLookup;
        }
        set;
    }
    
    // Assigned Dealer functionality
    
    public static Set<DealerFound> searchAssignedDealersByPostalCode(String brandCode, String postalCode, String countryName, Integer MAX_LIMIT){
        Set<DealerFound> dealersFound = new Set<DealerFound>();
        
        Map<Id, Set<String>> dealerIdToProductCategories = new Map<Id, Set<String>>();
        
        // Question: Should we be returning all product categories regardless of matching territory.
        //               As in boat_class__c that are not matching input postal code, county, state, etc. 
        
        for (Territory__c matchingTerritory : [
            SELECT 
                Id
                ,Dealer__c
                , Dealer_Name__c
                , Dealer_Brand__c
                , State_Province_formula__c  
                , Dealer_Brand__r.Brand__c
                , Country_formula__c
                , Boat_Class__c
                , Dealer_Brand__r.Dealer__r.Name
                , Dealer_Brand__r.Dealer__r.Id
                , Dealer_Brand__r.Dealer__r.Website
                , Dealer_Brand__r.Dealer__r.Phone
                , Dealer_Brand__r.Dealer__r.ShippingStreet
                , Dealer_Brand__r.Dealer__r.ShippingState
                , Dealer_Brand__r.Dealer__r.ShippingPostalCode
                , Dealer_Brand__r.Dealer__r.ShippingCountry
                , Dealer_Brand__r.Dealer__r.ShippingCity
                , Dealer_Brand__r.Brand_Phone_Number__c
                , Dealer_Brand__r.Brand_URL__c
            FROM Territory__c
            WHERE Zipcode_Postal_Code__c = :postalCode
            AND Dealer_Brand__r.Brand__c = :brandCode
            AND Country_formula__c = :countryName
            AND Dealer_Brand__r.Dealer__c != null
            AND Dealer_Brand__r.Status__c ='Active'
            AND Dealer_Brand__r.Dealer__r.Dealer_Type__c NOT IN :TerritoryServices.EXCLUDED_DEALER_TYPES])
        {
            if (MAX_LIMIT != null && MAX_LIMIT != 0 && dealersFound.size() >= MAX_LIMIT) 
                break;
            DealerFound dealerMatch = new DealerFound(matchingTerritory.Dealer_Brand__r.Dealer__r, matchingTerritory.Dealer_Brand__r);
            
            if (!dealerIdToProductCategories.containsKey(matchingTerritory.Dealer_Brand__r.Dealer__c)){
                dealerIdToProductCategories.put(matchingTerritory.Dealer_Brand__r.Dealer__c, new Set<String>());
            }
            if (String.isNotBlank(matchingTerritory.Boat_Class__c)){
                dealerIdToProductCategories.get(matchingTerritory.Dealer_Brand__r.Dealer__c).addAll(matchingTerritory.Boat_Class__c.split(';'));
            }
            dealersFound.add( dealerMatch );
        }
        
        for (DealerFound dealerMatch : dealersFound){
            if ( dealerIdToProductCategories.containsKey(dealerMatch.account.Id) ){
                dealerMatch.otherDealerInfo.put(DEALER_INFO_PRODUCT_CATEGORY_KEY, 
                    String.join(new List<String>(dealerIdToProductCategories.get(dealerMatch.account.Id)), ';'));
            }
        }
        
        return dealersFound;
        
    }
    
    
    public static Set<DealerFound> searchAssignedDealersByFSACode(String brandCode, String postalCode, String countryName, Integer MAX_LIMIT){
        // we will only get the first 3 digits for the Territory object, we need to match on the first 3 characters only
        final String firstThreeCharactersOfPostalCode = ((postalCode != null) || postalCode.length() < 3) ? postalCode.substring(0,3) : postalCode; 
        Set<DealerFound> dealersFound = new Set<DealerFound>();   
        
        Map<Id, Set<String>> dealerIdToProductCategories = new Map<Id, Set<String>>();
            
        for (Territory__c matchingTerritory : [
            SELECT 
                Id
                ,Dealer__c
                , Dealer_Name__c
                , Dealer_Brand__c
                , State_Province_formula__c  
                , Dealer_Brand__r.Brand__c
                , Country_formula__c
                , Boat_Class__c
                , Dealer_Brand__r.Dealer__r.Name
                , Dealer_Brand__r.Dealer__r.Id
                , Dealer_Brand__r.Dealer__r.Website
                , Dealer_Brand__r.Dealer__r.Phone
                , Dealer_Brand__r.Dealer__r.ShippingStreet
                , Dealer_Brand__r.Dealer__r.ShippingState
                , Dealer_Brand__r.Dealer__r.ShippingPostalCode
                , Dealer_Brand__r.Dealer__r.ShippingCountry
                , Dealer_Brand__r.Dealer__r.ShippingCity
                , Dealer_Brand__r.Brand_Phone_Number__c
                , Dealer_Brand__r.Brand_URL__c              
            FROM Territory__c
            WHERE Zipcode_Postal_Code__c like :firstThreeCharactersOfPostalCode+'%'
            AND Country_formula__c = :countryName
            AND Dealer_Brand__r.Brand__c = :brandCode
            AND Dealer_Brand__r.Dealer__c != null
            AND Dealer_Brand__r.Status__c ='Active'
            AND Dealer_Brand__r.Dealer__r.Dealer_Type__c NOT IN :TerritoryServices.EXCLUDED_DEALER_TYPES])
        {
            if (MAX_LIMIT != null && MAX_LIMIT != 0 && dealersFound.size() >= MAX_LIMIT) 
                break;
            DealerFound dealerMatch = new DealerFound(matchingTerritory.Dealer_Brand__r.Dealer__r, matchingTerritory.Dealer_Brand__r);
            
            if (!dealerIdToProductCategories.containsKey(matchingTerritory.Dealer_Brand__r.Dealer__c)){
                dealerIdToProductCategories.put(matchingTerritory.Dealer_Brand__r.Dealer__c, new Set<String>());
            }
            if (String.isNotBlank(matchingTerritory.Boat_Class__c)){
                dealerIdToProductCategories.get(matchingTerritory.Dealer_Brand__r.Dealer__c).addAll(matchingTerritory.Boat_Class__c.split(';'));
            }
            dealersFound.add( dealerMatch );
        }
        
        for (DealerFound dealerMatch : dealersFound){
            if ( dealerIdToProductCategories.containsKey(dealerMatch.account.Id) ){
                dealerMatch.otherDealerInfo.put(DEALER_INFO_PRODUCT_CATEGORY_KEY, 
                    String.join(new List<String>(dealerIdToProductCategories.get(dealerMatch.account.Id)), ';'));
            }
        }
        
        return dealersFound;
    }
    
    public static Set<DealerFound> searchAssignedDealersByCountryCode(String brandCode, String countryName, Integer MAX_LIMIT){
        
        Set<DealerFound> dealersFound = new Set<DealerFound>();       
        Map<Id, Set<String>> dealerIdToProductCategories = new Map<Id, Set<String>>();
        
        for (Territory__c matchingTerritory : [
            SELECT 
                Id
                ,Dealer__c
                , Dealer_Name__c
                , Dealer_Brand__c
                , State_Province_formula__c  
                , Dealer_Brand__r.Brand__c
                , Country_formula__c
                , Boat_Class__c
                , Dealer_Brand__r.Dealer__r.Name
                , Dealer_Brand__r.Dealer__r.Id
                , Dealer_Brand__r.Dealer__r.Website
                , Dealer_Brand__r.Dealer__r.Phone
                , Dealer_Brand__r.Dealer__r.ShippingStreet
                , Dealer_Brand__r.Dealer__r.ShippingState
                , Dealer_Brand__r.Dealer__r.ShippingPostalCode
                , Dealer_Brand__r.Dealer__r.ShippingCountry
                , Dealer_Brand__r.Dealer__r.ShippingCity
                , Dealer_Brand__r.Brand_Phone_Number__c
                , Dealer_Brand__r.Brand_URL__c              
            FROM Territory__c
            WHERE Country_formula__c != null AND Country_formula__c = :countryName
            AND Dealer_Brand__r.Brand__c = :brandCode
            AND Dealer_Brand__r.Dealer__c != null
            AND Dealer_Brand__r.Status__c ='Active'
            AND Dealer_Brand__r.Dealer__r.Dealer_Type__c NOT IN :TerritoryServices.EXCLUDED_DEALER_TYPES])
        {
            if (MAX_LIMIT != null && MAX_LIMIT != 0 && dealersFound.size() >= MAX_LIMIT) 
                break;
            DealerFound dealerMatch = new DealerFound(matchingTerritory.Dealer_Brand__r.Dealer__r, matchingTerritory.Dealer_Brand__r);
            
            if (!dealerIdToProductCategories.containsKey(matchingTerritory.Dealer_Brand__r.Dealer__c)){
                dealerIdToProductCategories.put(matchingTerritory.Dealer_Brand__r.Dealer__c, new Set<String>());
            }
            if (String.isNotBlank(matchingTerritory.Boat_Class__c)){
                dealerIdToProductCategories.get(matchingTerritory.Dealer_Brand__r.Dealer__c).addAll(matchingTerritory.Boat_Class__c.split(';'));
            }
            
            dealersFound.add( dealerMatch );
        }
        
        for (DealerFound dealerMatch : dealersFound){
            if ( dealerIdToProductCategories.containsKey(dealerMatch.account.Id) ){
                dealerMatch.otherDealerInfo.put(DEALER_INFO_PRODUCT_CATEGORY_KEY, 
                    String.join(new List<String>(dealerIdToProductCategories.get(dealerMatch.account.Id)), ';'));
            }
        }
        
        return dealersFound;
    }
    
    public static Set<DealerFound> searchAssignedDealersByState( String brandCode, String state, String countryName, Integer MAX_LIMIT){
        
        Set<DealerFound> dealersFound = new Set<DealerFound>();   
        Map<Id, Set<String>> dealerIdToProductCategories = new Map<Id, Set<String>>();    
        for (Territory__c matchingTerritory : [
            SELECT 
                Id
                ,Dealer__c
                , Dealer_Name__c
                , Dealer_Brand__c
                , State_Province_formula__c  
                , Dealer_Brand__r.Brand__c
                , Country_formula__c
                , Boat_Class__c
                , Dealer_Brand__r.Dealer__r.Name
                , Dealer_Brand__r.Dealer__r.Id
                , Dealer_Brand__r.Dealer__r.Website
                , Dealer_Brand__r.Dealer__r.Phone
                , Dealer_Brand__r.Dealer__r.ShippingStreet
                , Dealer_Brand__r.Dealer__r.ShippingState
                , Dealer_Brand__r.Dealer__r.ShippingPostalCode
                , Dealer_Brand__r.Dealer__r.ShippingCountry
                , Dealer_Brand__r.Dealer__r.ShippingCity
                , Dealer_Brand__r.Brand_Phone_Number__c
                , Dealer_Brand__r.Brand_URL__c              
            FROM Territory__c
            WHERE State_Province__c = :state
            AND Country_formula__c = :countryName
            AND Dealer_Brand__r.Brand__c = :brandCode
            AND Dealer_Brand__r.Dealer__c != null
            AND Dealer_Brand__r.Status__c ='Active'
            AND Dealer_Brand__r.Dealer__r.Dealer_Type__c NOT IN :TerritoryServices.EXCLUDED_DEALER_TYPES])
        {
            if (MAX_LIMIT != null && MAX_LIMIT != 0 && dealersFound.size() >= MAX_LIMIT) 
                break;
            DealerFound dealerMatch = new DealerFound(matchingTerritory.Dealer_Brand__r.Dealer__r, matchingTerritory.Dealer_Brand__r);
            
            if (!dealerIdToProductCategories.containsKey(matchingTerritory.Dealer_Brand__r.Dealer__c)){
                dealerIdToProductCategories.put(matchingTerritory.Dealer_Brand__r.Dealer__c, new Set<String>());
            }
            if (String.isNotBlank(matchingTerritory.Boat_Class__c)){
                dealerIdToProductCategories.get(matchingTerritory.Dealer_Brand__r.Dealer__c).addAll(matchingTerritory.Boat_Class__c.split(';'));
            }           
            dealersFound.add( dealerMatch );
        }
        
        for (DealerFound dealerMatch : dealersFound){
            if ( dealerIdToProductCategories.containsKey(dealerMatch.account.Id) ){
                dealerMatch.otherDealerInfo.put(DEALER_INFO_PRODUCT_CATEGORY_KEY, 
                    String.join(new List<String>(dealerIdToProductCategories.get(dealerMatch.account.Id)), ';'));
            }
        }
        
        return dealersFound;
    }
    
    public static Set<DealerFound> searchAssignedDealersByCounty(String brandCode, String county, String stateCode, Integer MAX_LIMIT){
        
        Set<DealerFound> dealersFound = new Set<DealerFound>();       
        Map<Id, Set<String>> dealerIdToProductCategories = new Map<Id, Set<String>>();
        for (Territory__c matchingTerritory : [
            SELECT 
                Id
                ,Dealer__c
                , Dealer_Name__c
                , Dealer_Brand__c
                , State_Province_formula__c  
                , Dealer_Brand__r.Brand__c
                , Country_formula__c
                , Boat_Class__c
                , Dealer_Brand__r.Dealer__r.Name
                , Dealer_Brand__r.Dealer__r.Id
                , Dealer_Brand__r.Dealer__r.Website
                , Dealer_Brand__r.Dealer__r.Phone
                , Dealer_Brand__r.Dealer__r.ShippingStreet
                , Dealer_Brand__r.Dealer__r.ShippingState
                , Dealer_Brand__r.Dealer__r.ShippingPostalCode
                , Dealer_Brand__r.Dealer__r.ShippingCountry
                , Dealer_Brand__r.Dealer__r.ShippingCity
                , Dealer_Brand__r.Brand_Phone_Number__c
                , Dealer_Brand__r.Brand_URL__c              
            FROM Territory__c
            WHERE County__c = :county
            AND State_Province__c = :stateCode
            AND Dealer_Brand__r.Brand__c = :brandCode
            AND Dealer_Brand__r.Dealer__c != null
            AND Dealer_Brand__r.Status__c ='Active'
            AND Dealer_Brand__r.Dealer__r.Dealer_Type__c NOT IN :TerritoryServices.EXCLUDED_DEALER_TYPES])
        {
            
            if (MAX_LIMIT != null && MAX_LIMIT != 0 && dealersFound.size() >= MAX_LIMIT) 
                break;
    
            DealerFound dealerMatch = new DealerFound(matchingTerritory.Dealer_Brand__r.Dealer__r, matchingTerritory.Dealer_Brand__r);
            
            if (!dealerIdToProductCategories.containsKey(matchingTerritory.Dealer_Brand__r.Dealer__c)){
                dealerIdToProductCategories.put(matchingTerritory.Dealer_Brand__r.Dealer__c, new Set<String>());
            }
            if (String.isNotBlank(matchingTerritory.Boat_Class__c)){
                dealerIdToProductCategories.get(matchingTerritory.Dealer_Brand__r.Dealer__c).addAll(matchingTerritory.Boat_Class__c.split(';'));
            }
            dealersFound.add( dealerMatch );
        }
        
        for (DealerFound dealerMatch : dealersFound){
            if ( dealerIdToProductCategories.containsKey(dealerMatch.account.Id) ){
                dealerMatch.otherDealerInfo.put(DEALER_INFO_PRODUCT_CATEGORY_KEY, 
                    String.join(new List<String>(dealerIdToProductCategories.get(dealerMatch.account.Id)), ';'));
            }
        }
        
        return dealersFound;
    }
    
    
    
    
    // Non-Assigned Dealer functionality
    
    
    
    public static List<DealerFound> searchClosestNonAssignedDealersByDistance(String brandCode, String countryName, decimal latitude, decimal longitude, Integer MAX_LIMIT){
    
        List<DealerFound> dealersFound = new List<DealerFound>();
        String dealerBrandQuery = 'Select ' +        
               'Id, ' +  
               'Brand__c, ' +  
               'Dealer__c, ' +  
               'Status__c, ' +  
               'Dealer__r.Longitude__c, ' +  
               'Dealer__r.Latitude__c, ' +  
               'Dealer__r.Country_ISO_Code__c, ' +  
               'Dealer__r.Name, ' + 
               'Dealer__r.Id, ' + 
               'Dealer__r.Website, ' + 
               'Dealer__r.Phone, ' + 
               'Dealer__r.ShippingStreet, ' + 
               'Dealer__r.ShippingState, ' + 
               'Dealer__r.ShippingPostalCode, ' + 
               'Dealer__r.ShippingCountry, ' + 
               'Dealer__r.ShippingCity, ' +
               'Brand_Phone_Number__c, ' +
               'Brand_URL__c, ' +
              '(Select Boat_Class__c From Territories__r Where Boat_Class__c != null AND Brand__c = :brandCode AND Country_formula__c = :countryName ORDER BY Zipcode_Postal_Code__c, County__c, State_Province__c LIMIT 200) ' + 
              'from Dealer_Brand__c ' +  
              'where Dealer__r.ShippingCountry = :countryName ' +  
              'and Brand__c = :brandCode ' +  
              'and Dealer__r.GeoLocation__Latitude__s != null ' + 
              'and Dealer__r.GeoLocation__Longitude__s != null ' + 
              'and Status__c =\'Active\' ';
        if (!TerritoryServices.EXCLUDED_DEALER_TYPES.isEmpty()){
              dealerBrandQuery += ' AND Dealer__r.Dealer_Type__c NOT IN ' + BluewolfDevUtils.flattenListForQuery(new List<String>(TerritoryServices.EXCLUDED_DEALER_TYPES));
        } 
        dealerBrandQuery += ' ORDER BY DISTANCE(Dealer__r.GeoLocation__c, GEOLOCATION('+latitude+', '+longitude+'), \'km\') ';
        
        
              
        for(Dealer_Brand__c  dealerBrand :(List<Dealer_Brand__c>)Database.query(dealerBrandQuery))
        {
            if (MAX_LIMIT != null && MAX_LIMIT != 0 && dealersFound.size() >= MAX_LIMIT) 
                break;
            DealerFound dealerMatch = new DealerFound(dealerBrand.Dealer__r, dealerBrand);
            
            Set<String> productCategories = new Set<String>();
            for (Territory__c terr : dealerBrand.Territories__r){
                productCategories.addAll(terr.Boat_Class__c.split(';'));
            }
            dealerMatch.otherDealerInfo.put(DEALER_INFO_PRODUCT_CATEGORY_KEY, String.join(new List<String>(productCategories), ';'));
            
            dealersFound.add( dealerMatch );
        }
        return dealersFound;
        
    }
    
    public static Set<DealerFound> searchNonAssignedDealersByCountryCode(String brandCode, String countryName, Integer MAX_LIMIT){
    
        Set<DealerFound> dealersFound = new Set<DealerFound>();
        
        for(Dealer_Brand__c  dealerBrand : [
            Select 
               Id, 
               Brand__c,   
               Dealer__c,  
               Status__c, 
               Dealer__r.Longitude__c, 
               Dealer__r.Latitude__c, 
               Dealer__r.Country_ISO_Code__c,  
               Dealer__r.Id,
               Dealer__r.Name,
               Dealer__r.Website,
               Dealer__r.Phone,
               Dealer__r.ShippingStreet,
               Dealer__r.ShippingState,
               Dealer__r.ShippingPostalCode,
               Dealer__r.ShippingCountry,
               Dealer__r.ShippingCity,
               Brand_Phone_Number__c,
               Brand_URL__c,
               (Select Boat_Class__c From Territories__r Where Boat_Class__c != null AND Brand__c = :brandCode AND Country_formula__c = :countryName ORDER BY Zipcode_Postal_Code__c, County__c, State_Province__c LIMIT 200)
              from Dealer_Brand__c 
              where Dealer__r.ShippingCountry = :countryName  
              and Brand__c = :brandCode 
              and Status__c = 'Active'
             AND Dealer__r.Dealer_Type__c NOT IN :TerritoryServices.EXCLUDED_DEALER_TYPES])
        {
            if (MAX_LIMIT != null && MAX_LIMIT != 0 && dealersFound.size() >= MAX_LIMIT) 
                break;
            DealerFound dealerMatch = new DealerFound(dealerBrand.Dealer__r, dealerBrand);
            
            Set<String> productCategories = new Set<String>();
            for (Territory__c terr : dealerBrand.Territories__r){
                productCategories.addAll(terr.Boat_Class__c.split(';'));
            }
            dealerMatch.otherDealerInfo.put(DEALER_INFO_PRODUCT_CATEGORY_KEY, String.join(new List<String>(productCategories), ';'));
            
            dealersFound.add( dealerMatch );
        }
        return dealersFound;
        
    }
    
    
    
    
    
    
    public static Set<DealerFound> getRegionalOfficeByCountryCode(String brandCode, String countryISOCode){
        
        Set<DealerFound> dealersFound = new Set<DealerFound>();       
        // search for account type "Regional Office" 
        for (Territory__c matchingTerritory : [
            SELECT 
                Id
                ,Dealer__c
                , Dealer_Name__c
                , Dealer_Brand__c
                , State_Province_formula__c  
                , Dealer_Brand__r.Brand__c
                , Country_formula__c
                , Boat_Class__c
                , Dealer_Brand__r.Dealer__r.Name
                , Dealer_Brand__r.Dealer__r.Id
                , Dealer_Brand__r.Dealer__r.Website
                , Dealer_Brand__r.Dealer__r.Phone
                , Dealer_Brand__r.Dealer__r.ShippingStreet
                , Dealer_Brand__r.Dealer__r.ShippingState
                , Dealer_Brand__r.Dealer__r.ShippingPostalCode
                , Dealer_Brand__r.Dealer__r.ShippingCountry
                , Dealer_Brand__r.Dealer__r.ShippingCity 
                , Dealer_Brand__r.Dealer__r.Dealer_Type__c
                , Dealer_Brand__r.Brand_Phone_Number__c
                , Dealer_Brand__r.Brand_URL__c
            FROM Territory__c
            WHERE Regional_Office_Country__c = :countryISOCode
            AND Dealer_Brand__r.Brand__c = :brandCode
            AND Dealer_Brand__r.Dealer__c != null
            AND Dealer_Brand__r.Status__c ='Active'
            AND Dealer_Brand__r.Dealer__r.Dealer_Type__c = :REGIONAL_OFFICE_DEALER_TYPE])
        {
            DealerFound dealerMatch = new DealerFound(matchingTerritory.Dealer_Brand__r.Dealer__r, matchingTerritory.Dealer_Brand__r);
            dealersFound.add( dealerMatch );
        }
        return dealersFound;
    }
    
    
}