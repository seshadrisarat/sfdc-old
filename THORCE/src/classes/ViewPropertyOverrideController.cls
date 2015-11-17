/*
*       ViewPropertyOverrideController is controller class for View Property button overrides
*       This controller is used to determine whether the current user should redirected to the custom Flows, or to the std SF detail pages.
* 
*       Author  :   Wilson Ng 
*       Date    :   November 06, 2012
* 
*/
public with sharing class ViewPropertyOverrideController {

    ViewSobjectOverrideHelper overrideHelper;

    public ViewPropertyOverrideController(ApexPages.StandardController controller) {
        this.overrideHelper = new ViewSobjectOverrideHelper(
            (string)ApexPages.currentPage().getParameters().get('id'),
            Schema.SobjectType.Property__c.getKeyPrefix(),
            new list<string> { 'Acquisitions and Leasing', 'Acquisitions', 'System Administrator' },
            Page.AcquisitionsFlow_1PropertyDetail,
            (string)ApexPages.currentPage().getParameters().get('retURL')
        );
    }
    
    public PageReference initView() {
        return overrideHelper.initView();
    }
    
    //
    // test method
    @isTest
    static void testThisClass() {
        
        // create dummy property
        Location_Neighborhood__c loc = new Location_Neighborhood__c(Name='test loc');
        insert loc;
        Property__c prop = new Property__c(Name='test property', Location_Neighborhood__c=loc.Id);
        insert prop;
        
        Test.startTest();
        
        ViewPropertyOverrideController controller = new ViewPropertyOverrideController(new ApexPages.StandardController(prop));
        PageReference nextPage = controller.initView();
        system.assert(nextPage.getUrl().containsIgnoreCase('AcquisitionsFlow_1PropertyDetail'), 'Error: ViewPropertyOverride did not redirect to acquisitions flow page 1.');
        
        Test.stopTest();
    }
}