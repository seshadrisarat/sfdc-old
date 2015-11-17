/**
* @ClassName    : SL_TaskHandler
* @JIRATicket   : HIL-1
* @CreatedOn    : 9/April/ 2014
* @ModifiedBy   : Sruti Srivastava
* @Description  : This is the handler class for Event trigger. Updates date field on Account and Group member records
*/ 

public without sharing class SL_EventHandler
{
    /* start - global variables*/
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    /* end - global variables*/

    //Constructor of a Handler Class
    public SL_EventHandler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    // This function will be called on OnAfterInsert of Event record.
    public void onAfterInsert(Map<Id, Event> mapNewEvent)
    {
        //Updating Activities
        updateEvents(mapNewEvent, null);
    }
    
    // This function will be called on onAfterUpdate of Event record.
    public void onAfterUpdate(Map<Id, Event> mapNewEvent, Map<Id, Event> mapOldEvent)
    {
        //Updating Activities
        updateEvents(mapNewEvent, mapOldEvent);
    }
    
    // This function will be called on onAfterUndelete of Event record.
    public void onAfterUndelete(Map<Id, Event> mapNewEvent)
    {
        //Updating Activities
        updateEvents(mapNewEvent, null);
    }
    
    private void updateEvents(Map<Id, Event> mapNewEvent, Map<Id, Event> mapOldEvent)
    {
        Map<Id, Account> mapId_UpdateAccount = new Map<Id, Account>(); // Map for storing Account Id and Account object for updating the Account
        Datetime yesterdayDatetime = datetime.newInstance(Date.Today().year(), Date.Today().month(), Date.Today().day());//yesterday Date
        
        Set<Id> setAccountIds = new Set<Id>();// Event's What Id
        Set<Id> setContactIds = new Set<Id>();// Event's Who Id

        Map<Id, Account> mapIdPersonAccount         = new Map<Id, Account>(); // Map of Id to Person Account
        Map<Id, Contact> mapIdPersonContact         = new Map<Id, Contact>();// Map of Id to Person Contact
        Map<Id, String> mapContactIdPersonAccountId = new Map<Id, String>();// Map of Contact Id to person Account Id
        
        updateWhatIdOnEvents(mapNewEvent, mapOldEvent);

        for(Event objEvent : mapNewEvent.values())
        {
            
            If((objEvent.Type == 'Call' || objEvent.Type == 'Meeting' ) 
            && (objEvent.EndDateTime != null && objEvent.EndDateTime < yesterdayDatetime) 
            && objEvent.Count_Towards_SLA__c != null 
            && objEvent.Count_Towards_SLA__c)
            {
                if(objEvent.WhatId != null && String.valueOf(objEvent.WhatId).startsWith('001') )
                    setAccountIds.add(objEvent.WhatId); 
                if(objEvent.WhoId != null && String.valueOf(objEvent.WhoId).startsWith('003') )
                    setContactIds.add(objEvent.WhoId);  
            }  
        }
        
        //Querying Person Contact which is WhoId for inserted/updated event
        if(!setContactIds.isEmpty())
            for(Contact objContact : [Select Id, Name, AccountId FROM Contact WHERE Id In :setContactIds and Account.IsPersonAccount = true])
            {
                mapIdPersonContact.put(objContact.Id, objContact);
                mapContactIdPersonAccountId.put(objContact.Id, objContact.AccountId);
            }

        //Querying Account which is WhatId for inserted/updated event or a Person Account for Contact which is WhoId for inserted/updated event
        if(!mapContactIdPersonAccountId.isEmpty())
            mapIdPersonAccount.putAll([Select Id, Name, IsPersonAccount, Primary_Relationship_Group__c, Last_Contact_Date__c, Last_Meeting_Date__c FROM Account 
                                    WHERE (Id In :setAccountIds OR Id In: mapContactIdPersonAccountId.values()) ]);// AND IsPersonAccount = true
        
        if(!mapContactIdPersonAccountId.isEmpty())

            ///Create maps to update WhatId  and date fields
            for(Event objEvent : mapNewEvent.values())
            {
                ///Get EndDate of inserted/updated event
                Date eventEndDate = objEvent.EndDateTime != null ? date.valueOf(objEvent.EndDateTime): null;

                //Forming map of Task and Account records to update
                if(objEvent.WhoId != null  
                &&(( mapContactIdPersonAccountId.containsKey(objEvent.WhoId) && ( objEvent.WhatId != null && mapIdPersonAccount.containsKey(objEvent.WhatId)) && mapContactIdPersonAccountId.get(objEvent.WhoId) == objEvent.WhatId ) || 
                    mapIdPersonAccount.containsKey(objEvent.WhatId)  ||
                (objEvent.WhatId == null  || ( mapContactIdPersonAccountId.containsKey(objEvent.WhoId) &&  mapIdPersonAccount.containsKey(mapContactIdPersonAccountId.get(objEvent.WhoId)) && objEvent.WhatId == mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objEvent.WhoId)).Primary_Relationship_Group__c)) ) 
                && (objEvent.Type == 'Call'  || objEvent.Type == 'Meeting')
                && (objEvent.EndDateTime != null && eventEndDate < Date.today())
                && objEvent.Count_Towards_SLA__c != null && objEvent.Count_Towards_SLA__c)
                {
                    Id idPersonAccountId;
                    
                    if( mapContactIdPersonAccountId.containsKey(objEvent.WhoId) && 
                    mapIdPersonAccount.containsKey(mapContactIdPersonAccountId.get(objEvent.WhoId)) 
                    && mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objEvent.WhoId)).Primary_Relationship_Group__c != null
                    && (objEvent.WhatId == null || objEvent.WhatId == mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objEvent.WhoId)).Primary_Relationship_Group__c))
                    {
                        idPersonAccountId =  mapContactIdPersonAccountId.get(objEvent.WhoId);
                    }
                    else if(( mapContactIdPersonAccountId.containsKey(objEvent.WhoId) && ( objEvent.WhatId != null && mapIdPersonAccount.containsKey(objEvent.WhatId))  &&
                             mapContactIdPersonAccountId.get(objEvent.WhoId) == objEvent.WhatId ) || (mapIdPersonAccount.containsKey(objEvent.WhatId) && mapIdPersonAccount.get(objEvent.WhatId).IsPersonAccount == False) )
                    {
                        idPersonAccountId = objEvent.WhatId;
                    }
                    
                    //Updating Last_Contact_Date__c
                    if(mapIdPersonAccount.containsKey(idPersonAccountId) && ( mapIdPersonAccount.get(idPersonAccountId).Last_Contact_Date__c == null
                         || mapIdPersonAccount.get(idPersonAccountId).Last_Contact_Date__c < eventEndDate))
                    {

                        mapIdPersonAccount.get(idPersonAccountId).Last_Contact_Date__c = eventEndDate;
                        mapId_UpdateAccount.put(idPersonAccountId, mapIdPersonAccount.get(idPersonAccountId));
                    }
                    
                    //updating Last_Meeting_Date__c
                    if(mapIdPersonAccount.containsKey(idPersonAccountId) && 
                        (objEvent.Type == 'Meeting' && (mapIdPersonAccount.get(idPersonAccountId).Last_Meeting_Date__c == null || 
                        mapIdPersonAccount.get(idPersonAccountId).Last_Meeting_Date__c < eventEndDate)))
                    {

                        mapIdPersonAccount.get(idPersonAccountId).Last_Meeting_Date__c = eventEndDate;
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


     private void updateWhatIdOnEvents(Map<Id, Event> mapNewEvent, Map<Id, Event> mapOldEvent)
     {
            Set<Id> setAccountIds = new Set<Id>();// Event's What Id
            Set<Id> setContactIds = new Set<Id>();// Event's Who Id
            Map<Id, Event> mapEventsToUpdate = new  Map<Id, Event>();//To store Events where Related To field should be updated
            Map<Id, Account> mapIdPersonAccount         = new Map<Id, Account>(); // Map of Id to Person Account
            Map<Id, Contact> mapIdPersonContact         = new Map<Id, Contact>();// Map of Id to Person Contact
            Map<Id, String> mapContactIdPersonAccountId = new Map<Id, String>();// Map of Contact Id to person Account Id

            for(Event objEvent : mapNewEvent.values())
            {
                    if(objEvent.WhatId != null && String.valueOf(objEvent.WhatId).startsWith('001') )
                        setAccountIds.add(objEvent.WhatId); 
                    if(objEvent.WhoId != null && String.valueOf(objEvent.WhoId).startsWith('003') )
                        setContactIds.add(objEvent.WhoId);  
            }

             //Querying Person Contact which is WhoId for inserted/updated event
            if(!setContactIds.isEmpty())
            for(Contact objContact : [Select Id, Name, AccountId FROM Contact WHERE Id In :setContactIds and Account.IsPersonAccount = true])
            {
                mapIdPersonContact.put(objContact.Id, objContact);
                mapContactIdPersonAccountId.put(objContact.Id, objContact.AccountId);
            }

        //Querying Account which is WhatId for inserted/updated event or a Person Account for Contact which is WhoId for inserted/updated event
        if(!mapContactIdPersonAccountId.isEmpty())
            mapIdPersonAccount.putAll([Select Id, Name, IsPersonAccount, Primary_Relationship_Group__c, Last_Contact_Date__c, Last_Meeting_Date__c FROM Account 
                                    WHERE (Id In :setAccountIds OR Id In: mapContactIdPersonAccountId.values()) ]);// AND IsPersonAccount = true

             if(!mapContactIdPersonAccountId.isEmpty())

            ///Create maps to update WhatId  and date fields
            for(Event objEvent : mapNewEvent.values())
            {

                //Forming map of Task and Account records to update
                if(objEvent.WhoId != null  
                &&(( mapContactIdPersonAccountId.containsKey(objEvent.WhoId) && ( objEvent.WhatId != null && mapIdPersonAccount.containsKey(objEvent.WhatId)) && mapContactIdPersonAccountId.get(objEvent.WhoId) == objEvent.WhatId ) || 
                    mapIdPersonAccount.containsKey(objEvent.WhatId)  ||
                (objEvent.WhatId == null  || ( mapContactIdPersonAccountId.containsKey(objEvent.WhoId) &&  mapIdPersonAccount.containsKey(mapContactIdPersonAccountId.get(objEvent.WhoId)) && objEvent.WhatId == mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objEvent.WhoId)).Primary_Relationship_Group__c)) )) 
                {
                    if( mapContactIdPersonAccountId.containsKey(objEvent.WhoId) && 
                    mapIdPersonAccount.containsKey(mapContactIdPersonAccountId.get(objEvent.WhoId)) 
                    && mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objEvent.WhoId)).Primary_Relationship_Group__c != null
                    && (objEvent.WhatId == null || objEvent.WhatId == mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objEvent.WhoId)).Primary_Relationship_Group__c))
                    {
                        mapEventsToUpdate.put(objEvent.Id, New Event(Id= objEvent.Id, 
                                                            WhatId = mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objEvent.WhoId)).Primary_Relationship_Group__c));
                      
                    }
                    
                    else if(( mapContactIdPersonAccountId.containsKey(objEvent.WhoId) && ( objEvent.WhatId != null && mapIdPersonAccount.containsKey(objEvent.WhatId))  &&
                             mapContactIdPersonAccountId.get(objEvent.WhoId) == objEvent.WhatId ))
                    {
                       
                        if(mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objEvent.WhoId)).Primary_Relationship_Group__c != null)
                            mapEventsToUpdate.put(objEvent.Id, New Event(Id= objEvent.Id, 
                                                            WhatId = mapIdPersonAccount.get(mapContactIdPersonAccountId.get(objEvent.WhoId)).Primary_Relationship_Group__c));

                    }
              }
        }

        if(!mapEventsToUpdate.isEmpty())
            Database.update(mapEventsToUpdate.values(), false);
        }
}