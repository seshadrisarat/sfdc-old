/**
* \arg ClassName        : SL_Test_FileUploadController
* \arg JIRATicket     	: YNHH-160
* \arg CreatedOn      	: 19/AUG/2015
* \arg LastModifiedOn	: -
* \arg CreatededBy    	: Pankaj Ganwani
* \arg ModifiedBy     	: -
* \arg Description      : This class serves as test class for examining the functionality of FileUploadController class.
*/
@isTest
private class SL_Test_FileUploadController 
{	
	//Preparing data for testing the functioanlity
	@testSetup
	static void setupData()
	{
		Case objCase = new Case(Status = 'New', Type = 'Payroll');
		insert objCase;
	}
	
	//checking for upload functionality for success case
    static testMethod void test_FileUpload() 
    {
        Id caseId = [SELECT Id FROM Case LIMIT 1].Id;
        ApexPages.currentPage().getParameters().put('caseId',caseId);
        
        FileUploadController objFileUploader = new FileUploadController();
        objFileUploader.a.Body = Blob.valueOf('Test Body');
        objFileUploader.a.Name = 'Test Attachment';
        objFileUploader.c.CommentBody = 'Test Comments';
        
        Test.startTest();
        objFileUploader.upload();
        Test.stopTest();
        
        System.assert(checkExistence('File uploaded successfully'));
    }
    
    //checking for upload functionality for failure case
    static testMethod void test_UploadFailure() 
    {
        Id caseId = [SELECT Id FROM Case LIMIT 1].Id;
        ApexPages.currentPage().getParameters().put('caseId',caseId);
        
        FileUploadController objFileUploader = new FileUploadController();
        objFileUploader.a.Body = Blob.valueOf('Test Body');
        objFileUploader.c.CommentBody = 'Test Comments';
        
        Test.startTest();
        objFileUploader.upload();
        Test.stopTest();
        
        System.assert(checkExistence('Error uploading file'));
    }
    
    //Method to return status of the page message based on their existence
    static Boolean checkExistence(String Pagemessage)
    {
    	for(ApexPages.Message message : ApexPages.getMessages())
    	{
    		if(message.getSummary().contains(Pagemessage))
    			return true;
    	}	
    	return false;
    }
}