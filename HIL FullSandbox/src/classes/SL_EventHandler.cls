/**
* @ClassName    	: SL_TaskHandler
* @JIRATicket   	: HIL-1,HIL-10
* @CreatedOn    	: 9/April/ 2014
* @LastModifiedOn   : 9/APR/ 2015
* @CreatedBy		: Sruti
* @ModifiedBy   	: Pankaj Ganwani
* @Description  	: This is the handler class for Event trigger. Updates date field on Account and Group member records
*/ 

public without sharing class SL_EventHandler
{
    /* start - global variables*/
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private static Set<Id> setUserId = new Set<Id>(new Map<Id,User>([SELECT Id FROM User WHERE Alias IN ('scrm','infa')]).keyset());// This set is used to hold the User ids for whom we are not supposed to create Note records
    /* end - global variables*/

    //Constructor of a Handler Class
    public SL_EventHandler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    //class to hold the group member id and relationship group id corresponding to AccountId of inserted Task
    //private class GroupMemberWrapper
    //{
    //    private Id groupMemberId;
    //    private Id relationshipGroupId;
        
    //    private GroupMemberWrapper(Id groupMemberId, Id relationshipGroupId)
    //    {
    //        this.groupMemberId = groupMemberId;
    //        this.relationshipGroupId = relationshipGroupId;
    //    }
    //}
    
    // This function will be called on OnAfterInsert of Event record.
    public void onAfterInsert(Map<Id, Event> mapNewEvent)
    {
        //Updating Activities
        updateEvents(mapNewEvent, null);
        createNoteAndNoteJoiner(mapNewEvent);
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
        
         //Function to create Note and corresponding Note joiner records when new event is inserted.
    private void createNoteAndNoteJoiner(Map<Id, Event> mapNewEvent)
    {
        List<Note__c> lstNote = new List<Note__c>();// list to hold the note records that need to be inserted.
        List<Note_Joiner__c> lstNoteJoiner = new List<Note_Joiner__c>();// list to hold note joiner record corresponding to the inserted note records.
        /*Set<Id> setEventId = new Set<Id>();//set to hold events that we are going to delete.
        Set<Id> setOwnerId = new Set<Id>();
        Set<Id> setAccountId = new Set<Id>();
        Set<Id> setRepCodeId = new Set<Id>();
        Map<Id, List<GroupMemberWrapper>> mapAccIdToLstOfGMW = new Map<Id, List<GroupMemberWrapper>>();*/
        
        for(Event objEvent : mapNewEvent.values())
        {
            if(!setUserId.contains(objEvent.OwnerId))
            {
	            lstNote.add(new Note__c(Account_Del__c = (objEvent.WhatId!=null && objEvent.WhatId.getSobjectType() == Account.getSobjectType() ? objEvent.WhatId : null),
                                        CallObject__c = objEvent.WhatId,
                                        Relationship_Group__c = (objEvent.WhatId!=null && objEvent.WhatId.getSobjectType() == Relationship_Group__c.getSobjectType() ? objEvent.WhatId : null),
	                                    Description__c = objEvent.Description, ActivityDate__c = objEvent.ActivityDate,
	                                    Count_Towards_SLA__c = objEvent.Count_Towards_SLA__c, Import_ID__c = objEvent.Import_ID__c, Import_Text__c = objEvent.Import_Text__c,
	                                    Subject__c = objEvent.Subject, Subject_Text__c = objEvent.Subject,
	                                    Type__c = objEvent.Type, RecurrenceInstance__c = objEvent.RecurrenceInstance, RecurrenceMonthOfYear__c = objEvent.RecurrenceMonthOfYear,
	                                    RecurrenceTimeZoneSidKey__c = objEvent.RecurrenceTimeZoneSidKey, RecurrenceType__c = objEvent.RecurrenceType, OwnerId = objEvent.OwnerId,
	                                    ReminderDateTime__c = objEvent.ReminderDateTime, RecurrenceEndDateOnly__c = objEvent.RecurrenceEndDateOnly));
	            
	            /*setOwnerId.add(objEvent.OwnerId);
	            
	            if(objEvent.AccountId!=null)
	                setAccountId.add(objEvent.AccountId);
	                
	            if(objEvent.Type == 'Other')
	            	setEventId.add(objEvent.Id);*/
            }
        }
        
        
        if(!lstNote.isEmpty())
            insert lstNote;
        
        //fetching rep codes corresponding to the task owners
        /*for(Rep_Code_User__c objRCU : [SELECT Rep_Code__c FROM Rep_Code_User__c WHERE User__c IN : setOwnerId])
        {
            setRepCodeId.add(objRCU.Rep_Code__c);
        }
        
        
        //fetching related group member records
        for(Group_Member__c objGM : [SELECT Id, Client_Prospect__c, Relationship_Group__c FROM Group_Member__c WHERE Client_Prospect__c IN : setAccountId AND Relationship_Group__r.Rep_Code__c IN : setRepCodeId])
        {
            if(!mapAccIdToLstOfGMW.containskey(objGM.Client_Prospect__c))
                mapAccIdToLstOfGMW.put(objGM.Client_Prospect__c, new List<GroupMemberWrapper>{new GroupMemberWrapper(objGM.Id,objGM.Relationship_Group__c)});
            else 
                mapAccIdToLstOfGMW.get(objGM.Client_Prospect__c).add(new GroupMemberWrapper(objGM.Id,objGM.Relationship_Group__c));
        }
        
        //Iterating over note object to create corresponding note joiner records
        for(Note__c objNote : lstNote)
        {
            if(objNote.Account_Del__c!=null)
            {
                if(mapAccIdToLstOfGMW.containskey(objNote.Account_Del__c))
                {
                    for(GroupMemberWrapper objGMW : mapAccIdToLstOfGMW.get(objNote.Account_Del__c))
                    {
                        lstNoteJoiner.add(new Note_Joiner__c(Client_Prospect__c = objNote.Account_Del__c, Group_Member__c = objGMW.groupMemberId, Relationship_Group__c = objGMW.relationshipGroupId, Note__c = objNote.Id));
                    }
                }
                else
                {
                    lstNoteJoiner.add(new Note_Joiner__c(Client_Prospect__c = objNote.Account_Del__c, Note__c = objNote.Id, Relationship_Group__c = objNote.Relationship_Group__c));
                }
            }
            else if(objNote.Relationship_Group__c!=null)
            {
                lstNoteJoiner.add(new Note_Joiner__c(Relationship_Group__c = objNote.Relationship_Group__c, Note__c = objNote.Id));
            }
        }*/
        
        if(!lstNoteJoiner.isEmpty())
            insert lstNoteJoiner;
        //if(!setEventId.isEmpty())
        	//SL_EventHandler.deleteEvents(setEventId);
    }
    //Method to delete the events in an asynchronous manner
    //@future
    //private static void deleteEvents(Set<Id> setEventId)
    //{
    	//delete [SELECT Id FROM Event WHERE Id IN:setEventId];
    //}
}