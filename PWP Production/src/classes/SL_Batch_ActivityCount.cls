/**
* \arg ClassName      : SL_Batch_CreateRelationships
* \arg JIRATicket     : PWP-7
* \arg CreatedOn      : 24/DEC/2014
* \arg LastModifiedOn : 9/MAR/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This batch process is used to count total events, total tasks and total call reports corresponding to PWP employees and external contacts.
*/
global class SL_Batch_ActivityCount implements Database.Batchable<sobject> 
{
    /* START : Global variables */
    String strQuery;
    /* END : Global variables */
    
    /* Start - Constructor */
    global SL_Batch_ActivityCount(String strBatchQuery)
    {
        strQuery = strBatchQuery;        
    }
    /* End - Constructor */
    
    private class DateWrapper
    {
    	Date minDate;
    	Date maxDate;
    	
    	private DateWrapper(Date minDate, Date maxDate)
    	{
    		this.minDate = minDate;
    		this.maxDate = maxDate;
    	}
    }
    
    /*
        * MethodName   : start
        * Param        : Database.BatchableContext BC
        * Description  : This method returns Contact role records with pending status
    */
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(strQuery);
    }
    
    /*
        * MethodName   : execute
        * Param        : Database.BatchableContext BC, List<Contact_Role__c> lstContactRole
        * Description  : Processes Contact Role records returned by start method
    */
    global void execute(Database.BatchableContext BC, List<Relationship__c> lstRelationship)
    {
        Map<String, Integer> mapContactId_UsrIdToTaskCount = new Map<String, Integer>();// map to hold the count of tasks correponding to relationship record
        Map<String, Integer> mapContactId_UsrIdToEvntCount = new Map<String, Integer>();// map to hold the count of events correponding to relationship record
        Map<String, Integer> mapContactId_UsrIdToCallReportCount = new Map<String, Integer>();// map to hold the count of call reports correponding to relationship record
        Map<String, DateWrapper> mapContactId_UsrIdToDateWrapper = new Map<String, DateWrapper>(); // map to hold the values of max date and min date of activity(Event).
        Map<Id, Set<Id>> mapCRIdToSetOfContactId = new Map<Id, Set<Id>>();// map to hold the external contacts corresponding to call reports
        Map<Id, Set<Id>> mapCRIdToSetOfUserId = new Map<Id, Set<Id>>();// map to hold the pwp employees corresponding to call reports
        Set<Id> setPWPEmployee = new Set<Id>();//set to hold the values of pwp employees i.e. users
        Set<Id> setExternalContact = new Set<Id>();//set to hold the Id of contacts
        Set<String> setExternalContact_PWPEmployee = new Set<String>();// set to hold the combination of external contact and pwp employee.
        
        List<Relationship__c> LstRelationshipToUpdate = new List<Relationship__c>();//list to update relationship records
		
		//Iterating over relationship object to hold the values of pwp employees and external contact.
        for(Relationship__c objRelationship : lstRelationship)
        {            
            setPWPEmployee.add(objRelationship.PWP_Employee__c);
            setExternalContact.add(objRelationship.External_Contact__c);
            setExternalContact_PWPEmployee.add(objRelationship.External_Contact__c+'_'+objRelationship.PWP_Employee__c);
        }
        
        //fetching count of number of tasks corresponding to the pwp employee and related contact
        for(AggregateResult objTaskCount : [SELECT COUNT(Id) totaltask, RelationId, Task.OwnerId ownerId FROM TaskRelation WHERE Task.OwnerId IN: setPWPEmployee AND RelationId IN: setExternalContact GROUP BY RelationId, Task.OwnerId])
        {            
           mapContactId_UsrIdToTaskCount.put(objTaskCount.get('RelationId') +'_'+ objTaskCount.get('ownerId'), Integer.valueOf(objTaskCount.get('totaltask')));            
        } 
        
        //fetching count of number of event corresponding to the pwp employee and related contact 
        for(AggregateResult objEventCount : [SELECT COUNT(Id) totalEvent, MIN(Event.ActivityDateTime) mindate, MAX(Event.ActivityDateTime) maxdate, RelationId, Event.OwnerId ownerId FROM EventRelation WHERE Event.OwnerId IN: setPWPEmployee AND RelationId IN: setExternalContact GROUP BY RelationId, Event.OwnerId])
        {
            mapContactId_UsrIdToEvntCount.put(objEventCount.get('RelationId') +'_'+ objEventCount.get('ownerId'), Integer.valueOf(objEventCount.get('totalEvent')));
            mapContactId_UsrIdToDateWrapper.put(objEventCount.get('RelationId') +'_'+ objEventCount.get('ownerId'), new DateWrapper(objEventCount.get('mindate')!=null ? ((DateTime)objEventCount.get('mindate')).date() : null, objEventCount.get('maxdate')!=null ? ((DateTime)objEventCount.get('maxdate')).date() : null));
        } 
                
        //fetching all contacts and their related attendees which are related to the relationship records
        for(Call_Report_Attendees__c objCRAttendee : [SELECT Call_Report_Attendee__c, Call_Report_Attendee__r.User__c, Call_Report__c FROM Call_Report_Attendees__c WHERE Call_Report_Attendee__c IN : setExternalContact OR (Call_Report_Attendee__r.User__c IN :setPWPEmployee AND Call_Report_Attendee__r.RecordType.DeveloperName = 'PWP_Employee')])
        {
        	if(!mapCRIdToSetOfContactId.containskey(objCRAttendee.Call_Report__c))
        		mapCRIdToSetOfContactId.put(objCRAttendee.Call_Report__c, new Set<Id>{objCRAttendee.Call_Report_Attendee__c});
        	else
        		mapCRIdToSetOfContactId.get(objCRAttendee.Call_Report__c).add(objCRAttendee.Call_Report_Attendee__c);
        		
        	if(objCRAttendee.Call_Report_Attendee__r.User__c!=null)
        	{
        		if(!mapCRIdToSetOfUserId.containskey(objCRAttendee.Call_Report__c))
        			mapCRIdToSetOfUserId.put(objCRAttendee.Call_Report__c, new Set<Id>{objCRAttendee.Call_Report_Attendee__r.User__c});
        		else
        			mapCRIdToSetOfUserId.get(objCRAttendee.Call_Report__c).add(objCRAttendee.Call_Report_Attendee__r.User__c);
        	}
        }
        
        //iterating on relationship object records to count the call reports corresponding the pwp employee and external contact.
        for(Relationship__c objRshp : lstRelationship)
        {
        	for(Id callReportId : mapCRIdToSetOfContactId.keyset())
        	{
        		String strExternalContact_PWPEmployee = objRshp.External_Contact__c+'_'+ objRshp.PWP_Employee__c;
        		if(mapCRIdToSetOfContactId.get(callReportId).contains(objRshp.External_Contact__c) && mapCRIdToSetOfUserId.containskey(callReportId) && mapCRIdToSetOfUserId.get(callReportId).contains(objRshp.PWP_Employee__c))
        		{
        			if(!mapContactId_UsrIdToCallReportCount.containskey(strExternalContact_PWPEmployee))
        				mapContactId_UsrIdToCallReportCount.put(strExternalContact_PWPEmployee,1);
        			else
        				mapContactId_UsrIdToCallReportCount.put(strExternalContact_PWPEmployee,mapContactId_UsrIdToCallReportCount.get(strExternalContact_PWPEmployee)+1);
        		}        			
        	}
        }
        
        //Iterating over relationship object to update the records
        for(Relationship__c objRshp : lstRelationship)
        {
            String strExternalContact_PWPEmployee = objRshp.External_Contact__c+'_'+ objRshp.PWP_Employee__c;
            if(mapContactId_UsrIdToDateWrapper.containskey(strExternalContact_PWPEmployee))
            {
            	DateWrapper objDateWrapper = mapContactId_UsrIdToDateWrapper.get(strExternalContact_PWPEmployee);
            	LstRelationshipToUpdate.add(new Relationship__c(Id = objRshp.Id, Event_Count__c = mapContactId_UsrIdToEvntCount.containskey(strExternalContact_PWPEmployee) && setExternalContact_PWPEmployee.contains(strExternalContact_PWPEmployee) ?  mapContactId_UsrIdToEvntCount.get(strExternalContact_PWPEmployee) : null, 
	                                                            Count_Task__c = mapContactId_UsrIdToTaskCount.containskey(strExternalContact_PWPEmployee) && setExternalContact_PWPEmployee.contains(strExternalContact_PWPEmployee) ? mapContactId_UsrIdToTaskCount.get(strExternalContact_PWPEmployee) : null,
	                                                            Call_Report_Count__c = mapContactId_UsrIdToCallReportCount.containskey(strExternalContact_PWPEmployee) && setExternalContact_PWPEmployee.contains(strExternalContact_PWPEmployee) ? mapContactId_UsrIdToCallReportCount.get(strExternalContact_PWPEmployee) : null,
	                                                            Last_Meeting_Date__c = objDateWrapper.minDate, Next_Meeting_Date__c = objDateWrapper.maxDate));
            }
            else if(setExternalContact_PWPEmployee.contains(strExternalContact_PWPEmployee))
            {
            	LstRelationshipToUpdate.add(new Relationship__c(Id = objRshp.Id, Last_Meeting_Date__c = null, Next_Meeting_Date__c = null,Event_Count__c = mapContactId_UsrIdToEvntCount.containskey(strExternalContact_PWPEmployee) && setExternalContact_PWPEmployee.contains(strExternalContact_PWPEmployee) ?  mapContactId_UsrIdToEvntCount.get(strExternalContact_PWPEmployee) : null, 
	                                                            Count_Task__c = mapContactId_UsrIdToTaskCount.containskey(strExternalContact_PWPEmployee) && setExternalContact_PWPEmployee.contains(strExternalContact_PWPEmployee) ? mapContactId_UsrIdToTaskCount.get(strExternalContact_PWPEmployee) : null,
	                                                            Call_Report_Count__c = mapContactId_UsrIdToCallReportCount.containskey(strExternalContact_PWPEmployee) && setExternalContact_PWPEmployee.contains(strExternalContact_PWPEmployee) ? mapContactId_UsrIdToCallReportCount.get(strExternalContact_PWPEmployee) : null));
            }
            else
            {
            	LstRelationshipToUpdate.add(new Relationship__c(Id = objRshp.Id, Event_Count__c = mapContactId_UsrIdToEvntCount.containskey(strExternalContact_PWPEmployee) && setExternalContact_PWPEmployee.contains(strExternalContact_PWPEmployee) ?  mapContactId_UsrIdToEvntCount.get(strExternalContact_PWPEmployee) : null, 
	                                                            Count_Task__c = mapContactId_UsrIdToTaskCount.containskey(strExternalContact_PWPEmployee) && setExternalContact_PWPEmployee.contains(strExternalContact_PWPEmployee) ? mapContactId_UsrIdToTaskCount.get(strExternalContact_PWPEmployee) : null,
	                                                            Call_Report_Count__c = mapContactId_UsrIdToCallReportCount.containskey(strExternalContact_PWPEmployee) && setExternalContact_PWPEmployee.contains(strExternalContact_PWPEmployee) ? mapContactId_UsrIdToCallReportCount.get(strExternalContact_PWPEmployee) : null));
            }
            
        }
        
        if(!LstRelationshipToUpdate.isEmpty())
        	update LstRelationshipToUpdate;//dml to update the records
    }

    /*
        * MethodName   : finish
        * Param        : Database.BatchableContext BC
        * Description  : Performs necessary post-execution steps
    */
    global void finish(Database.BatchableContext BC)
    {
        //Do Nothing
    }     
}