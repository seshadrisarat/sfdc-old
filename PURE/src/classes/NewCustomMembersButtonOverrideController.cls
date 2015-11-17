/*
*		NewCustomMembersButtonOverrideController is controller class for New Members (custom) button overrides
*		This controller is used to redirected to the custom Members VF page.
* 
*		Author	:	Wilson Ng 
*		Date	:	January 30, 2013
* 
*/
public with sharing class NewCustomMembersButtonOverrideController {

    public NewCustomMembersButtonOverrideController(ApexPages.StandardController controller) {
    }
       
    public PageReference init() {
    	// retrieve Members record type value
		id memberRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Member').getRecordTypeId();
		// navigate to new custom Member new edit page
		PageReference nextPage = Page.NewEditMembersPage;
		nextPage.getParameters().put('RecordType', memberRTId);
		nextPage.getParameters().put('ent', 'Account');
        return nextPage;
    }
    
    //
    // test method
    @isTest
    static void testThisClass_Members() {
    	// create dummy member
		Member_do_not_use__c memb = new Member_do_not_use__c();
		
		Test.startTest();
		
		PageReference pageRef = Page.NewCustomMembersButtonOverride;
		Test.setCurrentPageReference(pageRef);		
		NewCustomMembersButtonOverrideController controller = new NewCustomMembersButtonOverrideController(new ApexPages.StandardController(memb));

		PageReference nextPage = controller.init();
		system.assert(nextPage.getUrl().containsIgnoreCase('NewEditMembersPage'), 'Error: Override controller did not redirect member record type to custom NewEditMembersPage vf page.');
		
		Test.stopTest();
    }
}