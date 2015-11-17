/**
* \arg TriggerName      : SL_Call_ReportHandler
* \arg JIRATicket     	: PWP-17, PWP-19, PWP-18, PWP-43
* \arg CreatedOn      	: 6/FEB/2015
* \arg LastModifiedOn	: 07/JULY/2015
* \arg CreatededBy    	: Pradeep 
* \arg ModifiedBy     	: Lodhi
* \arg Description    	: This class serves as SL_CallReport trigger handler and is used to share call report records, corresponding to call report company records for coverage team members.
*/
public with sharing class SL_Call_ReportHandler 
{
	private static List<Event> lstEvent;
	private static final Date dynamicDate = Dynamic_Date_for_Email__c.getInstance('Dynamic Date')!=null 
	                                        ? Dynamic_Date_for_Email__c.getInstance('Dynamic Date').Start_Date__c : null;
	
	/* Start - Constructor */
	public SL_Call_ReportHandler()
	{
		//Do Nothing
	}
	/* End - Constructor */
	
	/**
	    @MethodName : onAfterInsert
	    @Param 		: map of inserted call report records 
	    @Description: This method called on after insert of call report record.
    **/
	public void onAfterInsert(Map<Id,Call_Report__c> mapNewIdToCallReport)
	{
		createCRCompanyRecords(mapNewIdToCallReport, null);//calling method to create the call report company records
		updateEventsCallReportId(mapNewIdToCallReport, new Map<Id,Call_Report__c>());//calling method to update call report id on the correspoding events.
	}
	
	/**
	    @MethodName : onAfterUpdate
	    @Param 		: new and old map of updated call report records 
	    @Description: This method called on after Update of call report record.
    **/
	public void onAfterUpdate(Map<Id,Call_Report__c> mapNewIdToCallReport, Map<Id,Call_Report__c> mapOldIdToCallReport)
	{
		createCRCompanyRecords(mapNewIdToCallReport, mapOldIdToCallReport);//calling method to create the call report company records
		updateEventsCallReportId(mapNewIdToCallReport, mapOldIdToCallReport);//calling method to update the newly matched event call_report_Id
	}                                                                        //when subject or date or primary account on call report is changed.             
	
	/**
	    @MethodName : onBeforeDelete
	    @Param 		: old map call report records 
	    @Description: This method called on before delete of call report record.
    **/
	public static void onBeforeDelete(Map<Id,Call_Report__c> mapOldIdToCallReport)
	{
		lstEvent = [SELECT Id FROM Event WHERE Call_Report_Id__c IN : mapOldIdToCallReport.keyset()];
	}
	
	/**
	    @MethodName : onAfterDelete
	    @Param 		: NA
	    @Description: This method called on after delete of call report record to blank out the call report id from the corresponding event records.
    **/
	public static void onAfterDelete()
	{
		List<Event> lstEventToUpdate = new List<Event>();
		
		for(Event objEvent : lstEvent)
		{
			lstEventToUpdate.add(new Event(Id = objEvent.Id, Call_Report_Id__c = NULL));
		}
		
		update lstEventToUpdate;
	}
	
	/**
	    @MethodName : createCRCompanyRecords
	    @Param 		: new and old map of of call report company record corresponding to which we have to insert call report company records
	    @Description: This method called on after insert, on after update of call report records.
    **/
	public void createCRCompanyRecords(Map<Id,Call_Report__c> mapNewIdToCallReport , Map<Id,Call_Report__c> mapOldIdToCallReport)
	{
		Set<Id> setAccountId = new set<Id>();//set to hold AccountId
		Set<String> setCallReportIdANDRelavantCompany = new set<String>();//set to hold call report id with relevant company id
		List<Call_Report_Company__c> lstCRCompanyToInsert = new List<Call_Report_Company__c>();//list of call report company
		Set<Id> setCallReportId = new Set<Id>();
		Set<Id> setUpdatedCR = new Set<Id>();// set to hold the ids of call report records whose owner is changed.
		List<Call_Report__c> lstCallReport = new List<Call_Report__c>(); // This list is used to hold those call report records whose owner is changed.
		//iterate over the new Call_Report__c map 
		for(Call_Report__c objCallReport : mapNewIdToCallReport.values())
		{
			//check whether Reference_Account__c of call report is not null
			if(objCallReport.Reference_Account__c != null)
			{
				setAccountId.add(objCallReport.Reference_Account__c);
			}
			setCallReportId.add(objCallReport.Id);
			
			/* Start - This code portion comes under the requirement of PWP-19 */
			if(Trigger.isUpdate && objCallReport.OwnerId!=mapOldIdToCallReport.get(objCallReport.Id).OwnerId)
				setUpdatedCR.add(objCallReport.Id);
			/* End - This code portion comes under the requirement of PWP-19 */
		}
		
		/* Start - This code portion comes under the requirement of PWP-19 */
		if(!setUpdatedCR.isEmpty())
			SL_SharingController.createSharingRecords([SELECT Call_Report__c, Relevant_Company__c FROM Call_Report_Company__c WHERE Call_Report__c IN:setUpdatedCR]);
		/* End - This code portion comes under the requirement of PWP-19 */
					
		//query the Call_Report_Company__c records based on the Relevant_Company__c id and Call_Report__c Id
		for(Call_Report_Company__c objCRCompany: [Select Relevant_Company__c, Call_Report__c From Call_Report_Company__c WHERE Relevant_Company__c IN:setAccountId AND Call_Report__c IN:setCallReportId])
		{
			setCallReportIdANDRelavantCompany.add(objCRCompany.Call_Report__c +'-'+objCRCompany.Relevant_Company__c);
		}
		
		//iterate over the new Call_Report__c map 
		for(Call_Report__c objCallReport : mapNewIdToCallReport.values())
		{
			//check wheather old Call_Report__c is not null or old Reference_Account__c and new Reference_Account__c is equals or not
			if(mapOldIdToCallReport == null || (mapOldIdToCallReport != null && objCallReport.Reference_Account__c != null &&
				objCallReport.Reference_Account__c != mapOldIdToCallReport.get(objCallReport.Id).Reference_Account__c))
			{
				//Add call report company to lstCRCompanyToInsert only when it is not already present on setCallReportIdANDRelavantCompany 
				if(!setCallReportIdANDRelavantCompany.contains(objCallReport.Id +'-'+ objCallReport.Reference_Account__c))
				{
					lstCRCompanyToInsert.add(new Call_Report_Company__c(Relevant_Company__c = objCallReport.Reference_Account__c, Call_Report__c = objCallReport.Id));
				}
			}
		}
		//check whether List empty or not and perform insert operation
		if(!lstCRCompanyToInsert.isEmpty())
			Database.insert(lstCRCompanyToInsert);
	}
	
	/**
	    @MethodName : updateEventsCallReportId
	    @Param 		: new map of of call report
	    @JiraTicket : PWP-43
	    @CreatedBy  : Lodhi
	    @Description: This method will update the Call Report id on the corresponding Event records.
    **/
	private void updateEventsCallReportId(Map<Id,Call_Report__c> mapNewIdToCallReport , Map<Id,Call_Report__c> mapOldIdToCallReport)
	{
	    Set<Id> setAccountId = new Set<Id>();//set to hold account id
	    Set<Id> setCallReportId = new Set<Id>();//set to hold call report id whose one of the field from Reference_Account__c or Call_Report_Date__c or name is changed
	    Map<Id, Event> mapEventToUpdate = new Map<Id, Event>();//Map of event to update Call_Report_Id__c
	    Map<String, List<Call_Report__c>> mapCRNameAccIdDateToLstCallReport = new Map<String, List<Call_Report__c>>();//hold unique string combination to list of call reports
	    Map<String, List<Event>> mapEventSubWhatIdActDateToLstEvent = new Map<String, List<Event>>();//hold unique String combination to list of event 
	    
	    //to get set call report id, set account id and map of unique String to list of call report.
	    for(Call_Report__c objNewCR : mapNewIdToCallReport.values()) 
	    {
	        Call_Report__c objOldCR = mapOldIdToCallReport.get(objNewCR.Id);
	        
	        if(objNewCR.Reference_Account__c != null && objNewCR.Call_Report_Date__c != null && !objNewCR.Do_Not_Fire_Trigger__c
	           && (mapOldIdToCallReport.isEmpty() || (objNewCR.Reference_Account__c != objOldCR.Reference_Account__c 
	           || objNewCR.Call_Report_Date__c != objOldCR.Call_Report_Date__c || objNewCR.Name != objOldCR.Name
	           || objNewCR.OwnerId != objOldCR.OwnerId)))
	        {
	            setCallReportId.add(objNewCR.Id);
	            setAccountId.add(objNewCR.Reference_Account__c);
	            String strCombined = objNewCR.Name +'_'+ objNewCR.Reference_Account__c +'_'+ objNewCR.Call_Report_Date__c +'_'+ objNewCR.OwnerId;
	            if(mapCRNameAccIdDateToLstCallReport.containsKey(strCombined))
                    mapCRNameAccIdDateToLstCallReport.get(strCombined).add(objNewCR);
                else
                    mapCRNameAccIdDateToLstCallReport.put(strCombined, new List<Call_Report__c>{objNewCR});
	        }
	    }
	    
	    //to blank out the Call_Report_Id__c from the previous events.
	    for(Event objEvent : [SELECT Id FROM Event WHERE Call_Report_Id__c IN : setCallReportId])
	    {
	        mapEventToUpdate.put(objEvent.Id, new Event(Id = objEvent.Id, Call_Report_Id__c = null));
	    }
	    update mapEventToUpdate.values();
	    
	    //to get map of unique string to list of events
	    for(Event objEvent : [SELECT Id, Subject, ActivityDate, WhatId, Call_Report_Id__c, OwnerId 
	                            FROM Event WHERE WhatId IN : setAccountId 
	                             AND Call_Report_Id__c = null AND GroupEventType != '2' AND ActivityDate >: dynamicDate 
	                             AND ActivityDate < TODAY AND Owner.isActive = true AND WhatId != null 
	                             AND What.Type = 'Account' AND Don_t_Send_Call_Report_Reminder__c = false
	                           ORDER BY LastModifiedDate DESC])
        {
            String strCombined = objEvent.Subject +'_'+ objEvent.WhatId +'_'+ objEvent.ActivityDate +'_'+ objEvent.OwnerId;
            if(mapEventSubWhatIdActDateToLstEvent.containsKey(strCombined))
                mapEventSubWhatIdActDateToLstEvent.get(strCombined).add(objEvent);
            else
                mapEventSubWhatIdActDateToLstEvent.put(strCombined, new List<Event>{objEvent});
        }
        
        mapEventToUpdate = new Map<Id, Event>();
        //updating Call_Report_Id__c on event with the matched call report id
        for(String strCombined : mapEventSubWhatIdActDateToLstEvent.keySet())
        {
            if(mapCRNameAccIdDateToLstCallReport.containsKey(strCombined))
            {
                Integer intCount = 0;
                for(Event objEvent : mapEventSubWhatIdActDateToLstEvent.get(strCombined))
                {
                    if(intCount == 0)
                        for(Call_Report__c objCallReport : mapCRNameAccIdDateToLstCallReport.get(strCombined))
                            mapEventToUpdate.put(objEvent.Id, new Event(Id = objEvent.Id, Call_Report_Id__c = objCallReport.Id));    
                    else
                        mapEventToUpdate.put(objEvent.Id, new Event(Id = objEvent.Id, Don_t_Send_Call_Report_Reminder__c = true));    
                    intCount++;
                }
            }    
        }
        database.update(mapEventToUpdate.values(), false);  
	}
	/* End */
}