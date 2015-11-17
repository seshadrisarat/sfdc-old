/*
*       ViewTenantOverrideController is controller class for View Account button overrides
*       This controller is used to determine whether the current user should redirected to the custom Flows, or to the std SF detail pages.
* 
*       Author  :   Wilson Ng 
*       Date    :   November 06, 2012
* 
*/
public with sharing class ViewTenantOverrideController {

    final Account record; 
    ViewSobjectOverrideHelper overrideHelper;
    
    public ViewTenantOverrideController(ApexPages.StandardController controller) {
        this.overrideHelper = new ViewSobjectOverrideHelper(
            (string)ApexPages.currentPage().getParameters().get('id'),
            Schema.SobjectType.Account.getKeyPrefix(),
            new list<string> { 'THS', 'Leasing and THS', 'System Administrator' },
            Page.HighStreetFlow_1TenantDetail,
            (string)ApexPages.currentPage().getParameters().get('retURL')
        );
        this.record = (Account) controller.getRecord();
    }
       
    public PageReference initView() {
        // check for Tenant RT only
        id tenantRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Tenant').getRecordTypeId();
        if(this.record.RecordTypeId != tenantRTId)
            overrideHelper.checkProfiles.clear();       // this should force redirect to std detail page
        return overrideHelper.initView();
    }
    
    //
    // test method
    @isTest
    static void testThisClass_Tenant() {
        
        // create dummy account/tenant
        Account acct = new Account(Name='test tenant', RecordType=new RecordType(Name='Tenant'));
        insert acct;
        acct = [select Id, Name, RecordTypeId from Account where Id = :acct.Id];
        
        Test.startTest();
        
        ViewTenantOverrideController controller = new ViewTenantOverrideController(new ApexPages.StandardController(acct));
        PageReference nextPage = controller.initView();
        system.assert(nextPage.getUrl().containsIgnoreCase('HighStreetFlow_1TenantDetail'), 'Error: ViewTenantOverride did not redirect to high street flow page 1.');
        
        Test.stopTest();
    }
    
    @isTest
    static void testThisClass_NonTenant() {
        
        // create dummy account/tenant
        Account acct = new Account(Name='test non tenant', RecordType=new RecordType(Name='Landlord'));
        insert acct;
        acct = [select Id, Name, RecordTypeId from Account where Id = :acct.Id];
        
        Test.startTest();
        
        ViewTenantOverrideController controller = new ViewTenantOverrideController(new ApexPages.StandardController(acct));
        PageReference nextPage = controller.initView();
        system.assert(nextPage.getUrl().containsIgnoreCase('nooverride'), 'Error: ViewTenantOverride did not redirect to nooverride standard SF detail page.');
        
        Test.stopTest();
    }
}