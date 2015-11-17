/**
 * Implementation of functionality called in the trigger for the IST__SuperTRUMP_Pricing_Quote__c object.
 */
public with sharing class SuperTRUMPPricingQuoteTriggerImpl{

    /**
     * All trigger logic before an insert
     */
    public static void beforeInsert(List<IST__SuperTRUMP_Pricing_Quote__c> quotes){
        System.assertNotEquals(null, quotes);
        initializeQuotes(quotes);
    }

    /**
     * All trigger logic before an update
     * 
     * @param newMap Trigger.newMap variable from trigger
     * @param oldMap Trigger.oldMap variable from trigger
     */
    public static void beforeUpdate(Map<ID, IST__SuperTRUMP_Pricing_Quote__c> newMap, Map<ID, IST__SuperTRUMP_Pricing_Quote__c> oldMap){
        System.assertNotEquals(null, newMap);
        System.assertNotEquals(null, oldMap);
        SuperTRUMPPricingQuoteTriggerImpl.preventUpdatesIfOpportunityIsPromoted(newMap);
    }
    
    /**
     * Provide default values to newly created pricing quotes.
     * 
     * @param quotes List of newly created quotes.
     */
    public static void initializeQuotes(List<IST__SuperTRUMP_Pricing_Quote__c> quotes){
        Map<ID, List<IST__SuperTRUMP_Pricing_Quote__c>> oppToQuoteMap = new Map<ID, List<IST__SuperTRUMP_Pricing_Quote__c>>();
        List<ID> oppIds = new List<ID>();
        for (IST__SuperTRUMP_Pricing_Quote__c q : quotes){
            if (q.Prepared_By__c == null){
                q.Prepared_By__c = UserInfo.getName();
            }
            // If there an opportunity and the lessee name is not set, we'll query
            // the opportunity to find out the associated account name
            if (q.IST__Opportunity__c != null && q.Lessee__c == null){
                if (!oppToQuoteMap.containsKey(q.IST__Opportunity__c)){
                    oppToQuoteMap.put(q.IST__Opportunity__c, new List<IST__SuperTRUMP_Pricing_Quote__c>());
                }
                oppToQuoteMap.get(q.IST__Opportunity__c).add(q);
                oppIds.add(q.IST__Opportunity__c);
            }
        }
        
        // Get the account name for opportunities with quotes that don't have a lessee name set
        Opportunity[] oppList = [SELECT ID, Account.Name FROM Opportunity WHERE ID IN :oppIds];
        Map<ID, Opportunity> oppMap = new Map<ID, Opportunity>(oppList);
        
        for (ID oppId : oppToQuoteMap.keySet()){
            Opportunity opp = oppMap.get(oppId);
            if (opp != null){
                for (IST__SuperTRUMP_Pricing_Quote__c q : oppToQuoteMap.get(oppId)){
                    q.Lessee__c = opp.Account.Name;
                }
            }
        }
    }
    
    /**
     * Quotes whose parent opportunity has been approved and sent to operations, should not be updated. Throw
     * an error if this occurs.
     * 
     * @param quoteMap Map of quotes being updated with the quote ID as the key
     * @return true if there are errors, false otherwise
     */
    public static boolean preventUpdatesIfOpportunityIsPromoted(Map<ID, IST__SuperTRUMP_Pricing_Quote__c> quoteMap){
        List<IST__SuperTRUMP_Pricing_Quote__c> quotes = [SELECT ID, IST__Opportunity__r.Opp_Is_Approved__c
                                                         FROM IST__SuperTRUMP_Pricing_Quote__c
                                                         WHERE ID IN :quoteMap.keySet()];
        boolean hasErrors = false;
        for (IST__SuperTRUMP_Pricing_Quote__c quote : quotes){
            if (quote.IST__Opportunity__r != null && quote.IST__Opportunity__r.Opp_Is_Approved__c){
                hasErrors = true;
                quoteMap.get(quote.ID).addError('The associated opportunity is approved. This quote cannot be changed.');
            }
        }
        return hasErrors;
    }
}