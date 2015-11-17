/** 
    * \arg ClassName             : SL_TestLoanCurrentVolumeController
    * \arg JIRA Ticket           : RA-4
    * \arg CreatedOn             : 19/06/2015
    * \arg LastModifiedOn        : 23/06/2015
    * \arg CreatededBy           : Shailendra Singh
    * \arg ModifiedBy            : Pankaj Ganwani
    * \arg Description           : This is a test class for SL_LoanCurrentVolumeController.                     
**/
@isTest
public with sharing class SL_TestLoanCurrentVolumeController 
{
	static testMethod void testLoanCurrentVolume()
	{
		List<Loan__c> lstLoan = new List<Loan__C>{new Loan__c(Name='Test1',
															  Closing_Date__c=date.parse('03/03/2014'),
															  Loan_Number__c='001',
															  Loan_Stage__c='REO',
															  Total_Commitment__c=100000,
															  Loan_Type__c='Whole Loan'),
												  new Loan__c(Name='Test2',
															  Closing_Date__c=date.parse('05/05/2014'),
															  Loan_Number__c='002',
															  Loan_Stage__c='Funded',
															  Total_Commitment__c=100000,
															  Loan_Type__c='Whole Loan'),
												  new Loan__c(Name='Test3',
															  Closing_Date__c=date.parse('07/07/2013'),
															  Loan_Number__c='003',
															  Loan_Stage__c='Paid Off',
															  Total_Commitment__c=1000000,
															  Loan_Type__c='Whole Loan'),
												  new Loan__c(Name='Test4',
															  Closing_Date__c=date.parse('05/05/2017'),
															  Loan_Number__c='004',
															  Loan_Stage__c='REO',
															  Total_Commitment__c=1000000,
															  Loan_Type__c='Whole Loan'),
												  new Loan__c(Name='Test5',
															  Closing_Date__c=date.parse('09/09/2019'),
															  Loan_Number__c='001',
															  Loan_Stage__c='REO',
															  Total_Commitment__c=1000000,
															  Loan_Type__c='Whole Loan'),
												  new Loan__c(Name='Test6',
															  Closing_Date__c=date.parse('11/11/2015'),
															  Loan_Number__c='006',
															  Loan_Stage__c='Funded',
															  Total_Commitment__c=100000,
															  Loan_Type__c='Whole Loan'),
													new Loan__c(Name='Test7',
															  Closing_Date__c=date.parse('06/06/2015'),
															  Loan_Number__c='007',
															  Loan_Stage__c='Funded',
															  Total_Commitment__c=100000,
															  Loan_Type__c='Whole Loan'),
													new Loan__c(Name='Test8',
															  Closing_Date__c=date.parse('06/06/2015'),
															  Loan_Number__c='007',
															  Loan_Stage__c='REO',
															  Total_Commitment__c=100000,
															  Loan_Type__c='Whole Loan')};
									  
		insert lstLoan;
		
		SL_LoanCurrentVolumeController objController = new SL_LoanCurrentVolumeController();
		objController.getCurrentVolumeRecords();	
	}	        
}