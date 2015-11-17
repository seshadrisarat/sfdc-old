/*
    JIRA Ticket   : LIB-184
    Created on    : May-19-2014
    Created by    : Praful
    Description   : Trigger handler for SL_Event and SL_Task, and purpose is to delete the child activities on deletion of parent activity.
*/
public with sharing class SL_ActivityHandler {

    //Static variable to maintain recursion handler, as we are firing trigger on update and again performing update operation for tasks records
    public static boolean run = true;
    
    /*--Added by Sanath--*/
    private static Set<Id> setAccountRecordType = new Map<Id,RecordType>([SELECT Id FROM RecordType WHERE DeveloperName IN ('Intermediary','Investor_Company') AND SobjectType=:'Account']).keyset();
    private static Id callNotRecordType = [SELECT Id FROM RecordType WHERE DeveloperName =: 'Fundraising_Event' AND SobjectType =:'Event' LIMIT 1].Id;
    private static String strUrl = Url.getSalesforceBaseUrl().toExternalform();
    private static Id FundraisingEventRecordType;
    private static set<Id> fundraisingAccountRecordTypeIds;
    /*--Added by Sanath--*/
    
    public void onAfterDelete(List<sObject> lstActivity) {
        
        Set<Id> setActivitiesIds = new Set<Id>(); // To hold the set of parent activities Ids
        List<sObject> lstChildActivitiesToDelete = new List<sObject>(); // To hold the list of child activities to delete

        // Iterating over list of activity
        for(sObject obj : lstActivity)
        {
            // Checking parent activity and collecting in set of activities ids
            if(obj.get('IsParent__c') == true)
                setActivitiesIds.add((Id)obj.get('Id'));
        }

        for(Event objEvent : [SELECT Id FROM Event WHERE ParentId__c IN: setActivitiesIds]){
            lstChildActivitiesToDelete.add(objEvent);
        } 

        for(Task objTask : [SELECT Id FROM Task WHERE ParentId__c IN: setActivitiesIds]) {        
            lstChildActivitiesToDelete.add(objTask);
        }

        if(!lstChildActivitiesToDelete.isEmpty()) {
            delete lstChildActivitiesToDelete;
        } 
    }

    //This method will execute on after update to update the related activities details
    public void onAfterUpdate(Map<Id, sObject> mapActivityNew, Map<Id, sObject> mapActivityOld) {
        
        /*-- Added by Sanath --*/
        map<Id , Task> mapIdToTaskNew = new map<Id ,Task>();
        map<Id , Task> mpaIdToTaskOld = new map<Id ,Task>();
        
        for(sObject objTask : mapActivityOld.values())
        {
            if(String.valueOf(objTask.Id.getSObjectType()) == 'Task')
            {
                mpaIdToTaskOld.put(objTask.Id , (Task)objTask);
                mapIdToTaskNew.put(objTask.Id , (Task)mapActivityNew.get(objTask.Id));
            }        
        }
        /*-- Added by Sanath --*/
        
        if(!mapIdToTaskNew.isEmpty() && !mpaIdToTaskOld.isEmpty())
            changeStatusOfRelatedTask(mapIdToTaskNew , mpaIdToTaskOld);
        
        set<Id> setActivityIds = new set<Id>();
        Map<Id,sObject> mapParentId_Activity = new Map<Id,sObject>();
        
        Schema.SObjectType objType;
        String dynamicQuery;
        List<sObject> lstActivityToUpdate = new List<sObject>();
        
        //Iterate over the updated activity records and collect them into map
        for(sObject objActivity: mapActivityNew.values()) {

            if(objActivity.get('isParent__c') == true && objActivity.get('ParentId__c') == null) {

                setActivityIds.add(objActivity.Id);
                mapParentId_Activity.put(objActivity.Id, objActivity);

            } else if(objActivity.get('isParent__c') == false && objActivity.get('ParentId__c') != null) {

                setActivityIds.add((Id)objActivity.get('ParentId__c'));
                mapParentId_Activity.put((Id)objActivity.get('ParentId__c'), objActivity);
            }            
        }

        if(!setActivityIds.isEmpty()) {

            objType = (new list<Id>(setActivityIds))[0].getSobjectType();

            if(objType == Task.SObjectType) {

                dynamicQuery = 'SELECT Id, Subject, isParent__c, ParentId__c, WhoId, WhatId, Status, IsReminderSet FROM Task WHERE ParentId__c IN: setActivityIds OR Id IN: setActivityIds';

            } else {

                dynamicQuery = 'SELECT Id, Subject, isParent__c, ParentId__c, WhoId, WhatId, IsReminderSet FROM Event WHERE ParentId__c IN: setActivityIds OR Id IN: setActivityIds';
            }

            for(sObject objActivity: Database.query(dynamicQuery)) {

                if(!mapActivityNew.containsKey(objActivity.Id)) {

                    sObject obj;

                    if(objActivity.get('isParent__c') == true && objActivity.get('ParentId__c') == null) {

                        obj = objType.newSObject();
                        obj = mapParentId_Activity.get(objActivity.Id).clone();

                    } else if(objActivity.get('isParent__c') == false && objActivity.get('ParentId__c') != null) {

                        obj = objType.newSObject();
                        obj = mapParentId_Activity.get((Id)objActivity.get('ParentId__c')).clone();                    
                    }

                    if(obj != null) {

                        Boolean closeRelatedActivities;

                        obj.Id = objActivity.Id;
                        obj.put('isParent__c', objActivity.get('isParent__c'));
                        obj.put('ParentId__c', objActivity.get('ParentId__c'));
                        obj.put('WhatId', objActivity.get('WhatId'));
                        obj.put('WhoId', objActivity.get('WhoId'));

                        //To avoid addition of common dependencies while Package building
                        String userQueryString = 'SELECT Close_Related_Activities__c FROM SL_MN_Related_List__c WHERE SetupOwnerId =\''+ UserInfo.getUserId()+'\' LIMIT 1';
                        String proQueryString = 'SELECT Close_Related_Activities__c FROM SL_MN_Related_List__c WHERE SetupOwnerId=\''+ UserInfo.getProfileId()+'\' LIMIT 1';
                        String orgQueryString = 'SELECT Close_Related_Activities__c FROM SL_MN_Related_List__c WHERE SetupOwnerId =\''+ UserInfo.getOrganizationId()+'\' LIMIT 1' ;

                        List<SL_MN_Related_List__c> userResult = Database.query(userQueryString);

                        if(userResult.isEmpty()) {

                            List<SL_MN_Related_List__c> profileResult = Database.query(proQueryString);

                            if(profileResult.isEmpty()) {
                                
                                List<SL_MN_Related_List__c> orgResult = Database.query(orgQueryString);
                                if(orgResult.isEmpty()) {

                                    closeRelatedActivities = false;

                                } else{

                                    closeRelatedActivities = (Boolean)orgResult[0].get('Close_Related_Activities__c');
                                }

                            } else {

                                closeRelatedActivities = (Boolean)profileResult[0].get('Close_Related_Activities__c');
                            }

                        } else {

                            closeRelatedActivities = (Boolean)userResult[0].get('Close_Related_Activities__c');
                        }

                        //Set the old status, if closeRelatedActivities is false
                        if(objType == Task.SObjectType && closeRelatedActivities == false) {

                            obj.put('Status', objActivity.get('Status'));
                        }

                        //Do not copy IsReminderSet value if Do_Not_Set_Reminder_To_Child_Activities__c value is true
                        if(SL_Meeting_Notes_Settings__c.getInstance().Do_Not_Set_Reminder_To_Child_Activities__c == true) {

                            obj.put('IsReminderSet', objActivity.get('IsReminderSet'));
                        }

                        lstActivityToUpdate.add(obj);
                    }
                }
            }
        }        

        if(lstActivityToUpdate.size()>0)
            update lstActivityToUpdate;
    }
    
    //Static class for recursion handler
    public static boolean runOnce(){
        if(run) {
            run=false; 
            return true;
        } 
        else {
            return run;
        }
     }
    
    /*-- Added by Sanath --*/
    private void changeStatusOfRelatedTask(Map<Id, Task> mapTaskNew, Map<Id, Task> mapTaskOld)
    {
        Map<Id, String> mapTaskToOpen_Status = new Map<Id, String>();  // To hold the Task Id and its Status(can be any except COMPLETED) to which we need to make open.
        Set<Id> setTaskIdsToClose = new Set<Id>();                     // To hold the Id to which we want to close.
        List<Task> lstTasksToClose = new List<Task>();                 // To hold task which we need to close(completed) and update.
        List<Task> lstTasksToOpen = new List<Task>();                  // To hold task which we need to open(other than completed) and update.

        for(Task objTask : mapTaskNew.values()) {
            
            //Checking the criteria if status updated and if its parent
            if(objTask.Status != mapTaskOld.get(objTask.Id).Status && objTask.isParent__c && objTask.ParentId__c == null){

                //If current task is open then get its Id and Status to update its child with same status.
                if(!objTask.IsClosed)
                    mapTaskToOpen_Status.put(objTask.Id, objTask.Status);
                //If current task is closed then get its Id to update its child with Completed status.
                else if(objTask.IsClosed)
                    setTaskIdsToClose.add(objTask.Id);

            //Checking the criteria if status updated and if its child
            }else if(objTask.Status != mapTaskOld.get(objTask.Id).Status && !objTask.isParent__c && objTask.ParentId__c != null){

                //If current task is open then get its Id and Status to update its parent with same status.
                if(!objTask.IsClosed) 
                    mapTaskToOpen_Status.put(objTask.ParentId__c, objTask.Status);  
                //If current task is closed then get its Id to update its parent with Completed status.
                else if(objTask.IsClosed) 
                    setTaskIdsToClose.add(objTask.ParentId__c); 

            }

        } 
        
        //Iterate over above collected setTaskIdsToClose, to get its child or parent records
        for(Task objTask : [SELECT Id, 
                                   Status, 
                                   IsClosed 
                              FROM Task 
                             WHERE ParentId__c IN: setTaskIdsToClose OR Id IN: setTaskIdsToClose]) {

                // If its related task Status is not completed then make it completed.
                if(objTask.Status != 'Completed') {  
                    objTask.Status = 'Completed';
                    lstTasksToClose.add(objTask);
                } 
        }
        
        //Update above collected lstTasksToClose
        if(!lstTasksToClose.isEmpty()) 
            update lstTasksToClose;
            
        //Iterate over above collected mapTaskToOpen_Status, to get its child or parent records
        for(Task objTask : [SELECT Id, 
                                   Status, 
                                   IsClosed,
                                   ParentId__c, 
                                   IsParent__c 
                              FROM Task 
                             WHERE ParentId__c IN: mapTaskToOpen_Status.keySet() OR Id IN: mapTaskToOpen_Status.keySet()]) {

                //If mapTaskToOpen_Status contains parent record then update the child record's status with parent's status.
                if(objTask.Status == 'Completed' && mapTaskToOpen_Status.containsKey(objTask.Id) && objTask.IsParent__c) {
                    objTask.Status = mapTaskToOpen_Status.get(objTask.Id);
                    lstTasksToOpen.add(objTask);

                //If mapTaskToOpen_Status contains child record then update the parent record's status with child's status.
                }else if(objTask.Status == 'Completed' && mapTaskToOpen_Status.containsKey(objTask.ParentId__c) && !objTask.IsParent__c){
                    objTask.Status = mapTaskToOpen_Status.get(objTask.ParentId__c);
                    lstTasksToOpen.add(objTask);
                }
        }
        
        //Update above collected lstTasksToOpen
        if(!lstTasksToOpen.isEmpty()) 
            update lstTasksToOpen;
    }
    
    public void onBeforeInsert(List<sObject> lstActivityNew)
    {
        List<Event> lstParentEvent = new List<Event>();
        List<Event> parentCallNoteEvents = new List<Event>();
        set<Id> parentCallNoteEventIds = new set<Id>();
        List<Event> childCallNoteEvents = new List<Event>();
        
        for(sObject objEvent : lstActivityNew)
        {
            if(objEvent.getSObjectType() == Event.sObjectType && objEvent.get('isParent__c') == true)
            {
                lstParentEvent.add((Event)objEvent);
            }        
        }
        if(!lstParentEvent.isEmpty()){
            parentCallNoteEvents = getFundraisingEvents(lstParentEvent);
        }

        for(Event e : parentCallNoteEvents){
            parentCallNoteEventIds.add((Id)e.Id);
        }

        for(sObject objEvent : lstActivityNew)
        {
            if(objEvent.getSObjectType() == Event.sObjectType && objEvent.get('isParent__c') == false){
                
                Event e =(Event)objEvent;
                if(parentCallNoteEventIds.contains((Id)e.ParentId__c)){
                    childCallNoteEvents.add((Event)objEvent);
                }
            }
        }

        if(parentCallNoteEvents.size() > 0){
            parentCallNoteEvents = populateTearsheetURL(parentCallNoteEvents);
            parentCallNoteEvents = populateCallNoteRecordType(parentCallNoteEvents);
        }
        if(childCallNoteEvents.size() > 0){
            childCallNoteEvents = populateTearsheetURL(childCallNoteEvents);
            childCallNoteEvents = populateCallNoteRecordType(childCallNoteEvents);
        }
    }

    public static list<Event> populateTearsheetURL(list<Event> callNoteEvents){
        for(Event e : callNoteEvents){
            e.Tearsheet__c = '/apex/SL_TearSheetReportPDF?id=';
            e.Tearsheet_Link_Label__c = 'Launch Tearsheet';
        }
        return callNoteEvents;
    }

    public static list<Event> populateCallNoteRecordType(list<Event> callNoteEvents){
        If(FundraisingEventRecordType == null){
            FundraisingEventRecordType = [SELECT Id from RecordType WHERE sObjectType = 'Event' AND DeveloperName = 'Fundraising_Event'].Id;
        }
        for(Event e : callNoteEvents){
            e.RecordTypeId = FundraisingEventRecordType;
        }
        return callNoteEvents;
    }
    
     /*
    * MethodName        : onAfterInsert
    * param             : List of inserted event records
    * Description       : This function is used to update the inserted event records with call note record type and tearsheet url if WhatId belongs to either Account or Fundraising Opportunity object.
    
     public static void insertCallnoteRecordandTearSheetURL(List<Event> lstEvent)
     {
     	List<Event> lstEventToUpdate = new List<Event>();// This list is used to contain the event records which needs to be updated with call note record type and tearsheet url
     	Map<Id,Id> mapChildEventToParent = new Map<Id,Id>();// This map is used to keep child event and its corresponding parent event Id
     	Set<Id> setParentId = new Set<Id>();// Set to hold the parent event ids whose what id belongs to either Account or Fundraising_Opportunity__c.
     	
     	//Itreating over inserted list of events to filter the records
     	for(Event objEvent : lstEvent)
     	{     		
     		if(objEvent.WhatId!=NULL && (objEvent.WhatId.getSobjectType() == Account.SobjectType || objEvent.WhatId.getSobjectType() == Fundraising_Opportunity__c.SobjectType) && objEvent.isParent__c)
     		{
     			lstEventToUpdate.add(new Event(Id = objEvent.Id, RecordTypeId = callNotRecordType, Tearsheet__c = strUrl + '/apex/SL_TearSheetReportPDF?id='+objEvent.Id));
     		}
     		else if(!objEvent.isParent__c && objEvent.ParentId__c!=NULL)
     		{
     			mapChildEventToParent.put(objEvent.Id, objEvent.ParentId__c);
     		}     		
     	}
     	
     	//Fetching the parent events and their what ids and storing them in a set after filteration. 
     	for(Event objEvent : [SELECT Id, WhatId FROM Event WHERE Id IN : mapChildEventToParent.values() AND WhatId!=NULL])
     	{
     		if(objEvent.WhatId.getSobjectType() == Account.SobjectType || objEvent.WhatId.getSobjectType() == Fundraising_Opportunity__c.SobjectType)
     			setParentId.add(objEvent.Id);
     	}
     	
     	for(Id eventId : mapChildEventToParent.keyset())
     	{
     		if(setParentId.contains(mapChildEventToParent.get(eventId)))
     			lstEventToUpdate.add(new Event(Id = eventId, RecordTypeId = callNotRecordType, Tearsheet__c = strUrl + '/apex/SL_TearSheetReportPDF?id='+mapChildEventToParent.get(eventId)));
     	}
     	
     	if(!lstEventToUpdate.isEmpty())
     		update lstEventToUpdate;
     }
    Added by Sanath --*/

    public static list<Event> getFundraisingEvents(list<Event> newEvents){
        list<Event> accountEvents = new list<Event>();
        list<Event> fundraisingOpportunityEvents = new list<Event>();
        list<Event> allFundraisingEvents = new list<Event>();
        list<Event> fundraisingAccountEvents;

        for(Event e : newEvents){
            if(e.whatId.getSobjectType() == Account.sObjectType){
                accountEvents.add(e);
            }
            else if(e.whatId.getSobjectType() == Fundraising_Opportunity__c.sObjectType){
                fundraisingOpportunityEvents.add(e);
            }
        }
        fundraisingAccountEvents = getFundraisingAccountEvents(accountEvents);

        allFundraisingEvents.addAll(fundraisingOpportunityEvents);
        allFundraisingEvents.addAll(fundraisingAccountEvents);

        return allFundraisingEvents;
    }

    public static list<Event> getFundraisingAccountEvents(list<Event> accountEvents){
        list<Id> accountIds = new list<Id>();
        list<Event> fundraisingAccountEvents = new list<Event>();
        map<Id,Account> accountIdToRecordtype;

        if(fundraisingAccountRecordTypeIds == null){
            fundraisingAccountRecordTypeIds = new set<Id>();
            for(RecordType r : [select id from recordtype where sObjectType = 'Account' AND DeveloperName IN ('Intermediary','Investor_Company')]){
                fundraisingAccountRecordTypeIds.add(r.Id);
            }
        }

        for(Event e : accountEvents){
            accountIds.add(e.whatId);
        }

        accountIdToRecordtype = new map<Id,Account>([SELECT Id, RecordTypeId from Account where Id = :accountIds]);

        for(Event e : accountEvents){
            if(fundraisingAccountRecordTypeIds.contains(accountIdToRecordtype.get(e.WhatId).RecordTypeId)){
                fundraisingAccountEvents.add(e);
            }
        }

        return fundraisingAccountEvents;

    }
            
}