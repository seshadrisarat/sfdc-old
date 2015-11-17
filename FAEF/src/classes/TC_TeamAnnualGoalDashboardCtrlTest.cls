/*
* @author : sfdcdev, Tamarack Consulting, Inc.
* @date : 02/26/2015
* @description: Team dashboard controller
*	https://trello.com/c/dd4U9I6F/5-add-team-metrics-view-to-dashboard
*
* © Copyright 2003 - 2015 Tamarack Consulting, Inc.  All Rights Reserved.
* 
*/

@isTest
private class TC_TeamAnnualGoalDashboardCtrlTest {
	
	@testSetup static void setup() {
		// Start of Preparing test data
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User u = new User ();
        u.Username = 'test@test121212.' + System.Math.random(); // make sure we don't create a user that already exists
        u.LastName = 'someuser';
        u.Email = 't@t.com';
        u.Alias = 'test12';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'en_US';
        u.Sales_Team__c = 'Education';
        u.Exclude_Dashboard__c = 'FALSE';
        u.AnnualGoalsManagerView__c = true;

        insert u;
        
        AnnualGoals__c teamGoal = new  AnnualGoals__c(Name = 'Education - 2014'
        												,FMAGrossMarginGoal__c = 275000
        												,FundedCGMBacklog__c=null
        												,NewAccountsFMVFMATransactions__c=0
        												,FundedCGM__c = 500000
        												,Year__c = '2014'
        												,CSCGrossMarginGoal__c = 250000);
		insert teamGoal;



		AnnualGoals__c ag2014 = new AnnualGoals__c ();
		ag2014.Year__c = '2014';
		ag2014.Name = 'test';
		ag2014.User__c = u.Id;
		insert ag2014;
        
    }

	@isTest static void testPageExceptions() {
		//make sure there is one 

		// Setting Url Parameters
		ApexPages.currentPage().getParameters().put('team', 'Education');
		ApexPages.currentPage().getParameters().put('year', '2014');
		ApexPages.currentPage().getParameters().put('print', 'true');
		Test.setCurrentPage(Page.TC_TeamAnnualGoalDashboard);


		Test.startTest();
		TC_TeamAnnualGoalDashboardCtrl ctrl = new TC_TeamAnnualGoalDashboardCtrl ();
		Test.stopTest();
	}
	
		@isTest static void testPageDefaults() {
		// Setting Url Parameters
		ApexPages.currentPage().getParameters().put('team', 'Education');
		ApexPages.currentPage().getParameters().put('year', '2014');
		ApexPages.currentPage().getParameters().put('print', 'true');
		Test.setCurrentPage(Page.TC_TeamAnnualGoalDashboard);
		User u = [SELECT Id FROM User WHERE isActive = true and Sales_Team__c = 'Education' LIMIT 1];
		System.runAs(u) {
			Test.startTest();
			TC_TeamAnnualGoalDashboardCtrl ctrl = new TC_TeamAnnualGoalDashboardCtrl ();
			System.debug(ctrl.isManager);
			System.assertNotEquals(null, ctrl.permUtil);
			ctrl.loadIndividualGoals();
			ctrl.switchToPrintView();
			ctrl.rerenderDashboard();
			Test.stopTest();
		}	
		
	}
	
}