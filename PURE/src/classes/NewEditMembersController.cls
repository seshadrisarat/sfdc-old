/*
*		NewEditMembersController is controller class for New and Edit Members (Account) page.
*		This controller is used to save or cancel changes in the New and Edit Members page.
* 
*		Author	:	Wilson Ng 
*		Date	:	January 30, 2013
* 
*/
public with sharing class NewEditMembersController {

	final Account record; 
	
    public NewEditMembersController(ApexPages.StandardController controller) {
    	this.record = (Account) controller.getRecord();
    }
       
    public PageReference saveAndNew() {
    	if(this.record.Id == null)
    		insert record;
    	else
    		update record;
    		
    	PageReference nextPage = new PageReference('/001/e');
		// append url parmeters for RecordType and ent
		nextPage.getParameters().put('RecordType', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Member').getRecordTypeId());
		nextPage.getParameters().put('ent', 'Account');
        return nextPage;
    }
    
    //
    // test method
    @isTest
    static void testThisClass_Update() {
    	// create dummy account
		Account acct = new Account(Name='test Account', RecordType=new Recordtype(Name='Member'));
		insert acct;
		acct = [select Id, Name, RecordTypeId from Account where Id = :acct.Id];
		
		Test.startTest();
		
		PageReference pageRef = Page.NewEditMembersPage;
		Test.setCurrentPageReference(pageRef);		
		NewEditMembersController controller = new NewEditMembersController(new ApexPages.StandardController(acct));

		// test update
		controller.record.BillingStreet = 'test street';
		PageReference nextPage = controller.saveAndNew();
		
		Test.stopTest();
    }
    
    @isTest
    static void testThisClass_Insert() {
    	// create dummy account
		Account acct = new Account();
		
		Test.startTest();
		
		PageReference pageRef = Page.NewEditMembersPage;
		Test.setCurrentPageReference(pageRef);		
		NewEditMembersController controller = new NewEditMembersController(new ApexPages.StandardController(acct));

		// insert new
		controller.record.Name = 'test Account 2';
		PageReference nextPage = controller.saveAndNew();
		
		Test.stopTest();
    }
}