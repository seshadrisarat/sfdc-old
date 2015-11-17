/**
* \arg ClassName      : SL_Test_WS_CreateDocument
* \arg JIRATicket     : OAKHILL-6
* \arg CreatedOn      : 30/DEC/2014
* \arg LastModifiedOn : 30/DEC/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as test class for SL_WS_CreateDocument webservice.
*/
@isTest
private class SL_Test_WS_CreateDocument 
{
    static final String strCustomObjectRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =:'Custom_Object'].Id;
    static final String strAttachRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =:'Attach'].Id;
    static Account objAccount;
    static Fund_Family__c objFundFamily;
    static Fund__c objFund;
    static Legal_Entity__c objLegalEntity;
    static List<Report_Generator__c> lstReportGenerator;
    static List<Related_Account__c> lstRelatedAccount;
    static List<Transaction__c> lstTransaction;
    static List<Contact> lstContact;
    static List<Investor_Contact__c> lstInvestorContact;
    static List<Loop__DDP__c> lstDDP;
    static List<Loop__DDP_Integration_Option__c> lstDeliveryOption;
    static List<SL_LoopParameters__c> lstLoopParameters;
    static List<Month_End_Balance__c> lstMonthEndBalance;
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
    										new Loop__DDP__c(Name = 'Capital Call', Loop__Object_Name__c = 'Transaction_Document__c', RecordTypeId = strCustomObjectRecordTypeId),
    										new Loop__DDP__c(Name = 'Capital Call Statement', Loop__Object_Name__c = 'Transaction_Document__c', RecordTypeId = strCustomObjectRecordTypeId),
    										new Loop__DDP__c(Name = 'Distribution', Loop__Object_Name__c = 'Transaction_Document__c', RecordTypeId = strCustomObjectRecordTypeId)
    								   };
    	insert lstDDP;
    	
    	lstDeliveryOption = new List<Loop__DDP_Integration_Option__c>{
    																	  new Loop__DDP_Integration_Option__c(Name = 'Send to Loop Storage', RecordTypeId = strAttachRecordTypeId, Loop__DDP__c = lstDDP[0].Id),
    																	  new Loop__DDP_Integration_Option__c(Name = 'Send to Loop Storage', RecordTypeId = strAttachRecordTypeId, Loop__DDP__c = lstDDP[1].Id),
    																	  new Loop__DDP_Integration_Option__c(Name = 'Send to Loop Storage', RecordTypeId = strAttachRecordTypeId, Loop__DDP__c = lstDDP[2].Id)
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
		
		lstMonthEndBalance = new List<Month_End_Balance__c>{
    															new Month_End_Balance__c(Name = '20141010', Related_Account__c = lstRelatedAccount[0].Id, Commitment_Funded_c__c = 123, Net_Balance__c = 8977),
    															new Month_End_Balance__c(Name = '20141011', Related_Account__c = lstRelatedAccount[0].Id, Commitment_Funded_c__c = 124, Net_Balance__c = 8978),
    															new Month_End_Balance__c(Name = '20141012', Related_Account__c = lstRelatedAccount[1].Id, Commitment_Funded_c__c = 125, Net_Balance__c = 8979),
    															new Month_End_Balance__c(Name = '20141013', Related_Account__c = lstRelatedAccount[1].Id, Commitment_Funded_c__c = 126, Net_Balance__c = 8970)
    														};
    	insert lstMonthEndBalance;
		
		lstLoopParameters = new List<SL_LoopParameters__c>{
																new SL_LoopParameters__c(Name = 'Capital Call', Checkbox_API_Name__c = 'Capital_Call__c', 
																						 DDPId__c = lstDDP[0].Id, DeliveryOptionId__c = lstDeliveryOption[0].Id, Record_Type_Developer_Name__c = 'Capital_Call'),
																
																new SL_LoopParameters__c(Name = 'Capital Call Statement', Checkbox_API_Name__c = 'Balance_Statement__c', 
																						 DDPId__c = lstDDP[1].Id, DeliveryOptionId__c = lstDeliveryOption[1].Id, Record_Type_Developer_Name__c = 'Contribution'),
																
																new SL_LoopParameters__c(Name = 'Distribution', Checkbox_API_Name__c = 'Estimate__c', 
																						 DDPId__c = lstDDP[2].Id, DeliveryOptionId__c = lstDeliveryOption[2].Id, Record_Type_Developer_Name__c = 'Distribution')
														  };
		insert lstLoopParameters;
    }
    
    //checking for capital call
    static testMethod void checkForCapitalCall() 
    {
        createData();
        
        Date dtToday = Date.today();
        Test.startTest();
        SL_WS_CreateDocuments.createDocuments(lstReportGenerator[0].Id, objFund.Id, 'Capital Call', String.join(new List<String>{String.valueOf(dtToday.month()),String.valueOf(dtToday.day()), String.valueOf(dtToday.year())},'/'));
        Test.stopTest();
    }
    
    //checking for disribution
    static testMethod void checkForDistribution() 
    {
        createData();
        
        Date dtToday = Date.today();
        Test.startTest();
        SL_WS_CreateDocuments.createDocuments(lstReportGenerator[2].Id, objFund.Id, 'Distribution', String.join(new List<String>{String.valueOf(dtToday.month()),String.valueOf(dtToday.day()), String.valueOf(dtToday.year())},'/'));
        Test.stopTest();
    }
    
    //checking for capital call statement
    static testMethod void checkForCapitalCallStatement() 
    {
        createData();
        
        Date dtToday = Date.today();
        Test.startTest();
        SL_WS_CreateDocuments.createDocuments(lstReportGenerator[1].Id, objFund.Id, 'Capital Call Statement', String.join(new List<String>{String.valueOf(dtToday.month()),String.valueOf(dtToday.day()), String.valueOf(dtToday.year())},'/'));
        Test.stopTest();
    }
}