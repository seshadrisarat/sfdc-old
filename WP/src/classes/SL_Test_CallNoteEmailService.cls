/**
* \arg ClassName      : SL_Test_CallNoteEmailService
* \arg JIRATicket     : WP-137
* \arg CreatedOn      : 6/MAY/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as test class for checking the functionality of call note email service handler.
*/
@isTest
private class SL_Test_CallNoteEmailService 
{
	static Account objAccount;
	static Event objEvent;
	static Event objEvent1;
	
	private static void createData()
	{
		objAccount = new Account(Name = 'Test Account');
	    insert objAccount;
		
		objEvent = new Event(Subject = 'Call with Sarah', StartDateTime = Date.Today(), EndDateTime = Date.Today().addDays(5), whatId = objAccount.Id);
	    insert objEvent;
	    
	    objEvent1 = new Event(Subject = 'Call with Sarah', StartDateTime = Date.Today(), EndDateTime = Date.Today().addDays(5), whatId = objAccount.Id, Description='Test11');
	    insert objEvent1;		
	}
	
	
    static testMethod void checkForBlankDescription() 
    {
        createData();
        // create a new email and envelope object
	    Messaging.InboundEmail email = new Messaging.InboundEmail() ;
	    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
	  
	    // setup the data for the email
	    email.subject = 'Test Job Applicant - '+'('+objEvent.Id+')';
	    email.fromname = 'FirstName LastName';
	    email.htmlBody = '<div dir="ltr">Test Notes...<div class="gmail_extra"></div>';
	    env.fromAddress = 'someaddress@email.com';
	  
	    // call the email service class and test it with the data in the testMethod
	    SL_CallNoteEmailService objCallNoteEmailService = new SL_CallNoteEmailService();
	    objCallNoteEmailService.handleInboundEmail(email, env);
	    
	    System.assertEquals([SELECT Description FROM Event WHERE Id=:objEvent.Id].Description, 'Test Notes...');   
    }
    
    static testMethod void checkForNotBlankDescription()
    {
    	 createData();
        // create a new email and envelope object
	    Messaging.InboundEmail email = new Messaging.InboundEmail() ;
	    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
	  
	    // setup the data for the email
	    email.subject = 'Test Job Applicant - '+'('+objEvent1.Id+')';
	    email.fromname = 'FirstName LastName';
	    email.htmlBody = '<div dir="ltr">Test Notes...<div class="gmail_extra"></div>';
	    env.fromAddress = 'someaddress@email.com';
	  
	    // call the email service class and test it with the data in the testMethod
	    SL_CallNoteEmailService objCallNoteEmailService = new SL_CallNoteEmailService();
	    objCallNoteEmailService.handleInboundEmail(email, env);
	    
	    System.assertEquals([SELECT Description FROM Event WHERE Id=:objEvent1.Id].Description, 'Test11 Test Notes...');   
    }
}