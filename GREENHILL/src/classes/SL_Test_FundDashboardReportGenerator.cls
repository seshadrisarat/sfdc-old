/**
* \arg ClassName  		: SL_Test_FundDashboardReportGenerator
* \arg JIRATicket 		: GREENHILL-26, GREENHILL-28
* \arg CreatedOn  		: 5/6/2014
* \arg LastModifiedOn   : 9/30/2014
* \arg ModifiedBy 		: Pankaj Ganwani
* \arg Description		: This class works as controller for SL_FundDashboardReportGenerator page
*/
@isTest
private class SL_Test_FundDashboardReportGenerator 
{
    static testMethod void myUnitTest() 
    {
        List<Account> lstAccount = new List<Account>{new Account(Name = 'Test Account',Consultant__c = 'Test Consultant',Mailing_City__c = 'New York',
        														Mailing_Country__c = 'USA'),
        											 new Account(Name = 'Test Account1',Consultant__c = 'Test Consultant1',Mailing_City__c = 'Chennai',
        														Mailing_Country__c = 'India')};
        insert lstAccount;
        
        List<vced2__Fund__c> lstFund = new List<vced2__Fund__c>{new vced2__Fund__c(Name = 'Test Fund'),
        														new vced2__Fund__c(Name = 'Test Fund1')};
        insert lstFund;
        
        List<Fundraising_Deal__c> lstFundraisingDeal = new List<Fundraising_Deal__c>{new Fundraising_Deal__c(Name = 'Test Fundraising', Company__c = lstAccount[0].Id, 
        																				 					Commitment_Size_MM__c = 123.90, Fund__c = lstFund[0].Id, 
        																				 					Stage__c = 'Circled', Minimum_Commitment_Size__c = 0.0, Close_Date__c = Date.today()),
        																		 	 new Fundraising_Deal__c(Name = 'Test Fundraising1', Company__c = lstAccount[0].Id
        																		 	 						 , Commitment_Size_MM__c = 345.90,Fund__c = lstFund[0].Id, 
        																		 	 						 Stage__c = 'Closed', Minimum_Commitment_Size__c = 0.0, Close_Date__c = Date.today()),
        																		 	 new Fundraising_Deal__c(Name = 'Test Fundraising2', Company__c = lstAccount[0].Id, 
        																				 					Commitment_Size_MM__c = 123.90, Fund__c = lstFund[1].Id, 
        																				 					Stage__c = 'Circled', Minimum_Commitment_Size__c = 0.0, Close_Date__c = Date.today()),
        																		 	 new Fundraising_Deal__c(Name = 'Test Fundraising3', Company__c = lstAccount[0].Id
        																		 	 						 , Commitment_Size_MM__c = 345.90,Fund__c = lstFund[1].Id, 
        																		 	 						 Stage__c = 'Closed', Minimum_Commitment_Size__c = 0.0, Close_Date__c = Date.today())
        																			
        																			 };
        insert lstFundraisingDeal;
        
        SL_FundDashboardReportGenController objSL_FundDashboardReportGenController = new SL_FundDashboardReportGenController();
        objSL_FundDashboardReportGenController.objFundraisingDeal.Fund__c = lstFund[0].Id;
        objSL_FundDashboardReportGenController.strConsultant = 'Test Consultant';
        objSL_FundDashboardReportGenController.strCity = 'New York';
        objSL_FundDashboardReportGenController.strCountry = 'USA';
        objSL_FundDashboardReportGenController.strCoverage = 'Test Consultant';
        objSL_FundDashboardReportGenController.generateReport();
        
        objSL_FundDashboardReportGenController.strConsultant = 'Test Consultant,Test Consultant1';
        objSL_FundDashboardReportGenController.strCity = 'New York, Chennai';
        objSL_FundDashboardReportGenController.strCountry = 'USA,India';
        objSL_FundDashboardReportGenController.strCoverage = 'Test Consultant,Test Consultant1';
        objSL_FundDashboardReportGenController.generateReport();
        objSL_FundDashboardReportGenController.getDate();
        objSL_FundDashboardReportGenController.getSortValue();
        
        objSL_FundDashboardReportGenController.objFundraisingDeal.Fund__c = lstFund[1].Id;
         objSL_FundDashboardReportGenController.strConsultant = '';
        objSL_FundDashboardReportGenController.strCity = '';
        objSL_FundDashboardReportGenController.strCountry = '';
        objSL_FundDashboardReportGenController.strCoverage = '';
        objSL_FundDashboardReportGenController.generateReport();
    }
}