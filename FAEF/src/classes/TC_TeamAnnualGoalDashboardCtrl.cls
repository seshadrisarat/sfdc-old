/*
* @author : sfdcdev, Tamarack Consulting, Inc.
* @date : 02/09/2015
* @description: Team dashboard controller
*	https://trello.com/c/dd4U9I6F/5-add-team-metrics-view-to-dashboard
*
* © Copyright 2003 - 2015 Tamarack Consulting, Inc.  All Rights Reserved.
* 
*/



public with sharing class TC_TeamAnnualGoalDashboardCtrl {
	public AnnualGoals__c teamAnnualGoal {get; set;}
	public List <AnnualGoals__c> individualMemberGoals {get; set;}
	public String selectedTeamName {get; set;}
	public String selectedYearString {get; set;}
	public Boolean onPrintPage {get; set;}
	public String teamChartColor {get {return '#177CD1';} private set;}

	//one of those dumb things where you can't aggregate formula fields
	List <AggregateResult> teamGoalNamesAggr = [SELECT count (id) , Name FROM AnnualGoals__c WHERE User__c = null GROUP BY Name];
	Set <String> teamNames;
	Set <String> yearStrings;

	public User currentUser {
		get{
			if (currentUser == null) {
				currentUser = [SELECT Id , AnnualGoalsManagerView__c, Sales_Team__c FROM User WHERE Id =: UserInfo.getUserId()];
			}

			return currentUser;
		}

		private set;
	}
	
	public Boolean isManager {
		get{
			return currentUser.AnnualGoalsManagerView__c;
		}
		private set;
	}

	public TC_AnnualGoalsDashboardPermUtil permUtil {
        get {
            return TC_AnnualGoalsDashboardPermUtil.getInstance();
        } 
        private set;
    }
	

	public TC_TeamAnnualGoalDashboardCtrl() {
		
		try {

			onPrintPage = ApexPages.currentPage().getParameters().get('print') == null ? false : Boolean.valueOf(ApexPages.currentPage().getParameters().get('print'));

			teamNames = new Set <String> ();
			yearStrings = new Set <String> ();

			//this is a bit hacky, but again the issue is the formula field and aggregation... 
			for (AggregateResult ar: teamGoalNamesAggr) {
				String s = String.valueOf(ar.get('Name'));

				if (s != null) {
					yearStrings.add (s.split(' - ')[0]);
					teamNames.add (s.split(' - ')[1]);
				}
			}

			selectedTeamName = !String.isEmpty(ApexPages.currentPage().getParameters().get('team')) ? ApexPages.currentPage().getParameters().get('team') : currentUser.Sales_Team__c;
			selectedYearString = !String.isEmpty(ApexPages.currentPage().getParameters().get('year')) ? ApexPages.currentPage().getParameters().get('year') : String.valueOf(System.today().year());

			//in case we have a user that is not a part of a team 
			selectedTeamName = String.isEmpty(selectedTeamName) ? getTeamOptions()[0].getLabel() : selectedTeamName;

			loadGoal();
			loadIndividualGoals();
		} catch (Exception e) {
			ApexPages.addMessages(e);
			System.debug(e);
		}

	}

	public void loadGoal () {
		try {
			//get team annual goal for individual
	        String goalName = selectedYearString + ' - ' + selectedTeamName;
	        String teamAnnualGoalQueryString = TC_DataUtility.createSelectAllString('AnnualGoals__c', 'Name = :goalName', '1', null, null);

	        teamAnnualGoal = Database.query(teamAnnualGoalQueryString);

	        //check for nulls and set nulls to zeros
	        teamAnnualGoal.AACGMNewCustomersGoal__c = teamAnnualGoal.AACGMNewCustomersGoal__c == null ? 0 : teamAnnualGoal.AACGMNewCustomersGoal__c;

		} catch (System.QueryException sqe) {
			throw new TC_TeamAnnualGoalDashboardException ('No team goal found.');
			System.debug(sqe);
		}
	}

	public void loadIndividualGoals () {
		try {
			String teamName = String.escapeSingleQuotes(selectedTeamName);
			String yearName = String.escapeSingleQuotes(selectedYearString);
			Set <String> additionalFields = new Set <String> ();
			additionalFields.add('User__r.FirstName');
			additionalFields.add('User__r.LastName');
	        String goalQueryString = TC_DataUtility.createSelectAllString('AnnualGoals__c', 'Sales_Team__c = :teamName AND Year__c = :yearName', '1000', null, additionalFields);

	        individualMemberGoals = Database.query(goalQueryString);
		} catch (System.QueryException sqe) {
			throw new TC_TeamAnnualGoalDashboardException ('No team member goals found found.');
			System.debug(sqe);
		}
	}

	public List <SelectOption> getTeamOptions () {
		List <SelectOption> teamOptions = new List <SelectOption> ();
			
		List <String> options = new List <String> ();
		options.addAll(teamNames);
		options.sort();

		for (String s: options) {
			teamOptions.add(new SelectOption(s, s));
		}

		return teamOptions;	
	}

	public List <SelectOption> getYearOptions () {
		List <SelectOption> yearOptions = new List <SelectOption> ();
		
		List <String> options = new List <String> ();
		options.addAll(yearStrings);
		options.sort();

		for (String s: options) {
			yearOptions.add(new SelectOption(s, s));
		}

		return yearOptions;	
	}

	public PageReference rerenderDashboard () {
		teamAnnualGoal = null;
		individualMemberGoals = null;
		try {
			loadGoal();
			loadIndividualGoals();
		} catch (Exception e) {
			System.debug(e);
			ApexPages.addMessages (e);
		}

		return null;
	}

	public List <User> getTeamMembers () {
		return [SELECT Id FROM User WHERE Sales_Team__c = :selectedTeamName LIMIT 1000];
	}

	public PageReference switchToPrintView () {
		onPrintPage = true;
		return null;
	}

	public class TC_TeamAnnualGoalDashboardException extends Exception {}

}