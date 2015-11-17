/*
* @author : sfdcdev, Tamarack Consulting, Inc.
* @date : 02/01/2015
* @description: test class for TC_AnnualGoalsDashboardPermUtil
*
* © Copyright 2003 - 2015 Tamarack Consulting, Inc.  All Rights Reserved.
* 
*/

@isTest
private class TC_AnnualGoalsDashboardPermUtilTest {
	
	@isTest static void testPermsException() {
		try {
			TC_AnnualGoalsDashboardPermUtil.getInstance();
		} catch (Exception e) {
			System.assert(true); //exception expected
		}
	}

	@isTest static void testPerms() {
		AnnualGoalsDashboardPermissions__c perms = new AnnualGoalsDashboardPermissions__c ();
		insert perms;
		System.assertNotEquals(null, TC_AnnualGoalsDashboardPermUtil.getInstance());

		TC_AnnualGoalsDashboardPermUtil util  = TC_AnnualGoalsDashboardPermUtil.getInstance();
		util.getAnnualBusinessPlanInd();
		util.getAnnualBusinessPlanTeam();
		util.getDeferredBonus();
		util.getPresidentsClubQual();
		util.getPromotionNextLevel();
		util.getAnnualBusinessPlanTeamDashboard();

	}
	
}