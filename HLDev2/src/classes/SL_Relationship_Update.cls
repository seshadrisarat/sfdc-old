/**  
* \arg ClassName      : SL_Relationship_Update
* \arg JIRATicket     : HL-15
* \arg CreatedOn      : 6/NOV/2014
* \arg LastModifiedOn : 6/NOV/2014
* \arg CreatededBy    : Edward Rivera
* \arg ModifiedBy     : -
* \arg Description    : Class for handling updates of Relationship__c objects
*/
public with sharing class SL_Relationship_Update {

	private List<Relationship__c> relationshipsToUpdate; // list received on instantiation of relationships to be updated
	private Map<Id, Relationship__c> mapRelationship; // map of relationships being updated generated from list
	private Map<String, Id> StringToRelationship; // maps 'User.Id+:+'Contact.Id' to the Id of the corresponding relationship
	private Map<Id, Relationship__c> mapRelationshipToUpdate;//!< Relationship records to update.
	
	private Set<Id> setHLContactUserId;//!< set to hold the HL Contact User Ids.
    private Set<Id> setHLContactId;//!< set to hold the HL Contact Ids.
    private Set<Id> setExContactId;//!< set to hold the External Contact Ids.
    private Set<Id> allRelatedIds;

    private Set<Id> setEngagementIds;//!< set to hold the Engagement record Ids.
    private Map<Id, Id> mapHLContactToUserId; // maps an HL contact ID to their user ID to save queries

    private Map<Id, Set<Id>> mapEngagementIdToSetHLClosed = new Map<Id, Set<Id >>();//!<map ContactIds corresponding to EngagementIds closeactivity.
    private Map<Id, Set<Id>> mapEngagementIdToSetHLActive = new Map<Id, Set<Id>>();//!< map ContactIds corresponding to EngagementIds activeactivity.

	public SL_Relationship_Update(List<Relationship__c> relationshipsToUpdate) {
		this.relationshipsToUpdate = relationshipsToUpdate;
	}
	/*
        @MethodName : calculateAllFields
        @param 		: Set<Id> setHLContactId and Set<Id> setExContactId
        @Description: Generates the map from engagement Ids to a list of Ids comprising the internal engagement team
    */
	public void calculateAllFields(){
		lazyLoadSetsAndMaps(); // load the previous sets and maps
 		getLastActivity(); // calculate the Last Activity Date field
 		getNextActivity(); // calculate the Next Activity Date field
 		getActivityLTM(); // calculate the # of Activities LTM field
    	getOpenOpportunities(); // calculate the Share Open Opp? field
     	getSharedEngagements(); // calculate the Share Active Deal?, # of Deals Shown, # of Deals on Client/External Team fields
    }
    /*
        @MethodName : updateAll
        @param 		: 
        @Description: updates based off the calculations performed
    */
    public void updateAll(){
    	update mapRelationshipToUpdate.values();  
    }  
    
    /*
        @MethodName : lazyLoadSetsAndMaps
        @param 		: 
        @Description: lazy loads the id sets, the string-to-id map and the id to record map
    */
    private void lazyLoadSetsAndMaps(){
    	if (setHLContactId!=null){
    		return;
    	}
    	mapRelationship = new Map<Id, Relationship__c>();
        StringToRelationship = new Map<String,Id>();
        mapRelationshipToUpdate = new Map<Id, Relationship__c>();
    	setHLContactUserId = new Set<Id>();
        setHLContactId = new Set<Id>();
        setExContactId = new Set<Id>();   
        mapHLContactToUserId = new Map<Id, Id>();
    	for(Relationship__c objRelationship :relationshipsToUpdate){
    		mapRelationship.put(objRelationship.id, objRelationship);
    		StringToRelationship.put(objRelationship.HL_Contact__r.User__c + ':' + (String) objRelationship.External_Contact__c, objRelationship.Id);
            setHLContactUserId.add(objRelationship.HL_Contact__r.User__c);
    		setHLContactId.add(objRelationship.HL_Contact__c);
            if (objRelationship.External_Contact__c!=null){
                setExContactId.add(objRelationship.External_Contact__c);
            }
    		mapHLContactToUserId.put(objRelationship.HL_Contact__c, objRelationship.HL_Contact__r.User__c);
        }
        allRelatedIds = new Set<Id>();
        allRelatedIds.addAll(setHlContactUserId);
        allRelatedIds.addAll(setHlContactId);
        allRelatedIds.addAll(setExContactId);  
    }
    /*
        @MethodName : addToUpdateMap
        @param 		: Map<Id, Object> genericMap - map of new records to update, String fieldName - field to be updated
        @Description: adds to the update map records whose associated field have changed, or updates them in the map
    */
    private void addToUpdateMap(Map<Id, Object> genericMap, String fieldName ){
    	for (Id relationshipId: genericMap.keySet()){
    		Relationship__c relationship = mapRelationship.get(relationshipId);

            // relationship already in update map
        	if (mapRelationshipToUpdate.keyset().contains(relationshipId)){
        		mapRelationshipToUpdate.get(relationshipId).put(fieldName,genericMap.get(relationshipId));
        	}
        	else if(relationship.get(fieldName)!=genericMap.get(relationshipId)){
        		relationship.put(fieldName,genericMap.get(relationshipId));
        		mapRelationshipToUpdate.put(relationshipId, relationship);
        	}
    	}
    }

    /*
        @MethodName : getEngagementHLTeams
        @param 		: 
        @Description: Generates the map from engagement Ids to a list of Ids comprising the internal engagement team
    */
    private void getEngagementHLTeams(){
    	//!< Iterating to get close deal and active deal in Internal Team.
    	if (setEngagementIds!=null){
    		return;
    	}
    	setEngagementIds = new Set<Id>();
    	mapEngagementIdToSetHLClosed = new Map<Id, Set<Id>>();
    	mapEngagementIdToSetHLActive = new Map<Id, Set<Id>>();  
        for(Engagement_Internal_Team__c objEIT : [SELECT Id, 
        												 Engagement__c,
        												 Contact__c,
                                                         Contact__r.User__c,
        												 Engagement__r.Closed__c
        										    FROM Engagement_Internal_Team__c 
        										   WHERE Contact__c IN: setHLContactId])
        {
        	setEngagementIds.add(objEIT.Engagement__c);
        	if(objEIT.Engagement__r.Closed__c)
        	{
        		if(mapEngagementIdToSetHLClosed.containsKey(objEIT.Engagement__c))
        			mapEngagementIdToSetHLClosed.get(objEIT.Engagement__c).add(objEIT.Contact__r.User__c);
        		else
        			mapEngagementIdToSetHLClosed.put(objEIT.Engagement__c, new Set<Id>{objEIT.Contact__r.User__c});
        	}
        	else
        	{
        		if(mapEngagementIdToSetHLActive.containsKey(objEIT.Engagement__c))
        			mapEngagementIdToSetHLActive.get(objEIT.Engagement__c).add(objEIT.Contact__r.User__c);
        		else
        			mapEngagementIdToSetHLActive.put(objEIT.Engagement__c, new Set<Id>{objEIT.Contact__r.User__c});
        	}
        }
    }
    /*
        @MethodName : getUpdateActivityMap
        @param      : List<TaskRelation> taskRelations, SObjType type
        @Description: Generates the map from a relationship to a potential updated field value
    */
    private Map<Id, Object> getUpdateActivityMap (List<TaskRelation> taskRelations, System.Type type){
        Map<Id, Object> genericMap = new Map<Id, Object>();
        Map<Id, Set<Id>> HoulihanMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> ExternalMap = new Map<Id, Set<Id>>();
        for (TaskRelation tr: taskRelations){
            if (!HoulihanMap.keyset().contains(tr.TaskId)){
                HoulihanMap.put(tr.TaskId, new Set<Id>());
                ExternalMap.put(tr.TaskId, new Set<Id>());
            }
            Id HoulihanId;
            Id ExternalId;
            Set<Id> Others;
            Boolean Houlihan;
            if (setHLContactId.contains(tr.RelationId)||setHLContactUserId.contains(tr.RelationId)){
                Houlihan=true;
                HoulihanId = tr.RelationId;
                if (setHLContactId.contains(tr.RelationId)){
                    HoulihanId = mapHLContactToUserId.get(HoulihanId);  // convert contact Id to User Id
                }
                HoulihanMap.get(tr.TaskId).add(HoulihanId);
                Others = ExternalMap.get(tr.TaskId);
            }
            else{
                Houlihan=false;
                ExternalId = tr.RelationId;
                ExternalMap.get(tr.TaskId).add(tr.relationId);
                // add owner id if needed
                if (setHLContactId.contains(tr.Task.OwnerId)){
                    HoulihanMap.get(tr.TaskId).add(mapHLContacttoUserId.get(tr.Task.OwnerId));
                }
                else if (setHLContactUserId.contains(tr.Task.OwnerId)){
                    HoulihanMap.get(tr.TaskId).add(tr.Task.OwnerId);
                }
                Others = HoulihanMap.get(tr.TaskId);
            }
            for (Id OtherId: Others){
                if (Houlihan){
                    ExternalId=OtherId;
                }
                else{
                    HoulihanId=OtherId;
                }
                if (StringToRelationship.keyset().contains(HoulihanId+':'+ExternalId)){
                    Id relationshipId = StringToRelationship.get(HoulihanId+':'+ExternalId);
                    if (Integer.class==type){                     
                        if (!genericMap.keyset().contains(relationshipId)){
                            genericMap.put(relationshipId, 1);
                        }
                        else{
                            genericMap.put( relationshipId, ((Integer)genericMap.get(relationshipId))+1);
                        }
                    }
                    else if (!genericMap.keyset().contains(relationshipId)){
                        genericMap.put( relationshipId, tr.Task.ActivityDate);
                    }
                }
            }
        }
        if (Integer.class==type){  
            // create the set of relationships that have had 0 tasks in the last 12 months
            Set<Id> nilActivitiesLTM = new Set<Id>(mapRelationship.keySet());
            nilActivitiesLTM.removeAll(genericMap.keySet());
            for (Id id: nilActivitiesLTM){
                // put the relationship in the map with 0 activities
                genericMap.put( id, 0);
            }
        }
        return genericMap;
    }
    /*
        @MethodName : getUpdateActivityMap
        @param      : List<EventRelation> eventRelations, SObjType type
        @Description: Generates the map from a relationship to a potential updated field value
    */
    private Map<Id, Object> getUpdateActivityMap (List<EventRelation> eventRelations, System.Type type){
        Map<Id, Object> genericMap = new Map<Id, Object>();
        Map<Id, Set<Id>> HoulihanMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> ExternalMap = new Map<Id, Set<Id>>();
        for (EventRelation tr: eventRelations){
            if (!HoulihanMap.keyset().contains(tr.EventId)){
                HoulihanMap.put(tr.EventId, new Set<Id>());
                ExternalMap.put(tr.EventId, new Set<Id>());
            }
            Id HoulihanId;
            Id ExternalId;
            Set<Id> Others;
            Boolean Houlihan;
            if (setHLContactId.contains(tr.RelationId)||setHLContactUserId.contains(tr.RelationId)){
                Houlihan=true;
                HoulihanId = tr.RelationId;
                if (setHLContactId.contains(tr.RelationId)){
                    HoulihanId = mapHLContactToUserId.get(HoulihanId);  // convert contact Id to User Id
                }
                HoulihanMap.get(tr.EventId).add(HoulihanId);
                Others = ExternalMap.get(tr.EventId);
            }
            else{
                Houlihan=false;
                ExternalId = tr.RelationId;
                ExternalMap.get(tr.EventId).add(tr.relationId);
                // add owner id if needed
                if (setHLContactId.contains(tr.Event.OwnerId)){
                    HoulihanMap.get(tr.EventId).add(mapHLContacttoUserId.get(tr.Event.OwnerId));
                }
                else if (setHLContactUserId.contains(tr.Event.OwnerId)){
                    HoulihanMap.get(tr.EventId).add(tr.Event.OwnerId);
                }
                Others = HoulihanMap.get(tr.EventId);
            }
            for (Id OtherId: Others){
                if (Houlihan){
                    ExternalId=OtherId;
                }
                else{
                    HoulihanId=OtherId;
                }
                if (StringToRelationship.keyset().contains(HoulihanId+':'+ExternalId)){
                    Id relationshipId = StringToRelationship.get(HoulihanId+':'+ExternalId);
                    if (Integer.class==type){                     
                        if (!genericMap.keyset().contains(relationshipId)){
                            genericMap.put(relationshipId, 1);
                        }
                        else{
                            genericMap.put( relationshipId, ((Integer)genericMap.get(relationshipId))+1);
                        }
                    }
                    else if (!genericMap.keyset().contains(relationshipId)){
                        genericMap.put( relationshipId, tr.Event.ActivityDate);
                    }
                }
            }
        }
        if (Integer.class==type){  
            // create the set of relationships that have had 0 events in the last 12 months
            Set<Id> nilActivitiesLTM = new Set<Id>(mapRelationship.keySet());
            nilActivitiesLTM.removeAll(genericMap.keySet());
            for (Id id: nilActivitiesLTM){
                // put the relationship in the map with 0 activities
                genericMap.put( id, 0);
            }
        }
        return genericMap;
    }
    /*
        @MethodName : getLastActivity
        @param 		: 
        @Description: Generates the map from relationship Ids to their date field 'Last_Activity_Date__c'
    */
    private void getLastActivity(){
    	Map<Id, Date> mapLastActivity = new Map<Id, Date>();//!< map to hold last activity date
        Map<Id, Date> mapLastTask = new Map<Id, Date>();//!< map to hold last activity date
        Map<Id, Date> mapLastEvent = new Map<Id, Date>();//!< map to hold last activity date
        Map<Id, Object> temp = new Map<Id, Object>();

        temp = getUpdateActivityMap([SELECT RelationId,
                                            TaskId,
                                            Task.OwnerId,
                                            Task.ActivityDate
                                    FROM    TaskRelation
                                    WHERE   Task.IsClosed=True
                                    AND     RelationId IN :allRelatedIds
                                    ORDER BY Task.ActivityDate DESC]
                                    , Date.class);
        for (Id id: temp.keySet()){
            mapLastTask.put(id, (Date)temp.get(id));
        }
        temp = getUpdateActivityMap([SELECT RelationId,
                                            EventId,
                                            Event.OwnerId,
                                            Event.ActivityDate
                                    FROM    EventRelation
                                    WHERE   (Event.ActivityDate < TODAY OR (Event.IsAllDayEvent=False AND Event.ActivityDateTime < :DateTime.Now()))
                                    AND     RelationId IN :allRelatedIds
                                    ORDER BY Event.ActivityDate DESC]
                                    , Date.class);
        for (Id id: temp.keySet()){
            mapLastEvent.put(id, (Date)temp.get(id));
        }
        Set <Id> AllIdsWithPastActivity = new Set<Id>();
        AllIdsWithPastActivity.addAll(mapLastTask.keyset());
        AllIdsWithPastActivity.addAll(mapLastEvent.keyset());
        for (Id relationshipId: allIdsWithPastActivity){
            if (mapLastTask.keySet().contains(relationshipId)&&mapLastEvent.keySet().contains(relationshipId) ){
                if (mapLastEvent.get(relationshipId)<mapLastTask.get(relationshipId)){
                    mapLastActivity.put(relationshipId, mapLastTask.get(relationshipId));
                }
                else{
                    mapLastActivity.put(relationshipId, mapLastEvent.get(relationshipId));
                }
            }
            else if (mapLastTask.keySet().contains(relationshipId)){
                mapLastActivity.put(relationshipId, mapLastTask.get(relationshipId));
            }
            else{
                mapLastActivity.put(relationshipId, mapLastEvent.get(relationshipId));
            }
        }
        addToUpdateMap(mapLastActivity, 'Last_Activity_Date__c');
	}

	/*
        @MethodName : getNextActivity
        @param 		: 
        @Description: Generates the map from relationship Ids to their numeric field 'Next_Activity_Date__c'
    */
    private void getNextActivity(){
    	Map<Id, Date> mapNextActivity = new Map<Id, Date>();//!< map to hold next activity date
        Map<Id, Date> mapNextTask = new Map<Id, Date>();//!< map to hold next activity date
        Map<Id, Date> mapNextEvent = new Map<Id, Date>();//!< map to hold next activity date
        Map<Id, Object> temp = new Map<Id, Object>();

		temp = getUpdateActivityMap([SELECT RelationId,
                                            TaskId,
                                            Task.OwnerId,
                                            Task.ActivityDate
                                    FROM    TaskRelation
                                    WHERE   Task.IsClosed=False
                                    AND     RelationId IN :allRelatedIds
                                    ORDER BY Task.ActivityDate ASC]
                                    , Date.class);
        for (Id id: temp.keySet()){
            mapNextTask.put(id, (Date)temp.get(id));
        }
        temp = getUpdateActivityMap([SELECT RelationId,
                                            EventId,
                                            Event.OwnerId,
                                            Event.ActivityDate
                                    FROM    EventRelation
                                    WHERE   (Event.ActivityDate >= TODAY OR (Event.IsAllDayEvent=False AND Event.ActivityDateTime >= :DateTime.Now()))
                                    AND     RelationId IN :allRelatedIds
                                    ORDER BY Event.ActivityDate ASC]
                                    , Date.class);
        for (Id id: temp.keySet()){
            mapNextEvent.put(id, (Date)temp.get(id));
        }
        Set <Id> AllIdsWithFutureActivity = new Set<Id>();
        AllIdsWithFutureActivity.addAll(mapNextTask.keyset());
        AllIdsWithFutureActivity.addAll(mapNextEvent.keyset());
        for (Id relationshipId: allIdsWithFutureActivity){
            if (mapNextTask.keySet().contains(relationshipId)&&mapNextEvent.keySet().contains(relationshipId) ){
                if (mapNextEvent.get(relationshipId)<mapNextTask.get(relationshipId)){
                    mapNextActivity.put(relationshipId, mapNextTask.get(relationshipId));
                }
                else{
                    mapNextActivity.put(relationshipId, mapNextEvent.get(relationshipId));
                }
            }
            else if (mapNextTask.keySet().contains(relationshipId)){
                mapNextActivity.put(relationshipId, mapNextTask.get(relationshipId));
            }
            else{
                mapNextActivity.put(relationshipId, mapNextEvent.get(relationshipId));
            }
        }
        addToUpdateMap(mapNextActivity, 'Next_Activity_Date__c');
    }

    /*
        @MethodName : getActivityLTM
        @param 		: Set<Id> setHLContactId and Set<Id> setExContactId
        @Description: Generates the map from relationship Ids to their date field 'Number_of_Activities_LTM__c'
    */
    private void getActivityLTM(){
    	Map<Id, Integer> mapActivityLTM = new Map<Id, Integer>();//!< map to hold next activity date
        Map<Id, Integer> mapTaskLTM = new Map<Id, Integer>();//!< map to hold next activity date
        Map<Id, Object> temp = new Map<Id, Object>();

        temp = getUpdateActivityMap([SELECT RelationId,
                                            TaskId,
                                            Task.OwnerId,
                                            Task.ActivityDate
                                    FROM    TaskRelation
                                    WHERE  Task.ActivityDate = LAST_N_DAYS:365
                                    AND     RelationId IN :allRelatedIds]
                                    , Integer.class);
        for (Id id: temp.keySet()){
            mapTaskLTM.put(id, (Integer)temp.get(id));
        }
        temp = getUpdateActivityMap([SELECT RelationId,
                                            EventId,
                                            Event.OwnerId,
                                            Event.ActivityDate
                                    FROM    EventRelation
                                    WHERE   Event.ActivityDate = LAST_N_DAYS:365
                                    AND     RelationId IN :allRelatedIds]
                                    , Integer.class);
        for (Id id: temp.keySet()){
            mapActivityLTM.put(id, mapTaskLTM.get(id)+(Integer)temp.get(id));
        }
        addToUpdateMap(mapActivityLTM, 'Number_of_Activities_LTM__c');
    }
    

    /*
        @MethodName : getSharedEngagements
        @param 		:
        @Description: Generates the map from relationship Ids to their checkbox field 'Share_Active_Deal__c' and 'Number_of_Deals_Shown__c'
    */
    private void getSharedEngagements(){

    	getEngagementHLTeams();
    	List<Engagement_External_Team__c> externalTeam = [SELECT Id, 
        												 Engagement__c,
        												 Contact__c,
        												 Engagement__r.Closed__c
        										    FROM Engagement_External_Team__c 
        										   WHERE Contact__c IN: setExContactId 
        										     AND Engagement__c IN: setEngagementIds];
    	Map<Id, Integer> mapNoOfDealsClosed = new Map<Id, Integer>();//!< map to hold no of deal close.
    	Map<Id, Integer> mapNoOfDealShown = new Map<Id, Integer>();//!< map to hold no of deal shown.
    	Map<Id, Boolean> mapActiveDeal = new Map<Id, Boolean>();//!< map to hold is there is active deal present.

        for(Engagement_External_Team__c objEET : externalTeam)
        {
        	if(objEET.Engagement__r.Closed__c && mapEngagementIdToSetHLClosed.containsKey(objEET.Engagement__c))
        	{
        		// for all of the HL employees on this closed engagement, pair them up with this external team member and add 1 to their number of deals closed together
        		for(Id strHLUserId : mapEngagementIdToSetHLClosed.get(objEET.Engagement__c))
        		{
        			if(mapNoOfDealsClosed.containsKey(StringToRelationship.get(strHLUserId + ':' + objEET.Contact__c)))
        				mapNoOfDealsClosed.put(StringToRelationship.get(strHLUserId + ':' + objEET.Contact__c), mapNoOfDealsClosed.get(StringToRelationship.get(strHLUserId + ':' + objEET.Contact__c)) + 1);
        			else
        				mapNoOfDealsClosed.put(StringToRelationship.get(strHLUserId + ':' + objEET.Contact__c), 1);
        		}
        	}
        	else
        	{
        		for(Id strHLUserId : mapEngagementIdToSetHLActive.get(objEET.Engagement__c))
        		{
        			mapActiveDeal.put(StringToRelationship.get(strHLUserId + ':' + objEET.Contact__c), true);
        		}
        	}
        }
        
        //!< Iterating to get deal shown.
        for(Engagement_Counterparty_Contact__c objECC : [SELECT Id,
        														Contact__c, 
        														Counterparty__r.Engagement__c,
        														Counterparty__r.Engagement__r.Closed__c 
        												   FROM Engagement_Counterparty_Contact__c 
        												  WHERE Counterparty__r.Engagement__r.Closed__c = true 
        												    AND Counterparty__r.Engagement__c IN : mapEngagementIdToSetHLClosed.keySet()
        												    AND Contact__c IN: setExContactId])
		{
			// for all of the HL employees on this closed engagement, pair them up with this external team member and add 1 to their number of deals shown
			for(Id strHLUserId : mapEngagementIdToSetHLClosed.get(objECC.Counterparty__r.Engagement__c))
    		{
    			if(mapNoOfDealShown.containsKey(StringToRelationship.get(strHLUserId + ':' + objECC.Contact__c)))
    				mapNoOfDealShown.put(StringToRelationship.get(strHLUserId + ':' + objECC.Contact__c), mapNoOfDealShown.get(StringToRelationship.get(strHLUserId + ':' + objECC.Contact__c)) + 1);
    			else
    				mapNoOfDealShown.put(StringToRelationship.get(strHLUserId + ':' + objECC.Contact__c), 1);
    		}
		}
		addToUpdateMap(mapNoOfDealsClosed, 'Number_of_Deals_on_Client_External_Team__c');
		addToUpdateMap(mapActiveDeal, 'Share_Active_Deal__c');
		addToUpdateMap(mapNoOfDealShown, 'Number_of_Deals_Shown__c');
    }
    /*
        @MethodName : getOpenOpportunities.
        @param 		: 
        @Description: Generates the map from relationship Ids to their checkbox field 'Share_Open_Opp__c'
    */
    private void getOpenOpportunities(){
    	Map<Id, Set<Id>> mapOpportunityIdToSetHLContactOpen = new Map<Id, Set<Id>>();//!< map ContactIds corresponding to OpportunityIds open activity.
    	Map<Id, Boolean> mapOpenOpportunity = new Map<Id, Boolean>();//!< map to hold, is there open Opportunity available.
    	//!< Iterating to get open Opportunity.
        for(Opportunity_Internal_Team__c objOIT : [SELECT Id, 
        												  Opportunity__c,
        												  Contact__c,
                                                          Contact__r.User__c, 
        												  Opportunity__r.Closed__c 
        										     FROM Opportunity_Internal_Team__c 
        										    WHERE Contact__c IN :setHLContactId 
        										      AND Opportunity__r.Closed__c = false])
       	{
       		// add this HL employee to the set of employees on the related opportunity
    		if(mapOpportunityIdToSetHLContactOpen.containsKey(objOIT.Opportunity__c))
    			mapOpportunityIdToSetHLContactOpen.get(objOIT.Opportunity__c).add(objOIT.Contact__r.User__c);
    		else
    			mapOpportunityIdToSetHLContactOpen.put(objOIT.Opportunity__c, new Set<Id>{objOIT.Contact__r.User__c});
    	}
    	//!< Iterating to get open Opportunity.
    	for(Opportunity_External_Team__c objOET : [SELECT Id, 
        												  Opportunity__c,
        												  Contact__c, 
        												  Opportunity__r.Closed__c 
        										     FROM Opportunity_External_Team__c 
        										    WHERE Contact__c IN:setExContactId 
        										      AND Opportunity__r.Closed__c = false])
       	{
       		// if this opportunity has an associated internal op team
       		if(mapOpportunityIdToSetHLContactOpen.containsKey(objOET.Opportunity__c))
       		{
       			// for each member of the internal op team, pair them up with this external op team member; they're on an open opportunity together
	       		for(Id strHLId : mapOpportunityIdToSetHLContactOpen.get(objOET.Opportunity__c))
	    		{
	    			mapOpenOpportunity.put(StringToRelationship.get(strHLId + ':' + objOET.Contact__c), true);
	    		}
       		}
    	}
    	addToUpdateMap(mapOpenOpportunity, 'Share_Open_Opp__c');
    }
}