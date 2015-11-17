public with sharing class psaProjectWorklogTimecards {


public static void psaConvertProjectWorklogTime(set<id> worklogIds)
{
	map<string, Worklog__c> worklogMap = new map<string, Worklog__c>();
	set<id> projIds = new set<id>();
	set<id> tchIds = new set<id>();
	set<id> mstoneIds = new set<id>();
	set<id> resourceIds = new set<id>();
	list<pse__Timecard_Header__c> tchUpdate = new list<pse__Timecard_Header__c>();
	list<pse__Timecard_Header__c> tchInsert = new list<pse__Timecard_Header__c>();
	
	map<id, Worklog__c> newPsaTimecardMap = new map<id, Worklog__c>();  // This map holds Worklog records that do NOT match existing PSA Timecards
	string worklogKey;
	string timecardKey;

	// Query all the Project Worklog records (aka "Jira Timecards") and build sets of data to be used as
	// filter to query the Timecard Header object
	for(Worklog__c wl : [
		SELECT id,
				Name,
				Week_Start_Date__c,
				Hours__c,
				PSA_Project__c,
				PSA_Timecard__c,
				PSA_Milestone__c,
				JIRA_Contact__c,
				JIRA_Notes__c,
				Day_Of_Week__c,
				JIRA_Start_Date__c
		   FROM Worklog__c
		  WHERE id in :worklogIds
		    AND PSA_Timecard__c = null]) 
	{
		projIds.add(wl.PSA_Project__c);
		mstoneIds.add(wl.PSA_Milestone__c);
		resourceIds.add(wl.JIRA_Contact__c);
		
		// Insert record into the worklogMap using the "Project Id | Resource Id | Milestone Id | Week Start" as the key
		worklogKey = wl.PSA_Project__c + '|' + wl.JIRA_Contact__c + '|' + wl.PSA_Milestone__c + '|' + wl.Week_Start_Date__c;
		worklogMap.put(worklogKey, wl);
		
	}
	
	// Now query PSA Timecard Header records that might fall within the Project/Resource/Milestone values on Jira worklog records
	for(pse__Timecard_Header__c tch : [
		SELECT id,
			   pse__Project__c,
			   pse__Resource__c,
			   pse__Milestone__c,
			   pse__Start_Date__c,
			   pse__Sunday_Hours__c,
			   pse__Monday_Hours__c,
			   pse__Tuesday_Hours__c,
			   pse__Wednesday_Hours__c,
			   pse__Thursday_Hours__c,
			   pse__Friday_Hours__c,
			   pse__Saturday_Hours__c,
			   pse__Additional_Notes__c
		  FROM pse__Timecard_Header__c
		 WHERE pse__Project__c in :projIds
		   AND pse__Milestone__c in :mstoneIds
		   AND pse__Resource__c in :resourceIds])
	{
		timecardKey = tch.pse__Project__c + '|' + tch.pse__Resource__c + '|' + tch.pse__Milestone__c + '|' + tch.pse__Start_Date__c;
		
		// Check to see if timecardKey matches a Jira worklog record
		if(worklogMap.containsKey(timecardKey))
		{
			// Update the Timecard with the Worklog's hours and notes
			pse__Timecard_Header__c tmpTch = new pse__Timecard_Header__c();
			
			if(worklogMap.get(timecardKey).Day_Of_Week__c == 'Sunday')
				tmpTch.pse__Sunday_Hours__c+= worklogMap.get(timecardKey).Hours__c;
		    else if (worklogMap.get(timecardKey).Day_Of_Week__c == 'Monday')
		    	tmpTch.pse__Monday_Hours__c+= worklogMap.get(timecardKey).Hours__c;
		    else if (worklogMap.get(timecardKey).Day_Of_Week__c == 'Tuesday')
		    	tmpTch.pse__Tuesday_Hours__c+= worklogMap.get(timecardKey).Hours__c;
		    else if (worklogMap.get(timecardKey).Day_Of_Week__c == 'Wednesday')
		    	tmpTch.pse__Wednesday_Hours__c+= worklogMap.get(timecardKey).Hours__c;
		    else if (worklogMap.get(timecardKey).Day_Of_Week__c == 'Thursday')
		    	tmpTch.pse__Thursday_Hours__c+= worklogMap.get(timecardKey).Hours__c;
		    else if (worklogMap.get(timecardKey).Day_Of_Week__c == 'Friday')
		    	tmpTch.pse__Friday_Hours__c+= worklogMap.get(timecardKey).Hours__c;
		    else if (worklogMap.get(timecardKey).Day_Of_Week__c == 'Saturday')
		    	tmpTch.pse__Saturday_Hours__c+= worklogMap.get(timecardKey).Hours__c;
		    	
		    // Append the worklog notes onto any notes in the "Additional Notes" field on the Timecard Header
		    tmpTch.pse__Additional_Notes__c = tch.pse__Additional_Notes__c + worklogMap.get(timecardKey).JIRA_Notes__c;
		   
		    tchUpdate.add(tmpTch);
		    
		    // Remove the Worklog record from the worklog map (note, those Worklog records in the Worklog map that are left over need to be inserted as a new PSA Timecard)
		    worklogMap.remove(timecardKey)	;
		    
		    // ****** TO DO *******//
		    // NEED TO UPDATE THE Worklog__c.PSA_Timecard__c value for any Worklog__c record that is used to update an existing Timecard Header record
		}
		
		// Now create a PSA Timecard Header record for all the Jira Worklog records (one PSA Timecard for each Week) by first loading
		// a Map of Timecard Header records based on the Project-Resource-Milestone.. recall that a Jira worklog is for a single day but
		// the PSA Timecard Header is a record that holds a weeks worth of hours (Sun - Sat)
		map<string, pse__Timecard_Header__c> newTchMap = new map<string, pse__Timecard_Header__c>();
		for(string wlKey : worklogMap.keySet())
		{
			pse__Timecard_Header__c tmpTch = new pse__Timecard_Header__c();
			
			if(newTchMap.containsKey(wlKey))
			{
				// Already have a new PSA Timecard Header in the newTchMap.. so just set the tmpTch to the value in the map and we'll update any hours/notes below
				tmpTch = newTchMap.get(wlKey);
			}
			else
			{
			
				// Need to initialize the tmpTch to the values from the worklog
				tmpTch.pse__Project__c = worklogMap.get(wlKey).PSA_Project__c;
				tmpTch.pse__Resource__c = worklogMap.get(wlKey).JIRA_Contact__c;
				tmpTch.pse__Milestone__c = worklogMap.get(wlKey).PSA_Milestone__c;
				tmpTch.pse__Start_Date__c = worklogMap.get(wlKey).Week_Start_Date__c;

			}
			
			// Update any Hours and notes values on the tmpTch record (recall that if the tmpTch was already in the map we need to update those previously entered value)
			if(worklogMap.get(wlKey).Day_Of_Week__c == 'Sunday')
				tmpTch.pse__Sunday_Hours__c+= worklogMap.get(wlKey).Hours__c;
		    else if (worklogMap.get(wlKey).Day_Of_Week__c == 'Monday')
		    	tmpTch.pse__Monday_Hours__c+= worklogMap.get(wlKey).Hours__c;
		    else if (worklogMap.get(wlKey).Day_Of_Week__c == 'Tuesday')
		    	tmpTch.pse__Tuesday_Hours__c+= worklogMap.get(wlKey).Hours__c;
		    else if (worklogMap.get(wlKey).Day_Of_Week__c == 'Wednesday')
		    	tmpTch.pse__Wednesday_Hours__c+= worklogMap.get(wlKey).Hours__c;
		    else if (worklogMap.get(wlKey).Day_Of_Week__c == 'Thursday')
		    	tmpTch.pse__Thursday_Hours__c+= worklogMap.get(wlKey).Hours__c;
		    else if (worklogMap.get(wlKey).Day_Of_Week__c == 'Friday')
		    	tmpTch.pse__Friday_Hours__c+= worklogMap.get(wlKey).Hours__c;
		    else if (worklogMap.get(wlKey).Day_Of_Week__c == 'Saturday')
		    	tmpTch.pse__Saturday_Hours__c+= worklogMap.get(wlKey).Hours__c;
		    	
		    // Append the worklog notes onto any notes in the "Additional Notes" field on the Timecard Header
		    tmpTch.pse__Additional_Notes__c = tch.pse__Additional_Notes__c + worklogMap.get(wlKey).JIRA_Notes__c;
		   
		    newTchMap.put(wlKey, tmpTch);
		    
		    // ****** TO DO *******//
		    // NEED TO UPDATE THE Worklog__c.PSA_Timecard__c value for any Worklog__c record that is used to insert an existing Timecard Header record
		    
			
		}
		
		// Make a list of Timecard Headers to be inserted from the tch Map
		tchInsert = newTchMap.values();
			
	}
	
			
	// Insert any new Timecard Header records, Update any updated Timecard Header records
	if(tchInsert.size() > 0)
		insert tchInsert;
		
	if(tchUpdate.size() > 0)
		update tchUpdate;

}

}