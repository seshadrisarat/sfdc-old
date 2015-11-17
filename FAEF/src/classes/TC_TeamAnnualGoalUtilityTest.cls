/*
* @author : sfdcdev, Tamarack Consulting, Inc.
* @date : 03/03/2015
* @description: test class for TC_TeamAnnualGoalUtilityTest
*
* © Copyright 2003 - 2015 Tamarack Consulting, Inc.  All Rights Reserved.
* 
*/

@isTest
private class TC_TeamAnnualGoalUtilityTest {
	
	@testSetup static void setupData () {
		List <User> uList = [SELECT Id, Sales_Team__c FROM User WHERE Sales_Team__c != null LIMIT 2];
		//u.Sales_Team__c = 'Education';
		//update u;
		//SL_ChatterGroupHelper is broken so we have to just take a user

		AnnualGoals__c teamAg2014 = new AnnualGoals__c ();
		teamAg2014.Year__c = '2014';
		teamAg2014.Name = uList[0].Sales_Team__c + ' - 2014';
		insert teamAg2014;

		AnnualGoals__c ag2014 = new AnnualGoals__c ();
		ag2014.Year__c = '2014';
		ag2014.Name = 'test';
		ag2014.User__c = uList[0].Id;
		insert ag2014;

		AnnualGoals__c ag2014_2 = new AnnualGoals__c ();
		ag2014_2.Year__c = '2014';
		ag2014_2.Name = 'test';
		ag2014_2.User__c = uList[1].Id;
		insert ag2014_2;
	}

	@isTest static void testUtilityFor2015() {
		List <User> users = [SELECT Id FROM User WHERE isActive = true];
		Set <Id> userIdSet = new Set <Id> ();

		for (User u: users) {
			userIdSet.add (u.Id);
		}

		Test.startTest();
 		
 		TC_TeamAnnualGoalUtility.processTeamAnnualGoals(2015, userIdSet);

		Test.stopTest();
	}

	@isTest static void testUtilityFor2014() {
		List <User> users = [SELECT Id FROM User WHERE isActive = true];
		Set <Id> userIdSet = new Set <Id> ();

		for (User u: users) {
			userIdSet.add (u.Id);
		}

		Test.startTest();
 		
 		TC_TeamAnnualGoalUtility.processTeamAnnualGoals(2014, userIdSet);

		Test.stopTest();
	}
	
}