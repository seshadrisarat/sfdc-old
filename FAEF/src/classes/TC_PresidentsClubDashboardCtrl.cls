/*
* @author : sfdcdev, Tamarack Consulting, Inc.
* @date : 02/23/2015
* @description: Controller for Presidents club dashboard
*
* © Copyright 2003 - 2015 Tamarack Consulting, Inc.  All Rights Reserved.
* 
*/

public with sharing class TC_PresidentsClubDashboardCtrl {
	public String redColor {get {return '#CC3300';} private set;}
	public String yellowColor {get {return '#FFFF00';} private set;}
	public String greenColor {get {return '#009933';} private set;}

	public Boolean printView {get; set;}
	public String selectedYear {
		get {
			if (String.isEmpty(selectedYear))
				selectedYear = String.valueOf(System.today().year());

			return selectedYear;
		} 
		set;
	}

	//need for guaranteed order since we are using maps
	public List <String> pcCategories {get; private set;}

  	public List <SelectOption> goalYears {
        get {
            List <SelectOption> goalYearList = new List <SelectOption> ();
            
            Set <String> yearSet = new Set <String> ();

            AggregateResult [] agGoalYears = [SELECT year__c FROM AnnualGoals__c WHERE User__c != null AND User__r.Exclude_Dashboard__c = 'FALSE' GROUP BY Year__c ORDER BY Year__c DESC];

            for (AggregateResult ar: agGoalYears) {
                yearSet.add(String.valueOf(ar.get('Year__c')));
            }
            //requirement to always have current year in picklist
            yearSet.add(String.valueOf(Date.today().year()));

            List <String> yearList = new List <String> ();
            yearList.addAll(yearSet);
            yearList.sort();

            for(Integer i = yearList.size()-1; i>=0; i--) {//DESC sort
                goalYearList.add(new SelectOption (yearList.get(i), yearList.get(i)));
            }

            return goalYearList;
        }
        private set;
    }

     public TC_AnnualGoalsDashboardPermUtil permUtil {
        get {
            return TC_AnnualGoalsDashboardPermUtil.getInstance();
        } 
        private set;
    }

    private static final Boolean IsManager = [SELECT AnnualGoalsManagerView__c FROM User WHERE Id =: UserInfo.getUserId()][0].AnnualGoalsManagerView__c;

    public static final String NO_ANNUAL_GOALS_FOUND = 'No annual goals found.';
    public Map <String, List <AnnualGoals__c>> annualGoalsMap {get; set;}

	public TC_PresidentsClubDashboardCtrl() {
		printView = ApexPages.currentPage().getParameters().get('print') == null ? false : Boolean.valueOf(ApexPages.currentPage().getParameters().get('print'));
		loadGoals();
	}

	public void loadGoals () {

		try {
			annualGoalsMap = new Map <String, List <AnnualGoals__c>> ();
			pcCategories = new List <String> ();

			Set <String> extraFieldsSet = new Set <String> ();
			extraFieldsSet.add ('Presidents_Club_Goal__r.Name');
			extraFieldsSet.add ('Presidents_Club_Goal__r.PresidentsClubCategory__c');
			extraFieldsSet.add ('User__r.FirstName');
			extraFieldsSet.add ('User__r.LastName');

			String yearName = String.escapeSingleQuotes(selectedYear);
			String orderBy = 'Presidents_Club_Goal__r.Category_Sort_Order__c, Year__c, User__r.LastName';

		    String goalQueryString = TC_DataUtility.createSelectAllString('AnnualGoals__c', 'User__c != null AND Presidents_Club_Goal__c != null AND User__r.Exclude_Dashboard__c != \'TRUE\' AND Year__c = :selectedYear', '1000', orderBy, extraFieldsSet);
		    List <AnnualGoals__c> goalsList = Database.query (goalQueryString);

			if (goalsList != null) {
				for (AnnualGoals__c ag: goalsList) {

					String category = ag.Presidents_Club_Goal__r.PresidentsClubCategory__c;

					if (annualGoalsMap.get(category) == null) {
						pcCategories.add(category);
						annualGoalsMap.put(category, new List <AnnualGoals__c> {ag});
					} else {
						annualGoalsMap.get(category).add (ag);
					}
				}
			}
		} catch (System.QueryException sqe) {
			throw new TC_PresidentsClubDashboardException ('No records found.');
			System.debug(sqe);
		}

	}

	public PageReference rerenderDashboard () {
		loadGoals();
		return null;
	}

	public PageReference switchToPrintView () {
		printView = true;
		return null;
	}

	public class TC_PresidentsClubDashboardException extends Exception {}
}