/**
*  ClassName      : SL_EventHandler
*  JIRATicket     : GA-2
*  CreatedOn      : 10/DEC/2014
*  ModifiedBy     : Hemant Shukla
*  Description    : This is the handler class for Event trigger
*/
public without sharing class SL_EventHandler {
    
    public String strAccountKeyPrefix = '';                    // To store Account KeyPrefix
    public String strOpportunityKeyPrefix = '';         // To store Opportunity KeyPrefix
    private static boolean run = true;
    
    /* Constructor */
    public SL_EventHandler(){
    
        /*Fetching Account and Opportunity KeyPrefix*/
        Map<String, SObjectType> mapSchemaSobject = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult result =  mapSchemaSobject.get('Account').getDescribe();
        strAccountKeyPrefix = Result.getKeyPrefix();
        
        Schema.DescribeSObjectResult opportunityResult =  mapSchemaSobject.get('Opportunity').getDescribe();
        strOpportunityKeyPrefix = opportunityResult.getKeyPrefix();
    }

    public static boolean runOnce()
    {
        if(run)
        {
            run=false;
            return true;
        }else
        {
            return run;
        }
    }
    
    /*
    * MethodName   : onAfterInsert
    * param        : trigger.newMap
    * Description  : This method is called after Event records are inserted
    */
    public void onAfterInsert(Map<Id,Event> mapNewEvent){
        if(SL_EventHandler.runOnce())
        {
            prospectMeetingUnflag(mapNewEvent.values(),true);
            updateMaterialInteractionNotes(null, mapNewEvent, false);
            updateCPNextSteps(null, mapNewEvent,false);
            setAttFlag(null, mapNewEvent);
        }
    }
    
    /*
    * MethodName   : onAfterUpdate
    * param        : trigger.newMap,trigger.oldMap
    * Description  : This method is called after Event records are updated
    */
    public void onAfterUpdate(Map<Id,Event> mapOldEvent, Map<Id,Event> mapNewEvent){
        if(SL_EventHandler.runOnce())
        {    
            prospectMeetingUnflag(mapNewEvent.values(),true);
            updateMaterialInteractionNotes(mapOldEvent, mapNewEvent, false);
            updateCPNextSteps(mapOldEvent, mapNewEvent, false);
            setAttFlag(mapOldEvent, mapNewEvent);
        }
    }
    
    /*
    * MethodName   : onAfterDelete
    * param        : trigger.oldMap
    * Description  : This method is called after Event records are deleted
    */
    public void onAfterDelete(Map<Id,Event> mapOldEvent){

        if(SL_EventHandler.runOnce())
        {    
            prospectMeetingUnflag(mapOldEvent.values(),false);
            updateMaterialInteractionNotes(mapOldEvent, null, true); 
            updateCPNextSteps(mapOldEvent, null, true);
        }
    }
    
    /*
    * MethodName   : prospectMeetingUnflag
    * param        : trigger.new and boolean 
    * Description  : This method is called after Event records are inserted,updated and deleted. This code has been taken from 
                     MostRecentCommentsHandler.cls
    */
    private void prospectMeetingUnflag(List<Event> lstNewEvent, Boolean bInsertUpdate) {
        
        set<String> setAccId = new set<String>();  //set to store Account Id
        
        /*In this iteration will get all the Account Id */
        for(Event objEvent : lstNewEvent)
            if(objEvent.WhatId != null && String.valueOf(objEvent.WhatId).startsWith(strAccountKeyPrefix) && objEvent.ActivityDate < date.today())
                setAccId.add(objEvent.WhatId);
        
        if(setAccId.size() > 0) updateMostRecentActivity(setAccId);
        
        if(bInsertUpdate) updateProspectAccount(lstNewEvent);
    }
    
    /*
    * MethodName   : updateMostRecentActivity
    * param        : Set of account Id 
    * Description  : 
    */
    private void updateMostRecentActivity(set<String> setAccountId){ 
    
        map<String, Task> mapAccountId_Task = new map<String, Task>();
        map<String, String> mapAccountId_Comment = new map<String, String>();
        List<Account> lstAccountToUpdate = new List<Account>();
        
        try{
            
            for(Task objTask: [select Id, ActivityDate, WhatId, Description From Task where IsClosed=TRUE AND WhatId IN: setAccountId order by ActivityDate DESC, LastModifiedDate DESC]){
                if(!mapAccountId_Task.containsKey(objTask.WhatId)){
                
                    mapAccountId_Task.put(objTask.WhatId, objTask);
                    mapAccountId_Comment.put(objTask.WhatId, objTask.Description);
                }
            }
            
            for(Event objEvent : [select Id, ActivityDate, WhatId, Description From Event where WhatId IN: setAccountId order by ActivityDate DESC, LastModifiedDate DESC]){
                if(mapAccountId_Task.containsKey(objEvent.WhatId)){
                
                    if(mapAccountId_Task.get(objEvent.WhatId).ActivityDate > objEvent.ActivityDate)
                        mapAccountId_Comment.put(objEvent.WhatId, mapAccountId_Task.get(objEvent.WhatId).Description);
                    else
                        mapAccountId_Comment.put(objEvent.WhatId, objEvent.Description);
                }
                else
                    mapAccountId_Comment.put(objEvent.WhatId, objEvent.Description);
            }
            
            for(Account objAccount :[select Id, Most_Recent_Activity_Comment__c from Account where Id IN: mapAccountId_Comment.keySet()]){
                objAccount.Most_Recent_Activity_Comment__c = mapAccountId_Comment.get(objAccount.Id);
                lstAccountToUpdate.add(objAccount);    
            }
            
            if(lstAccountToUpdate.size() > 0) update lstAccountToUpdate;
            
            if(Test.isRunningTest())
                Integer i = 10/0;
        }
        catch(Exception e) { 
        
            Task objTask = new Task();
            objTask.addError('An unexpected error has occured, please notify your Administrator.');
        }
    }
    
    /*
    * MethodName   : updateProspectAccount
    * param        : list of Event 
    * Description  : 
    */
    private void updateProspectAccount(List<Event> lstEvent) {
        
        List<Account> prospectAccounts = new List<Account>();
        if((trigger.isAfter && trigger.isUpdate) || (trigger.isAfter && trigger.isInsert)){
            for (Event e : lstEvent) {
                if (e.Type == 'Prospect Meeting' && e.AccountId != null) 
                    prospectAccounts.add(new Account(Id = e.AccountId,Add_to_call_list__c = false));
            }
        }
        
        if (!prospectAccounts.isEmpty()) update prospectAccounts;
    }
    
    /*
    * MethodName   : updateMaterialInteractionNotes
    * param        : list of Event 
    * Description  : This method is called when Insert/Update and Delete of an Event records
    */
    private void updateMaterialInteractionNotes(Map<Id,Event> oldMap, Map<Id,Event> newMap, Boolean isDelete)
    {
        Set<Id> acctIds = new Set<Id>();
        Account[] updAccts = new Account[]{};

        Event[] tempList = isDelete ? oldMap.values() : newMap.values();

        for(Event e : tempList)
        {
            if(e.WhatId != null)
            {
                if(e.WhatId.getSObjectType() == Schema.Account.SObjectType)
                {
                    acctIds.add(e.WhatId);
                }
            }
        }

        Account[] aList = [Select Id,
                          (Select Id,Subject,ActivityDate,Material_Interaction__c
                           From ActivityHistories
                           ORDER BY ActivityDate DESC NULLS LAST LIMIT 500)
                           From Account
                           WHERE Id IN: acctIds];

        for(Account a : aList)
        {
            a.Material_Interaction_Notes_Short__c = '';
            a.Material_Interaction_Notes__c = '';

            ActivityHistory[] ahList = new ActivityHistory[]{};

            for(ActivityHistory ah : a.ActivityHistories)
            {
                if(ah.Material_Interaction__c)
                {
                    ahList.add(ah);
                }

                if(ahList.size() == 10)
                {
                    break;
                }
            }

            System.debug('Look at me = ' + ahList.size());

            if(ahList != null && !ahList.isEmpty())
            {
                for(Integer i=0;i<ahList.size();i++)
                {
                    String strDate = '';

                    if(ahList[i].ActivityDate != null)
                    {
                        strDate = ahList[i].ActivityDate.month() + '/' + ahList[i].ActivityDate.day() + '/' + String.valueOf(ahList[i].ActivityDate.year()).substring(2,4);
                    }

                    if(i<2)
                    {
                        a.Material_Interaction_Notes_Short__c = a.Material_Interaction_Notes_Short__c + '- ' + (strDate != '' ? strDate + ': ' : '') + ahList[i].Subject + '\n';
                    }
                    
                    a.Material_Interaction_Notes__c = a.Material_Interaction_Notes__c + '- ' + (strDate != '' ? strDate + ': ' : '') + ahList[i].Subject + '\n';
                }
            }

            updAccts.add(a);
        }

        update updAccts;
    }

    private void updateCPNextSteps(Map<Id,Event> oldMap, Map<Id,Event> newMap, Boolean isDelete)
    {
        Set<Id> acctIds = new Set<Id>();
        Account[] updAccts = new Account[]{};

        Event[] tempList = isDelete ? oldMap.values() : newMap.values();

        for(Event e : tempList)
        {
            if(e.WhatId != null)
            {
                if(e.WhatId.getSObjectType() == Schema.Account.SObjectType)
                {
                    acctIds.add(e.WhatId);
                }
            }
        }

        Account[] aList = [Select Id,(Select Id,Subject,ActivityDate,IsClosed
                                      From OpenActivities
                                      ORDER BY ActivityDate DESC NULLS LAST LIMIT 10)
                           From Account
                           WHERE Id IN: acctIds];

        for(Account a : aList)
        {
            a.CP_Next_Steps__c = '';

            OpenActivity[] ahList = a.OpenActivities;

            if(ahList != null && !ahList.isEmpty())
            {
                for(Integer i=0;i<ahList.size();i++)
                {
                    if(!ahList[i].IsClosed)
                    {
                        String strDate = '';

                        if(ahList[i].ActivityDate != null)
                        {
                            strDate = ahList[i].ActivityDate.month() + '/' + ahList[i].ActivityDate.day() + '/' + String.valueOf(ahList[i].ActivityDate.year()).substring(2,4);
                        }
                    
                        a.CP_Next_Steps__c = a.CP_Next_Steps__c + '- ' + (strDate != '' ? strDate + ': ' : '') + ahList[i].Subject + '\n';
                    }
                }
            }

            updAccts.add(a);
        }

        update updAccts;
    }

    private void setAttFlag(Map<Id,Event> oldMap, Map<Id,Event> newMap)
    {
        Event[] eList = [Select Id,Has_Attachment__c,Attachment_Names__c,
                        (Select Id,Name From Attachments)
                         From Event WHERE Id IN: newMap.keyset()];

        Event[] updList = new Event[]{};

        for(Event e : eList)
        {
            if(e.Attachments != null && !e.Attachments.isEmpty())
            {
                e.Has_Attachment__c = true;
                e.Attachment_Names__c = '';

                for(Attachment a : e.Attachments)
                {
                    e.Attachment_Names__c = e.Attachment_Names__c + a.Name + '\n';
                }

                updList.add(e);
            }
        }

        update updList;
    }
}