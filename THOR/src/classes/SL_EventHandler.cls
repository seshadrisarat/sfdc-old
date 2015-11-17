/**
*  ClassName      : SL_EventHandler
*  JIRATicket     : THOR-26
*  CreatedOn      : 26/AUG/2014
*  ModifiedBy     : Sanath Kumar
*  Description    : This is the handler class to rollup the event dates based on type to the Lead and Opportunity
*/
public with sharing class SL_EventHandler 
{
	/*
    	* MethodName   : onAfterInsert
        * param        : trigger.new values
        * Description  : This method is called after event records are inserted
    */
	public void onAfterInsert(List<Event> lstEvent)
	{
		///Call updateLeadAndOpportunity method to update fields on lead and opportunity on insert of event
		updateLeadAndOpportunity(lstEvent);
	}
	
	/*
    	* MethodName   : onAfterUpdate
        * param        : trigger.oldMap, trigger.newMap
        * Description  : This method is called after event records are updated
    */
	public void onAfterUpdate(map<Id,Event> mapEventOld, map<Id,Event> mapEventNew)
	{
		List<Event> lstNewFilteredEvents = new List<Event>();///List to store the new filtered event records
		List<Event> lstOldFilteredEvents = new List<Event>();///List to store the Old filtered event records
		
		///Create lists of events whose Start date or End date or Type or WhatId or WhoId has been updated
		for(Id objEventId:mapEventNew.keyset())
		{
			if((mapEventOld.get(objEventId).StartDateTime != mapEventNew.get(objEventId).StartDateTime) ||
			   (mapEventOld.get(objEventId).EndDateTime != mapEventNew.get(objEventId).EndDateTime) ||
			   (mapEventOld.get(objEventId).Type != mapEventNew.get(objEventId).Type) ||
			   (mapEventOld.get(objEventId).WhatId != mapEventNew.get(objEventId).WhatId) ||
			   (mapEventOld.get(objEventId).WhoId != mapEventNew.get(objEventId).WhoId))
			{
				lstNewFilteredEvents.add(mapEventNew.get(objEventId));
				lstOldFilteredEvents.add(mapEventOld.get(objEventId));
			}
		}
		
		///Call updateLeadAndOpportunity method to update fields on new lead and opportunity on update of event
		updateLeadAndOpportunity(lstNewFilteredEvents);
		
		///Call updateLeadAndOpportunity method to update fields on old lead and opportunity on update of event
		updateLeadAndOpportunity(lstOldFilteredEvents);
	}
	
	/*
    	* MethodName   : onAfterDelete
        * param        : trigger.old values
        * Description  : This method is called after event records are deleted
    */
	public void onAfterDelete(List<Event> lstEventOld)
	{
		///Call updateLeadAndOpportunity method to update fields on lead and opportunity on delete of event
		updateLeadAndOpportunity(lstEventOld);
	}
	
	/*
    	* MethodName   : onAfterUnDelete
        * param        : trigger.new values
        * Description  : This method is called after event records are undeleted
    */
	public void onAfterUnDelete(List<Event> lstEventNew)
	{
		///Call updateLeadAndOpportunity method to update fields on lead and opportunity on undelete of event
		updateLeadAndOpportunity(lstEventNew);
	}
	
	/*
    	* MethodName   : updateLeadAndOpportunity
        * param        : Filtered event records
        * Description  : This method is to update lead and opportunity records
    */
	private void updateLeadAndOpportunity(List<Event> lstEvent)
	{
		Set<Id> setWhatId = new Set<Id>();
		Set<Id> setWhoId = new Set<Id>();
		List<Sobject> lstSobject = new List<Sobject>();
		
		///Create sets of Opportunity and lead ids
		for(Event objEvent:lstEvent)
		{
			if(objEvent.WhatId != null)
				setWhatId.add(objEvent.WhatId);
			if(objEvent.WhoId != null)
				setWhoId.add(objEvent.WhoId);
		}
		
		///Create a list of Opportunity
		for(Opportunity objOpportunity:[SELECT Id 
		                                FROM Opportunity
		                                WHERE Id IN:setWhatId])
		{
			lstSobject.add((sObject)objOpportunity);
		}
		
		///Create a list of Lead
		for(Lead objLead:[SELECT Id 
		                  FROM Lead
		                  WHERE Id IN:setWhoId])
		{
			lstSobject.add((sObject)objLead);
		}
		
		SL_ActivityMilestoneGenericClass  objActivityMilestoneGenericClass  = new SL_ActivityMilestoneGenericClass(lstSobject);		
	}
}