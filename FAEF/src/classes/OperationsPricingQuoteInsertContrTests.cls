@IsTest
private with sharing class OperationsPricingQuoteInsertContrTests {

    private static final String TEST_TRANSACTION_STATE = 'Fqx7rhK2uKc=';
    
    static testMethod void testIsCreateable_False(){
        // Name cannot be created or updated
        String[] fieldsToCreate = new List<String>{ 'Name', 'Structure__c' };
        DescribeSObjectResult describeObj = Schema.sObjectType.Operations_Pricing_Quote__c;
        
        Test.startTest();
        boolean isCreateable = OperationsPricingQuoteInsertController.isCreateable(describeObj, fieldsToCreate);
        Test.stopTest();
        
        System.assert(!isCreateable);
    }
    
    static testMethod void testIsCreateable(){
        String[] fieldsToCreate = new List<String>{ 'Structure__c', 'Schedule__c' };
        DescribeSObjectResult describeObj = Schema.sObjectType.Operations_Pricing_Quote__c;
        
        Test.startTest();
        boolean isCreateable = OperationsPricingQuoteInsertController.isCreateable(describeObj, fieldsToCreate);
        Test.stopTest();
        
        System.assert(isCreateable);
    }
    
    static testMethod void testIsSuperTRUMPTemplate_False(){
        Letter_Of_Intent__c loi = getNewLetterOfIntent();
        insert loi;
        
        Test.startTest();
        System.assert(!OperationsPricingQuoteInsertController.isSuperTRUMPTemplate(loi.ID));
        Test.stopTest();
    }
    
    static testMethod void testIsSuperTRUMPTemplate_True(){
        IST__SuperTRUMP_Template__c template = getNewTemplate();
        insert template;
        
        Test.startTest();
        System.assert(OperationsPricingQuoteInsertController.isSuperTRUMPTemplate(template.ID));
        Test.stopTest();
    }
    
    static testMethod void testGetTransactionState(){
        IST__SuperTRUMP_Template__c template = createTemplate();
        Operations_Pricing_Quote__c quote = new Operations_Pricing_Quote__c();
        OperationsPricingQuoteInsertController controller = setupController(quote);
        
        Test.startTest();
        System.assertEquals(TEST_TRANSACTION_STATE, controller.getTransactionState(template.Id));
        Test.stopTest();
    }
    
    static testMethod void testGetTransactionState_NoState(){
        IST__SuperTRUMP_Template__c template = getNewTemplate();
        insert template;
        Operations_Pricing_Quote__c quote = new Operations_Pricing_Quote__c();
        OperationsPricingQuoteInsertController controller = setupController(quote);
        
        Test.startTest();
        System.assertEquals(null, controller.getTransactionState(template.id));
        Test.stopTest();
    }
    
    static testMethod void testPrepareToSave_NoTemplate(){
        Operations_Pricing_Quote__c quote = new Operations_Pricing_Quote__c();
        OperationsPricingQuoteInsertController controller = setupController(quote);
        
        try{
            // no template set, should throw an error
            Test.startTest();
            controller.prepareToSave();
            Test.stopTest();
            System.assert(false, 'An exception should have been thrown.');
        }
        catch(OperationsPricingQuoteInsertController.InternalException e){
            System.assertEquals('A SuperTRUMP template is required.', e.getMessage());
        }
    }
    
    static testMethod void testPrepareToSave_NotATemplateId(){
        Operations_Pricing_Quote__c quote = new Operations_Pricing_Quote__c();
        OperationsPricingQuoteInsertController controller = setupController(quote);
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        controller.templateId = String.valueOf(acc.ID);
        
        try{
            // no template set, should throw an error
            Test.startTest();
            controller.prepareToSave();
            Test.stopTest();
            System.assert(false, 'An exception should have been thrown.');
        }
        catch(OperationsPricingQuoteInsertController.InsertionException e){
            System.assertEquals('The template id must reference a SuperTRUMP Template', e.getMessage());
        }
    }
    
    static testMethod void testPrepareToSave_Template_NoTransactionState(){
        IST__SuperTRUMP_Template__c template = getNewTemplate();
        insert template;
        Operations_Pricing_Quote__c quote = new Operations_Pricing_Quote__c();
        OperationsPricingQuoteInsertController controller = setupController(quote);
        controller.templateId = String.valueOf(template.ID);
        
        try{
            // no template set, should throw an error
            Test.startTest();
            controller.prepareToSave();
            Test.stopTest();
            System.assert(false, 'An exception should have been thrown.');
        }
        catch(OperationsPricingQuoteInsertController.InternalException e){
            System.assertEquals('The data for the selected template could not be retrieved.', e.getMessage());
        }
    }
    
    static testMethod void testPrepareToSave_NoExternalId(){
        IST__SuperTRUMP_Template__c template = createTemplate();
        Account acc = new Account();
        Test.setCurrentPage(Page.Operations_Pricing_Quote_Insert);
        ApexPages.StandardController con = new ApexPages.StandardController(acc);
        OperationsPricingQuoteInsertController controller = new OperationsPricingQuoteInsertController(con);
        controller.templateId = String.valueOf(template.ID);
        
        try{
            // no template set, should throw an error
            Test.startTest();
            controller.prepareToSave();
            Test.stopTest();
            System.assert(false, 'An exception should have been thrown.');
        }
        catch(OperationsPricingQuoteInsertController.InsertionException e){
            System.assertEquals('The field \'stExternalId__c\' must be present in the quote object.', e.getMessage());
        }
    }
    
    static testMethod void testPrepareToSave(){
        IST__SuperTRUMP_Template__c template = createTemplate();
        Operations_Pricing_Quote__c quote = new Operations_Pricing_Quote__c();
        OperationsPricingQuoteInsertController controller = setupController(quote);
        controller.templateId = String.valueOf(template.ID);
        
        Test.startTest();
        String transactionState = controller.prepareToSave();
        Test.stopTest();
        
        System.assertEquals(TEST_TRANSACTION_STATE, transactionState);
    }
    
    static testMethod void testCreatePRM(){
        Schedule__c schedule = createSchedule();
        Operations_Pricing_Quote__c quote = getNewOpsQuote(schedule);
        OperationsPricingQuoteInsertController controller = setupController(quote);
        
        insert quote;
        
        Test.startTest();
        boolean isCreated = controller.createPRM(TEST_TRANSACTION_STATE);
        Test.stopTest();
        
        System.assert(isCreated, 'An attachment should have been created.');
        Attachment[] attachments = [SELECT ID, Name, Body, ParentId FROM Attachment LIMIT 10];
        System.assertEquals(1, attachments.size(), 'There should only be one attachment.');
        System.assertEquals(quote.ID, attachments[0].ParentId, 'The attachment to reference the quote.');
        System.assertEquals(TEST_TRANSACTION_STATE, System.EncodingUtil.base64Encode(attachments[0].Body));
    }
    
    static testMethod void testDoSave_QuoteSaveFailed(){
        Operations_Pricing_Quote__c quote = new Operations_Pricing_Quote__c();
        OperationsPricingQuoteInsertController controller = setupController(quote);
        
        Test.startTest();
        // fail because the quote fields are not set
        PageReference ref = controller.doSave(TEST_TRANSACTION_STATE);
        Test.stopTest();
        
        // save failed, sending back to the same page
        System.assertEquals(null, ref, 'The page reference should be null.');
    }
    
    static testMethod void testDoSave_PRMSaveFailed(){
        Schedule__c schedule = createSchedule();
        IST__SuperTRUMP_Template__c template = getNewTemplate();
        insert template;
        Operations_Pricing_Quote__c quote = new Operations_Pricing_Quote__c();
        quote.Schedule__c = schedule.ID;
        OperationsPricingQuoteInsertController controller = setupController(quote);
        
        Test.startTest();
        // fail because there is no transaction state in the template
        PageReference ref = controller.doSave(null);
        Test.stopTest();
        
        // save failed, sending back to the same page
        System.assertEquals(null, ref, 'The page reference should be null.');
    }
    
    static testMethod void testDoSave(){
        Schedule__c schedule = createSchedule();
        Operations_Pricing_Quote__c quote = new Operations_Pricing_Quote__c();
        // this quote field should be set by the page
        quote.Schedule__c = schedule.ID;
        OperationsPricingQuoteInsertController controller = setupController(quote);
        
        Test.startTest();
        // should succeed
        PageReference ref = controller.doSave(TEST_TRANSACTION_STATE);
        Test.stopTest();
        
        // save failed, sending back to the same page
        System.assertNotEquals(null, ref, 'The page reference should NOT be null.');
    }
    
    static testMethod void testSave_NoTemplate(){
        Operations_Pricing_Quote__c quote = new Operations_Pricing_Quote__c();
        OperationsPricingQuoteInsertController controller = setupController(quote);
        
        Test.startTest();
        PageReference ref = controller.save();
        Test.stopTest();
        
        System.assertEquals(null, ref, 'The save should NOT have succeeded.');
    }
    
    static testMethod void testSave(){
        /*
        We dont' test a successful save using the save method because it would call the SuperTRUMP
        package asynchronous synchSFToST, which we are not setup to run.  Instead we rely on unit
        tests to provide coverage and test that everything is functioning properly
        */
        System.assert(true);
    }
    
    static testMethod void testGetTemplateOptions(){
        createTemplate();
        Operations_Pricing_Quote__c quote = new Operations_Pricing_Quote__c();
        OperationsPricingQuoteInsertController controller = setupController(quote);
        
        Test.startTest();
        System.SelectOption[] options = controller.getTemplateOptions();
        Test.stopTest();
        
        System.assertEquals(1, options.size());
        System.assertEquals(controller.templateId, options[0].getValue());
    }
    
    static testMethod void testGetTimezoneOffset(){
        ID userId = UserInfo.getUserId();
        User u = [SELECT ID, TimeZoneSidKey FROM User WHERE ID = :userId LIMIT 1];
        u.TimeZoneSidKey = 'America/Los_Angeles';
        update u;
        
        Test.startTest();
        DateTime dt = DateTime.newInstance(2014, 1, 1, 0, 0, 0);
        Integer timezoneOffset = OperationsPricingQuoteInsertController.getTimeZoneOffset(dt);
        Test.stopTest();
        
        System.assertEquals(480, timezoneOffset);
    }

    private static OperationsPricingQuoteInsertController setupController(Operations_Pricing_Quote__c pq){
        Test.setCurrentPage(Page.Operations_Pricing_Quote_Insert);
        ApexPages.StandardController stdController = new ApexPages.StandardController(pq);
        return new OperationsPricingQuoteInsertController(stdController);
    }

    private static Letter_Of_Intent__c getNewLetterOfIntent(){
        return new Letter_Of_Intent__c();
    }
    
    private static Schedule__c getNewSchedule(){
        Schedule__c schedule =  new Schedule__c(
            Name = 'Test Schedule'
        );
        
        return schedule;
    }
    
    private static Schedule__c createSchedule(){
        Letter_Of_Intent__c loi = getNewLetterOfIntent();
        insert loi;
        Schedule__c s = getNewSchedule();
        s.Letter_of_Intent__c = loi.ID;
        insert s;
        
        return s;
    }
    
    private static Operations_Pricing_Quote__c getNewOpsQuote(Schedule__c schedule){
        System.assertNotEquals(null, schedule.ID);
        
        return new Operations_Pricing_Quote__c(
            Schedule__c = schedule.ID
        );
    }
    
    private static IST__SuperTRUMP_Template__c getNewTemplate(){
        return new IST__SuperTRUMP_Template__c(Name = 'Economic Summary');
    }
    
    private static IST__SuperTRUMP_Template__c createTemplate(){
        IST__SuperTRUMP_Template__c template = getNewTemplate();
        insert template;
        
        Attachment prm = new Attachment(
            Name = OperationsPricingQuoteInsertController.QUOTE_ATTACHMENT_NAME,
            Body = System.EncodingUtil.base64Decode(TEST_TRANSACTION_STATE),
            ParentId = template.ID
        );
        insert prm;
        
        return template;
    }
}