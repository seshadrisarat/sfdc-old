/**
* \arg ClassName      : SL_Test_WS_GenerateMergedPDF
* \arg JIRATicket     : OAKHILL-6
* \arg CreatedOn      : 30/DEC/2014
* \arg LastModifiedOn : 30/DEC/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as test class for SL_WS_EmailDocument webservice.
*/
@isTest
private class SL_Test_WS_GenerateMergedPDF 
{
    static Fund_Family__c objFundFamily;
    static Fund__c objFund;
    static Account objAccount;
    static List<Report_Generator__c> lstReportGenerator;
    static List<Investor_Report_Document__c> lstTransactionDocument;
    static List<Loop__Document_Request__c> lstDocumentRequest;
    static List<Related_Account__c> lstRelatedAccount;
    
    //create data
    private static void createData()
    {
    	objAccount = new Account(Name = 'Account1');
    	insert objAccount;
    	
    	objFundFamily = new Fund_Family__c(Name = 'Fund_Family_1');
		insert objFundFamily;
		
		objFund = new Fund__c(Name = 'Name', Fund_Family__c = objFundFamily.Id );
		insert objFund;
    	
    	Legal_Entity__c objLegal_Entity = new Legal_Entity__c(Name = 'LegalEntity1', Organization__c = objAccount.Id, 
															  Tax_Number__c = '123450');
		insert objLegal_Entity;
    	
    	lstRelatedAccount = new List<Related_Account__c>{
															new  Related_Account__c(Name = 'RelatedAccount1', 
																					Legal_Entity__c = objLegal_Entity.Id, Fund__c = objFund.Id),
															new  Related_Account__c(Name = 'RelatedAccount2', 
																					Legal_Entity__c = objLegal_Entity.Id, Fund__c = objFund.Id),
															new  Related_Account__c(Name = 'RelatedAccount3', 
																					Legal_Entity__c = objLegal_Entity.Id, Fund__c = objFund.Id)
														};
		insert lstRelatedAccount;
    	
    	lstReportGenerator = new List<Report_Generator__c>{
																new Report_Generator__c(Name = 'RG 1', Run_Date__c = date.today(), Report_Generator_Type__c = 'Capital Call', Fund__c = objFund.Id),
																new Report_Generator__c(Name = 'RG 2', Run_Date__c = date.today(), Report_Generator_Type__c = 'Capital Call Statement', Fund__c = objFund.Id),
																new Report_Generator__c(Name = 'RG 3', Run_Date__c = date.today(), Report_Generator_Type__c = 'Distribution', Fund__c = objFund.Id)
														  };
		insert lstReportGenerator;
		
		lstTransactionDocument = new List<Investor_Report_Document__c>{
																		new Investor_Report_Document__c(Report_Generator__c = lstReportGenerator[0].Id, Related_Account__c = lstRelatedAccount[0].Id, Status__c = 'Approved'),
																		new Investor_Report_Document__c(Report_Generator__c = lstReportGenerator[0].Id, Related_Account__c = lstRelatedAccount[1].Id, Status__c = 'Approved'),
																		new Investor_Report_Document__c(Report_Generator__c = lstReportGenerator[0].Id, Related_Account__c = lstRelatedAccount[2].Id, Status__c = 'Approved')
																  };
		
		insert lstTransactionDocument;
		
		lstDocumentRequest = new List<Loop__Document_Request__c>{
																	new Loop__Document_Request__c(Loop__Object_Id__c = lstTransactionDocument[0].Id, Loop__Status__c = 'Complete'),
																	new Loop__Document_Request__c(Loop__Object_Id__c = lstTransactionDocument[1].Id, Loop__Status__c = 'Complete'),
																	new Loop__Document_Request__c(Loop__Object_Id__c = lstTransactionDocument[2].Id, Loop__Status__c = 'Complete')
																};
		insert lstDocumentRequest;
    }
    
    //check for merged pdf
    static testMethod void checkForMergedPDF()
    {
    	createData();
    	
    	Test.startTest();
    	SL_WS_GenerateMergedPDF.mergeFiles(lstReportGenerator[0].Id, 'RG 1');
    	Test.stopTest();
    }
}