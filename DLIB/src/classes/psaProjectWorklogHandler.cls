/****************************************************************************************
Name            : psaProjectWorklogHandler
Author          : Julia Kolesnik
Created Date    : January 27, 2014
Description     : Contains methods for the ProjectWorklog trigger.
******************************************************************************************/
public class psaProjectWorklogHandler {
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	public static boolean isConverted = false;
	private static boolean isFirstRun = true;
	private map<Id, pse__Proj__c> mapProjects;
	private map<Id,Contact> mapContacts;

	/**
		* Constructor		: Initialise the global variables
		* @param			: None
	*/
	public psaProjectWorklogHandler(boolean isExecuting, integer size)
	{
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	public static boolean isFirstRun() {
		return isFirstRun;
	}

	public static void setRun() {
		isFirstRun = false;
	}

	/*
		@MethodName		: onBeforeInsert
		@param			: lstNew (Trigger New Values)
		@Description	: To set TimecardKey
	*/
	public void onBeforeInsert(list<Worklog__c> lstNew)
	{
		try
		{
			setMilestoneFromJiraIssue(lstNew);
			setTimecardKey(lstNew);
			list<Worklog__c> lstSuccessWorklogs = new list<Worklog__c>();
			for (Worklog__c item:lstNew) {
				if (item.PSA_Timecard__c!=null) {
					lstSuccessWorklogs.add(item);
				}
			}
			if (lstSuccessWorklogs.size()>0) setSuccessStatus(lstSuccessWorklogs);
		}
		catch(Exception e) {
			System.Debug(LoggingLevel.ERROR, e.getMessage());
		}
	}
	
	/*
		@MethodName		: onBeforeUpdate
		@param			: mapNew (Trigger New Values)
		@param			: mapOld (Trigger New Values)
		@Description	: To set TimecardKey
	*/
	public void onBeforeUpdate(map<Id,Worklog__c> mapNew, map<Id,Worklog__c> mapOld)
	{
		try
		{
			//to ask if it is possible to change Project/Milestone/Resource/StartDate on Worklog
			list<Worklog__c> lstWorklogs = new list<Worklog__c>();
			list<Worklog__c> lstSuccessWorklogs = new list<Worklog__c>();
			for (Worklog__c item:mapNew.values()) {
				if (item.Timecard_Key__c==null 	||item.PSA_Project__c!=mapOld.get(item.Id).PSA_Project__c
												||item.PSA_Milestone__c!=mapOld.get(item.Id).PSA_Milestone__c
												||item.JIRA_Contact__c!=mapOld.get(item.Id).JIRA_Contact__c
												||item.JIRA_Start_Date__c!=mapOld.get(item.Id).JIRA_Start_Date__c) {
					lstWorklogs.add(item);
				}
				if (item.PSA_Timecard__c!=null&& (item.PSA_Timecard__c!=mapOld.get(item.Id).PSA_Timecard__c || item.PSA_Integration_Status__c != 'SUCCESS')) {
					lstSuccessWorklogs.add(item);
				}
			}
			if (lstWorklogs.size()>0) setTimecardKey(lstWorklogs);
			if (lstSuccessWorklogs.size()>0) setSuccessStatus(lstSuccessWorklogs);
		}
		catch(Exception e) {
			System.Debug(LoggingLevel.ERROR, e.getMessage());
		}
	}
	
	/*
		@MethodName		: onAfterInsert
		@param			: lstNew (Trigger New Values)
		@Description	: To convert Project Worklogs into Timecards
	*/
	public void onAfterInsert(list<Worklog__c> lstNew)
	{
		try
		{
			psaConvertProjectWorklogTime(lstNew, new map<Id,Worklog__c>());
		}
		catch(Exception e) {
			System.Debug(LoggingLevel.ERROR, e.getMessage());
		}
	}
	
	/*
		@MethodName		: onAfterUpdate
		@param			: mapNew (Trigger New Values)
		@param			: mapOld (Trigger New Values)
		@Description	: To convert Project Worklogs into Timecards
	*/
	public void onAfterUpdate(map<Id,Worklog__c> mapNew, map<Id,Worklog__c> mapOld)
	{
		try
		{
			if (!psaProjectWorklogHandler.isConverted) {
				list<Worklog__c> lstWorklogs = new list<Worklog__c>();
				list<Id> lstUpdateTimecardKey = new list<Id>();
				map<Id,Worklog__c> mapTC_worklog = new Map<Id,Worklog__c>();

				for (Worklog__c item:mapNew.values()) {
					if(item.PSA_Milestone__c != mapOld.get(item.Id).PSA_Milestone__c && item.PSA_Milestone__c != null && item.PSA_Timecard__c != null) {
						// update the timecard key for timesheets NOT submitted or approved
						lstUpdateTimecardKey.add(item.PSA_Timecard__c);

						// getting any worklog per timecard in order to get the milestone and key from it (same across worklogs)
						mapTC_worklog.put(item.PSA_Timecard__c, item);
					}

					if (item.fix__c == true ||
						item.hours__c!=mapOld.get(item.Id).hours__c||
						item.JIRA_Start_Date__c!=mapOld.get(item.Id).JIRA_Start_Date__c||
						(item.PSA_Timecard__c==null&&
						(item.PSA_Integration_Status__c!=mapOld.get(item.Id).PSA_Integration_Status__c && item.PSA_Integration_Status__c!='SUCCESS'))) {
						lstWorklogs.add(item);
					}
				}
				if(lstUpdateTimecardKey.isEmpty() == false) updateTimecardKey(lstUpdateTimecardKey, mapTC_worklog);
				
				if (lstWorklogs.size()>0) psaConvertProjectWorklogTime(lstWorklogs, mapOld);
			} else psaProjectWorklogHandler.isConverted = false;
		}
		catch(Exception e) {
			System.Debug(LoggingLevel.ERROR, e.getMessage());
		}
	}
	
	/*
		@MethodName		: onAfterDelete
		@param			: lstOld (Trigger Old Values)
		@Description	: To reduce hours on related Timecards
	*/
	public void onAfterDelete(list<Worklog__c> lstOld)
	{
		try
		{
			psaBackoutProjectWorklogTime(lstOld);
		}
		catch(Exception e) {
			System.Debug(LoggingLevel.ERROR, e.getMessage());
		}
	}
	
	private void setMilestoneFromJiraIssue(list<Worklog__c> lstWorklog) {
		Set<Id> setIssueIds = new Set<Id>();
		
		for(Worklog__c w : lstWorklog) setIssueIds.add(w.SF_Issue__c);

		Map<Id,SF_Issue__c> sfIssues = new Map<Id,SF_Issue__c>( [select Id, Milestone__c from SF_Issue__c where Id in :setIssueIds AND Milestone__c != null]); 

		for(Worklog__c w : lstWorklog) {
			if(w.PSA_Milestone__c == null && sfIssues.containsKey(w.SF_Issue__c)) {
				w.PSA_Milestone__c = sfIssues.get(w.SF_Issue__c).Milestone__c;
			}
		}
	}

	//method to set TimecardKeyId for Worklog (to easy find its Timecard and making their upserts)
	private void setTimecardKey(list<Worklog__c> lstWorklog) {
		for (Worklog__c item:lstWorklog) {
			item.Timecard_Key__c = item.PSA_Project__c+'|'+item.PSA_Milestone__c+'|'+item.JIRA_Contact__c+'|'+item.Week_Start_Date__c;
			item.Timecard_Key__c = item.Timecard_Key__c.replace(' 00:00:00','');
			item.PSA_Integration_Status__c = '';
			item.PSA_Integration_Error__c = '';
		}

	}
	
	private void updateTimecardKey(list<Id> timecards, map<Id,Worklog__c> mapKey) {
		list<pse__Timecard_Header__c> updTimecards = new List<pse__Timecard_Header__c>();

		for(pse__Timecard_Header__c tc : [Select Id, Timecard_Key__c, pse__submitted__c, pse__approved__c,
						pse__Project__c, pse__Milestone__c, pse__Resource__c, pse__Start_Date__c FROM pse__Timecard_Header__c WHERE Id IN :timecards and pse__submitted__c = false and pse__approved__c = false]) {
			tc.Timecard_Key__c = mapKey.get(tc.Id).Timecard_Key__c;
			tc.pse__Milestone__c = mapKey.get(tc.Id).PSA_Milestone__c;
			updTimecards.add(tc);
		}

		update updTimecards;
	}
	
	//method to Convert ProjectWorklog into Timecard
	private void psaConvertProjectWorklogTime(list<Worklog__c> lstWorklog, map<Id,Worklog__c> mapOld) {
		map<string,Worklog__c> mapTimecardKeys = new map<string,Worklog__c>();
		map<string, pse__Timecard_Header__c> mapTimecards = new map<string, pse__Timecard_Header__c>();
		list<pse__Timecard_Header__c> lstTimecards = new list<pse__Timecard_Header__c>();

		set<Id> setProjectIds = new set<Id>();
		set<Id> setResourceIds = new set<Id>();
		//get all Timecard Keys
		for (Worklog__c item:lstWorklog) {
			mapTimecardKeys.put(item.Timecard_Key__c,item);
			setProjectIds.add(item.PSA_Project__c);
			setResourceIds.add(item.JIRA_Contact__c);
		}
		
		//get all Timecards with specified TimecardKeys
		for (pse__Timecard_Header__c item:[Select Id, Timecard_Key__c, pse__Monday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c, 
						pse__Thursday_Hours__c, pse__Friday_Hours__c, pse__Saturday_Hours__c, pse__Sunday_Hours__c, pse__submitted__c, pse__approved__c,
						pse__Project__c, pse__Milestone__c, pse__Resource__c, pse__Start_Date__c FROM pse__Timecard_Header__c WHERE Timecard_Key__c IN :mapTimecardKeys.keySet()]) {
			mapTimecards.put(item.Timecard_Key__c,item);
		}
		
		map<string, Id> mapAssignments = new map<string, Id>();
		for (pse__Assignment__c item:[Select Id, pse__Project__c, pse__Resource__c FROM pse__Assignment__c WHERE pse__Project__c IN :setProjectIds AND pse__Resource__c IN :setResourceIds]) {
			mapAssignments.put(item.pse__Project__c+''+item.pse__Resource__c, item.Id);
		}

		mapContacts = new Map<Id,Contact>([select Id, pse__Resource_Role__c from Contact where Id in :setResourceIds]);
		
		mapProjects = new map<Id, pse__Proj__c>([select BA__c, DA__c, Dev__c, DevMgmt__c, DIS__c, DRC__c, EM__c,Id, JIRA_Project_Name__c, Legacy_OpenAir_Project_ID__c, Name, OwnerId, PC__c, Project_Resume_Summary__c, Project_Scope__c, Project_Summary__c, Project_Timeline__c, SA__c, SM__c, SME__c, TA__c, Technical_PM__c from pse__Proj__c where Id IN :setProjectIds]);

		//get all Worklogs with specified TimecardKeys
		map<string,list<Worklog__c>> mapKeyWorklogs = new map<string,list<Worklog__c>>();
		for (Worklog__c item:[Select Id, Hours__c, Timecard_Key__c, Day_Of_Week__c, PSA_Milestone__r.Project_Phase__c, Jira_Notes__c FROM Worklog__c WHERE Timecard_Key__c IN :mapTimecardKeys.keySet() limit 10000]) {
			if (!mapKeyWorklogs.containskey(item.Timecard_Key__c)) mapKeyWorklogs.put(item.Timecard_Key__c, new list<Worklog__c>());
			mapKeyWorklogs.get(item.Timecard_Key__c).add(item);
		}
		
		pse__Timecard_Header__c curTimecard;
		Worklog__c oldWorklog;
		Worklog__c curWorklog;
		set<Id> setWorklogWithNullTimecardIds = new set<Id>();
		//loop through all TimecardKeys
		for (string key:mapTimecardKeys.keySet()) {
			curWorklog = mapTimecardKeys.get(key);

			if (mapTimecards.containsKey(key)) {
				// don't touch submitted or approved timecards
				if(mapTimecards.get(key).pse__submitted__c == true || mapTimecards.get(key).pse__approved__c == true) continue;

				//init Timecard from existing
				curTimecard = mapTimecards.get(key);
			} else {
				//init new Timecard
				curTimecard = new pse__Timecard_Header__c(pse__Project__c = curWorklog.PSA_Project__c, pse__Milestone__c = curWorklog.PSA_Milestone__c, pse__Resource__c = curWorklog.JIRA_Contact__c, pse__Start_Date__c = curWorklog.Week_Start_Date__c, pse__End_Date__c = curWorklog.Week_Start_Date__c+6);
				if (mapAssignments.containsKey(curWorklog.PSA_Project__c+''+curWorklog.JIRA_Contact__c)) {
					curTimecard.pse__Assignment__c = mapAssignments.get(curWorklog.PSA_Project__c+''+curWorklog.JIRA_Contact__c);
				}
				curTimecard.Timecard_Key__c = curWorklog.PSA_Project__c+'|'+curWorklog.PSA_Milestone__c+'|'+curWorklog.JIRA_Contact__c+'|'+curWorklog.Week_Start_Date__c;
				curTimecard.Timecard_Key__c = curTimecard.Timecard_Key__c.replace(' 00:00:00','');

			}
			
			//curTimecard.pse__Project_Phase_Object__c = curWorklog.PSA_Milestone__r.Parent_Milestone__r.Project_Phase__c;
			curTimecard.pse__Project_Phase_Object__c = curWorklog.PSA_Milestone__r.Project_Phase__c;
			//clear all hour fields on the Timecard
			curTimecard = setZeroHours(curTimecard);

			curTimecard.pse__Project__c = curWorklog.PSA_Project__c;
			curTimecard.pse__Bill_Rate__c = getBillRate(curWorklog);

			//loop through all existing worklogs for this TimecardKey and apply hour to the Timecard
			if (mapKeyWorklogs.containsKey(key)) {
				for (Worklog__c item:mapKeyWorklogs.get(key)) {
					curTimecard = convertWorklogIntoTimecard(item,curTimecard,false);
				}
			}
			system.debug(curTimecard);
			lstTimecards.add(curTimecard);
			//get Worklog Id to update this record with its PSA_Timecard 
			if (curWorklog.PSA_Timecard__c==null) setWorklogWithNullTimecardIds.add(curWorklog.Id);
		}
		
		//upsert Timecards 
		if (lstTimecards.size()>0) upsertTimecards(lstTimecards);
		
		
		psaProjectWorklogHandler.isConverted = true;
		//set PSA_Timecard__c field for Worklogs if it was null
		if (setWorklogWithNullTimecardIds.size()>0) setProjectWorklogTimecard(setWorklogWithNullTimecardIds);
		
	}
	
	private Decimal getBillRate(worklog__c worklog) {
		if(mapProjects.get(worklog.PSA_Project__c) == null) return 0.0;
		if(mapContacts.get(worklog.JIRA_Contact__c) == null) return 0.0;

		if(mapContacts.get(worklog.JIRA_Contact__c).pse__Resource_Role__c == 'Developer') return mapProjects.get(worklog.PSA_Project__c).Dev__c;
		else if(mapContacts.get(worklog.JIRA_Contact__c).pse__Resource_Role__c == 'Technical PM') return mapProjects.get(worklog.PSA_Project__c).Technical_PM__c;
		else return 0.0;
	}

	//method to remove hours from existing Timecard if Worklog was deleted
	private void psaBackoutProjectWorklogTime (list<Worklog__c> lstWorklog) {
		set<string> setTimecardKeys = new set<string>();
		map<string, pse__Timecard_Header__c> mapTimecards = new map<string, pse__Timecard_Header__c>();
		list<pse__Timecard_Header__c> lstTimecards = new list<pse__Timecard_Header__c>();
		//get all TimecardKeys which were deleted
		for (Worklog__c item:lstWorklog) {
			setTimecardKeys.add(item.Timecard_Key__c);
		}
		
		//get all Timecards with specified TimecardKeys
		for (pse__Timecard_Header__c item:[Select Id, Timecard_Key__c, pse__Monday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c, 
						pse__Thursday_Hours__c, pse__Friday_Hours__c, pse__Saturday_Hours__c, pse__Sunday_Hours__c,
						pse__Project__c, pse__Milestone__c, pse__Resource__c, pse__Start_Date__c FROM pse__Timecard_Header__c WHERE Timecard_Key__c IN :setTimecardKeys]) {
			mapTimecards.put(item.Timecard_Key__c,item);
		}
		
		//loop through deleted Worklogs
		pse__Timecard_Header__c curTimecard;
		for (Worklog__c item:lstWorklog) {
			if (mapTimecards.containsKey(item.Timecard_Key__c)) {
				curTimecard = mapTimecards.get(item.Timecard_Key__c);
				//remove hours from Timecard
				curTimecard = convertWorklogIntoTimecard(item,curTimecard,true);
				lstTimecards.add(curTimecard);
			} 
		}
		
		//upsert Timecards 
		//if (lstTimecards.size()>0) upsert lstTimecards Timecard_Key__c;
		if (lstTimecards.size()>0) upsertTimecards(lstTimecards);
	}
	
	//method to set Hours to specified field on the Timecard
	private pse__Timecard_Header__c convertWorklogIntoTimecard(Worklog__c item, pse__Timecard_Header__c curTimecard, boolean isBack) {
		Integer k = 1;
		String notes = '';
		Decimal hours = 0.00;
		
		if (isBack) k = -1;
		hours = (Decimal)curTimecard.get('pse__' + item.Day_Of_Week__c + '_Hours__c') + item.Hours__c*k;
		curTimecard.put('pse__' + item.Day_Of_Week__c + '_Hours__c', hours);
		notes = (String)curTimecard.get('pse__' + item.Day_Of_Week__c + '_Notes__c');
		if(item.JIRA_Notes__c != null && !notes.contains(item.JIRA_Notes__c)) notes += ' | ' + item.JIRA_Notes__c;
		if(notes == null) notes = '';
		notes = notes.substring(0,notes.length() > 254 ? 254 : notes.length());
		curTimecard.put('pse__' + item.Day_Of_Week__c + '_Notes__c', notes);

		//if (item.Day_Of_Week__c=='Monday') curTimecard.pse__Monday_Hours__c += item.Hours__c*k;
		//if (item.Day_Of_Week__c=='Tuesday') curTimecard.pse__Tuesday_Hours__c += item.Hours__c*k;
		//if (item.Day_Of_Week__c=='Wednesday') curTimecard.pse__Wednesday_Hours__c += item.Hours__c*k;
		//if (item.Day_Of_Week__c=='Thursday') curTimecard.pse__Thursday_Hours__c += item.Hours__c*k;
		//if (item.Day_Of_Week__c=='Friday') curTimecard.pse__Friday_Hours__c += item.Hours__c*k;
		//if (item.Day_Of_Week__c=='Saturday') curTimecard.pse__Saturday_Hours__c += item.Hours__c*k;
		//if (item.Day_Of_Week__c=='Sunday') curTimecard.pse__Sunday_Hours__c += item.Hours__c*k;
		return curTimecard;
	}
	
	//method to set 0 instead null or clear timecard before aggregating hours into it
	private pse__Timecard_Header__c setZeroHours(pse__Timecard_Header__c curTimecard) {
		curTimecard.pse__Monday_Hours__c = 0;
		curTimecard.pse__Tuesday_Hours__c = 0;
		curTimecard.pse__Wednesday_Hours__c = 0;
		curTimecard.pse__Thursday_Hours__c = 0;
		curTimecard.pse__Friday_Hours__c = 0;
		curTimecard.pse__Saturday_Hours__c = 0;
		curTimecard.pse__Sunday_Hours__c = 0;

		curTimecard.pse__Monday_Notes__c = '';
		curTimecard.pse__Tuesday_Notes__c = '';
		curTimecard.pse__Wednesday_Notes__c = '';
		curTimecard.pse__Thursday_Notes__c = '';
		curTimecard.pse__Friday_Notes__c = '';
		curTimecard.pse__Saturday_Notes__c = '';
		curTimecard.pse__Sunday_Notes__c = '';		

		return curTimecard;
	}
	
	//upsert lstTimecards and get upsertresult
	private void upsertTimecards(list<pse__Timecard_Header__c> lstTimecards) {
		
		set<Id> setSuccessIds = new set<Id>();
		map<String,String> mapErrorIds = new map<String,String>();
		string errMess = '';
		Database.UpsertResult[] results = Database.upsert(lstTimecards, Schema.pse__Timecard_Header__c.Timecard_Key__c, false);
        integer i=0;
        for (Database.UpsertResult res : results) {
        	system.debug(res);
        	if (!res.isSuccess()) {
        		errMess = '';
        		if (res.getErrors().size() > 0) errMess = res.getErrors()[0].getMessage();
        		if (errMess.length()>255) errMess = errMess.substring(0, 255);
            	mapErrorIds.put(lstTimecards[i].Timecard_Key__c, errMess);
            }
            i++;
        }
        
		if (mapErrorIds.size()>0) setErrorStatus(mapErrorIds);
	}
	
	//method to set Worklog__c.PSA_Timecard__c value after creating Timecard
	//@future
	public static void setProjectWorklogTimecard(set<Id> setWorklogIds) {
		set<string> setTimecardKeys = new set<string>();
		list<Worklog__c> lstWorklogs = new list<Worklog__c>([Select Id, Timecard_Key__c, PSA_Timecard__c FROM Worklog__c WHERE Id IN :setWorklogIds AND PSA_Timecard__c=null limit 10000]);
		for (Worklog__c item:lstWorklogs) {
			setTimecardKeys.add(item.Timecard_Key__c);
		}
		
		map<string,Id> mapTimecards = new map<string,Id>();
		for (pse__Timecard_Header__c item:[Select Id, Timecard_Key__c FROM pse__Timecard_Header__c WHERE Timecard_Key__c IN :setTimecardKeys]) {
			mapTimecards.put(item.Timecard_Key__c,item.Id);
		}
		
		for (Worklog__c item:lstWorklogs) {
			if (mapTimecards.containsKey(item.Timecard_Key__c)) {
				item.PSA_Timecard__c = mapTimecards.get(item.Timecard_Key__c);
				if (item.PSA_Timecard__c!=null) {
					item.PSA_Integration_Status__c = 'SUCCESS';
					item.PSA_Integration_Error__c = '';
				}
			}	
		}
		
		if (lstWorklogs.size()>0) update lstWorklogs;
	}
	
	//method to set 'SUCCESS' status for Worklog
	private static void setSuccessStatus(list<Worklog__c> lstWorklogs) {
		for (Worklog__c item:lstWorklogs) {
			item.PSA_Integration_Status__c = 'SUCCESS';
			item.PSA_Integration_Error__c = '';
		}
	}
	
	//method to set 'ERROR' status for Worklog with empty PSA_Timecard__c
	//@future 
	public static void setErrorStatus(map<String,String> mapTimecardIds) {
		list<Worklog__c> lstWorklogs = new list<Worklog__c>([Select Id, PSA_Integration_Error__c, PSA_Integration_Status__c, Timecard_Key__c FROM Worklog__c 
						WHERE Timecard_Key__c IN :mapTimecardIds.keySet() AND PSA_Timecard__c=null limit 10000]);
		for (Worklog__c item:lstWorklogs) {
			item.PSA_Integration_Status__c = 'ERROR';
			item.PSA_Integration_Error__c = mapTimecardIds.get(item.Timecard_Key__c);
		}
		if (lstWorklogs.size()>0) update lstWorklogs;
	}
}