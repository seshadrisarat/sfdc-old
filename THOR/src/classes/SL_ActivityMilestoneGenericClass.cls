/**
*  ClassName      : SL_ActivityMilestoneGenericClass
*  JIRATicket     : THOR-40
*  CreatedOn      : 22/SEP/2014
*  ModifiedBy     : Sanath Kumar
*  Description    : This is the generic class to rollup the activity dates based on type to the Lead and Opportunity
*/
public with sharing class SL_ActivityMilestoneGenericClass 
{
	public static final string CALL = 'Call';
	public static final string EMAIL = 'Email';
	public static final string APPOINTMENT = 'Appointment';
	public static final Schema.sObjectType OPPORTUNITY_TYPE = Opportunity.sObjectType;
	public static final Schema.sObjectType LEAD_TYPE = Lead.sObjectType;
	
	public SL_ActivityMilestoneGenericClass(List<Sobject> lstSobjects)
	{
		Set<Id> setOpportunityId = new Set<Id>();
    	Set<Id> setLeadId = new Set<Id>();
    	Set<Id> setSobjectId = new Set<Id>();
    	Set<String> setStrWhatIdAndType = new Set<String>();
		Set<String> setStrWhoIdAndType = new Set<String>();
		Map<Id,DateTime> mapSobjectId_FirstCall = new Map<Id,DateTime>();
		Map<Id,DateTime> mapSobjectId_FirstEmail = new Map<Id,DateTime>();
		Map<Id,DateTime> mapSobjectId_FirstAppointment = new Map<Id,DateTime>();
		Map<Id,DateTime> mapSobjectId_LastAppointment = new Map<Id,DateTime>();
		
    	///Create sets of Opportunity id and Lead id
    	for(Sobject objSobject : lstSobjects)
    	{
    		if(objSobject.getSObjectType() == OPPORTUNITY_TYPE)
    			setOpportunityId.add(objSobject.Id);
    		else if(objSobject.getSObjectType() == LEAD_TYPE)
    			setLeadId.add(objSobject.Id);
    		setSobjectId.add(objSobject.Id);
    	}
    	
    	///Create a map of Opportunity/Lead id to date values
		for(Event objEvent:[SELECT WhatId,WhoId,StartDateTime,Type 
							FROM Event 
							WHERE (WhatId IN: setOpportunityId OR WhoId IN:setLeadId) AND EndDateTime <: Date.today()
							ORDER BY StartDateTime ASC])
    	{
    		if(objEvent.Type == CALL)
    		{
				if(!mapSobjectId_FirstCall.containsKey(objEvent.WhatId) && objEvent.WhatId != null)
					mapSobjectId_FirstCall.put(objEvent.WhatId, objEvent.StartDateTime);
				if(!mapSobjectId_FirstCall.containsKey(objEvent.WhoId) && objEvent.WhoId != null)
					mapSobjectId_FirstCall.put(objEvent.WhoId, objEvent.StartDateTime);	
    		}		
			else if(objEvent.Type == EMAIL)
			{		
				if(!mapSobjectId_FirstEmail.containsKey(objEvent.WhatId) && objEvent.WhatId != null)
					mapSobjectId_FirstEmail.put(objEvent.WhatId, objEvent.StartDateTime);
				if(!mapSobjectId_FirstEmail.containsKey(objEvent.WhoId) && objEvent.WhoId != null)
					mapSobjectId_FirstEmail.put(objEvent.WhoId, objEvent.StartDateTime);
			}	
			else if(objEvent.Type == APPOINTMENT)	
			{
				if(!mapSobjectId_FirstAppointment.containsKey(objEvent.WhatId) && objEvent.WhatId != null)
					mapSobjectId_FirstAppointment.put(objEvent.WhatId, objEvent.StartDateTime);
				if(!mapSobjectId_FirstAppointment.containsKey(objEvent.WhoId) && objEvent.WhoId != null)
					mapSobjectId_FirstAppointment.put(objEvent.WhoId, objEvent.StartDateTime);
			}
    	}
    	
    	///Create a map of Opportunity/Lead ids to last appointment date
		for(Event objEvent:[SELECT WhatId,WhoId,StartDateTime 
		                    FROM Event 
		                    WHERE (WhatId IN: setOpportunityId OR WhoId IN:setLeadId) AND TYPE =: APPOINTMENT  AND EndDateTime <: Date.today()
		                    ORDER BY StartDateTime DESC])
		{
			if(objEvent.WhatId != null  && !mapSobjectId_LastAppointment.containsKey(objEvent.WhatId))
				mapSobjectId_LastAppointment.put(objEvent.WhatId, objEvent.StartDateTime);
			if(objEvent.WhoId != null  && !mapSobjectId_LastAppointment.containsKey(objEvent.WhoId))
				mapSobjectId_LastAppointment.put(objEvent.WhoId, objEvent.StartDateTime);
		}
		
		///Create map to store whatid/whoid and type of task as a string and also check if different date fields on task are less than that of event
		for(Task objTask:[SELECT WhatId,WhoId,Type,ActivityDate
		                  FROM Task
		                  WHERE (WhatId IN: setOpportunityId OR WhoId IN:setLeadId)  AND IsClosed = true
		                  ORDER BY ActivityDate ASC])
		{
			Date TASK_ACTIVITY_DATE = objTask.ActivityDate;
			DateTime TASK_ACTIVITY_DATETIME;
			
			if(TASK_ACTIVITY_DATE != null)
				TASK_ACTIVITY_DATETIME = System.Datetime.newInstance(Date.ValueOf(TASK_ACTIVITY_DATE), Time.newInstance(8, 0, 0, 0));
			
			if(objTask.WhatId != null  && !setStrWhatIdAndType.contains(String.ValueOf(objTask.WhatId) +'-'+ String.ValueOf(objTask.Type)))
			{
				if(objTask.Type == CALL && (mapSobjectId_FirstCall.containskey(objTask.WhatId) && mapSobjectId_FirstCall.get(objTask.WhatId) != null &&
				    TASK_ACTIVITY_DATE < mapSobjectId_FirstCall.get(objTask.WhatId) || (mapSobjectId_FirstCall.get(objTask.WhatId) == null)))
				{
					mapSobjectId_FirstCall.put(objTask.WhatId,TASK_ACTIVITY_DATETIME);
				}
				else if(objTask.Type == EMAIL &&  (mapSobjectId_FirstEmail.containskey(objTask.WhatId) && mapSobjectId_FirstEmail.get(objTask.WhatId) != null &&
				    TASK_ACTIVITY_DATE < mapSobjectId_FirstEmail.get(objTask.WhatId) || (mapSobjectId_FirstEmail.get(objTask.WhatId) == null)))
				{
					mapSobjectId_FirstEmail.put(objTask.WhatId,TASK_ACTIVITY_DATETIME);
				}
				else if(objTask.Type == APPOINTMENT && (mapSobjectId_FirstAppointment.containskey(objTask.WhatId) && mapSobjectId_FirstAppointment.get(objTask.WhatId) != null &&
				    TASK_ACTIVITY_DATE < mapSobjectId_FirstAppointment.get(objTask.WhatId) || (mapSobjectId_FirstAppointment.get(objTask.WhatId) == null)))
				{
					mapSobjectId_FirstAppointment.put(objTask.WhatId,TASK_ACTIVITY_DATETIME);
				}
			}
			if(objTask.WhoId != null  && !setStrWhoIdAndType.contains(String.ValueOf(objTask.WhoId)+'-'+String.ValueOf(objTask.Type)))
			{
				if(objTask.Type == CALL && (mapSobjectId_FirstCall.containskey(objTask.WhoId) && mapSobjectId_FirstCall.get(objTask.WhoId) != null &&
			    	TASK_ACTIVITY_DATE < mapSobjectId_FirstCall.get(objTask.WhoId) || (mapSobjectId_FirstCall.get(objTask.WhoId) == null)))
				{
					mapSobjectId_FirstCall.put(objTask.WhoId,TASK_ACTIVITY_DATETIME);
				}
				else if(objTask.Type == EMAIL && (mapSobjectId_FirstEmail.containskey(objTask.WhoId) && mapSobjectId_FirstEmail.get(objTask.WhoId) != null &&
				    TASK_ACTIVITY_DATE < mapSobjectId_FirstEmail.get(objTask.WhoId) || (mapSobjectId_FirstEmail.get(objTask.WhoId) == null)))
				{
					mapSobjectId_FirstEmail.put(objTask.WhoId,TASK_ACTIVITY_DATETIME);
				}
				else if(objTask.Type == APPOINTMENT && (mapSobjectId_FirstAppointment.containskey(objTask.WhoId) && mapSobjectId_FirstAppointment.get(objTask.WhoId) != null &&
			     	TASK_ACTIVITY_DATE < mapSobjectId_FirstAppointment.get(objTask.WhoId) || (mapSobjectId_FirstAppointment.get(objTask.WhoId) == null)))
				{
					mapSobjectId_FirstAppointment.put(objTask.WhoId,TASK_ACTIVITY_DATETIME);
				}
			}
			
			if(objTask.WhatId != null && objTask.Type != null)
				setStrWhatIdAndType.add(String.ValueOf(objTask.WhatId) +'-'+ String.ValueOf(objTask.Type));
				
			if(objTask.WhoId != null && objTask.Type != null)
				setStrWhoIdAndType.add(String.ValueOf(objTask.WhoId)+'-'+String.ValueOf(objTask.Type));
		}
		
		
		///Check if appointment date on task is more than that of event
		for(Task objTask:[SELECT WhatId,WhoId,Type,ActivityDate
		                  FROM Task
		                  WHERE (WhatId IN: setOpportunityId OR WhoId IN:setLeadId) AND IsClosed = true
		                  ORDER BY ActivityDate DESC])
		{
			Date TASK_ACTIVITY_DATE = objTask.ActivityDate;
			DateTime TASK_ACTIVITY_DATETIME;       
			
			if(TASK_ACTIVITY_DATE != null)
				TASK_ACTIVITY_DATETIME = System.Datetime.newInstance(Date.ValueOf(TASK_ACTIVITY_DATE), Time.newInstance(8, 0, 0, 0));
			
			if(objTask.Type == APPOINTMENT && objTask.WhatId != null)
			{
				if(mapSobjectId_LastAppointment.containskey(objTask.WhatId) && mapSobjectId_LastAppointment.get(objTask.WhatId) != null &&
				    TASK_ACTIVITY_DATE > mapSobjectId_LastAppointment.get(objTask.WhatId) || (mapSobjectId_LastAppointment.get(objTask.WhatId) == null))
				{
					mapSobjectId_LastAppointment.put(objTask.WhatId,TASK_ACTIVITY_DATETIME);
				}
			}
			
			if(objTask.Type == APPOINTMENT && objTask.WhoId != null)
			{
				if(mapSobjectId_LastAppointment.containskey(objTask.WhoId) && mapSobjectId_LastAppointment.get(objTask.WhoId) != null &&
				     TASK_ACTIVITY_DATE > mapSobjectId_LastAppointment.get(objTask.WhoId) || (mapSobjectId_LastAppointment.get(objTask.WhoId) == null))
				{
					mapSobjectId_LastAppointment.put(objTask.WhoId,TASK_ACTIVITY_DATETIME);
				}
			}
		}
		
		updateRecords(setSobjectId,mapSobjectId_FirstCall,mapSobjectId_FirstEmail,mapSobjectId_FirstAppointment,mapSobjectId_LastAppointment,setStrWhatIdAndType);
		
		if(!setLeadId.isEmpty())
			updateLeadStatusToContacted(setLeadId);
	}
	
	
	/*
    	* MethodName   : updateRecords
        * Description  : This method is to update opportunity/lead records
    */
	private void updateRecords(Set<Id> setSobjectId, Map<Id,DateTime> mapSobjectId_FirstCall,Map<Id,DateTime> mapSobjectId_FirstEmail,
	                                       Map<Id,DateTime> mapSobjectId_FirstAppointment, Map<Id,DateTime> mapSobjectId_LastAppointment,Set<String> setStrWhatIdAndType)
	{
		List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
		List<Lead> lstLeadToUpdate = new List<Lead>();
		
		DateTime firstCallDate;
		DateTime firstEmailDate;
		DateTime firstAppointmentDate;
		DateTime lastAppointmentDate;
		
		///Create list of Opportunity/Lead records to update
		for(Id objSobjectId:setSobjectId)
		{
			String SOBJECTID = String.ValueOf(objSobjectId);
			
			if(mapSobjectId_FirstCall.containskey(objSobjectId) && mapSobjectId_FirstCall.get(objSobjectId) != null)
				firstCallDate = mapSobjectId_FirstCall.get(objSobjectId);
			else if(!mapSobjectId_FirstCall.containskey(objSobjectId) && !setStrWhatIdAndType.contains(SOBJECTID + '-' + CALL))
				firstCallDate = null;
			
			if(mapSobjectId_FirstEmail.containskey(objSobjectId) && mapSobjectId_FirstEmail.get(objSobjectId) != null)
				firstEmailDate = mapSobjectId_FirstEmail.get(objSobjectId);
			else if(!mapSobjectId_FirstEmail.containskey(objSobjectId) && !setStrWhatIdAndType.contains(SOBJECTID + '-' + EMAIL))
				firstEmailDate = null;
			
			if(mapSobjectId_FirstAppointment.containskey(objSobjectId) && mapSobjectId_FirstAppointment.get(objSobjectId) != null)
				firstAppointmentDate = mapSobjectId_FirstAppointment.get(objSobjectId);
			else if(!mapSobjectId_FirstAppointment.containskey(objSobjectId) && !setStrWhatIdAndType.contains(SOBJECTID + '-' + APPOINTMENT))
				firstAppointmentDate = null;
			
			if(mapSobjectId_LastAppointment.containskey(objSobjectId) && mapSobjectId_LastAppointment.get(objSobjectId) != null)
				lastAppointmentDate= mapSobjectId_LastAppointment.get(objSobjectId);
			else if(!mapSobjectId_LastAppointment.containskey(objSobjectId) && !setStrWhatIdAndType.contains(SOBJECTID + '-' + APPOINTMENT))
				lastAppointmentDate= null;
			
			///Create list of Opportunity records
			if(objSobjectId.getSObjectType() == OPPORTUNITY_TYPE)
			{	
				sObject objOpportunitySobject = new Opportunity();
				objOpportunitySobject.put('Id',objSobjectId);
				objOpportunitySobject.put('First_Call_Date__c',firstCallDate);
				objOpportunitySobject.put('First_Email_Date__c',firstEmailDate);
				objOpportunitySobject.put('First_Appointment_Date__c',firstAppointmentDate);
				objOpportunitySobject.put('Last_Appointment_Date__c',lastAppointmentDate);
				lstOpportunityToUpdate.add((Opportunity)objOpportunitySobject);
			}
			///Create list of lead records
			else if(objSobjectId.getSObjectType() == LEAD_TYPE)
			{
				sObject objLeadSobject = new Lead();
				objLeadSobject.put('Id',objSobjectId);
				objLeadSobject.put('First_Call_Date__c',firstCallDate);
				objLeadSobject.put('First_Email_Date__c',firstEmailDate);
				objLeadSobject.put('First_Appointment_Date__c',firstAppointmentDate);
				objLeadSobject.put('Last_Appointment_Date__c',lastAppointmentDate);
				lstLeadToUpdate.add((Lead)objLeadSobject);
			} 
		}
		
		if(!lstOpportunityToUpdate.isEmpty())
			database.update(lstOpportunityToUpdate,false);
			
		if(!lstLeadToUpdate.isEmpty())
			database.update(lstLeadToUpdate,false);
	}
	
	/*
    	* MethodName   : updateLeadStatusToContacted
        * param        : Set<Id> setLeadId
        * Description  : This method updates lead status to contacted if activity history of type email or call is present
    */
	private void updateLeadStatusToContacted(Set<Id> setLeadId)
	{
		List<Lead> lstLeadToUpdate = new List<Lead>();
		
		///Use two for loops and inner query since ActivityHistory cannot be directly queried
		for(Lead objLead:[SELECT Id,Status,(SELECT ActivityType FROM ActivityHistories)
		                  FROM Lead
		                  WHERE Id IN:setLeadId AND Status = 'Open'])
		{
			for(ActivityHistory objActivityHistory:objLead.ActivityHistories)
			{
				if((objActivityHistory.ActivityType == 'Call') ||  (objActivityHistory.ActivityType == 'Email'))
				{
					Lead objLeadToUpdate = new Lead
					(
						Id = objLead.Id,
						Status = 'Contacted'
					);
					lstLeadToUpdate.add(objLeadToUpdate);
					
					///If atleast *One* ActivityHistory is found with type call or email set lead status then break.
					break;
				}
			}
		}
		
		if(!lstLeadToUpdate.isEmpty())
			database.update(lstLeadToUpdate,false);
	}
}