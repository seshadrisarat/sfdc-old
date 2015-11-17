/*
*       ViewListingOverrideController is controller class for View Listing button overrides
*       This controller is used to determine whether the current user should redirected to the custom Flows, or to the std SF detail pages.
* 
*       Author  :   Wilson Ng 
*       Date    :   November 06, 2012
* 
*/
public with sharing class ViewListingOverrideController {

    ViewSobjectOverrideHelper overrideHelper;

    public ViewListingOverrideController(ApexPages.StandardController controller) {
        this.overrideHelper = new ViewSobjectOverrideHelper(
            (string)ApexPages.currentPage().getParameters().get('id'),
            Schema.SobjectType.Listing__c.getKeyPrefix(),
            new list<string> { 'Leasing and THS', 'THS', 'System Administrator' },
            Page.ListingFlow_1ListingDetail,
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
        
        // create dummy listing
        Location_Neighborhood__c loc = new Location_Neighborhood__c(Name='testloc');
        insert loc;
        Property__c prop = new Property__c(Name='test property', Location_Neighborhood__c=loc.Id, Thor_Ownership__c='Thor Prospect');
        insert prop;
        Listing__c listing = new Listing__c(Name='test property', Property__c=prop.Id);
        insert listing;
        
        Test.startTest();
        
        ViewListingOverrideController controller = new ViewListingOverrideController(new ApexPages.StandardController(listing));
        PageReference nextPage = controller.initView();
        system.assert(nextPage.getUrl().containsIgnoreCase('ListingFlow_1ListingDetail'), 'Error: ViewListingOverride did not redirect to listing flow page 1.');
        
        Test.stopTest();
    }
}