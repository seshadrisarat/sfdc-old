public class DealerLocatorRuleServices {
    
    public static String APPLY_TO_ANY_OTHER_COUNTRY = 'All Others Not Defined';
    
    public static String ASSIGNED_DEALERS_BY_POSTAL_CODE = 'Use Assigned Dealers by Postal Code';
    public static String ASSIGNED_DEALERS_BY_FSA_CODE = 'Use Assigned Dealers by FSA Code';
    public static String ASSIGNED_DEALERS_BY_COUNTRY_CODE = 'Use Assigned Dealers by Country Code';
    public static String ASSIGNED_DEALERS_BY_STATE_CODE = 'Use Assigned Dealers by State';
    public static String ASSIGNED_DEALERS_BY_COUNTY_CODE = 'Use Assigned Dealers by County';
    
    public static String NON_ASSIGNED_DEALERS_BY_POSTAL_CODE = 'Use Closest Dealers to Input PostalCode';
    public static String NON_ASSIGNED_DEALERS_BY_COUNTRY_CODE = 'Use All Country Code Dealers';
    
    public static String NO_DEALERS_COUNTRY_REGIONAL_OFFICE_LOOKUP = 'Regional Office Lookup (Country)';
    
    
    public static String DEALER_INFO_RETURNED_BASIC_INFO = 'Dealer Information Fields Basic Info';
    public static String DEALER_INFO_RETURNED_CUSTOM_1 = 'Dealer Information Fields Custom 1';
    
    
    public static void populateUniqueHash(List<Dealer_Locator_Rule__c> newList, 
                                            Map<Id, Dealer_Locator_Rule__c> oldMap)
    {
        
        for (Dealer_Locator_Rule__c dRule : newList){
            
            if ( String.isBlank(dRule.Rule_Hash_Key__c) || 
                 (oldMap != null && 
                     (dRule.Brand_Code__c != oldMap.get(dRule.Id).Brand_Code__c ||
                     dRule.Country_Code__c != oldMap.get(dRule.Id).Country_Code__c || 
                     dRule.Domestic_or_International__c != oldMap.get(dRule.Id).Domestic_or_International__c ||
                     dRule.Website__c != oldMap.get(dRule.Id).Website__c) 
                 ))
            {
                dRule.Rule_Hash_Key__c = dRule.Brand_Code__c + '#' + 
                                        dRule.Domestic_or_International__c + '#' + 
                                        dRule.Website__c + '#' + 
                                        dRule.Country_Code__c;
            }
        }
        
    }
    
    public static Dealer_Locator_Rule__c getDealerLocatorRule(
                                                        String countryCode, 
                                                        String brandCode, 
                                                        String domesticOrInternational, 
                                                        String website) 
    {
        String websiteNormalized = website.endsWith('/') ? website.substringBeforeLast('/') : website;
        List<Dealer_Locator_Rule__c> foundRules = [Select Id, Assigned_Dealer_Functionality__c, 
                                                        Include_Product_Category__c, 
                                                        Final_No_Results_Functionality__c, 
                                                        Max_Assigned_Dealers_to_Return__c, 
                                                        Max_Non_Assigned_Dealers_to_Return__c, 
                                                        No_Assigned_Dealer_Functionality__c, 
                                                        Country_Code__c, 
                                                        Brand_Code__c, 
                                                        Website__c, 
                                                        Domestic_or_International__c
                                                    From Dealer_Locator_Rule__c 
                                                    Where 
                                                    //Country_Code__c includes (:countryCode, :APPLY_TO_ANY_OTHER_COUNTRY) AND 
                                                    Brand_Code__c = :brandCode AND 
                                                    Website__c = :websiteNormalized AND 
                                                    Domestic_or_International__c = :domesticOrInternational];
                                                    
        if (foundRules.isEmpty()){
            return null;
        }
        
        else if (foundRules.size() > 1){
            /*
                If we have a Dealer Locator Rule setup that matches the coutnry code, then return that Rule
                    If we do not have any rules that match the country code, then return the rule 
                    that does not have a country defined as it should apply to all Countries that 
                    are not directly defined.
                    
                    
            */
            Dealer_Locator_Rule__c ruleMatch;
            Dealer_Locator_Rule__c applyToAllMatch;
            
            for (Dealer_Locator_Rule__c fRule : foundRules){
                
                
                Set<String> countrySet = new Set<String>();
                
                if (String.isNotBlank(fRule.Country_Code__c)){
                    countrySet.addAll(fRule.Country_Code__c.split(';'));
                }
                
                if (countrySet.contains(countryCode)){
                    // Validation Rule: Cannot define a country more than once per 
                    //                      Website, Domestic and Brand Code combo 
                    if (ruleMatch == null){
                        ruleMatch = fRule;
                    } else {
                        return null;
                    }
                    
                } else if (countrySet.size() == 0 ){
                    applyToAllMatch = fRule;
                }
                
            }
            return ruleMatch != null ? ruleMatch : applyToAllMatch;
        }
        
        return foundRules[0];
    }
    

}