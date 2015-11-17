/****************************************************************************************
Name            : psaTimecardHandler
Author          : Julia Kolesnik
Created Date    : January 21, 2014
Description     : Contains methods for the Timecard trigger.
******************************************************************************************/
public class psaTimecardHandler {
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	public static boolean isDone = false;

	/**
		* Constructor		: Initialise the global variables
		* @param			: None
	*/
	public psaTimecardHandler(boolean isExecuting, integer size)
	{
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	/*
		@MethodName		: onAfterInsert
		@param			: lstNew (Trigger New Values)
		@Description	: To rollup Timecard Hours/Amount fields to the ProjectPhases 
	*/
	public void onAfterInsert(list<pse__Timecard_Header__c> lstNew)
	{
		try
		{
			selectProjectPhaseIds(lstNew);
			setTimecards(lstNew);
		}
		catch(Exception e) {}
	}
	
	/*
		@MethodName		: onAfterUpdate
		@param			: mapNew (Trigger New Values)
		@param			: mapOld (Trigger New Values)
		@Description	: To rollup Timecard Hours/Amount fields to the ProjectPhases 
	*/
	public void onAfterUpdate(map<Id,pse__Timecard_Header__c> mapNew, map<Id,pse__Timecard_Header__c> mapOld)
	{
		try
		{
			selectProjectPhaseIds(mapNew,mapOld);
		}
		catch(Exception e) {}
	}
	
	/*
		@MethodName		: onAfterDelete
		@param			: lstOld (Trigger Old Values)
		@Description	: To rollup Timecard Hours/Amount fields to the ProjectPhases 
	*/
	public void onAfterDelete(list<pse__Timecard_Header__c> lstOld)
	{
		try
		{
			selectProjectPhaseIds(lstOld);
		}
		catch(Exception e) {}
	}
	
	private void setTimecards(list<pse__Timecard_Header__c> lstTimecard) {
		map<string,Id> mapTimecardKeys = new map<string,Id>();
		for (pse__Timecard_Header__c item:lstTimecard) {
			mapTimecardKeys.put(item.Timecard_Key__c, item.Id);
		}
		
		list<Worklog__c> lstWorklogs = new list<Worklog__c>([Select Id, Timecard_Key__c, PSA_Timecard__c 
					FROM Worklog__c WHERE Timecard_Key__c IN :mapTimecardKeys.keySet() AND PSA_Timecard__c=null AND PSA_Project__c!=null AND PSA_Milestone__c!=null limit 10000]);
		
		for (Worklog__c item:lstWorklogs) {
			item.PSA_Timecard__c = mapTimecardKeys.get(item.Timecard_Key__c);
			item.PSA_Integration_Status__c = 'SUCCESS';
			item.PSA_Integration_Error__c = '';
		}
		
		if (lstWorklogs.size()>0) update lstWorklogs;
	}
	
	private void selectProjectPhaseIds(list<pse__Timecard_Header__c> lstTimecard) {
		set<id> setProjectPhaseIds = new set<id>();
		for (pse__Timecard_Header__c item:lstTimecard) {
			if (item.pse__Project_Phase_Object__c!=null) {
				setProjectPhaseIds.add(item.pse__Project_Phase_Object__c);
			}
		}
		if (setProjectPhaseIds.size()>0) psaProjectRefesh.rollupTimecardFieldsToProjectPhase(setProjectPhaseIds);
	}
	
	private void selectProjectPhaseIds(map<Id,pse__Timecard_Header__c> mapNew, map<Id,pse__Timecard_Header__c> mapOld) {
		set<id> setProjectPhaseIds = new set<id>();
		for (pse__Timecard_Header__c item:mapNew.values()) {
			if (item.pse__Project_Phase_Object__c!=null)  					setProjectPhaseIds.add(item.pse__Project_Phase_Object__c);
			if (mapOld.get(item.id).pse__Project_Phase_Object__c!=null)  	setProjectPhaseIds.add(item.pse__Project_Phase_Object__c);
		}
		if (setProjectPhaseIds.size()>0) psaProjectRefesh.rollupTimecardFieldsToProjectPhase(setProjectPhaseIds);
	}

}