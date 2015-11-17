/**
* \arg ClassName      : SL_Test_RacetrackReport
* \arg JIRATicket     : HL-8,9,10
* \arg CreatedOn      : 13/MAY/2014
* \arg LastModifiedOn : 13/MAY/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Test class for SL_RacetrackReport.cls
*/


@isTest()
public with sharing class SL_Test_RacetrackReport 
{
	@isTest()
	static void test_RacetrackReport() 
	{
		SL_RacetrackReport__c objRRCustomSetting = new SL_RacetrackReport__c( Name = 'default',	
																			  ChildObjectAPIName__c = 'Engagement_Counterparty__c',
																			  FieldSetAPIName__c = 'SL_RacetrackReport',
																			  GroupingObjectAPIName__c = 'Account',
																			  GroupingObjectRelationshipAPIName__c ='Company__c', 	
																			  Logo_URL__c = 'https://google.com',
																			  ParentObjectAPIName__c = 'Engagement__c', 
																			  ParentObjectRelationshipAPIName__c = 'Engagement__c');
		insert objRRCustomSetting;
		
		List<Account> lstAccount = SL_TestSetupUtils.CreateAccount('Account' , 3);
		insert lstAccount; 
		
		List<Engagement__c> lstEngagement = new List<Engagement__c>();
		for(Engagement__c objEngagement : SL_TestSetupUtils.CreateEngagement('Engagement__c', 1))
        {
            objEngagement.Client__c = lstAccount[0].Id;
            objEngagement.Subject__c = lstAccount[0].Id;
            lstEngagement.add(objEngagement);
        }
        insert lstEngagement;
		
		List<Engagement_Counterparty__c> lstEC = new  List<Engagement_Counterparty__c>();
        for(Engagement_Counterparty__c objEC : SL_TestSetupUtils.CreateEC('Engagement_Counterparty__c', 5))
        {
            objEC.Company__c = lstAccount[0].Id;
            objEC.Engagement__c = lstEngagement[0].Id;
            lstEC.add(objEC);
        }
        
        for(Engagement_Counterparty__c objEC : SL_TestSetupUtils.CreateEC('Engagement_Counterparty__c', 5))
        {
            objEC.Company__c = lstAccount[1].Id;
            objEC.Engagement__c = lstEngagement[0].Id;
            lstEC.add(objEC);
        }
        
        for(Engagement_Counterparty__c objEC : SL_TestSetupUtils.CreateEC('Engagement_Counterparty__c', 5))
        {
            objEC.Company__c = lstAccount[2].Id;
            objEC.Engagement__c = lstEngagement[0].Id;
            lstEC.add(objEC);
        }
        insert lstEC;
        
        
		SL_RacetrackReport objRR = new SL_RacetrackReport();
		objRR.engagementCounterparty.Engagement__c = lstEngagement[0].Id;
		objRR.getGroupByOptions();
		objRR.getCurrentDateTime();
		objRR.getSortingOption();
		objRR.getStageOptions();
		objRR.generateReport();
		objRR.isFilter = true;
		objRR.generateReport();
		objRR.lstPicklistWrapperL[0].selectedValues = new List<String>();
		objRR.lstSelectedStage = new List<String>{'Book_Returned__c', 'Closing_Round_Bid_Date__c', 'Confidentiality_Agreement__c', 
												  'Final_Round_Bid_Date__c','Deal_Ranking__c', 'Declined_Passed__c'};
		objRR.strGroupBy = 'Book_Returned__c:DATE';
		objRR.strSortBy = 'Book_Returned__c';
		objRR.generateReport();
		objRR.strGroupBy = 'Company__c:REFERENCE';
		objRR.generateReport();
		objRR.strGroupBy = 'Company__r.OwnerId:REFERENCE';
		objRR.generateReport();
		objRR.lstPicklistWrapperL[0].selectedValues = new List<String>{'A', 'B', 'C'};
		objRR.generateReport();
	}
	
}