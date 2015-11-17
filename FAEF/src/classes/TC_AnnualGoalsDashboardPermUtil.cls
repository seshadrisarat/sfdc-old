/*
* @author : sfdcdev, Tamarack Consulting, Inc.
* @date : 02/01/2015
* @description: Util class for getting settings to view dashboard components
*
* © Copyright 2003 - 2015 Tamarack Consulting, Inc.  All Rights Reserved.
* 
*/

public with sharing class TC_AnnualGoalsDashboardPermUtil {
	
	public static TC_AnnualGoalsDashboardPermUtil util;
	private AnnualGoalsDashboardPermissions__c perms;

	private TC_AnnualGoalsDashboardPermUtil() {
		perms = AnnualGoalsDashboardPermissions__c.getInstance();
		if (perms == null) 
			throw new TC_AnnualGoalsDashboardPermUtilException ('No custom settings found. Please create global settings.');

	}

	public static TC_AnnualGoalsDashboardPermUtil getInstance () {
		if (util == null) util = new TC_AnnualGoalsDashboardPermUtil ();

		return util;
	}

	public Boolean getAnnualBusinessPlanInd() {
		return perms.Annual_Business_Plan_Individual__c;
	}

	public Boolean getAnnualBusinessPlanTeam () {
		return perms.Annual_Business_Plan_Team__c;
	}

	public Boolean getAnnualBusinessPlanTeamDashboard() {
		return perms.Annual_Business_Plan_Team_Dashboard__c;
	}

	public Boolean getDeferredBonus () {
		return perms.Deferred_Bonus__c;
	}

	public Boolean getPresidentsClubQual () {
		return perms.Presidents_Club_Qualification__c;
	}

	public Boolean getPromotionNextLevel () {
		return perms.Promotion_to_Next_Level__c;
	}

	public class TC_AnnualGoalsDashboardPermUtilException extends Exception {}
}