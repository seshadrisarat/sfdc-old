/*
*		ViewMembersButtonOverrideController is controller class for View Members (Account) button overrides
*		This controller is used to determine whether the current user should redirected to the custom Members VF page, or to the std SF detail pages.
* 
*		Author	:	Wilson Ng 
*		Date	:	January 30, 2013
* 
*/
public with sharing class ViewMembersButtonOverrideController {

	final Account record; 
	
    public ViewMembersButtonOverrideController(ApexPages.StandardController controller) {
    	this.record = (Account) controller.getRecord();
    }
       
    public PageReference init() {
    	PageReference nextPage;
    	// check for Members record type value
		id memberRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Member').getRecordTypeId();
		if(this.record.RecordTypeId == memberRTId) {
			// navigate to new custom Member detail page
			nextPage = Page.ViewMembersPage;
		}
		else {
			// navigate to std Account detail page
			nextPage = new PageReference('/'+(this.record.Id!=null?this.record.Id:'001/o'));
			nextPage.getParameters().put('nooverride', '1');
		}
		// append all url parameters
		nextPage.getParameters().putAll(ApexPages.currentPage().getParameters());
		
        return nextPage;
    }
    
    //
    // test method
    @isTest
    static void testThisClass_Members() {
    	// create dummy account
		Account acct = new Account(Name='test Account', RecordType=new Recordtype(Name='Member'));
		insert acct;
		acct = [select Id, Name, RecordTypeId from Account where Id = :acct.Id];
		
		Test.startTest();
		
		PageReference pageRef = Page.NewEditMembersButtonOverride;
		Test.setCurrentPageReference(pageRef);		
		ViewMembersButtonOverrideController controller = new ViewMembersButtonOverrideController(new ApexPages.StandardController(acct));

		PageReference nextPage = controller.init();
		system.assert(nextPage.getUrl().containsIgnoreCase('ViewMembersPage'), 'Error: Override controller did not redirect member record type to custom ViewMembersPage vf page.');
		
		Test.stopTest();
    }
    
    @isTest
    static void testThisClass_nonMembers() {
    	    	// create dummy account
		Account acct = new Account(Name='test Account', RecordType=new Recordtype(Name='Broker'));
		insert acct;
		acct = [select Id, Name, RecordTypeId from Account where Id = :acct.Id];
		
		Test.startTest();
		
		PageReference pageRef = Page.NewEditMembersButtonOverride;
		Test.setCurrentPageReference(pageRef);		
		ViewMembersButtonOverrideController controller = new ViewMembersButtonOverrideController(new ApexPages.StandardController(acct));

		PageReference nextPage = controller.init();
		system.assert(nextPage.getUrl().containsIgnoreCase('nooverride=1'), 'Error: Override controller did not redirect non member record type to standard SF page.');
		
		Test.stopTest();
    }
}