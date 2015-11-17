@IsTest
private with sharing class SuperTRUMPFAEFIntegrationTests {

    static private void verifyDefaultSettings(){
        final Integer NUM_COMMON_MAPPINGS = 39;
        final Integer NUM_OPS_MAPPINGS = 24;
        final Integer NUM_SALES_MAPPINGS = 5;
        
        IST__SuperTRUMP_Template__c[] templates = [SELECT ID FROM IST__SuperTRUMP_Template__c];
        IST__SuperTRUMP_Report__c[] reports = [SELECT ID FROM IST__SuperTRUMP_Report__c];
        IST__SuperTRUMP_Mapping__c[] opsMappings = [SELECT ID FROM IST__SuperTRUMP_Mapping__c WHERE IST__SF_Master_Object_Name__c = 'Operations_Pricing_Quote__c'];
        IST__SuperTRUMP_Mapping__c[] salesMappings = [SELECT ID FROM IST__SuperTRUMP_Mapping__c WHERE IST__SF_Master_Object_Name__c = 'IST__SuperTRUMP_Pricing_Quote__c'];
        
        System.assertEquals(1, templates.size());
        System.assertEquals(3, reports.size());
        System.assertEquals(NUM_COMMON_MAPPINGS + NUM_OPS_MAPPINGS, opsMappings.size());
        System.assertEquals(NUM_COMMON_MAPPINGS + NUM_SALES_MAPPINGS, salesMappings.size());
    }

    static testMethod void insertDefaultSettings(){
        
        Test.startTest();
        SuperTRUMPFAEFIntegration.FAEFDefaultSettings();
        Test.stopTest();
        
        verifyDefaultSettings();
    }
    
    static testMethod void insertDefaultSettingsTwice(){
        
        Test.startTest();
        SuperTRUMPFAEFIntegration.FAEFDefaultSettings();
        SuperTRUMPFAEFIntegration.FAEFDefaultSettings();
        Test.stopTest();
        
        verifyDefaultSettings();
    }
/*
    private static Letter_Of_Intent__c getNewLetterOfIntent(){
        return new Letter_Of_Intent__c();
    }
    
    private static Schedule__c getNewSchedule(String name, Letter_Of_Intent__c loi){
        return new Schedule__c(Name = name, Letter_Of_Intent__c = loi.ID);
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
    
    private static IST__SuperTRUMP_Pricing_Quote__c getNewQuote(Opportunity opp, IST__SuperTRUMP_Template__c template){
        System.assertNotEquals(null, opp.ID);
        System.assertNotEquals(null, template.ID);
        
        return new IST__SuperTRUMP_Pricing_Quote__c(
            IST__Opportunity__c = opp.Id,
            IST__Template__c = template.Id
        );
    }

    private static IST__SuperTRUMP_Pricing_Quote__c createQuote(){
        Account acc = getNewAccount();
        insert acc;
        
        Opportunity opp = getNewOpportunity();
        opp.AccountId = acc.Id;
        insert opp;
        
        SuperTRUMPFAEFIntegration.insertTemplates();
        
        IST__SuperTRUMP_Template__c template = [SELECT ID FROM IST__SuperTRUMP_Template__c WHERE Name = :SuperTRUMPFAEFIntegration.ECONOMIC_SUMMARY_TEMPLATE_NAME LIMIT 1];
        
        IST__SuperTRUMP_Pricing_Quote__c quote = getNewQuote(opp, template);
        
        insert quote;
        
        Attachment templatePRM = [SELECT Body, ContentType, Description, IsPrivate, Name FROM Attachment WHERE ParentId = :template.ID LIMIT 1];
        Attachment quotePRM = templatePRM.clone(false, true, true, true);
        quotePRM.Name = SuperTRUMPFAEFIntegration.QUOTE_ATTACHMENT_NAME;
        quotePRM.ParentId = quote.ID;
        insert quotePRM;
        
        return quote;
    }
    
    static testMethod void promoteQuote(){
        IST__SuperTRUMP_Pricing_Quote__c quote = createQuote();
        
        Letter_Of_Intent__c loi = getNewLetterOfIntent();
        insert loi;
        Schedule__c schedule = getNewSchedule('Test Schedule', loi);
        insert schedule;
        
        Map<ID, sObject> quoteToOps = new Map<ID, sObject>{ quote.ID => schedule };
        SuperTRUMPFAEFIntegration.doPromoteQuote(quoteToOps);
        
        Attachment schedulePRMAttachment = [SELECT ID, Name FROM Attachment WHERE ParentId = :schedule.ID AND Name = :SuperTRUMPFAEFIntegration.QUOTE_ATTACHMENT_NAME];
        Attachment quotePRMAttachment = [SELECT ID, Name FROM Attachment WHERE ParentId = :quote.ID AND Name = :SuperTRUMPFAEFIntegration.QUOTE_ATTACHMENT_NAME];
        
        System.assertNotEquals(null, schedule.stExternalId__c);
        System.assertNotEquals(null, quotePRMAttachment);
        System.assertNotEquals(null, schedulePRMAttachment);
        System.assertEquals(true, schedule.Is_Ops_View__c);
    }
    
    static testMethod void promoteQuote_quoteWithoutPRM(){
        IST__SuperTRUMP_Pricing_Quote__c quote = createQuote();
        
        Letter_Of_Intent__c loi = getNewLetterOfIntent();
        insert loi;
        Schedule__c schedule = getNewSchedule('Test Schedule', loi);
        insert schedule;
        
        Attachment quotePRMAttachment = [SELECT ID, Name FROM Attachment WHERE ParentId = :quote.ID AND Name = :SuperTRUMPFAEFIntegration.QUOTE_ATTACHMENT_NAME];
        delete quotePRMAttachment;
        try{
            Map<ID, sObject> quoteToOps = new Map<ID, sObject>{ quote.ID => schedule };
            SuperTRUMPFAEFIntegration.doPromoteQuote(quoteToOps);
        }
        catch(SuperTRUMPFAEFIntegration.NoDataFoundException e){
            String msg = e.getMessage();
            System.assert(msg.contains('A PRM attachment could not be found'), 'Unexpected exception: ' + e.getMessage());
        }
    }
    
    static testMethod void promoteQuoteTwice(){
        IST__SuperTRUMP_Pricing_Quote__c quote = createQuote();
        
        Letter_Of_Intent__c loi = getNewLetterOfIntent();
        insert loi;
        Schedule__c schedule = getNewSchedule('Test Schedule', loi);
        insert schedule;
        
        try{
            Map<ID, sObject> quoteToOps = new Map<ID, sObject>{ quote.ID => schedule };
            SuperTRUMPFAEFIntegration.doPromoteQuote(quoteToOps);
            SuperTRUMPFAEFIntegration.doPromoteQuote(quoteToOps);
            System.assert(false, 'It should not be possible to promote the same operations object twice.');
        }
        catch(SuperTRUMPFAEFIntegration.IntegrationException e){
            System.assert(e.getMessage().contains('The operations object already has PRM data'), 'Unexpected exception: ' + e.getMessage());
        }
    }
    */
}