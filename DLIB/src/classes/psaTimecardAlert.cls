/****************************************************************************************
Name            : psaTimecardAlert
Author          : CLD
Created Date    : April 17, 2013
Description     : Contains methods for calculating Timecard totals for given week for use in alerts.
******************************************************************************************/
public with sharing class psaTimecardAlert {

  public static integer calculateResourceTimecardHours(date calcDate, Id singleResourceId)
  {
  	// Batchable process will call with one Id at time, so convert to a Set() and call calculateTimecardHours(date, set)
    set<id> resourceIds = new set<id>();
    integer rtn;
    
    resourceIds.add(singleResourceId);
    rtn = calculateResourceTimecardHours(calcDate, resourceIds);
    return rtn;
  }
  


  /*** Takes a week date and a set of Resource Id's and calculates (upsert) records in the Timecard Alert object ***/
  public static integer calculateResourceTimecardHours(date calcDate, set<Id> resourceIds)
  {

    list<Timecard_Alert__c> tcAlertList = new list<Timecard_Alert__c>();
    Timecard_Alert__c tmpTcAlert = new Timecard_Alert__c();
    id prevResourceId;
    decimal approvedHrs = 0;
    decimal submittedHrs = 0;
    decimal savedHrs = 0;
    integer cntr = 0;
    datetime weekStartDtm;
    datetime weekEndDtm;
    date weekStart;
    date weekEnd;
        
    // get the week's Start Date and End Date value for the date that was passed to the method
    //weekEndDtm = datetime.valueOf(string.valueOf(calcDate) + '00:00:00');
    weekEndDtm = getWeekEndingDatetime(datetime.valueOf(string.valueOf(calcDate) + ' 00:00:00'));
    weekStartDtm = weekEndDtm.addDays(-6);
    
    weekEnd = date.valueOf(weekEndDtm.formatGmt('yyyy-MM-dd'));
    weekStart = date.valueOf(weekStartDtm.formatGmt('yyyy-MM-dd'));
  
    
    // Query Contact object with related query to Timceard Header 
    for(Contact results : [SELECT Id, 
                                  pse__Region__c,
                                  pse__Practice__c,
                                  pse__Group__c,
                                  pse__Work_Calendar__r.pse__Week_Total_Hours__c,
                                  pse__Salesforce_User__r.ManagerId,
                                  (
                                    SELECT id,
                                           pse__Status__c,
                                           pse__Start_Date__c,
                                           pse__End_Date__c,
                                           pse__Total_Hours__c
                                      FROM pse__Timecards__r
                                     WHERE pse__End_Date__c = :weekEnd
                                  )
                             FROM Contact
                            WHERE Id in :resourceIds
                         ORDER BY Id])
    {
    	// Reset buckets that hold hours summaries
    	approvedHrs = 0;
        submittedHrs = 0;
        savedHrs = 0;
        
        // Set the values from the Contact record
        tmpTcAlert.Resource__c = results.Id;
        tmpTcAlert.Week_End_Date__c = weekEnd;
        tmpTcAlert.Week_Start_Date__c = weekStart;
        tmpTcAlert.Work_Calendar_Hours__c = results.pse__Work_Calendar__r.pse__Week_Total_Hours__c;
        tmpTcAlert.Calculated_Date__c = datetime.now();
        tmpTcAlert.Record_Hash__c = tmpTcAlert.Resource__c + '|' + tmpTcAlert.Week_End_Date__c;  // NOTE: the Record Hash is the External Id used in the Upser below
        
        // These values may be null so we have to check first
        if(results.pse__Region__c != null)
            tmpTcAlert.Region__c = results.pse__Region__c;
        if(results.pse__Practice__c != null)
            tmpTcAlert.Practice__c = results.pse__Practice__c;
        if(results.pse__Group__c != null)
            tmpTcAlert.Group__c = results.pse__Group__c;
        if(results.pse__Salesforce_User__r.ManagerId != null)
            tmpTcAlert.Resource_Manager__c = results.pse__Salesforce_User__r.ManagerId;
        
        // Now loop through any Timecards in the sub-query to calculate the hours from the Timecards (by status)
        for(cntr=0;cntr < results.pse__Timecards__r.size();cntr++)
        {
        	// Check the Timecard's status and update appropriate bucket of hours
        	if(results.pse__Timecards__r[cntr].pse__Status__c == 'Approved')
        	   approvedHrs += results.pse__Timecards__r[cntr].pse__Total_Hours__c; 
        	else if(results.pse__Timecards__r[cntr].pse__Status__c == 'Submitted')
        	   submittedHrs += results.pse__Timecards__r[cntr].pse__Total_Hours__c;
        	else
        	   savedHrs += results.pse__Timecards__r[cntr].pse__Total_Hours__c;
        }
     	
        
        // Add the aggregated hours values
        tmpTcAlert.Approved_Hours__c = approvedHrs;
        tmpTcAlert.Submitted_Hours__c = submittedHrs;
        tmpTcAlert.Saved_Hours__c = savedHrs;
        
        // Add to list that will be upserted
        tcAlertList.add(tmpTcAlert);
    }
    
    system.debug('*** calculateResourceTimecardHours UPSERT');
    if(tcAlertList.Size() > 0)
    {
        system.debug('*** calculateResourceTimecardHours UPSERT tcAlertList.*: ' + tcAlertList);
        upsert tcAlertList Record_Hash__c;  // Note, using the Record Hash column to specify unique record, Record_Hash__c = ['Resource__c + '|' + Week_End_Date__c]
    }   
    
    return cntr;
  	
  }

 
  /*** Takes a date and determines the week ending date ****/  
  public static Datetime getWeekEndingDatetime(Datetime dtm){

    // Note: GMT is used from the datetime that is passed in
    //datetime dtm = datetime.valueOf(string.valueOf(dt) + '00:00:00');
    system.debug('*** psaTimecardAlert.getWeekEndingDateString: getWeekEndingDateString dtm=' + dtm);
  
    if(dtm == null) {
        return datetime.valueOf('1970-01-01');
    }
  
    datetime dtmWeekEndingGmt = datetime.newInstanceGmt(dtm.dateGMT(), Time.newInstance(0,0,0,0));
    string weekday = dtmWeekEndingGmt.formatGmt('E'); 
    
    // Note: assumes week ends on Saturday
    system.Debug('*** psaTimecardAlert.getWeekEndingDateString: Weekday for ' + dtmWeekEndingGmt + '=' + weekday);
  
    if(weekday == 'Mon'){
        dtmWeekEndingGmt = dtmWeekEndingGmt.addDays(5);
    } else if(weekday == 'Tue'){
        dtmWeekEndingGmt = dtmWeekEndingGmt.addDays(4);
    } else if(weekday == 'Wed'){
        dtmWeekEndingGmt = dtmWeekEndingGmt.addDays(3);
    } else if(weekday == 'Thu'){
        dtmWeekEndingGmt = dtmWeekEndingGmt.addDays(2);
    } else if(weekday == 'Fri'){
        dtmWeekEndingGmt = dtmWeekEndingGmt.addDays(1);
    } else if(weekday == 'Sat'){
        //do nothing
    } else if(weekday == 'Sun'){
        dtmWeekEndingGmt = dtmWeekEndingGmt.addDays(6);
    }
  
    string stringWeekEndingDate = dtmWeekEndingGmt.formatGmt('yyyy-MM-dd');
    system.debug('*** psaTimecardAlert.getWeekEndingDatetime: stringWeekEndingDate=' + stringWeekEndingDate);
    
    //return stringWeekEndingDate;
    return dtmWeekEndingGmt;
}
    



}