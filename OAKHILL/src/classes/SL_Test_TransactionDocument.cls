/**
* \arg ClassName      : SL_Test_TransactionDocument
* \arg JIRATicket     : OAKHILL-7
* \arg CreatedOn      : 13/OCT/2014
* \arg LastModifiedOn : 5/JAN/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as test class for checking the functionality of transaction document component controller.
*/

@isTest
private class SL_Test_TransactionDocument 
{
    static Report_Generator__c objReportGenerator;
    static List<Investor_Report_Document__c> lstTransactionDocument;    
    static SL_TransactionDocumentController objTransactionDocument;
    
    //method for preparing data
    static void createData()
    {
    	objReportGenerator = new Report_Generator__c(Name = 'Test Report Generator', Report_Generator_Type__c = 'Capital Call');
    	insert objReportGenerator;
    	
    	lstTransactionDocument = new List<Investor_Report_Document__c>();
    	//Preparing data
    	for(Integer i = 1; i <= 200; i++)
    	{
    		lstTransactionDocument.add(new Investor_Report_Document__c(Report_Generator__c = objReportGenerator.Id, Status__c = (i <= 5 ?'Unsent' : i>5 && i<=100 ? 'Rejected' : 'Approved'), Document_Link__c = 'Test Document Link'+i));
    	}
    	insert lstTransactionDocument;
    	objTransactionDocument = new SL_TransactionDocumentController();
    	objTransactionDocument.ReportGeneratorId = objReportGenerator.Id;
    }
    
    //method for record display
    static testMethod void checkForRecordDisplay() 
    {
        createData();
        
        Test.startTest();
        objTransactionDocument.fetchRecords();
        Test.stopTest();
    }
    
    //method for record sorting
    static testMethod void checkForSorting()
    {
    	 createData();
    	 objTransactionDocument.strSortExpresion = 'Status__c';
    	 objTransactionDocument.strSortDirection = 'ASC';
    	 objTransactionDocument.fetchRecords();
    	 
    	 Test.startTest();
    	 objTransactionDocument.sortRecords();
    	 Test.stopTest();
    	 
    	 for(Integer i=6;i < objTransactionDocument.lstTransactionDocument.size();i++)
    	 {
    	 	System.assertEquals('Approved', objTransactionDocument.lstTransactionDocument[i].Status__c);
    	 }
    }
   
    //method for showing records on first page
    static testMethod void checkForFirstPage()
    {
    	 createData();
    	 objTransactionDocument.strSortExpresion = 'Name';
    	 objTransactionDocument.strSortDirection = 'ASC';
    	 objTransactionDocument.fetchRecords();
    	 
    	 Test.startTest();
    	 objTransactionDocument.goToFirstPage();
    	 Test.stopTest();
    }
    
    //method for showing records on last page
    static testMethod void checkForLastPage()
    {
    	 createData();
    	 objTransactionDocument.fetchRecords();
    	 
    	 Test.startTest();
    	 objTransactionDocument.goToLastPage();
    	 Test.stopTest();
    }
    
    //method for showing records on previous and next page
    static testMethod void checkForPreviousAndNextPage()
    {
    	 createData();
    	 objTransactionDocument.fetchRecords();
    	 
    	 Test.startTest();
    	 objTransactionDocument.goToNextPage();
    	 objTransactionDocument.goToPreviousPage();
    	 Test.stopTest();
    }
    
    //method for showing records on random page
    static testMethod void checkForRandomPage()
    {
    	createData();
    	objTransactionDocument.fetchRecords();
    	objTransactionDocument.page = 14;
    	
    	Test.startTest();
    	objTransactionDocument.goToPage();
    	Test.stopTest();
    }
    
    //method for updating records using javascript remoting method
    static testMethod void checkForStatusUpdate()
    {
    	 createData();
    	 objTransactionDocument.fetchRecords();
    	 
    	 Test.startTest();
    	 SL_TransactionDocumentController.updateTransactionDocument(lstTransactionDocument[0].Id, 'Sent');
    	 Test.stopTest();
    }
    
    static testMethod void checkForApproveOrReject()
    {
    	 createData();
    	 objTransactionDocument.fetchRecords();
    	 
    	 Test.startTest();
    	 objTransactionDocument.approveOrRejectRecord();
    	 Test.stopTest();
    }
}