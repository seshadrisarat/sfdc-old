/*
*		FlowController is used to perform Controller logic for Flows VF pages and controllers.
*		This controller contains re-usabled methods for all the Flows-related controllers.
* 
*		Author	:	Wilson Ng 
*		Date	:	November 7, 2012
* 
*/
public with sharing virtual class FlowController {

	public PageReference init() {
		string newid = (String) ApexPages.currentPage().getParameters().get('newid');
		if(newid != null && newid != '') {
			PageReference nextPage = ApexPages.currentPage();
			nextPage.getParameters().put('id', newid);
			nextPage.getParameters().put('newid', null);
			nextPage.setRedirect(true);
			return nextPage;
		}
		return null;
	}
	
	protected PageReference redirectPage(PageReference nextpage, Id id) {
		nextpage.getParameters().put('id', id);
		nextpage.setRedirect(true);
		return nextpage;
	}
	
	//
	// test methods
	@isTest
	static void testThisClass() {
		
		// dummy data
		Account acct = new Account(Name='test account');
		insert acct;
		
		Test.startTest();

		PageReference pageRef = Page.HighStreetFlow_1TenantDetail;
		Test.setCurrentPageReference(pageRef);		
		FlowController fc = new FlowController();
		ApexPages.currentPage().getParameters().put('newid', acct.Id);

		PageReference nextPage = fc.init();
		system.assert(!nextPage.getUrl().containsIgnoreCase('newid='), 'Error: FlowController init() did not redirect newid url parameter to id url parameter.');
		
		nextPage = fc.redirectPage(Page.HighStreetFlow_1TenantDetail, acct.id);
		system.assert(nextPage.getUrl().containsIgnoreCase('id='), 'Error: FlowController redirectPage() did not add id url parameter.');
		
		Test.stopTest();
	}
}