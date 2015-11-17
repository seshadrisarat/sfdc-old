@isTest
private class TC_RequestUCCExtTest {
	
	@isTest static void testUcc() {
		CSC_Integration__c cs = new CSC_Integration__c();
	    cs.Name = 'csc';
	    Account a = new Account(Name = 'Test Account');
	    //a.BillingState = 'pa';
	    a.State_of_Incorporation__c = 'CA';
	    a.ucc_name_search__c = 'TCBY';
	    a.CSC_Order_Number__c = '74877477';
	    insert a;

	    cs.endpoint__c = 'endpoint';
	    cs.login__c = 'login';
	    cs.contact__c = '123';
	    insert cs;


	    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    	mock.setStaticResource('CSC_SubmitOnlineSearch');
    	mock.setStatusCode(200);
    	mock.setHeader('Content-Type', 'application/xml');

    	// Set the mock callout mode
    	Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();

		TC_RequestUCCExt ext = new TC_RequestUCCExt (new ApexPages.StandardController (a));
		ext.requestUCC();

		a.State_of_Incorporation__c = 'MN';
		update a;

		ext.requestUCC();

		Test.stopTest();

		System.assertEquals(System.today(),[SELECT Id, UCCs_Last_Checked_On__c FROM Account WHERE Id = :a.Id].UCCs_Last_Checked_On__c);
	}
	
}