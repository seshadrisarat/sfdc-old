/**
* \arg ClassName        : SL_TestManageCandidateJobOrderEmail
* \arg JIRATicket       : GA-23
* \arg CreatedOn        : 21/May/2015
* \arg LastModifiedOn   : -
* \arg CreatededBy      : Pankaj Ganwani
* \arg ModifiedBy       : -
* \arg Description      : This class is used to check the functionality of email service which is being used to keep track of email records that are sent corresponding to Job order and contact records.
*/
@isTest
private class SL_TestManageCandidateJobOrderEmail 
{
	static String strRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Candidate'].Id;
    static String strPortfolioRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'ts2__Job__c' AND DeveloperName = 'Portfolio'].Id;
	
	static Account objAccount;
	static List<Contact> lstContact;
	static List<ts2__Job__c> lstJobOrders;
	
	private static void createData()
	{
		objAccount = new Account(Name = 'Test Account');
		insert objAccount;
		
		lstContact = new List<Contact>{
											new Contact(FirstName = 'Test', LastName = 'Contact1', RecordTypeId = strRecordTypeId),
											new Contact(FirstName = 'Test', LastName = 'Contact2', RecordTypeId = strRecordTypeId)
									   };
		insert lstContact;
		
		lstJobOrders = new List<ts2__Job__c>{
												new ts2__Job__c(Name = 'CTO', ts2__Account__c = objAccount.Id, RecordTypeId = strPortfolioRecordTypeId),
												new ts2__Job__c(Name = 'CEO', ts2__Account__c = objAccount.Id, RecordTypeId = strPortfolioRecordTypeId)
											};
		insert lstJobOrders;
	}
	
	private static testMethod void checkForContact()
	{
		createData();
		// create a new email and envelope object
	    Messaging.InboundEmail email = new Messaging.InboundEmail() ;
	    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
	  
	    // setup the data for the email
	    email.subject = 'Test Contact1';
	    email.fromname = 'Test User';
	    email.plainTextBody = 'Test Test';
	    env.fromAddress = 'test@salesforce.com';
	  
	    // call the email service class and test it with the data in the testMethod
	    SL_ManageCandidateJobOrderEmailServices objCJEmailService = new SL_ManageCandidateJobOrderEmailServices();
	    objCJEmailService.handleInboundEmail(email, env); 
	}
	
	private static testMethod void checkForJobOrder()
	{
		createData();
		// create a new email and envelope object
	    Messaging.InboundEmail email = new Messaging.InboundEmail() ;
	    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
	  
	    // setup the data for the email
	    email.subject = 'CTO Test Account';
	    email.fromname = 'Test User';
	    email.plainTextBody = 'Test Test';
	    env.fromAddress = 'test@salesforce.com';
	  
	    // call the email service class and test it with the data in the testMethod
	    SL_ManageCandidateJobOrderEmailServices objCJEmailService = new SL_ManageCandidateJobOrderEmailServices();
	    objCJEmailService.handleInboundEmail(email, env); 
	}
	
	private static testMethod void checkForOrphan()
	{
		createData();
		// create a new email and envelope object
	    Messaging.InboundEmail email = new Messaging.InboundEmail() ;
	    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
	  
	    // setup the data for the email
	    email.subject = 'test test test test';
	    Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
	    binaryAttachment.Filename = 'test.pdf';
	    binaryAttachment.body = blob.valueOf('my attachment text');
	    email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
	    email.fromname = 'Test User';
	    email.plainTextBody = 'Test Test';
	    env.fromAddress = 'test@salesforce.com';
	  
	    // call the email service class and test it with the data in the testMethod
	    SL_ManageCandidateJobOrderEmailServices objCJEmailService = new SL_ManageCandidateJobOrderEmailServices();
	    objCJEmailService.handleInboundEmail(email, env); 
	}      
}