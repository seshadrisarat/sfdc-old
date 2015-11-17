/****************************************************************************************
Name            : psaMilestoneHandler
Author          : Julia Kolesnik
Created Date    : January 22, 2014
Description     : Contains methods for the psaMilestoneHandler trigger, SLFF-21
******************************************************************************************/
public class psaMilestoneHandler {
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;

	/**
		* Constructor		: Initialise the global variables
		* @param			: None
	*/
	public psaMilestoneHandler(boolean isExecuting, integer size)
	{
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	/*
		@MethodName		: onAfterInsert
		@param			: lstNew (Trigger New Values)
		@Description	: To set Project_Phase Status
	*/
	public void onAfterInsert(list<pse__Milestone__c> lstNew)
	{
		try
		{
			set<Id> setProjectPhaseIds = new set<Id>();
			set<Id> setParentMilestoneIds = new set<Id>();
			for (pse__Milestone__c item:lstNew) {
				if (item.Project_Phase__c!=null) setProjectPhaseIds.add(item.Project_Phase__c);
				if (item.Parent_Milestone__c!=null) setParentMilestoneIds.add(item.Parent_Milestone__c);
			}
			if (setProjectPhaseIds.size()>0) setProjectPhaseStatusDates(setProjectPhaseIds);
			if (setParentMilestoneIds.size()>0) setParentMilestoneDates(setParentMilestoneIds);
		}
		catch(Exception e) {}
	}
	
	/*
		@MethodName		: onAfterUpdate
		@param			: lstNew (Trigger New Values)
		@Description	: To set Bill Rate for Child Milestones + to set Project_Phase Status
	*/
	public void onAfterUpdate(map<Id,pse__Milestone__c> mapNew, map<Id,pse__Milestone__c> mapOld)
	{
		try
		{
			set<Id> setClosedParentMilestoneIds = new set<Id>();
			set<Id> setCanceledParentMilestoneIds = new set<Id>();
			set<Id> setProjectPhaseIds = new set<Id>();
			set<Id> setParentMilestoneIds = new set<Id>();
			for (pse__Milestone__c item:mapNew.values()) {
				if (item.pse__Status__c!=mapOld.get(item.id).pse__Status__c || item.Start_Date__c!=mapOld.get(item.id).Start_Date__c || item.End_Date__c!=mapOld.get(item.id).End_Date__c) {
					if (item.Project_Phase__c!=null) setProjectPhaseIds.add(item.Project_Phase__c);
					if (item.pse__Status__c=='Closed') setClosedParentMilestoneIds.add(item.Id);
					if (item.pse__Status__c=='Canceled') setCanceledParentMilestoneIds.add(item.Id);
				}
				if (item.Start_Date__c!=mapOld.get(item.id).Start_Date__c || item.End_Date__c!=mapOld.get(item.id).End_Date__c) {
					if (item.Parent_Milestone__c!=null) setParentMilestoneIds.add(item.Parent_Milestone__c);
				}
			}
			
			system.debug('--------setParentMilestoneIds='+setParentMilestoneIds);
			
			if (setClosedParentMilestoneIds.size()>0||setCanceledParentMilestoneIds.size()>0) setChildTaskStatus(setClosedParentMilestoneIds, setCanceledParentMilestoneIds);
			if (setProjectPhaseIds.size()>0) setProjectPhaseStatusDates(setProjectPhaseIds);
			if (setParentMilestoneIds.size()>0) setParentMilestoneDates(setParentMilestoneIds);
			
		}
		catch(Exception e) {}
	}
	
	/*
		@MethodName		: onAfterDelete
		@param			: lstOld (Trigger Old Values)
		@Description	: To set Project_Phase Status
	*/
	public void onAfterDelete(list<pse__Milestone__c> lstOld)
	{
		try
		{
			set<Id> setProjectPhaseIds = new set<Id>();
			set<Id> setParentMilestoneIds = new set<Id>();
			for (pse__Milestone__c item:lstOld) {
				if (item.Project_Phase__c!=null) setProjectPhaseIds.add(item.Project_Phase__c);
				if (item.Parent_Milestone__c!=null) setParentMilestoneIds.add(item.Parent_Milestone__c);
			}
			if (setProjectPhaseIds.size()>0) setProjectPhaseStatusDates(setProjectPhaseIds);
			if (setParentMilestoneIds.size()>0) setParentMilestoneDates(setParentMilestoneIds);
		}
		catch(Exception e) {}
	}
	
	private void setChildTaskStatus (set<Id> setClosedParentMilestoneIds, set<Id> setCanceledParentMilestoneIds) {
		list<pse__Milestone__c> lstChildMilestones = new list<pse__Milestone__c>([Select ID, pse__Status__c, Parent_Milestone__c FROM pse__Milestone__c
							WHERE Parent_Milestone__c IN :setClosedParentMilestoneIds OR Parent_Milestone__c IN :setCanceledParentMilestoneIds limit 10000]);
		for (pse__Milestone__c item:lstChildMilestones) {
			if (setClosedParentMilestoneIds.contains(item.Parent_Milestone__c))	item.pse__Status__c = 'Closed';
			if (setCanceledParentMilestoneIds.contains(item.Parent_Milestone__c))	item.pse__Status__c = 'Canceled';
		}
		
		if (lstChildMilestones.size()>0) update lstChildMilestones;
	}
	
	private void setProjectPhaseStatusDates (set<Id> setProjectPhaseIds) {
		list<pse__Project_Phase__c> lstProjectPhases = new list<pse__Project_Phase__c>([Select ID, Status__c, pse__Start_Date__c, pse__End_Date__c, 
							(Select ID, pse__Status__c, Start_Date__c, End_Date__c FROM Milestones__r) 
							FROM pse__Project_Phase__c
							WHERE Id IN :setProjectPhaseIds limit 10000]);
		Integer opened = 0;
		Integer closed = 0;
		for (pse__Project_Phase__c pp:lstProjectPhases) {
			opened = 0;
			closed = 0;
			if (pp.Milestones__r.size()>0) {
				pp.pse__Start_Date__c = pp.Milestones__r[0].Start_Date__c;
				pp.pse__Start_Date__c = pp.Milestones__r[0].End_Date__c;
			}
			for (pse__Milestone__c m:pp.Milestones__r) {
				if (m.pse__Status__c == 'Open' || m.pse__Status__c == null) opened++;
				else closed++;
				
				//set Start Phase Date
				pp.pse__Start_Date__c = m.Start_Date__c;
				if (m.Start_Date__c<pp.pse__Start_Date__c) pp.pse__Start_Date__c = m.Start_Date__c;
				
				//set End Phase Date
				pp.pse__End_Date__c = m.End_Date__c;
				if (m.End_Date__c>pp.pse__End_Date__c) {
					pp.pse__End_Date__c = m.End_Date__c;
				}
			}
			if (closed==0) pp.Status__c = 'Open';
			else if (opened==0) pp.Status__c = 'Complete';
			else pp.Status__c = 'In Progress';
		}
		if (lstProjectPhases.size()>0) update lstProjectPhases;
	}
	
	private void setParentMilestoneDates (set<Id> setParentMilestoneIds) {
		list<pse__Milestone__c> lstParentMilestones = new list<pse__Milestone__c>([Select ID, Start_Date__c, End_Date__c, pse__Actual_Date__c, RecordType.DeveloperName,
							(Select ID, Start_Date__c, End_Date__c, RecordType.DeveloperName FROM Milestones__r) 
							FROM pse__Milestone__c
							WHERE Id IN :setParentMilestoneIds limit 10000]);
							
		for (pse__Milestone__c pp:lstParentMilestones) {
			if (pp.Milestones__r.size()>0) {
				pp.Start_Date__c = pp.Milestones__r[0].Start_Date__c;
				pp.End_Date__c = pp.Milestones__r[0].End_Date__c;
				pp.pse__Actual_Date__c = pp.End_Date__c;
			}
			for (pse__Milestone__c m:pp.Milestones__r) {
				//set Start Phase Date
				if (m.Start_Date__c<pp.Start_Date__c) pp.Start_Date__c = m.Start_Date__c;
				//set End Phase Date
				if (m.End_Date__c>pp.End_Date__c) {
					pp.pse__Actual_Date__c = m.End_Date__c;
					pp.End_Date__c = m.End_Date__c;
				}
			}
		}
		system.debug('--------lstParentMilestones='+lstParentMilestones);
		if (lstParentMilestones.size()>0) update lstParentMilestones;
		system.debug('--------lstParentMilestones='+lstParentMilestones);
	}
	
}