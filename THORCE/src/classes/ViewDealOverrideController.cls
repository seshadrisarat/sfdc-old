/*
*       ViewDealOverrideController is controller class for View Deal button overrides
*       This controller is used to determine whether the current user should redirected to the custom Flows, or to the std SF detail pages.
* 
*       Author  :   Wilson Ng 
*       Date    :   November 06, 2012
* 
*/
public with sharing class ViewDealOverrideController {

    final Deal__c record; 
    ViewSobjectOverrideHelper overrideHelper;

    public ViewDealOverrideController(ApexPages.StandardController controller) {
        this.overrideHelper = new ViewSobjectOverrideHelper(
            (string)ApexPages.currentPage().getParameters().get('id'),
            Schema.SobjectType.Deal__c.getKeyPrefix(),
            new list<string> { 'Acquisitions and Leasing', 'Leasing and THS', 'Leasing', 'System Administrator' },
            Page.LeasingFlow_1DealDetail,
            (string)ApexPages.currentPage().getParameters().get('retURL')
        );
        this.record = (Deal__c) controller.getRecord();
    }
    
    public PageReference initView() {
        // check for Leasing Deal RT only
        id leasingDealRTId = Schema.SObjectType.Deal__c.getRecordTypeInfosByName().get('Leasing Deal').getRecordTypeId();
        if(this.record.RecordTypeId != leasingDealRTId)
            overrideHelper.checkProfiles.clear();       // this should force redirect to std detail page 
        PageReference nextPage = overrideHelper.initView();

        //leasing deal rt navigates to the new LeasingDealDetailPage VF page
        if(this.record.RecordTypeId == leasingDealRTId && string.isNotEmpty(nextPage.getParameters().get('nooverride'))) {
            nextPage = Page.LeasingDealDetailPage;
            nextPage.getParameters().put('id', this.record.Id);
            // add retURL parameter if in the current url
            if(string.isNotEmpty((string)ApexPages.currentPage().getParameters().get('retURL')))
                nextPage.getParameters().put('retURL', (string)ApexPages.currentPage().getParameters().get('retURL'));
        }
        return nextPage;
    }
    
    //
    // test method
    @isTest
    static void testThisClass_LeasingDeal1() {
        
        // create dummy deal
        Deal__c deal = new Deal__c(Name='test leasing deal', RecordType=new RecordType(Name='Leasing Deal'));
        insert deal;
        deal = [select Id, Name, RecordTypeId from Deal__c where Id = :deal.Id];
        
        Test.startTest();
        
        // test leasing flow redirect
        ViewDealOverrideController controller = new ViewDealOverrideController(new ApexPages.StandardController(deal));
        PageReference nextPage = controller.initView();
        system.assert(nextPage.getUrl().containsIgnoreCase('LeasingFlow_1DealDetail'), 'Error: ViewDealOverride did not redirect to leasing flow page 1.');
        
        Test.stopTest();
    }
    
     @isTest
    static void testThisClass_LeasingDeal2() {
        
        // needs to execute this test method as non-Leasing and non-System Admin User
        Profile p = [SELECT Id FROM Profile WHERE Name='Thor Retail'];
        User u = new User(Alias = 'thsusr', Email='ths.user@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='ths.user@testorg.com');
        System.runAs(u) {
            // create dummy deal
            Deal__c deal = new Deal__c(Name='test leasing deal', RecordType=new RecordType(Name='Leasing Deal'));
            insert deal;
            deal = [select Id, Name, RecordTypeId from Deal__c where Id = :deal.Id];
            
            Test.startTest();
            
            // test leasing flow nooverride
            ViewDealOverrideController controller = new ViewDealOverrideController(new ApexPages.StandardController(deal));
            ApexPages.currentPage().getParameters().put('retURL', '/home/home.jsp');
            PageReference nextPage = controller.initView();
            system.assert(nextPage.getUrl().containsIgnoreCase('LeasingDealDetailPage'), 'Error: ViewDealOverride nooverride did not redirect to custom LeasingDealDetailPage vf page.');
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testThisClass_NonLeasingDeal() {
        
        // create dummy deal
        Deal__c deal = new Deal__c(Name='test non leasing deal', RecordType=new RecordType(Name='THS Deal'));
        insert deal;
        deal = [select Id, Name, RecordTypeId from Deal__c where Id = :deal.Id];
        
        Test.startTest();
        
        ViewDealOverrideController controller = new ViewDealOverrideController(new ApexPages.StandardController(deal));
        PageReference nextPage = controller.initView();
        system.assert(nextPage.getUrl().containsIgnoreCase('nooverride'), 'Error: ViewDealOverride did not redirect to nooverride standard SF detail page.');
        
        Test.stopTest();
    }
}