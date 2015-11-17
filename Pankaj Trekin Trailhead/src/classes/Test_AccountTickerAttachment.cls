/**
* \arg ClassName      : Test_AccountTickerAttachment
* \arg JIRATicket     : TT-217
* \arg CreatedOn      : 25/JUNE/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as test class for checking the functionality for AccountTickerAttachment inbound email handler which is intended for creating Attachment records related to Account when an email is sent with ticker symbol as subject.
*/@isTest
private class Test_AccountTickerAttachment 
{
    static Account objAccount;
    static Messaging.InboundEmail.BinaryAttachment binaryAttachment;
    static Messaging.InboundEmail.Textattachment textAttachment;
    
    static void createData()
    {
    	objAccount = new Account(Name = 'Test Account', Ticker__c = 'TEST');
    	insert objAccount;
    	
    	binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
	    binaryAttachment.Filename = 'test.pdf';
	    binaryAttachment.body = blob.valueOf('my attachment text1');
	    
	    textAttachment = new Messaging.InboundEmail.Textattachment();
	    textAttachment.Filename = 'test.pdf';
	    textAttachment.body = 'Sample Text';
	    
    }
    
    static testMethod void checkWithAttachment() 
    {
    	createData();
		// create a new email and envelope object
	    Messaging.InboundEmail email = new Messaging.InboundEmail() ;
	    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
	  
	    // setup the data for the email
	    email.subject = 'TEST';
	    email.fromname = 'Test User';
	    email.plainTextBody = 'Test Test';
	    env.fromAddress = 'test@salesforce.com';
	  	
	    email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
	    email.textAttachments = new Messaging.InboundEmail.Textattachment[]{textAttachment};
	  	
	    // call the email service class and test it with the data in the testMethod
	    AccountTickerAttachment objAccountTickerAttachment = new AccountTickerAttachment();
	    objAccountTickerAttachment.handleInboundEmail(email, env); 
	    
	    System.assertEquals(2, [SELECT COUNT() FROM Attachment WHERE ParentId =: objAccount.Id]);
    }
    
    static testMethod void checkWithoutAttachment()
    {
    	createData();
		// create a new email and envelope object
	    Messaging.InboundEmail email = new Messaging.InboundEmail() ;
	    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
	  
	    // setup the data for the email
	    email.subject = 'TEST';
	    email.fromname = 'Test User';
	    email.plainTextBody = 'Test Test';
	    env.fromAddress = 'test@salesforce.com';
	  	
	    // call the email service class and test it with the data in the testMethod
	    AccountTickerAttachment objAccountTickerAttachment = new AccountTickerAttachment();
	    objAccountTickerAttachment.handleInboundEmail(email, env); 
	    
	    System.assertEquals(0, [SELECT COUNT() FROM Attachment WHERE ParentId =: objAccount.Id]);
    }
}