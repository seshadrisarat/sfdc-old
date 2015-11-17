/*
*		ListingFlowController is used to perform Controller logic for THS Listing Flow VF pages.
*		This controller is used for display the custom UI for the THS Listing Flow.
* 
*		Author	:	Wilson Ng 
*		Date	:	November 7, 2012
* 
*/
public with sharing class ListingFlowController extends FlowController {

	public final Listing__c listing;
	public ListingFlowController listingController { get; set; }

	public ListingFlowController(ApexPages.StandardController controller) {
		this.listing = (Listing__c)controller.getRecord();
		this.listingController = this;
	}
	
	public PageReference gotoListingDetail() {
		return redirectPage(Page.ListingFlow_1ListingDetail, this.listing.Id);
	}

	public PageReference gotoManageContacts() {
		return redirectPage(Page.ListingFlow_2AssociateContacts, this.listing.Id);
	}

	public PageReference gotoManageComps() {
		return redirectPage(Page.ListingFlow_3ManageComps, this.listing.Id);
	}

	public PageReference gotoSimilarListings() {
		return redirectPage(Page.ListingFlow_4ManageSimilarListings, this.listing.Id);
	}
	
	//
	// test methods
	@isTest
	static void testThisClass() {
		
		// dummy data
		Location_Neighborhood__c loc = new Location_Neighborhood__c(Name='testloc');
		insert loc;
		Property__c prop = new Property__c(Name='test property', Location_Neighborhood__c=loc.Id, Thor_Ownership__c='Thor Prospect');
		insert prop;
		Listing__c listing = new Listing__c(Name='test property', Property__c=prop.Id);
		insert listing;
		
		Test.startTest();

		ListingFlowController lfc = new ListingFlowController(new ApexPages.StandardController(listing));

		PageReference nextPage = lfc.gotoListingDetail();
		system.assert(nextPage.getUrl().containsIgnoreCase('_1ListingDetail?id='), 'Error: ListingFlowController did not redirect to listing detail page.');
		
		nextPage = lfc.gotoManageContacts();
		system.assert(nextPage.getUrl().containsIgnoreCase('_2AssociateContacts?id='), 'Error: ListingFlowController did not redirect to manage contacts page.');
		
		nextPage = lfc.gotoManageComps();
		system.assert(nextPage.getUrl().containsIgnoreCase('_3ManageComps?id='), 'Error: ListingFlowController did not redirect to manage comps page.');
		
		nextPage = lfc.gotoSimilarListings();
		system.assert(nextPage.getUrl().containsIgnoreCase('_4ManageSimilarListings?id='), 'Error: ListingFlowController did not redirect to similar listing page.');

		
		Test.stopTest();
	}
}