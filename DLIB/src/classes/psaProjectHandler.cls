/*
 * \author Vladimir Dobrelya
 * \see https://silverline.jira.com/browse/SLFF-24
 * \modified by Julia Kolesnik 2014/03/12 https://silverline.jira.com/browse/SLFF-35
 */
public class psaProjectHandler {
	
	private static map<string,string> mapFieldNameByLabel = null;
	
	/*
		@MethodName		: onBeforeInsert
		@param			: lstNew (Trigger New Values)
		@Description	: To set TimecardKey
	*/
	public void onBeforeInsert(list<pse__Proj__c> lstNew)
	{
		try
		{
			list<pse__Proj__c> lstProjects = new list<pse__Proj__c>();
			for (pse__Proj__c item:lstNew) {
				if (item.pse__Project_Manager__c!=null) {
					lstProjects.add(item);
				}
			}
			//if (lstProjects.size()>0) setProjectOwner(lstProjects);
		}
		catch(Exception e) {}
	}
	
	/*
		@MethodName		: onBeforeUpdate
		@param			: mapNew (Trigger New Values)
		@param			: mapOld (Trigger New Values)
		@Description	: To set TimecardKey
	*/
	public void onBeforeUpdate(map<Id,pse__Proj__c> mapNew, map<Id,pse__Proj__c> mapOld)
	{
		try
		{
			list<pse__Proj__c> lstProjects = new list<pse__Proj__c>();
			for (pse__Proj__c item:mapNew.values()) {
				if (item.pse__Project_Manager__c!=null && item.pse__Project_Manager__c!=mapOld.get(item.Id).pse__Project_Manager__c) {
					lstProjects.add(item);
				}
			}
			if (lstProjects.size()>0) setProjectOwner(lstProjects);
		}
		catch(Exception e) {}
	}

    public void OnAfterInsert( Map<ID, pse__Proj__c> aRecords ) {
        List<pse__Milestone__c> aMilestones = psaProjectSetup.psaBuildParentTaskMilestones( this.getProjectsWithOpp( aRecords.values() ) ); 
        map<Id,Id> mapProjectOwners = new map<Id,Id>();
        //when project is created there is now milestones and phases for it
        /*for (pse__Proj__c item:aRecords.values()) {
			if (item.pse__Project_Manager__c!=null) {
				mapProjectOwners.put(item.Id,item.OwnerId);
			}
		}*/
        if ( !aMilestones.isEmpty() ) {
            insert aMilestones;
        }
        if (!mapProjectOwners.isEmpty()) updateProjectChildrenOwner(mapProjectOwners);
    }
    
    /*
		@MethodName		: onAfterUpdate
		@param			: mapNew (Trigger New Values)
		@param			: mapOld (Trigger New Values)
		@Description	: To update rates on Assignments
	*/
	public void onAfterUpdate(map<Id,pse__Proj__c> mapNew, map<Id,pse__Proj__c> mapOld)
	{
		try
		{
			mapFieldNameByLabel = psaAssignmentHandler.getFieldNameByLabel(new String[]{'pse__Proj__c'});
			map<Id,pse__Proj__c> mapProjects = new map<Id,pse__Proj__c>();
			map<Id,Id> mapProjectOwners = new map<Id,Id>();
			for (pse__Proj__c item:mapNew.values()) {
				for (string field:mapFieldNameByLabel.values()){
					if (item.get(field)!=mapOld.get(item.Id).get(field)) {
						mapProjects.put(item.Id, item);
						break;
					}
				}
				if (item.pse__Project_Manager__c!=mapOld.get(item.Id).pse__Project_Manager__c) {
					mapProjectOwners.put(item.Id,item.OwnerId);
				}
			}
			if (!mapProjects.isEmpty()) syncRatesWithProject(mapProjects);
			if (!mapProjectOwners.isEmpty()) updateProjectChildrenOwner(mapProjectOwners);
		}
		catch(Exception e) {}
	}
	
	private void syncRatesWithProject(map<Id,pse__Proj__c> mapProjects) {
		list<pse__Assignment__c> lstAssignments = new list<pse__Assignment__c>();
		decimal newval = 0;
		for (pse__Assignment__c item:[Select Id, pse__Bill_Rate__c, pse__Role__c, pse__Project__c FROM pse__Assignment__c WHERE pse__Project__c IN :mapProjects.keySet()]) {
			if (mapFieldNameByLabel.containsKey(item.pse__Role__c)) {
				newval = decimal.valueOf(String.valueOf(mapProjects.get(item.pse__Project__c).get(mapFieldNameByLabel.get(item.pse__Role__c))));
				if (item.pse__Bill_Rate__c<>newval) {
					item.pse__Bill_Rate__c = newval;
					lstAssignments.add(item);
				}
			}
		}
		system.debug(LoggingLevel.ERROR, JSON.serialize(lstAssignments));
		if (!lstAssignments.isEmpty()) update lstAssignments;
	}
	
	private void setProjectOwner(list<pse__Proj__c> lstProjects) {
		set<Id> setContactIds = new set<Id>();
		for (pse__Proj__c item:lstProjects) {
			setContactIds.add(item.pse__Project_Manager__c);
		}
		
		map<Id,Contact> mapContacts = new map<Id,Contact>([Select Id, pse__Salesforce_User__c FROM Contact 
								WHERE Id IN :setContactIds AND pse__Salesforce_User__c!=null limit 10000]);
		
		for (pse__Proj__c item:lstProjects) {
			if (mapContacts.containsKey(item.pse__Project_Manager__c)) {
				if (item.OwnerId!=mapContacts.get(item.pse__Project_Manager__c).pse__Salesforce_User__c) {
					item.OwnerId = mapContacts.get(item.pse__Project_Manager__c).pse__Salesforce_User__c;
				}
			}
		}
		
	}
	
	private void updateProjectChildrenOwner(map<Id,Id> mapProjectOwners) {
		list<pse__Milestone__c> lstMilestones = new list<pse__Milestone__c>();
		for (pse__Milestone__c item:[Select ID, OwnerId, pse__Project__c FROM pse__Milestone__c 
									WHERE pse__Project__c IN :mapProjectOwners.keySet()]) {
			if (item.OwnerId!=mapProjectOwners.get(item.pse__Project__c)) {
				item.OwnerId = mapProjectOwners.get(item.pse__Project__c);
				lstMilestones.add(item);
			}
		}
		
		list<pse__Project_Phase__c> lstProjectPhases = new list<pse__Project_Phase__c>();
		for (pse__Project_Phase__c item:[Select ID, OwnerId, pse__Project__c FROM pse__Project_Phase__c 
									WHERE pse__Project__c IN :mapProjectOwners.keySet()]) {
			if (item.OwnerId!=mapProjectOwners.get(item.pse__Project__c)) {
				item.OwnerId = mapProjectOwners.get(item.pse__Project__c);
				lstProjectPhases.add(item);
			}
		}
		
		if (!lstProjectPhases.isEmpty()) update lstProjectPhases;
		if (!lstMilestones.isEmpty()) update lstMilestones;
	}
	
    public List<pse__Proj__c> getProjectsWithOpp( List<pse__Proj__c> aRecords ) {
        List<pse__Proj__c> aResult = new List<pse__Proj__c>();

        for ( pse__Proj__c oItem : aRecords ) {
            if ( oItem.pse__Opportunity__c != null ) {
                aResult.add( oItem );
            }
        }

        return aResult;
    }

}