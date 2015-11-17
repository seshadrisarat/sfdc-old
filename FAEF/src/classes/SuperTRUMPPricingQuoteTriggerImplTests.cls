/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private with sharing class SuperTRUMPPricingQuoteTriggerImplTests {

    /**
     * Verify that when a quote does not reference an opportunity, the prepared by
     * and lessee fields are left null without any errors
     */
    static testMethod void initializeEmptyQuotes() {
        IST__SuperTRUMP_Pricing_Quote__c quote = new IST__SuperTRUMP_Pricing_Quote__c();
        List<IST__SuperTRUMP_Pricing_Quote__c> quoteList = new List<IST__SuperTRUMP_Pricing_Quote__c>();
        quoteList.add(quote);
        
        SuperTRUMPPricingQuoteTriggerImpl.initializeQuotes(quoteList);
        
        System.assertEquals(UserInfo.getName(), quote.Prepared_By__c);
        System.assertEquals(null, quote.Lessee__c);
    }
    
    private static Account getNewAccount(){
        return new Account(Name = 'Test User');
    }
    
    private static Opportunity getNewOpportunity(){
        Date today = Date.today();
        Opportunity opp = new Opportunity(
            Name = 'A Test Opp',
            CloseDate = Date.parse(today.month() + '/' + today.day() + '/' + (today.year() + 2)),
            StageName = 'Prospecting'
        );
        return opp;
    }
    
    private static IST__SuperTRUMP_Template__c getNewTemplate(){
        return new IST__SuperTRUMP_Template__c(Name = 'Mock Template w\\out attachment');
    }
    
    static testMethod void initializeQuotesWithOppAndAccount() {
        Account acc = getNewAccount();
        insert acc;
        Opportunity opp = getNewOpportunity();
        opp.AccountId = acc.Id;
        insert opp;
        
        IST__SuperTRUMP_Pricing_Quote__c quote = new IST__SuperTRUMP_Pricing_Quote__c(IST__Opportunity__c = opp.ID);
        List<IST__SuperTRUMP_Pricing_Quote__c> quoteList = new List<IST__SuperTRUMP_Pricing_Quote__c>();
        quoteList.add(quote);
        
        SuperTRUMPPricingQuoteTriggerImpl.initializeQuotes(quoteList);
        
        System.assertEquals(UserInfo.getName(), quote.Prepared_By__c);
        System.assertEquals(acc.Name, quote.Lessee__c);
    }
    
    static testMethod void initializeQuotesWithOppNoAccount() {
        Opportunity opp = getNewOpportunity();
        insert opp;
        
        IST__SuperTRUMP_Pricing_Quote__c quote = new IST__SuperTRUMP_Pricing_Quote__c(IST__Opportunity__c = opp.ID);
        List<IST__SuperTRUMP_Pricing_Quote__c> quoteList = new List<IST__SuperTRUMP_Pricing_Quote__c>();
        quoteList.add(quote);
        
        SuperTRUMPPricingQuoteTriggerImpl.initializeQuotes(quoteList);
        
        System.assertEquals(UserInfo.getName(), quote.Prepared_By__c);
        System.assertEquals(null, quote.Lessee__c);
    }
    
    static testMethod void initializeQuotesMixed(){
        final Integer POOL_SIZE = 9;
        Account acc = getNewAccount();
        insert acc;
        Opportunity opp1 = getNewOpportunity();
        Opportunity opp2 = getNewOpportunity();
        opp2.AccountId = acc.Id;
        opp2.Account = acc;
        insert new sObject[]{ opp1, opp2 };
        List<IST__SuperTRUMP_Pricing_Quote__c> quoteList = new List<IST__SuperTRUMP_Pricing_Quote__c>();
        
        for (Integer i = 0; i < POOL_SIZE; i++){
            if (i < POOL_SIZE / 3){
                quoteList.add(new IST__SuperTRUMP_Pricing_Quote__c());
            }
            else if (i < POOL_SIZE * 2 / 3){
                quoteList.add(new IST__SuperTRUMP_Pricing_Quote__c(IST__Opportunity__c = opp1.ID));
            }
            else{
                quoteList.add(new IST__SuperTRUMP_Pricing_Quote__c(IST__Opportunity__c = opp2.ID));
            }
        }
        
        SuperTRUMPPricingQuoteTriggerImpl.initializeQuotes(quoteList);
        
        String nameOfUser = UserInfo.getName();
        for (Integer i = 0; i < POOL_SIZE; i++){
            if (i < POOL_SIZE / 3){
                System.assertEquals(null, quoteList[i].Lessee__c);
                System.assertEquals(nameOfUser, quoteList[i].Prepared_By__c);
            }
            else if (i < POOL_SIZE * 2 / 3){
                System.assertEquals(null, quoteList[i].Lessee__c);
                System.assertEquals(nameOfUser, quoteList[i].Prepared_By__c);
            }
            else{
                System.assertEquals(acc.Name, quoteList[i].Lessee__c);
                System.assertEquals(nameOfUser, quoteList[i].Prepared_By__c);
            }
        }
    }
    
    static testMethod void preventUpdatesIfOppApproved_NotApproved(){
        Opportunity opp = getNewOpportunity();
        IST__SuperTRUMP_Template__c template = getNewTemplate();
        insert new sObject[]{ opp, template };

        IST__SuperTRUMP_Pricing_Quote__c quote = new IST__SuperTRUMP_Pricing_Quote__c();
        quote.IST__Opportunity__c = opp.ID;
        quote.IST__Template__c = template.ID;
        insert quote;
        
        // update is allowed because the opportunity has not been approved
        Map<ID, IST__SuperTRUMP_Pricing_Quote__c> quoteMap =
            new Map<ID, IST__SuperTRUMP_Pricing_Quote__c>(new List<IST__SuperTRUMP_Pricing_Quote__c>{ quote });
        boolean hasErrors = SuperTRUMPPricingQuoteTriggerImpl.preventUpdatesIfOpportunityIsPromoted(quoteMap);
        System.assert(!hasErrors, 'Updating the quote should be allowed. The opportunity is NOT approved.');
    }
    
    static testMethod void preventUpdatesIfOppApproved_Approved(){
        Opportunity opp = getNewOpportunity();
        opp.Opp_Is_Approved__c = true;
        IST__SuperTRUMP_Template__c template = getNewTemplate();
        insert new sObject[]{ opp, template };

        IST__SuperTRUMP_Pricing_Quote__c quote = new IST__SuperTRUMP_Pricing_Quote__c();
        quote.IST__Opportunity__c = opp.ID;
        quote.IST__Template__c = template.ID;
        insert quote;
        
        Map<ID, IST__SuperTRUMP_Pricing_Quote__c> quoteMap =
            new Map<ID, IST__SuperTRUMP_Pricing_Quote__c>(new List<IST__SuperTRUMP_Pricing_Quote__c>{ quote });
        boolean hasErrors = SuperTRUMPPricingQuoteTriggerImpl.preventUpdatesIfOpportunityIsPromoted(quoteMap);
        System.assert(hasErrors, 'Updating this quote should fail.  The opportunity is approved.');
    }
    
    private static Map<String, Object> createQuoteTriggerData(final Integer NUM_QUOTES){
        return createQuoteTriggerData(NUM_QUOTES, new Map<String, Object>());
    }
    
    private static Map<String, Object> createQuoteTriggerData(final Integer NUM_QUOTES, Map<String, Object> oppFieldValues){
        Opportunity opp = getNewOpportunity();
        for (String fieldName : oppFieldValues.keySet()){
            opp.put(fieldName, oppFieldValues.get(fieldName));
        }
        IST__SuperTRUMP_Template__c template = getNewTemplate();
        insert new sObject[]{ opp, template };
        
        List<IST__SuperTRUMP_Pricing_Quote__c> updatedQuoteList = new List<IST__SuperTRUMP_Pricing_Quote__c>();
        List<IST__SuperTRUMP_Pricing_Quote__c> oldQuoteList = new List<IST__SuperTRUMP_Pricing_Quote__c>();

        for (Integer i = 0; i < NUM_QUOTES; i++){
            IST__SuperTRUMP_Pricing_Quote__c quote = new IST__SuperTRUMP_Pricing_Quote__c();
            quote.IST__Opportunity__c = opp.ID;
            quote.IST__Template__c = template.ID;
            oldQuoteList.add(quote);
        }
        
        insert oldQuoteList;
        
        for (IST__SuperTRUMP_Pricing_Quote__c quote : oldQuoteList){
            updatedQuoteList.add(quote.clone(true, true, true, true));
        }
        
        return new Map<String, Object>{
            'Opportunity' => opp,
            'Trigger.new' => updatedQuoteList,
            'Trigger.old' => oldQuoteList
        };
    }
    
    static testMethod void beforeUpdate(){
        Integer NUM_QUOTES = 1;
        Map<String, Object> triggerData = createQuoteTriggerData(NUM_QUOTES);

        List<IST__SuperTRUMP_Pricing_Quote__c> newQuoteList
            = (List<IST__SuperTRUMP_Pricing_Quote__c>) triggerData.get('Trigger.new');
        List<IST__SuperTRUMP_Pricing_Quote__c> oldQuoteList
            = (List<IST__SuperTRUMP_Pricing_Quote__c>) triggerData.get('Trigger.old');

        Map<ID, IST__SuperTRUMP_Pricing_Quote__c> newMap
            = new Map<ID, IST__SuperTRUMP_Pricing_Quote__c>(newQuoteList);
        Map<ID, IST__SuperTRUMP_Pricing_Quote__c> oldMap
            = new Map<ID, IST__SuperTRUMP_Pricing_Quote__c>(oldQuoteList);
        
        SuperTRUMPPricingQuoteTriggerImpl.beforeUpdate(newMap, oldMap);
    }
}