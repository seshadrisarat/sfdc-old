/**
* \arg ClassName      : SL_Test_CallReportEmailService
* \arg JIRATicket     : PWP-18
* \arg CreatedOn      : 7/APR/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This serves as the test class for checking the functionality of inbound email service. 
*/
@isTest
private class SL_Test_CallReportEmailService 
{
    static testMethod void checkForEmailService() 
    {
	   Account objAccount = new Account(Name = 'Test Account');
	   insert objAccount;
	   
	   Contact objContact = new Contact(LastName = 'Test Contact');
	   insert objContact;
	   
	   Event objEvent = new Event(Subject = 'Call with Sarah', StartDateTime = Date.Today(), EndDateTime = Date.Today().addDays(5), whatId = objAccount.Id);
	   insert objEvent;
	   
	   EventRelation objEventRelation = new EventRelation(RelationId = objContact.Id, EventId = objEvent.Id);
	   insert objEventRelation;
	   
	    // create a new email and envelope object
	    Messaging.InboundEmail email = new Messaging.InboundEmail() ;
	    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
	  
	    // setup the data for the email
	    email.subject = 'Test Job Applicant - '+objEvent.Id;
	    email.fromname = 'FirstName LastName';
	    email.htmlBody = '<div dir="ltr">Test Notes...Please see important legal disclaimer at test delivered by all parties thereto.From: noreply@salesforce.com<div class="gmail_extra">';
	    env.fromAddress = 'someaddress@email.com';
	  
	    // call the email service class and test it with the data in the testMethod
	    SL_CallReportEmailService objCallReportEmailService = new SL_CallReportEmailService();
	    objCallReportEmailService.handleInboundEmail(email, env);   
	}
}