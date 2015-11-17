/*
* @author : sfdcdev, Tamarack Consulting, Inc.
* @date : 02/23/2015
* @description: Test class for TC_PresidentsClubDashboardCtrl
*
* © Copyright 2003 - 2015 Tamarack Consulting, Inc.  All Rights Reserved.
* 
*/

@isTest
private class TC_PresidentsClubDashboardCtrlTest {
	
	@testSetup static void setupData () {
		List <User> uList = [SELECT Id, Sales_Team__c FROM User WHERE Sales_Team__c != null AND Exclude_Dashboard__c = 'FALSE' LIMIT 2];
		//u.Sales_Team__c = 'Education';
		//update u;
		//SL_ChatterGroupHelper is broken so we have to just take a user

		Presidents_Club_Goal__c pcGoal = new Presidents_Club_Goal__c ();
		pcGoal.PresidentsClubYear__c = String.valueOf(System.today().year());
		pcGoal.PresidentsClubCategory__c = 'Rookie';

		insert pcGoal;

		AnnualGoals__c teamAg2014 = new AnnualGoals__c ();
		teamAg2014.Year__c = String.valueOf(System.today().year());
		teamAg2014.Name = uList[0].Sales_Team__c + ' - ' + String.valueOf(System.today().year());
		insert teamAg2014;

		AnnualGoals__c ag2014 = new AnnualGoals__c ();
		ag2014.Year__c = String.valueOf(System.today().year());
		ag2014.Name = 'test';
		ag2014.User__c = uList[0].Id;
		ag2014.Presidents_Club_Goal__c = pcGoal.Id;
		insert ag2014;

		AnnualGoals__c ag2014_2 = new AnnualGoals__c ();
		ag2014_2.Year__c = String.valueOf(System.today().year());
		ag2014_2.Name = 'test';
		ag2014_2.User__c = uList[1].Id;
		ag2014_2.Presidents_Club_Goal__c = pcGoal.Id;
		insert ag2014_2;
	}

	@isTest static void pageLoad() {
		TC_PresidentsClubDashboardCtrl ctrl = new TC_PresidentsClubDashboardCtrl ();
		System.assertNotEquals(null, ctrl.permUtil);
		System.assertNotEquals(null, ctrl.goalYears);
		ctrl.rerenderDashboard();
		ctrl.switchToPrintView();

	}
	
}