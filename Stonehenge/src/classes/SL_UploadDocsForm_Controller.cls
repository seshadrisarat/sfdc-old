/**
* \Author: Shailendra
* \Date: 21/Dec/2011
* \See http://silverline.jira.com/browse/STONEPII-26
* \Brief : Controller for the Document Upload Form in the Application
*/ 

public with sharing class SL_UploadDocsForm_Controller 
{
    /*  Global Variables    */
    /*  Document variables  */
    public Blob photoIdentificationAttachment {get;set;}
    public Blob letterOfEmploymentAttachment {get;set;} 
    public Blob payStubsAttachment1 {get;set;}
    public Blob payStubsAttachment2	{get;set;}
    public Blob bankStatementsAttachment1 {get;set;}
    public Blob bankStatementsAttachment2{get;set;}
    public Blob taxReturnsAttachment1 {get;set;}
    public Blob taxReturnsAttachment2 {get;set;}
    public Blob petPhotoAttachment {get;set;}
    /*  End of Document Variables   */
    
    /*  Document FileName variables */
    public String pidName{get;set;}
    public String taxReturnsName1{get;set;}
    public String taxReturnsName2{get;set;}
    public String bankStatementName1{get;set;}
    public String bankStatementName2{get;set;}
    public String payStubsName1{get;set;}
    public String payStubsName2{get;set;}
    public String employmentLetterName{get;set;}
    public String petPhotoName{get;set;}
    public String isSuccess{get;set;}
    public String validSize{get;set;}
    /*  End of Document FileName variables  */
    /*  End of Global Variables */
    
    public Id currentId{get;set;} // Contact Role Id
    
    public SL_UploadDocsForm_Controller()
    {
        currentId = Apexpages.currentPage().getParameters().get('cid'); // contains the contact role ID
        isSuccess = ApexPages.currentPage().getParameters().get('isSuccess');   // to display the success message after doc upload
        validSize = ApexPages.currentPage().getParameters().get('validSize'); // to display the failure message for invalid size
    }
    
    
    /*  Method : submitDocs
        Parameters : none
        desc : saves the docs submitted by the applicant in the related Opportunity and displays the success message after upload
    */
    public pageReference submitDocs()
    {
        try
        {
            List<Attachment> lstAttachments = new List<Attachment>();
            Contact_Role__c objCR = new Contact_Role__c();
            objCR = [Select Id, Opportunity__c, Contact__r.Name From Contact_Role__c Where Id =: currentId];	// the current Contact Role record
            
            if(objCR != null)
            {
                if(validateFileSize())	// validating the attachments for their size 
                {
                    if(photoIdentificationAttachment != null)
                    {
                        Attachment photoId = new Attachment();
                        photoId.ParentId = objCR.Opportunity__c;
                        photoId.Name = objCR.Contact__r.Name + '-' + 'Photo ID';
                        if(pidName.contains('.'))
                            photoId.Name += pidName.substring(pidName.indexOf('.'),pidName.length());
                        photoId.body = photoIdentificationAttachment;
                        lstAttachments.add(photoId);
                        objCR.Submitted_PhotoId__c = true;
                    }
                    
                    if(letterOfEmploymentAttachment != null)
                    {
                        Attachment letterOfEmployment = new Attachment();
                        letterOfEmployment.ParentId = objCR.Opportunity__c;
                        letterOfEmployment.Name = objCR.Contact__r.Name + ' ' + 'Letter of Employment';
                        if(employmentLetterName.contains('.'))
                            letterOfEmployment.Name += employmentLetterName.substring(employmentLetterName.indexOf('.'),employmentLetterName.length());
                        letterOfEmployment.body = letterOfEmploymentAttachment;
                        lstAttachments.add(letterOfEmployment);
                        objCR.Submitted_Employment_Letter__c = true;
                    }
                    
                    if(payStubsAttachment1 != null)
                    {
                        Attachment payStubs = new Attachment();
                        payStubs.ParentId = objCR.Opportunity__c;
                        payStubs.Name = objCR.Contact__r.Name + ' ' + 'Pay Stub-1';
                        if(payStubsName1.contains('.'))
                            payStubs.Name += payStubsName1.substring(payStubsName1.indexOf('.'),payStubsName1.length());
                        payStubs.body = payStubsAttachment1;
                        lstAttachments.add(payStubs);
                        objCR.Submitted_Pay_Stubs__c = true;
                    }
                    
                    if(payStubsAttachment2 != null)
                    {
                        Attachment payStubs = new Attachment();
                        payStubs.ParentId = objCR.Opportunity__c;
                        payStubs.Name = objCR.Contact__r.Name + ' ' + 'Pay Stub-2';
                        if(payStubsName2.contains('.'))
                            payStubs.Name += payStubsName2.substring(payStubsName2.indexOf('.'),payStubsName2.length());
                        payStubs.body = payStubsAttachment2;
                        lstAttachments.add(payStubs);
                        objCR.Submitted_Pay_Stubs__c = true;
                    }
                    
                    if(bankStatementsAttachment1 != null)
                    {
                        Attachment bankStatements = new Attachment();
                        bankStatements.ParentId = objCR.Opportunity__c;
                        bankStatements.Name = objCR.Contact__r.Name + ' ' + 'Bank Statements-1';
                        if(bankStatementName1.contains('.'))
                            bankStatements.Name += bankStatementName1.substring(bankStatementName1.indexOf('.'),bankStatementName1.length());
                        bankStatements.body = bankStatementsAttachment1;
                        lstAttachments.add(bankStatements);
                        objCR.Submitted_Bank_Statements__c = true;
                    }
                    
                    if(bankStatementsAttachment2 != null)
                    {
                        Attachment bankStatements = new Attachment();
                        bankStatements.ParentId = objCR.Opportunity__c;
                        bankStatements.Name = objCR.Contact__r.Name + ' ' + 'Bank Statements-2';
                        if(bankStatementName2.contains('.'))
                            bankStatements.Name += bankStatementName2.substring(bankStatementName2.indexOf('.'),bankStatementName2.length());
                        bankStatements.body = bankStatementsAttachment2;
                        lstAttachments.add(bankStatements);
                        objCR.Submitted_Bank_Statements__c = true;
                    }
                    
                    if(taxReturnsAttachment1 != null)
                    {
                        Attachment taxReturns = new Attachment();
                        taxReturns.ParentId = objCR.Opportunity__c;
                        taxReturns.Name = objCR.Contact__r.Name + ' ' + 'Tax Returns-1';
                        if(taxReturnsName1.contains('.'))
                            taxReturns.Name += taxReturnsName1.substring(taxReturnsName1.indexOf('.'),taxReturnsName1.length());
                        taxReturns.body = taxReturnsAttachment1;
                        lstAttachments.add(taxReturns);
                        objCR.Submitted_Tax_Returns__c = true;
                    } 
                    
                    if(taxReturnsAttachment2 != null)
                    {
                        Attachment taxReturns = new Attachment();
                        taxReturns.ParentId = objCR.Opportunity__c;
                        taxReturns.Name = objCR.Contact__r.Name + ' ' + 'Tax Returns-2';
                        if(taxReturnsName2.contains('.'))
                            taxReturns.Name += taxReturnsName2.substring(taxReturnsName2.indexOf('.'),taxReturnsName2.length());
                        taxReturns.body = taxReturnsAttachment2;
                        lstAttachments.add(taxReturns);
                        objCR.Submitted_Tax_Returns__c = true;
                    }
                    if(petPhotoAttachment != null)
                    {
                        Attachment petPhoto = new Attachment();
                        petPhoto.ParentId = objCR.Opportunity__c;
                        petPhoto.Name = objCR.Contact__r.Name + ' ' + 'Pet Photo';
                        if(petPhotoName.contains('.'))
                            petPhoto.Name += petPhotoName.substring(petPhotoName.indexOf('.'),petPhotoName.length());
                        petPhoto.body = petPhotoAttachment;
                        lstAttachments.add(petPhoto);
                        objCR.Submitted_Tax_Returns__c = true;
                    }
                    update objCR;
                    // inserting the attachments in the Opportunity record
           			if(lstAttachments.size() > 0)
                		insert lstAttachments;
            
            		// redirect to the Page with Success Message after document uploads
            		//Pagereference pr = new Pagereference('https://stonehenge.uat.cs7.force.com/Application/SL_UploadDocsForm?cid='+currentId+'&isSuccess=true');
           			Pagereference pr = new Pagereference(Site.getCurrentSiteURL() + 'SL_UploadDocsForm?cid='+currentId+'&isSuccess=true');
           			return pr;
                }

                else if(!validateFileSize())
                {
                	// redirect to the Page with failure message regarding large file size
                    //Pagereference pr = new Pagereference('https://stonehenge.uat.cs7.force.com/Application/SL_UploadDocsForm?cid='+objCR.Id+'&validSize=false');
                    Pagereference pr = new Pagereference(Site.getCurrentSiteUrl() + 'SL_UploadDocsForm?cid='+objCR.Id+'&validSize=false');
                    pr.setRedirect(true);
                    return pr;
                }
                
                else
                {
                	return null;
                }
            }
            
            else
            {
            	return null;
            }
        }
        catch(exception e)
        {
            //Pagereference pr = new Pagereference('https://stonehenge.uat.cs7.force.com/Application/SL_UploadDocsForm?cid='+currentId+'&isSuccess=false');
            system.debug('========e=========='+e+'======URL======='+Site.getCurrentSiteURL());
            
            Pagereference pr = new Pagereference(Site.getCurrentSiteURL() + 'SL_UploadDocsForm?cid='+currentId+'&isSuccess=false');
            pr.setRedirect(true);
            return pr;
            //return null;
        }
    }
    
    
    /*  Method : validateAttachments
        Parameters : none
        desc : validates the attachments for their file size (accepts maximum 5mb per document)
    */
    public Boolean validateFileSize()
    {
		try
		{	
			// validating Photo Identification Doc size
	        if(photoIdentificationAttachment != null)
	        {
	        	if(photoIdentificationAttachment.size() > 5242880)
	                return false;
	        }
	        
	        // validating Letter of Employment Doc size
	        if(letterOfEmploymentAttachment != null)
	        {
	            if(letterOfEmploymentAttachment.size() > 5242880)
	                return false;
	        }
	        
	        // validating Pay Stub Doc size
	        if(payStubsAttachment1 != null)
	        {
	            if(payStubsAttachment1.size() > 5242880)
	                return false;
	        }
	        
	        if(payStubsAttachment2 != null)
	        {
	            if(payStubsAttachment2.size() > 5242880)
	                return false;
	        }
	        
	        // validating Tax Returns Doc size
	        if(taxReturnsAttachment1 != null)
	        {
	            if(taxReturnsAttachment1.size() > 5242880)
	                return false;
	        }
	         
	        if(taxReturnsAttachment2 != null)
	        {
	            if(taxReturnsAttachment2.size() > 5242880)
	                return false;
	        }
	        if(petPhotoAttachment != null)
	        {
	            if(petPhotoAttachment.size() > 5242880)
	                return false;
	        }
	        // validating Bank Statements Doc size
	        if(bankStatementsAttachment1 != null)
	        {
	            if(bankStatementsAttachment1.size() > 5242880)
	                return false;
	        }
	        
	        if(bankStatementsAttachment2 != null)
	        {
	            if(bankStatementsAttachment2.size() > 5242880)
	                return false;
	        }
    		return true;
		}
		catch(exception e)
		{
			return null;
		}
    }
    
    /*  Test Coverage Method    */
    @isTest
    private static void uploadDocsTest()
    {
        Account acc = new Account();
        acc.LastName = 'test';
        acc.FirstName = 'first';
        acc.RecordTypeId=[Select Id From RecordType Where Name = 'Client/Tenant Account' And SobjectType='Account'].Id;
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'testOpp';
        opp.AccountId = acc.Id;
        opp.StageName = 'Open';
        opp.CloseDate = date.today();
        insert opp;
        
        Contact_Role__c cr = new Contact_Role__c();
        cr.Opportunity__c = opp.Id;
        cr.Contact__c = acc.Id;
        insert cr;
        
	    SL_UploadDocsForm_Controller docs = new SL_UploadDocsForm_Controller();
	    docs.submitDocs();
        
        ApexPages.currentPage().getParameters().put('cid',cr.Id);
        
        docs = new SL_UploadDocsForm_Controller();
        
        docs.pidName = 'test.jpg';
        docs.bankStatementName1 = 'test.jpg';
        docs.bankStatementName2 = 'test.jpg';
        docs.employmentLetterName = 'test.jpg';
        docs.payStubsName1 = 'test.jpg';
        docs.payStubsName2 = 'test.jpg';
        docs.taxReturnsName1 = 'test.jpg';
        docs.taxReturnsName2 = 'test.jpg';
        docs.petPhotoName = 'test.jpg';
        
        docs.letterOfEmploymentAttachment =  Blob.valueOf('Test EmploymentLetter');     
        docs.payStubsAttachment1 = Blob.valueOf('Test PayStubs1');    
        docs.payStubsAttachment2 = Blob.valueOf('Test PayStubs2');    
        docs.photoIdentificationAttachment = Blob.valueOf('Test PhotoID');  
        docs.taxReturnsAttachment1 = Blob.valueOf('Test TaxReturns1');
        docs.taxReturnsAttachment2 = Blob.valueOf('Test TaxReturns2');   
        docs.petPhotoAttachment = Blob.valueOf('Test PetPhoto'); 
        docs.bankStatementsAttachment1 = Blob.valueOf('Test BankStatements1');    
    	docs.bankStatementsAttachment2 = Blob.valueOf('Test BankStatements2');
    	
        docs.submitDocs();
        
    }
}