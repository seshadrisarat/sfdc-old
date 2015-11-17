/*
* @author : sfdcdev, Tamarack Consulting, Inc.
* @date : 01/28/2015
* @description: Util class for aggregating call stats data from ShoreTel and adding it to Annual Goals object
*
* © Copyright 2003 - 2015 Tamarack Consulting, Inc.  All Rights Reserved.
* 
*/

public with sharing class TC_ShoreTelDailyCallUtil {
	public TC_ShoreTelDailyCallUtil() {}



	public static void aggregateDailyCallData (Date startDate, Set <Id> userIdsToProcess) {

		System.debug(LoggingLevel.INFO, 'TC_ShoreTelDailyCallUtil.aggregateDailyCallData \n ' + 'Date: ' + startDate + ' userIdsToProcess: ' + userIdsToProcess);
		
		List <ShoreTelDailyCallTotal__c> shoreTelTotalsList = new List <ShoreTelDailyCallTotal__c> ([SELECT Id
																											,Date__c
																											,Annual_Goal__r.User__c
																									FROM ShoreTelDailyCallTotal__c
																									WHERE Date__c >= :startDate
																									AND Annual_Goal__r.User__c IN :userIdsToProcess]);

		Map <Id, Map <Date, ShoreTelDailyCallTotal__c>> shoreTelTotalsUserMap =  new Map <Id, Map <Date, ShoreTelDailyCallTotal__c>> ();

		for (ShoreTelDailyCallTotal__c stt: shoreTelTotalsList) {
			if (shoreTelTotalsUserMap.get(stt.Annual_Goal__r.User__c) == null) {
				shoreTelTotalsUserMap.put(stt.Annual_Goal__r.User__c, new Map <Date, ShoreTelDailyCallTotal__c>{stt.Date__c => stt});
			} else {
				shoreTelTotalsUserMap.get(stt.Annual_Goal__r.User__c).put(stt.Date__c, stt);
			}
		}


		//get aggregate results for call stats
		List <AggregateResult> shoreTellCallsAggregates = [SELECT SUM (Call_Count__c) callCount
															 ,SUM(x2_Min_Call__c) x2MinCount
															 ,SUM(STCDR__Talk_Time_Seconds__c) talkTime
															 ,Connect_Date__c
															 ,STCDR__User__c
															 ,STCDR__User__r.LastName 
														FROM STCDR__ShoreTel_Connection__c 
														WHERE STCDR__User__c IN :userIdsToProcess 
														AND Connect_Date__c >= :startDate

														GROUP BY Connect_Date__c
																 ,STCDR__User__c
																 ,STCDR__User__r.LastName 
														ORDER BY STCDR__User__r.LastName
																,Connect_Date__c 
														LIMIT 50000];



		if (shoreTellCallsAggregates != null) {

			//prepare annual goals 
			Map <Id, Id> userAnnualGoalMap = new Map <Id, Id> ();

			for (AnnualGoals__c agoal: [SELECT Id, User__c FROM AnnualGoals__c WHERE Year__c = :String.valueOf(startDate.year()) AND User__c != null]) {
				userAnnualGoalMap.put (agoal.User__c, agoal.Id);
			}


			//get list of call stats to process
			List <ShoreTelDailyCallTotal__c> shoreTelTotalsListToInsert = new List <ShoreTelDailyCallTotal__c> ();
			
			for (AggregateResult ar: shoreTellCallsAggregates) {
				String userId = String.valueOf(ar.get('STCDR__User__c'));
				Date connectDate = Date.valueOf(ar.get('Connect_Date__c'));

				ShoreTelDailyCallTotal__c callTotal;

				if (shoreTelTotalsUserMap.get(userId) != null) {
					callTotal = shoreTelTotalsUserMap.get(userId).get(connectDate);
				}

				if (callTotal == null) {
					callTotal = new ShoreTelDailyCallTotal__c ();
					callTotal.Date__c = connectDate;

					if (userAnnualGoalMap.get(userId) != null) {
						callTotal.Annual_Goal__c = userAnnualGoalMap.get(userId);
					} 
				}

				callTotal.Call_Count__c = Integer.valueOf(ar.get('callCount'));
				callTotal.Talk_Time_in_Seconds__c = Integer.valueOf(ar.get('talkTime'));
				callTotal.Two_Minute_Call_Count__c = Integer.valueOf(ar.get('x2MinCount'));

				if (callTotal.Id == null && callTotal.Annual_Goal__c != null) //we only need call stats for users with goals 
					shoreTelTotalsListToInsert.add(callTotal);

			}//end for aggregate

			update shoreTelTotalsList;
			insert shoreTelTotalsListToInsert; //this will fail if goals are missing
		} //end if not aggregate null
	}
}