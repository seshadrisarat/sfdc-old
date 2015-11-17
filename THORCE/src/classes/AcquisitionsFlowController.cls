/*
*		AcquisitionsFlowController is used to perform Controller logic for the Acquisitions Flows VF pages.
* 
*		Author	:	Wilson Ng 
*		Date	:	November 7, 2012
* 
*/
public with sharing class AcquisitionsFlowController extends FlowController {

	public final Property__c property;
	public AcquisitionsFlowController acqController { get; set; }
	
	public AcquisitionsFlowController(ApexPages.StandardController controller) {
		this.property = (Property__c)controller.getRecord();
		this.acqController = this;
	}
	
	public PageReference gotoPropertyDetail() {
		return redirectPage(Page.AcquisitionsFlow_1PropertyDetail, this.property.Id);
	}
	
	public PageReference gotoManageContacts() {
		return redirectPage(Page.AcquisitionsFlow_2ManageContacts, this.property.Id);
	}
	
	public PageReference gotoManageComps() {
		return redirectPage(Page.AcquisitionsFlow_3ManageComps, this.property.Id);
	}
	
	public PageReference gotoManageRentRolls() {
		return redirectPage(Page.AcquisitionsFlow_4ManageRentRolls, this.property.Id);
	}
	
	public PageReference gotoManageDeals() {
		return redirectPage(Page.AcquisitionsFlow_5ManageDeals, this.property.Id);
	}
	
	//
	// test methods
	@isTest
	static void testThisClass() {
		
		// dummy data
		Location_Neighborhood__c loc = new Location_Neighborhood__c(Name='testloc');
		insert loc;
		Property__c prop = new Property__c(Name='test property', Location_Neighborhood__c=loc.Id);
		insert prop;
		
		Test.startTest();

		AcquisitionsFlowController afc = new AcquisitionsFlowController(new ApexPages.StandardController(prop));

		PageReference nextPage = afc.gotoPropertyDetail();
		system.assert(nextPage.getUrl().containsIgnoreCase('_1PropertyDetail?id='), 'Error: AcquisitionsFlowController did not redirect to property detail page.');
		
		nextPage = afc.gotoManageContacts();
		system.assert(nextPage.getUrl().containsIgnoreCase('_2ManageContacts?id='), 'Error: AcquisitionsFlowController did not redirect to manage contacts page.');
		
		nextPage = afc.gotoManageComps();
		system.assert(nextPage.getUrl().containsIgnoreCase('_3ManageComps?id='), 'Error: AcquisitionsFlowController did not redirect to manage comps page.');
		
		nextPage = afc.gotoManageRentRolls();
		system.assert(nextPage.getUrl().containsIgnoreCase('_4ManageRentRolls?id='), 'Error: AcquisitionsFlowController did not redirect to manage rent rolls page.');
		
		nextPage = afc.gotoManageDeals();
		system.assert(nextPage.getUrl().containsIgnoreCase('_5ManageDeals?id='), 'Error: AcquisitionsFlowController did not redirect to manage deals page.');
		
		Test.stopTest();
	}
}