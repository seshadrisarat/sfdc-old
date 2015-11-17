/*
* @author : sfdcdev, Tamarack Consulting, Inc.
* @date : 01/28/2015
* @description: Test class
*
* © Copyright 2003 - 2015 Tamarack Consulting, Inc.  All Rights Reserved.
* 
*/

@isTest
private class TC_ShoreTelDailyCallUtilTest {

	
	@isTest static void testAggregateDailyCallData() {
		//createTestData
    	Profile p = [SELECT Id FROM Profile WHERE Profile.Name LIKE 'Sales%' LIMIT 1];
        
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
        u.AnnualGoalsManagerView__c = true;
        u.IsActive = true;
        u.Exclude_Dashboard__c = 'FALSE';
        u.CurrentTitle__c = 'AVP1';
        u.Date_of_Hire_into_Sales__c = System.today()-4;

        insert u;

        System.debug(LoggingLevel.INFO, 'Creating user: ' + u);

		AnnualGoals__c goalThisYear = new AnnualGoals__c();
		goalThisYear.Name = 'Test Annual Goal-02';
		goalThisYear.FMAGrossMarginGoal__c = 50000;
		goalThisYear.FundedCGMBacklog__c=null;
		goalThisYear.FundedCGM__c = 250000;
		goalThisYear.Year__c = String.valueOf(Date.today().year());
		goalThisYear.CSCGrossMarginGoal__c = 75000;
		goalThisYear.User__c = u.Id;
		goalThisYear.OwnerId = u.Id;

		insert goalThisYear;

		STCDR__ShoreTel_Connection__c shoretelcon = new STCDR__ShoreTel_Connection__c ();
		shoretelcon.STCDR__User__c = u.Id;
		shoretelcon.STCDR__Connect_Time__c = System.now();
		shoretelcon.STCDR__Duration_seconds__c = 100;
		shoretelcon.STCDR__Talk_Time_seconds__c = 100;
		insert shoretelcon;

		Set <Id> userSet = new Set <Id> ();
		userSet.add(u.Id);

		TC_ShoreTelDailyCallUtil.aggregateDailyCallData(System.today(), userSet);
		System.assertEquals(1, [SELECT Id FROM ShoreTelDailyCallTotal__c].size(), 'Daily stat was not created.');


		//this one just updates
		TC_ShoreTelDailyCallUtil.aggregateDailyCallData(System.today(), userSet);
	}
}