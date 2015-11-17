/**
* \arg ClassName      : SL_Test_WS_EmailDocument
* \arg JIRATicket     : OAKHILL-23
* \arg CreatedOn      : 30/DEC/2014
* \arg LastModifiedOn : 30/DEC/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as test class for SL_WS_EmailDocument webservice.
*/
@isTest
private class SL_Test_WS_EmailDocument 
{
    static final String strCustomObjectRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =:'Custom_Object'].Id;
    static final String strEmailRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =:'Email'].Id;
    static Account objAccount;
    static Fund_Family__c objFundFamily;
    static Fund__c objFund;
    static Legal_Entity__c objLegalEntity;
    static List<Report_Generator__c> lstReportGenerator;
    static List<Related_Account__c> lstRelatedAccount;
    static List<Transaction__c> lstTransaction;
    static List<Contact> lstContact;
    static List<Investor_Contact__c> lstInvestorContact;
    static List<Investor_Report_Document__c> lstTransactionDocument;
    static List<Document_Recipient__c> lstDocumentRecipient;
    static List<Loop__DDP__c> lstDDP;
    static List<Loop__DDP_Integration_Option__c> lstDeliveryOption;
    static List<SL_LoopParameterForEmail__c> lstLoopParametersForEmail;
    static List<LStore__Stored_Document__c> lstStoredDocument;
    //create data
    private static void createData()
    {
    	objAccount = new Account(Name = 'Account1');
    	insert objAccount;
    	
    	lstContact = new List<Contact>{
    									 new Contact(LastName = 'Test Contact 1', AccountId = objAccount.Id),
    									 new Contact(LastName = 'Test Contact 2', AccountId = objAccount.Id),
    									 new Contact(LastName = 'Test Contact 3', AccountId = objAccount.Id),
    									 new Contact(LastName = 'Test Contact 4', AccountId = objAccount.Id)
    								  };
    	insert lstContact;
    	
    	lstDDP = new List<Loop__DDP__c>{
    										new Loop__DDP__c(Name = 'Capital Call', Loop__Object_Name__c = 'Investor_Report_Document__c', RecordTypeId = strCustomObjectRecordTypeId),
    										new Loop__DDP__c(Name = 'Capital Call Statement', Loop__Object_Name__c = 'Investor_Report_Document__c', RecordTypeId = strCustomObjectRecordTypeId),
    										new Loop__DDP__c(Name = 'Distribution', Loop__Object_Name__c = 'Investor_Report_Document__c', RecordTypeId = strCustomObjectRecordTypeId)
    								   };
    	insert lstDDP;
    	
    	lstDeliveryOption = new List<Loop__DDP_Integration_Option__c>{
    																	  new Loop__DDP_Integration_Option__c(Name = 'Send to Loop Storage', RecordTypeId = strEmailRecordTypeId, Loop__DDP__c = lstDDP[0].Id),
    																	  new Loop__DDP_Integration_Option__c(Name = 'Send to Loop Storage', RecordTypeId = strEmailRecordTypeId, Loop__DDP__c = lstDDP[1].Id),
    																	  new Loop__DDP_Integration_Option__c(Name = 'Send to Loop Storage', RecordTypeId = strEmailRecordTypeId, Loop__DDP__c = lstDDP[2].Id)
    																 };
   		insert lstDeliveryOption;
   		
   		objFundFamily = new Fund_Family__c(Name = 'Fund_Family_1');
		insert objFundFamily;
		
		objFund = new Fund__c(Name = 'Name', Fund_Family__c = objFundFamily.Id );
		insert objFund;
		
		lstReportGenerator = new List<Report_Generator__c>{
																new Report_Generator__c(Name = 'RG 1', Run_Date__c = date.today(), Report_Generator_Type__c = 'Capital Call', Fund__c = objFund.Id),
																new Report_Generator__c(Name = 'RG 2', Run_Date__c = date.today(), Report_Generator_Type__c = 'Capital Call Statement', Fund__c = objFund.Id),
																new Report_Generator__c(Name = 'RG 3', Run_Date__c = date.today(), Report_Generator_Type__c = 'Distribution', Fund__c = objFund.Id)
														  };
		insert lstReportGenerator;
		
		Legal_Entity__c objLegal_Entity = new Legal_Entity__c(Organization__c = objAccount.Id, 
																	Name = 'LegalEntity1', 
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
		
		lstInvestorContact = new List<Investor_Contact__c>{
																new Investor_Contact__c(Contact__c = lstContact[0].Id, Investment__c = lstRelatedAccount[0].Id, Capital_Call__c = true, Estimate__c = true, Balance_Statement__c = true),
																new Investor_Contact__c(Contact__c = lstContact[1].Id, Investment__c = lstRelatedAccount[1].Id, Capital_Call__c = true, Estimate__c = true, Balance_Statement__c = true),
																new Investor_Contact__c(Contact__c = lstContact[2].Id, Investment__c = lstRelatedAccount[2].Id, Capital_Call__c = true, Estimate__c = true, Balance_Statement__c = true)
														  };
		insert lstInvestorContact;
		
		lstTransaction = new List<Transaction__c>{
													new Transaction__c(Name = 'Test TR 1', Related_Account__c = lstRelatedAccount[0].Id, Date__c = date.today()),
													new Transaction__c(Name = 'Test TR 2', Related_Account__c = lstRelatedAccount[1].Id, Date__c = date.today()),
													new Transaction__c(Name = 'Test TR 3', Related_Account__c = lstRelatedAccount[2].Id, Date__c = date.today())
												 };
		insert lstTransaction;
		
		lstTransactionDocument = new List<Investor_Report_Document__c>{
																		new Investor_Report_Document__c(Report_Generator__c = lstReportGenerator[0].Id, Related_Account__c = lstRelatedAccount[0].Id, Status__c = 'Approved'),
																		new Investor_Report_Document__c(Report_Generator__c = lstReportGenerator[0].Id, Related_Account__c = lstRelatedAccount[1].Id, Status__c = 'Approved'),
																		new Investor_Report_Document__c(Report_Generator__c = lstReportGenerator[0].Id, Related_Account__c = lstRelatedAccount[2].Id, Status__c = 'Approved')
																  };
		
		insert lstTransactionDocument;
		
		lstDocumentRecipient = new List<Document_Recipient__c>{
																	new Document_Recipient__c(Investor_Report_Document__c = lstTransactionDocument[0].Id, Contact__c = lstContact[0].Id),
																	new Document_Recipient__c(Investor_Report_Document__c = lstTransactionDocument[0].Id, Contact__c = lstContact[0].Id),
																	new Document_Recipient__c(Investor_Report_Document__c = lstTransactionDocument[1].Id, Contact__c = lstContact[1].Id),
																	new Document_Recipient__c(Investor_Report_Document__c = lstTransactionDocument[1].Id, Contact__c = lstContact[1].Id),
																	new Document_Recipient__c(Investor_Report_Document__c = lstTransactionDocument[2].Id, Contact__c = lstContact[2].Id),
																	new Document_Recipient__c(Investor_Report_Document__c = lstTransactionDocument[2].Id, Contact__c = lstContact[2].Id)
															  };
		insert lstDocumentRecipient;
		
		lstLoopParametersForEmail = new List<SL_LoopParameterForEmail__c>{
																			new SL_LoopParameterForEmail__c(Name = 'Capital Call', DDPId__c = lstDDP[0].Id, Delivery_Option_Id__c = lstDeliveryOption[0].Id),																	
																			new SL_LoopParameterForEmail__c(Name = 'Capital Call Statement', DDPId__c = lstDDP[1].Id, Delivery_Option_Id__c = lstDeliveryOption[1].Id),																	
																			new SL_LoopParameterForEmail__c(Name = 'Distribution', DDPId__c = lstDDP[2].Id, Delivery_Option_Id__c = lstDeliveryOption[2].Id)
														  		   		  };
		insert lstLoopParametersForEmail;
		
		lstStoredDocument = new List<LStore__Stored_Document__c>{
																	new LStore__Stored_Document__c(Name = 'Test Document 1', LStore__Related_Object_Id__c = lstTransactionDocument[0].Id),
																	new LStore__Stored_Document__c(Name = 'Test Document 2', LStore__Related_Object_Id__c = lstTransactionDocument[1].Id),
																	new LStore__Stored_Document__c(Name = 'Test Document 3', LStore__Related_Object_Id__c = lstTransactionDocument[2].Id)
																};
																
		insert lstStoredDocument;
    }
    
    //updating transaction document records
    private static void updateTransactionDocument()
    {
    	update new List<Investor_Report_Document__c>{
        											new Investor_Report_Document__c(Id = lstTransactionDocument[0].Id, Status__c = 'Approved'),
													new Investor_Report_Document__c(Id = lstTransactionDocument[1].Id, Status__c = 'Approved'),
													new Investor_Report_Document__c(Id = lstTransactionDocument[2].Id, Status__c = 'Approved')
        										};
    }
    
    static testMethod void checkForCapitalCall()
    {
    	createData();
        updateTransactionDocument();
        
        Test.startTest();
        SL_WS_EmailDocument.emailDocuments(lstReportGenerator[0].Id,'Capital Call');
        Test.stopTest();
    }
    
    static testMethod void checkForNull()
    {
    	createData();
     	updateTransactionDocument();
     	
        Test.startTest();
        SL_WS_EmailDocument.emailDocuments(lstReportGenerator[0].Id,NULL);
        Test.stopTest();
    }
    
    static testMethod void checkForDistribution()
    {
    	createData();
        updateTransactionDocument();
        
        Test.startTest();
        SL_WS_EmailDocument.emailDocuments(lstReportGenerator[0].Id,'Distribution');
        Test.stopTest();
    }
    
    static testMethod void checkForCapitalCallStatement()
    {
    	createData();
        updateTransactionDocument();
        
        Test.startTest();
        SL_WS_EmailDocument.emailDocuments(lstReportGenerator[0].Id,'Capital Call Statement');
        Test.stopTest();
    }    
}