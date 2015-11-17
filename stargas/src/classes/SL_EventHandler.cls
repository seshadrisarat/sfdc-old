/**
*  ClassName      : SL_Event_Handler
*  JIRATicket     : STARGAS-6
*  CreatedOn      : 15/MAY/2014
*  CreatedBy      : Pankaj Ganwani
*  Description    : Handler class to update the opportunity Event related fields with most recent inserted Event record. 
*/
public with sharing class SL_EventHandler 
{
    /* Start - Constructor */
    public SL_EventHandler()
    {
        //Do Nothing
    }
    /* End - Constructor */
    
    /*
    * MethodName        : onBeforeInsert
    * param             : List of Event records
    * Description       : This function will be called on before insert of the trigger.
    */
    public void onBeforeInsert(List<Event> lstEvent)
    {
        //Calling function to update the subject and duration
        updateEventStatus(lstEvent, new Map<Id,Event>(), 'Insert');
    }
    
    /*
    * MethodName        : onAfterInsert
    * param             : Map of Event records
    * Description       : This function will be called on after insert of Event record.
    */
    public void onAfterInsert(Map<Id,Event> mapIdToEvent)
    {
        Set<Id> setWhatId = new Set<Id>();// set to contain those What ids which belongs to Opportunity and meeting type is 'Customer Appointment'.
        //Iterating over map of Event to fill the What id where type is Opportunity
        for(Event objEvent : mapIdToEvent.values())
        {
            //Checking if Event is related to Opportunity
            if(objEvent.WhatId!=null && String.valueOf(objEvent.WhatId).substring(0,3) == '006' && objEvent.Meeting_Type__c == 'Customer Appointment')
            {
                setWhatId.add(objEvent.WhatId);
            }
        }
        if(!setWhatId.isEmpty())
            updateOpportunityRecords(setWhatId);//Calling function
    }
    
    /*
    * MethodName        : onAfterDelete
    * param             : list of Event records
    * Description       : This function will be called on after delete of Event record.
    */
    public void onAfterDelete(List<Event> lstEvent)
    {
        Set<Id> setWhatId = new Set<Id>();
        
        //Iterating over Event object to fill the set with What Ids
        for(Event objEvent : lstEvent)
        {
            //Checking if Event is related to Opportunity
            if(objEvent.WhatId!=null && String.valueOf(objEvent.WhatId).substring(0,3) == '006' && objEvent.Meeting_Type__c == 'Customer Appointment')
            {
                setWhatId.add(objEvent.WhatId);
            }
        }
        if(!setWhatId.isEmpty())
            updateOpportunityRecords(setWhatId);//Calling function to update the related opportunity
    }


    public void onBeforeUpdate(Map<Id,Event> oldMap, Map<Id,Event> newMap) 
    {
        //CT - if the start datetime or end datetime has changed, change the
        for(Event evt : newMap.values()) 
        {
            if(evt.StartDateTime != null && evt.StartDateTime != oldMap.get(evt.id).StartDateTime && evt.Meeting_Type__c == 'Customer Appointment' && evt.Appointment_Status__c!='Canceled')
                evt.Appointment_Status__c = 'Rescheduled';
        }
        
        //Calling function to update the subject and duration
        updateEventStatus(newMap.values(),oldMap,'Update');
    }
    
    /*
    * MethodName        : onAfterUpdate
    * param             : old and new map of Id to Event records
    * Description       : This function will be called on after update of Event record.
    */
    public void onAfterUpdate(Map<Id,Event> mapOldIdToEvent, Map<Id,Event> mapNewIdToEvent)
    {
        Set<Id> setWhatId = new Set<Id>();
        //Iterating over Event object to compare old map with new map
        for(Event objEvent : mapNewIdToEvent.values())
        {
            if((objEvent.Appointment_Cancel_Reason__c != mapOldIdToEvent.get(objEvent.Id).Appointment_Cancel_Reason__c
               || objEvent.WhatId!=mapOldIdToEvent.get(objEvent.Id).WhatId
               || objEvent.OwnerId!=mapOldIdToEvent.get(objEvent.Id).OwnerId
               || objEvent.CreatedById!=mapOldIdToEvent.get(objEvent.Id).CreatedById
               || objEvent.ActivityDate!=mapOldIdToEvent.get(objEvent.Id).ActivityDate
               || objEvent.EndDateTime!=mapOldIdToEvent.get(objEvent.Id).EndDateTime
               || objEvent.StartDateTime!=mapOldIdToEvent.get(objEvent.Id).StartDateTime
               || objEvent.Subject!=mapOldIdToEvent.get(objEvent.Id).Subject
               || objEvent.Comments__c!=mapOldIdToEvent.get(objEvent.Id).Comments__c
               || objEvent.Appointment_Status__c!=mapOldIdToEvent.get(objEvent.Id).Appointment_Status__c
               || objEvent.Meeting_Type__c!=mapOldIdToEvent.get(objEvent.Id).Meeting_Type__c
               || objEvent.Appointment_Reschedule_Reason__c!=mapOldIdToEvent.get(objEvent.Id).Appointment_Reschedule_Reason__c)
               )
            {
                //Checking if new map object record belongs to Opportunity and meeting type is 'Customer Appointment'
                if(objEvent.WhatId!=null && String.valueOf(objEvent.WhatId).substring(0,3) == '006' && objEvent.Meeting_Type__c == 'Customer Appointment')
                    setWhatId.add(objEvent.WhatId);
                //If the whatid is changed from Opportunity to any other object then collecting that value to set so that we can get 
                //next most recent event record by passing to function
                if(mapOldIdToEvent.get(objEvent.Id).WhatId!=null && String.valueOf(mapOldIdToEvent.get(objEvent.Id).WhatId).substring(0,3) == '006'
                    && mapOldIdToEvent.get(objEvent.Id).Meeting_Type__c == 'Customer Appointment')
                    setWhatId.add(mapOldIdToEvent.get(objEvent.Id).WhatId);
            }
        }
        //Checking if set is not empty
        if(!setWhatId.isEmpty())
            updateOpportunityRecords(setWhatId);
    }
    
    /*
    * MethodName        : updateOpportunityRecords
    * param             : Set of Opportunity Ids
    * Description       : This function will update the corresponding Opportunity record of Event with most recent inserted record.
    */
    private void updateOpportunityRecords(Set<Id> setOpportunityId)
    {
        Map<Id,Event> mapOpportunityIdToEvent = new Map<Id,Event>();// map to get Opportunity id and its corresponding most recently inserted Event
        List<Opportunity> lstOpportunity = new List<Opportunity>();// list of Opportunity records that needs to be updated
        
        //Iterating over Event object to fill the map with OpportunityId and its corresponding most recent inserted event
        for(Event objEvent : [SELECT OwnerId, CreatedById, ActivityDateTime, EndDateTime, StartDateTime, Subject, Comments__c,
                                     Appointment_Status__c, Meeting_Type__c, Appointment_Cancel_Reason__c, WhatId,
                                     Appointment_Reschedule_Reason__c
                              FROM  Event 
                              WHERE WhatId IN : setOpportunityId AND Meeting_Type__c = 'Customer Appointment'
                              ORDER BY CreatedDate])
         {
            mapOpportunityIdToEvent.put(objEvent.WhatId, objEvent);
         }
         
        //Iterating over opportunity object to apply field mappings
         for(Opportunity objOpportunity : [SELECT Id, Appointment_Assigned_To__c, Appointment_Cancel_Reason__c, Appointment_Comments__c,
                                                   Appointment_Created_By__c, Appointment_Date__c, Appointment_End_Time__c, Appointment_Meeting_Type__c,
                                                   Appointment_Reschedule_Reason__c, Appointment_Start_Time__c, Appointment_Status__c, Appointment_Subject__c
                                           FROM    Opportunity
                                           WHERE   ID IN:mapOpportunityIdToEvent.keyset()])
         {
            //Checking if map contains the Opportunity or not
            if(mapOpportunityIdToEvent.containskey(objOpportunity.Id) && mapOpportunityIdToEvent.get(objOpportunity.Id)!=null)
            {
                lstOpportunity.add(new Opportunity(Id = objOpportunity.Id,
                                                   Appointment_Assigned_To__c = mapOpportunityIdToEvent.get(objOpportunity.Id).OwnerId,
                                                   Appointment_Cancel_Reason__c = mapOpportunityIdToEvent.get(objOpportunity.Id).Appointment_Cancel_Reason__c,
                                                   Appointment_Comments__c = mapOpportunityIdToEvent.get(objOpportunity.Id).Comments__c,
                                                   Appointment_Created_By__c = mapOpportunityIdToEvent.get(objOpportunity.Id).CreatedById,
                                                   Appointment_Date__c = mapOpportunityIdToEvent.get(objOpportunity.Id).ActivityDateTime,
                                                   Appointment_End_Time__c = mapOpportunityIdToEvent.get(objOpportunity.Id).EndDateTime,
                                                   Appointment_Meeting_Type__c = mapOpportunityIdToEvent.get(objOpportunity.Id).Meeting_Type__c,
                                                   Appointment_Reschedule_Reason__c = mapOpportunityIdToEvent.get(objOpportunity.Id).Appointment_Reschedule_Reason__c,
                                                   Appointment_Start_Time__c = mapOpportunityIdToEvent.get(objOpportunity.Id).StartDateTime,
                                                   Appointment_Status__c = mapOpportunityIdToEvent.get(objOpportunity.Id).Appointment_Status__c,
                                                   Appointment_Subject__c = mapOpportunityIdToEvent.get(objOpportunity.Id).Subject));
            }
         }
        //Iterating over set of opportunity ids to fill the null if there is no event exist corresponding to the Opportunity
        for(Id OpportunityId : setOpportunityId)
        {
            //Checking if map contains key or not
            if(!mapOpportunityIdToEvent.containskey(OpportunityId))
            {
                lstOpportunity.add(new Opportunity(Id = OpportunityId,
                                                   Appointment_Assigned_To__c = null,
                                                   Appointment_Cancel_Reason__c = null,
                                                   Appointment_Comments__c = null,
                                                   Appointment_Created_By__c = null,
                                                   Appointment_Date__c = null,
                                                   Appointment_End_Time__c = null,
                                                   Appointment_Meeting_Type__c = null,
                                                   Appointment_Reschedule_Reason__c = null,
                                                   Appointment_Start_Time__c = null,
                                                   Appointment_Status__c = null,
                                                   Appointment_Subject__c = null));
            }
        }
        //Checking if list is not empty
        if(!lstOpportunity.isEmpty())
            update lstOpportunity;
    }
    
    /*
    * MethodName        : updateEventStatus
    * param             : list of new, old map of event records and event name
    * Description       : This function will sets the event subject to CANCELED if event appointment status is set to canceled
    */
    private void updateEventStatus(List<Event> lstEvent, Map<Id,Event> mapOldIdToEvent, String strEvent)
    {
        //Iterating over Event to update the subject and duratioinminutes field
        for(Event objEvent : lstEvent)
        {
            //checking if appointment status is canceled
            if((strEvent == 'Insert' || (strEvent == 'Update' && objEvent.Appointment_Status__c!= mapOldIdToEvent.get(objEvent.Id).Appointment_Status__c)) 
                                     && objEvent.Appointment_Status__c == 'Canceled')
             {
                if(objEvent.Subject!=null)
                    objEvent.Subject = 'CANCELED ' + objEvent.Subject;
                objEvent.IsAllDayEvent = true;
                objEvent.DurationInMinutes = 1440;
             }
        }
    }
}