/*
* @author : sfdcdev, Tamarack Consulting, Inc.
* @date : 02/01/2015
* @description: Util class for aggregating annual goals into team stats
*
* © Copyright 2003 - 2015 Tamarack Consulting, Inc.  All Rights Reserved.
* 
*/

public with sharing class TC_TeamAnnualGoalUtility {
	
	private static final String teamGoalRecordTypeId = AnnualGoals__c.SObjectType.getDescribe().getRecordTypeInfosByName().get('Team Annual Goal').getRecordTypeId() ;


	public static void processTeamAnnualGoals (Integer currentYear, Set <Id> userIds) {

		//get all team goals for currentYear
		String currentYearString = String.valueOf(currentYear);
		List <AnnualGoals__c> teamGoals = new List <AnnualGoals__c> ([SELECT Id
																			,Name
																		FROM AnnualGoals__c 
																		WHERE User__c = null 
																		AND Year__c = :currentYearString]); 

		Map <String, AnnualGoals__c> teamAnnualGoalMap = new Map <String, AnnualGoals__c> ();

		for (AnnualGoals__c ag: teamGoals) {
			teamAnnualGoalMap.put (ag.Name, ag);// unique name per year per team 
		}  

		//collect aggregate data for teams 
		List <AggregateResult> individualGoalsAggregate = [SELECT count(id)
																	,SUM(AACGMNewCustomers__c) AACGMNewCustomers__c
																	,SUM(FMAGrossMargin__c) FMAGrossMargin__c
																	,SUM(FMVGrossMargin__c) FMVGrossMargin__c
																	,SUM(CSCGrossMargin__c) CSCGrossMargin__c
																	,SUM(FundedCGM__c) FundedCGM__c
																	,SUM(FundedCGMBacklog__c) FundedCGMBacklog__c
																	,SUM(Leads__c) Leads__c
																	,SUM(NewAccounts__c) NewAccounts__c
																	,SUM(NewAccountsFMVFMATransactions__c) NewAccountsFMVFMATrans
																	,SUM(OfficeMeetings__c) OfficeMeetings__c
																	,SUM(Proposals__c) Proposals__c
																	,SUM(Proposal_Size__c) Proposal_Size__c
																	,SUM(QualifiedNewAccounts__c) QualifiedNewAccounts__c
																	,SUM(Same_Year_Proposals__c) Same_Year_Proposals__c
																	,SUM(Total_Closed_Current_Customers__c) TotalClosedCurCust
																	,SUM(Total_Closed_Current_Customers_Not_Lost__c) TotalClosedCurCustNotLost
																	,SUM(Total_Closed_Prospects__c) Total_Closed_Prospects__c
																	,SUM(Total_Closed_Prospects_Not_Lost__c) TotalClosedProspNotLost
																	,SUM(VirtualMeetings__c) VirtualMeetings__c
																	,SUM(Total_Call_Count_YTD__c) Total_Call_Count_YTD__c
																	,SUM(Total_Talk_Time_in_Seconds_YTD__c) Total_Talk_Time_in_Sec
																	,SUM(Total_Two_Minute_Call_YTD__c) Total_Two_Minute_Call_YTD
																	,SUM(Total_Call_Count_Goal_YTD__c) Total_Call_Count_Goal_YTD
																	,SUM(Total_Talk_Time_Goal_YTD__c) Total_Talk_Time_Goal_YTD
																	,SUM(Total_Two_Minute_Call_Goal_YTD__c) TotalTwoMinCallGoalYTD

																	
																	,Display_Team__c
															FROM AnnualGoals__c 
															WHERE Year__c = :currentYearString
															AND User__c IN :userIds
															AND User__r.Sales_Team__c != null
															GROUP BY Display_Team__c  ];


		//in case there are goals missing, prepare a list 
		List <AnnualGoals__c> newTeamGoalsToInsert = new List <AnnualGoals__c> ();													

		for (AggregateResult ar: individualGoalsAggregate) {
			String teamGoalName = currentYearString + ' - ' + String.valueOf(ar.get('Display_Team__c'));
			AnnualGoals__c teamGoal;
			if (teamAnnualGoalMap.get(teamGoalName) != null) {
				teamGoal = teamAnnualGoalMap.get(teamGoalName);
			} else {
				teamGoal = new AnnualGoals__c ();
				teamGoal.Name = teamGoalName;
				teamGoal.RecordTypeId = teamGoalRecordTypeId;
				teamGoal.Year__c = currentYearString;
				newTeamGoalsToInsert.add (teamGoal);
			}

			teamGoal.AACGMNewCustomers__c 				= (Decimal) ar.get('AACGMNewCustomers__c');
			teamGoal.FMAGrossMargin__c 					= (Decimal) ar.get('FMAGrossMargin__c');
			teamGoal.FMVGrossMargin__c 					= (Decimal) ar.get('FMVGrossMargin__c');
			teamGoal.CSCGrossMargin__c 					= (Decimal) ar.get('CSCGrossMargin__c');
			teamGoal.FundedCGM__c 						= (Decimal) ar.get('FundedCGM__c');
			teamGoal.FundedCGMBacklog__c 				= (Decimal) ar.get('FundedCGMBacklog__c');
			teamGoal.Leads__c 							= (Decimal) ar.get('Leads__c');
			teamGoal.NewAccounts__c 					= (Decimal) ar.get('NewAccounts__c');
			teamGoal.NewAccountsFMVFMATransactions__c 	= (Decimal) ar.get('NewAccountsFMVFMATrans');
			teamGoal.OfficeMeetings__c 					= (Decimal) ar.get('OfficeMeetings__c');
			teamGoal.Proposals__c 						= (Decimal) ar.get('Proposals__c');
			teamGoal.Proposal_Size__c 					= (Decimal) ar.get('Proposal_Size__c');
			teamGoal.QualifiedNewAccounts__c 			= (Decimal) ar.get('QualifiedNewAccounts__c');
			teamGoal.Same_Year_Proposals__c 						= (Decimal) ar.get('Same_Year_Proposals__c');
			teamGoal.Total_Closed_Current_Customers__c 				= (Decimal) ar.get('TotalClosedCurCust');
			teamGoal.Total_Closed_Current_Customers_Not_Lost__c 	= (Decimal) ar.get('TotalClosedCurCustNotLost');
			teamGoal.Total_Closed_Prospects__c 						= (Decimal) ar.get('Total_Closed_Prospects__c');
			teamGoal.Total_Closed_Prospects_Not_Lost__c			 	= (Decimal) ar.get('TotalClosedProspNotLost');
			teamGoal.VirtualMeetings__c 							= (Decimal) ar.get('VirtualMeetings__c');
			teamGoal.Team_Call_Count_YTD__c 						= (Decimal) ar.get('Total_Call_Count_YTD__c');
			teamGoal.Team_Call_Count_Goal__c 						= (Decimal) ar.get('Total_Call_Count_Goal_YTD');
			teamGoal.Team_Talk_Time_In_Seconds_YTD__c 				= (Decimal) ar.get('Total_Talk_Time_in_Sec');
			teamGoal.Team_Talk_Time_Goal__c 						= (Decimal) ar.get('Total_Talk_Time_Goal_YTD');
			teamGoal.Team_Two_Minute_Count_YTD__c 					= (Decimal) ar.get('Total_Two_Minute_Call_YTD');
			teamGoal.Team_Two_Minute_Goal__c 						= (Decimal) ar.get('TotalTwoMinCallGoalYTD');
			
		}

		update teamAnnualGoalMap.values();
		if (!newTeamGoalsToInsert.isEmpty())
			insert newTeamGoalsToInsert;
	}
}