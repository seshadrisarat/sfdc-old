/*
*		NewEditDealOverrideController is controller class for New and Edit Deal button overrides
*		This controller is used to determine whether the deal record type is leasing deal.  If yes, then redirect to the LeasingDealDetailPage, else std nooverride page
* 
*		Author	:	Wilson Ng 
*		Date	:	December 05, 2012
* 
*/
public with sharing class NewEditDealOverrideController {

	final Deal__c record; 

	public NewEditDealOverrideController(ApexPages.StandardController controller) {
    	this.record = (Deal__c) controller.getRecord();
	}
	
	public PageReference initNewEdit() {
		PageReference nextPage;

		// get default record type for current user
		id myRecordTypeId = (this.record.RecordTypeId!=null ? this.record.RecordTypeId : getDefaultDealRecordTypeId() );
		// check for Leasing Deal RT only
		id leasingDealRTId = Schema.SObjectType.Deal__c.getRecordTypeInfosByName().get('Leasing Deal').getRecordTypeId();
		if(myRecordTypeId != leasingDealRTId) {
			nextPage = new PageReference('/' + (this.record.Id != null ? (string)this.record.Id : Schema.SObjectType.Deal__c.getKeyPrefix()) + '/e' );
			nextPage.getParameters().put('nooverride', '1');
		}
		else {
			//leasing deal rt navigates to the new LeasingDealDetailPage VF page
			nextPage = Page.LeasingDealDetailPage;
			nextPage.getParameters().put('isedit', '1');
			// add id parameter
            if(this.record.Id != null)
            	nextPage.getParameters().put('id', this.record.Id);
		}
		
		// copy all url parameters from currPage to nextPage
		system.debug('URL parameters: ' + ApexPages.currentPage().getParameters());
        nextPage.getParameters().putAll(ApexPages.currentPage().getParameters());
        nextPage.getParameters().put('save_new', null);	// fix - remove this parameter

		// navigate to next page
		return nextPage;
	}
	private Id getDefaultDealRecordTypeId() {
		Schema.DescribeSObjectResult d = Schema.SObjectType.Deal__c;
		Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
		for(Schema.RecordTypeInfo rinfo : rtMapById.values())
			if(rinfo.isAvailable() && rinfo.isDefaultRecordTypeMapping())
				return rinfo.getRecordTypeId();
		return null;
	}
	
		
	//
	// test methods
	@isTest
	static void testThisClass_LeasingDeal() {
		
		// create dummy deal
		Deal__c deal = new Deal__c(Name='test leasing deal', RecordType=new Recordtype(Name='Leasing Deal'));
		insert deal;
		deal = [select Id, Name, RecordTypeId from Deal__c where Id = :deal.Id];
		
		Test.startTest();
		
		PageReference pageRef = Page.NewEditDealOverride;
		Test.setCurrentPageReference(pageRef);		
		NewEditDealOverrideController controller = new NewEditDealOverrideController(new ApexPages.StandardController(deal));
		ApexPages.currentPage().getParameters().put('retURL', '/home/home.jsp');

		PageReference nextPage = controller.initNewEdit();
		system.assert(nextPage.getUrl().containsIgnoreCase('LeasingDealDetailPage'), 'Error: Override controller did not redirect leasing deal to custom LeasingDealDetailPage vf page.');
		
		Test.stopTest();
	}
	
	@isTest
	static void testThisClass_NonLeasingDeal() {
		
		// create dummy deal
		Deal__c deal = new Deal__c(Name='test ths deal', RecordType=new Recordtype(Name='THS Deal'));
		insert deal;
		deal = [select Id, Name, RecordTypeId from Deal__c where Id = :deal.Id];
		
		Test.startTest();
		
		PageReference pageRef = Page.NewEditDealOverride;
		Test.setCurrentPageReference(pageRef);		
		NewEditDealOverrideController controller = new NewEditDealOverrideController(new ApexPages.StandardController(deal));
		ApexPages.currentPage().getParameters().put('retURL', '/home/home.jsp');

		PageReference nextPage = controller.initNewEdit();
		system.assert(nextPage.getUrl().containsIgnoreCase('nooverride'), 'Error: Override controller did not redirect non-leasing deal to nooverride standard SF page.');
		
		Test.stopTest();
	}
	
	@isTest
	static void testThisClass_DefaultDeal() {
		
		// create dummy deal
		Deal__c deal = new Deal__c(Name='test leasing deal');
		insert deal;
		
		Test.startTest();
		
		PageReference pageRef = Page.NewEditDealOverride;
		Test.setCurrentPageReference(pageRef);		
		NewEditDealOverrideController controller = new NewEditDealOverrideController(new ApexPages.StandardController(deal));
		ApexPages.currentPage().getParameters().put('retURL', '/home/home.jsp');

		PageReference nextPage = controller.initNewEdit();
		
		Test.stopTest();
	}
}