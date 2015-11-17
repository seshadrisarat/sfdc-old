/*
*		NewEditMembersButtonOverrideController is controller class for New and Edit Members (Account) button overrides
*		This controller is used to determine whether the current user should redirected to the custom Members VF page, or to the std SF detail pages.
* 
*		Author	:	Wilson Ng 
*		Date	:	January 30, 2013
*	
*	Update History
*	04/11/2013	Redkite			Added functionality to check if the users are allowed to edit members
*								Added Common Config setting for Member Record Type Name
* 
*/
public with sharing class NewEditMembersButtonOverrideController {

	final Account record; 
	private Common_Config__c config;
	
    public NewEditMembersButtonOverrideController(ApexPages.StandardController controller) {
	   	this.record = (Account) controller.getRecord();
  		config = Common_Config__c.getInstance();
    }
       
    public PageReference init() {
    	PageReference nextPage;
    	// check for Members record type value
		id memberRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(config.Account_Member_Type_Name__c).getRecordTypeId();
		if(this.record.RecordTypeId == memberRTId) {
			if (config.Allow_Member_Edit__c == false){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, System.Label.NewEditMembers_CantEdit));
				return null;
			}
			// navigate to new custom Member new edit page
			nextPage = Page.NewEditMembersPage;
		}
		else {
			// navigate to std Account new or edit page
			nextPage = new PageReference('/'+(this.record.Id==null?'001':this.record.Id)+'/e');
			nextPage.getParameters().put('nooverride', '1');
		}
		// append all url parameters
		nextPage.getParameters().putAll(ApexPages.currentPage().getParameters());
		// remove save_new
		nextPage.getParameters().put('save_new', null);
        return nextPage;
    }
    
    //
    // test method
    @isTest
    static void testThisClass_Members() {
		Common_Config__c config = Common_Config__c.getInstance();
		config.Account_Member_Type_Name__c = 'Member';
		config.Allow_Member_Edit__c = true;
		upsert config;

    	// create dummy account
		Account acct = new Account(Name='test Account', RecordType=new Recordtype(Name='Member'));
		insert acct;
		acct = [select Id, Name, RecordTypeId from Account where Id = :acct.Id];
		
		Test.startTest();
		
		PageReference pageRef = Page.NewEditMembersButtonOverride;
		Test.setCurrentPageReference(pageRef);		
		NewEditMembersButtonOverrideController controller = new NewEditMembersButtonOverrideController(new ApexPages.StandardController(acct));

		PageReference nextPage = controller.init();
		system.assert(nextPage.getUrl().containsIgnoreCase('NewEditMembersPage'), 'Error: Override controller did not redirect member record type to custom NewEditMembersPage vf page.');
		
		Test.stopTest();
    }
    
    @isTest
    static void testThisClass_nonMembers() {
		Common_Config__c config = Common_Config__c.getInstance();
		config.Account_Member_Type_Name__c = 'Member';
		config.Allow_Member_Edit__c = true;
		upsert config;

	   	// create dummy account
		Account acct = new Account(Name='test Account', RecordType=new Recordtype(Name='Broker'));
		insert acct;
		acct = [select Id, Name, RecordTypeId from Account where Id = :acct.Id];
		
		Test.startTest();
		
		PageReference pageRef = Page.NewEditMembersButtonOverride;
		Test.setCurrentPageReference(pageRef);		
		NewEditMembersButtonOverrideController controller = new NewEditMembersButtonOverrideController(new ApexPages.StandardController(acct));

		PageReference nextPage = controller.init();
		system.assert(nextPage.getUrl().containsIgnoreCase('nooverride=1'), 'Error: Override controller did not redirect non member record type to standard SF page.');
		
		Test.stopTest();
    }
}