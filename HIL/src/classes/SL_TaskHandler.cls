/* @ClassName    : SL_TaskHandler
* @JIRATicket   : Hil-1
* @CreatedOn    : 9/April/ 2014
* @ModifiedBy   : Sruti Srivastava
* @Description  : This is the handler class for Task trigger. Updates date field on Account and Group member records
*/ 

public without sharing class SL_TaskHandler
{
    /* start - global variables*/
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    /* end - global variables*/

    //Constructor of a Handler Class
    public SL_TaskHandler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    // This function will be called on OnAfterInsert of Task record.
    public void onAfterInsert(Map<Id, Task> mapNewTask)
    {
        //Updating Activities
        updateTasks(mapNewTask, null);
    }
    
    // This function will be called on onAfterUpdate of Task record.
    public void onAfterUpdate(Map<Id, Task> mapNewTask, Map<Id, Task> mapOldTask)
    {
        //Updating Activities
        updateTasks(mapNewTask, mapOldTask);
    }
    
    // This function will be called on onAfterUndelete of Task record.
    public void onAfterUndelete(Map<Id, Task> mapNewTask)
    {
        //Updating Activities
        updateTasks(mapNewTask, null);
    }
    
    private void updateTasks(Map<Id, Task> mapNewTask, Map<Id, Task> mapOldTask)
    {
        Map<Id, Account> mapId_UpdateAccount = new Map<Id, Account>(); // Map for storing Account Id and Account object for updating the Account
        Set<Id> setAccountIds = new Set<Id>();// Task's What Id
        Set<Id> setContactIds = new Set<Id>();// Task's Who Id
        Map<Id, Account> mapIdPersonAccount         = new Map<Id, Account>(); // Map of Id to Person Account
        Map<Id, String> mapContactIdPersonAccountId = new Map<Id, String>();// Map of Contact Id to person Account Id

        //Call Method to update WhatId on Tasks
        updateWhatIdOnTasks(mapNewTask, mapOldTask);

        for(Task objTask : mapNewTask.values())
        {
            If( (objTask.Type == 'Call' || objTask.Type == 'Meeting' ) 
                    && (objTask.isClosed != null && objTask.isClosed) && objTask.ActivityDate != null && objTask.Count_Towards_SLA__c != null && objTask.Count_Towards_SLA__c)
            {
                if(objTask.WhatId != null && String.valueOf(objTask.WhatId).startsWith('001') )
                    setAccountIds.add(objTask.WhatId);  
                if(objTask.WhoId != null && String.valueOf(objTask.WhoId).startsWith('003') )
                    setContactIds.add(objTask.WhoId);   
            }   
        }
        //Querying Person Contact
        if(!setContactIds.isEmpty())
            for(Contact objContact : [Select Id, Name, AccountId FROM Contact WHERE Id In :setContactIds and Account.IsPersonAccount = true])
            {
                mapContactIdPersonAccountId.put(objContact.Id, objContact.AccountId);
            }
        
        //Querying related person Account
        if(!mapContactIdPersonAccountId.isEmpty())
        {
            For(Account objAccount : [Select Id, Name, IsPersonAccount, Primary_Relationship_Group__c, Last_Contact_Date__c, Last_Meeting_Date__c FROM Account 
                                    WHERE (Id In :setAccountIds OR Id In: mapContactIdPersonAccountId.values()) ])// AND IsPersonAccount = true
            {
                mapIdPersonAccount.put(objAccount.Id, objAccount);
            }
        }
        
        for(Task objTask : mapNewTask.values())
        {
            if(objTask.WhoId != null 
            && ((mapContactIdPersonAccountId.containsKey(objTask.WhoId) && ( objTask.WhatId != null && mapIdPersonAccount != null && mapIdPersonAccount.containsKey(objTask.WhatId)) && mapContactIdPersonAccountId.get(objTask.WhoId) == objTask.WhatId && (objTask.isClosed != null && objTask.isClosed) )
            || mapIdPersonAccount.containsKey(objTask.WhatId)
            || ( mapContactIdPersonAccountId.containsKey(objTask.WhoId)  && (objTask.WhatId == null || ( mapIdPersonAccount.containsKey(mapContactIdPersonAccountId.get(objTask.WhoId)) && objTask.WhatId == mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objTask.WhoId)).Primary_Relationship_Group__c)) ))
            && (objTask.Type != null && (objTask.Type == 'Call'  || objTask.Type == 'Meeting') ) && objTask.Count_Towards_SLA__c != null && objTask.Count_Towards_SLA__c)
            {
                Id idPersonAccountId;

                //Forming map of Task and Account records to update
                if(mapContactIdPersonAccountId.containsKey(objTask.WhoId) && mapIdPersonAccount.containsKey(mapContactIdPersonAccountId.get(objTask.WhoId)) 
                && mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objTask.WhoId)).Primary_Relationship_Group__c != null 
                && (objTask.WhatId == null || objTask.WhatId == mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objTask.WhoId)).Primary_Relationship_Group__c))
                {
                    idPersonAccountId =  mapContactIdPersonAccountId.get(objTask.WhoId);
                }
                else if((( mapContactIdPersonAccountId.containsKey(objTask.WhoId) && ( objTask.WhatId != null && mapIdPersonAccount.containsKey(objTask.WhatId)) && mapContactIdPersonAccountId.get(objTask.WhoId) == objTask.WhatId ) && objTask.ActivityDate != null) 
                    || (mapIdPersonAccount.containsKey(objTask.WhatId) && mapIdPersonAccount.get(objTask.WhatId).IsPersonAccount == False) )
                {
                        idPersonAccountId = objTask.WhatId;
                }
                
                //Updating Last_Contact_Date__c
                if(idPersonAccountId != null && ((mapIdPersonAccount.containsKey(idPersonAccountId) && ( mapIdPersonAccount.get(idPersonAccountId).Last_Contact_Date__c == null
                     || mapIdPersonAccount.get(idPersonAccountId).Last_Contact_Date__c < objTask.ActivityDate))))
                {
                    mapIdPersonAccount.get(idPersonAccountId).Last_Contact_Date__c = objTask.ActivityDate;
                    mapId_UpdateAccount.put(idPersonAccountId, mapIdPersonAccount.get(idPersonAccountId));
                }
                //updating Last_Meeting_Date__c
                if(idPersonAccountId != null && (mapIdPersonAccount.containsKey(idPersonAccountId) && (objTask.Type == 'Meeting' && (mapIdPersonAccount.get(idPersonAccountId).Last_Meeting_Date__c == null || 
                mapIdPersonAccount.get(idPersonAccountId).Last_Meeting_Date__c < objTask.ActivityDate))))
                {
                    mapIdPersonAccount.get(idPersonAccountId).Last_Meeting_Date__c = objTask.ActivityDate;
                    mapId_UpdateAccount.put(idPersonAccountId, mapIdPersonAccount.get(idPersonAccountId));
                }
            }
        }
        
        //Updating Date Fileds on Account
        if(!mapId_UpdateAccount.isEmpty())
            Database.update(mapId_UpdateAccount.values(), false);
            
        Map<Id, Group_Member__c> mapIdGroupMember = new Map<Id, Group_Member__c>();//Group member records to update
        
        //Updating Group relationship records
        if(!mapId_UpdateAccount.keyset().isEmpty())
            for(Group_Member__c objGroupMember : [Select Id, Last_Meeting_Date__c, Last_Contact_Date__c, Client_Prospect__c From Group_Member__c 
                                                    where Client_Prospect__c IN:  mapId_UpdateAccount.keyset()])
            {
                if(mapIdPersonAccount.containsKey(objGroupMember.Client_Prospect__c))
                {
                    objGroupMember.Last_Contact_Date__c = mapIdPersonAccount.get(objGroupMember.Client_Prospect__c).Last_Contact_Date__c;
                    objGroupMember.Last_Meeting_Date__c = mapIdPersonAccount.get(objGroupMember.Client_Prospect__c).Last_Meeting_Date__c;
                    
                    mapIdGroupMember.put(objGroupMember.Id, objGroupMember);
                }
            }
        
        //Updating Events and Group Member records      
        if(!mapIdGroupMember.isEmpty())
            Database.update(mapIdGroupMember.values(), false);
    }


    private void updateWhatIdOnTasks(Map<Id, Task> mapNewTask, Map<Id, Task> mapOldTask)
    {
        Set<Id> setAccountIds = new Set<Id>();// Task's What Id
        Set<Id> setContactIds = new Set<Id>();// Task's Who Id
        Map<Id, Account> mapIdPersonAccount         = new Map<Id, Account>(); // Map of Id to Person Account
        Map<Id, String> mapContactIdPersonAccountId = new Map<Id, String>();// Map of Contact Id to person Account Id
        Map<Id, Task> mapTasksToUpdate = new  Map<Id, Task>();

        for(Task objTask : mapNewTask.values())
        {
                if(objTask.WhatId != null && String.valueOf(objTask.WhatId).startsWith('001') )
                    setAccountIds.add(objTask.WhatId);  
                if(objTask.WhoId != null && String.valueOf(objTask.WhoId).startsWith('003') )
                    setContactIds.add(objTask.WhoId);   
        }

        //Querying Person Contact
        if(!setContactIds.isEmpty())
        for(Contact objContact : [Select Id, Name, AccountId FROM Contact WHERE Id In :setContactIds and Account.IsPersonAccount = true])
        {
             mapContactIdPersonAccountId.put(objContact.Id, objContact.AccountId);
        }
        
        //Querying related person Account
        if(!mapContactIdPersonAccountId.isEmpty())
        {
            For(Account objAccount : [Select Id, Name, IsPersonAccount, Primary_Relationship_Group__c, Last_Contact_Date__c, Last_Meeting_Date__c FROM Account 
                                    WHERE (Id In :setAccountIds OR Id In: mapContactIdPersonAccountId.values()) ])// AND IsPersonAccount = true
            {
                mapIdPersonAccount.put(objAccount.Id, objAccount);
            }
        }
        
        for(Task objTask : mapNewTask.values())
        {
            if(objTask.WhoId != null 
            && ((mapContactIdPersonAccountId.containsKey(objTask.WhoId) && ( objTask.WhatId != null && mapIdPersonAccount != null && mapIdPersonAccount.containsKey(objTask.WhatId)) && mapContactIdPersonAccountId.get(objTask.WhoId) == objTask.WhatId )
            || mapIdPersonAccount.containsKey(objTask.WhatId)
            || ( mapContactIdPersonAccountId.containsKey(objTask.WhoId)  && (objTask.WhatId == null || ( mapIdPersonAccount.containsKey(mapContactIdPersonAccountId.get(objTask.WhoId)) && objTask.WhatId == mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objTask.WhoId)).Primary_Relationship_Group__c)) )))
            {
                //Forming map of Task and Account records to update
                if(mapContactIdPersonAccountId.containsKey(objTask.WhoId) && mapIdPersonAccount.containsKey(mapContactIdPersonAccountId.get(objTask.WhoId)) 
                && mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objTask.WhoId)).Primary_Relationship_Group__c != null 
                && (objTask.WhatId == null || objTask.WhatId == mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objTask.WhoId)).Primary_Relationship_Group__c))
                {
                    mapTasksToUpdate.put(objTask.Id, New Task(Id = objTask.Id, WhatId= 
                    mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objTask.WhoId)).Primary_Relationship_Group__c));
                }

                else if(( mapContactIdPersonAccountId.containsKey(objTask.WhoId) && ( objTask.WhatId != null && mapIdPersonAccount.containsKey(objTask.WhatId)) 
                && mapContactIdPersonAccountId.get(objTask.WhoId) == objTask.WhatId ) )
                {
                    if(mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objTask.WhoId)).Primary_Relationship_Group__c != null)
                            mapTasksToUpdate.put(objTask.Id, New Task(Id= objTask.Id, 
                                                            WhatId = mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objTask.WhoId)).Primary_Relationship_Group__c));
                }
            }
        }

        if(!mapTasksToUpdate.isEmpty())
            Database.update(mapTasksToUpdate.values(), false);
    }
    
}