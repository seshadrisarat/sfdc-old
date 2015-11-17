/**
* \arg ClassName      : SL_Test_ManageCaseEmailServices
* \arg JIRATicket     : GA-25
* \arg CreatedOn      : 18/May/2015
* \arg LastModifiedOn : 18/May/2015
* \arg CreatededBy    : Sandeep
* \arg ModifiedBy     : Sandeep
* \arg Description    : this is the test class for SL_ManageCaseEmailServices
*/
@isTest
private class SL_Test_ManageCaseEmailServices {
	
	@isTest static void test_mangaeEmailService() 
	{
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// setup the data for the email
		email.subject = 'NEW: Test Subject';
		email.fromname = 'FirstName LastName';
		env.fromAddress = 'generalatlantic@silverlinecrm.com';
		email.plainTextBody = 'hello';
		// call the email service class and test it with the data in the testMethod
		SL_ManageCaseEmailServices emailProcess = new SL_ManageCaseEmailServices();
		emailProcess.handleInboundEmail(email, env);

		System.assertEquals([SELECT Id FROM Case WHERE Subject =: 'Test Subject'].size(), 1);
		System.assertEquals([SELECT Id FROM Task WHERE Subject =: 'Test Subject'].size(), 1);
		email.subject = 'Re: Sandbox: Test Subject';
		ManageCaseEmailServices__c obj = new ManageCaseEmailServices__c(Name = 'EmailServiceEmailAddress', ManageCaseEmailServicesEmail__c = 'generalatlantic@silverlinecrm.com');
		try{
			emailProcess.handleInboundEmail(email, env);
		}
		catch(Exception ex)
		{
			System.debug('===========ex======'+ex);
		}
		email.plainTextBody = 'YES hello this is the body';
		email.inReplyTo = 'test@test.com';
		emailProcess.handleInboundEmail(email, env);
		Case objCase = new Case();
		objCase.subject = 'Test Subject';
		objCase.status = 'Completed';
		insert objCase;
		email.subject = 'Test Subject 2';
		emailProcess.handleInboundEmail(email, env);
		System.assertEquals([SELECT Id FROM Case WHERE Subject =: 'Test Subject'].size(), 2);
		System.assertEquals([SELECT Id FROM Task WHERE Subject =: 'Test Subject'].size(), 2);
	}
}