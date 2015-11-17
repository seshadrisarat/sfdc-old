/**
 * \author Vika Osmak 
 * \date 03/12/12
 * \see https://silverline.jira.com/browse/MBS-2
 * \brief Senior Banker Scorecard Report (Summary and Detail Sections) 
 */
public with sharing class SL_BankerActivityStatement_Report 
{
    //public Id curEmployeeProfileId {get;set;} // RPT_BANKER Id - is the Record id for the banker selected
    //public Employee_Profile__c curEmployeeProfile {get; private set;} // RPT_BANKER
    public list<curEmployee> listSBS_Reports {get; private set;}
    
    public String filter {get; private set;}
    public list<String> subFilters {get; private set;}
    //RPT_START_DATE, RPT_END_DATE Parameters -> date range for filtering records for report
    public Date curStartDate {get; private set;} //RPT_START_DATE
    public Date curEndDate {get; private set;} //RPT_END_DATE
    public String DebugInfo {get; private set;} //RPT_END_DATE
    
    private map<Id,Employee_Profile__c> mapEmployeeId_Employee;
    private set<String> listMDSCTitles;
    private set<String> listExcludeGroups;
    
    public SL_BankerActivityStatement_Report()
    {
        DebugInfo = 'DebugInfo : ';
        
        if(ApexPages.currentPage().getParameters().get('filter') != null && ApexPages.currentPage().getParameters().get('filter') != '')
            this.filter = ApexPages.currentPage().getParameters().get('filter');
        //system.debug('subfilters = '+ApexPages.currentPage().getParameters().get('subfilters'));
        this.subFilters = new list<String>();
        if(ApexPages.currentPage().getParameters().get('subfilters') != null && ApexPages.currentPage().getParameters().get('subfilters') != '')
        {
            if(ApexPages.currentPage().getParameters().get('subfilters').contains(';'))
            {
                this.subFilters = ApexPages.currentPage().getParameters().get('subfilters').split(';');
            }
            else this.subFilters.add(ApexPages.currentPage().getParameters().get('subfilters'));
        }
        //system.debug('this.subFilters = '+this.subFilters);
        if(ApexPages.currentPage().getParameters().get('sdate') != null && ApexPages.currentPage().getParameters().get('sdate') != '')
            this.curStartDate  = Date.valueOf(ApexPages.currentPage().getParameters().get('sdate'));
        if(ApexPages.currentPage().getParameters().get('edate') != null && ApexPages.currentPage().getParameters().get('edate') != '')
            this.curEndDate  = Date.valueOf(ApexPages.currentPage().getParameters().get('edate'));
        //system.debug('curStartDate = '+curStartDate+ 'curEndDate = '+curEndDate);
        
        mapEmployeeId_Employee = new map<Id,Employee_Profile__c>();
        listSBS_Reports = new list<curEmployee>();
        
        this.getEmployeeOrderedList();
        
            
        if(listSBS_Reports.size() > 0)
        {
            list<AggregateResult> groupedResults;
            Integer countEvents;
            Integer countCallLogs;
            Integer countEventsMD;
            Integer countCallLogsMD;
            Integer countMDBankers;
            
            String strAttendees = '';
            Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
            String AccountPrefix = R.getKeyPrefix();
            R = User.SObjectType.getDescribe();
            String UserPrefix = R.getKeyPrefix();
            
            

            
            map<Id,Id> mapEmployeeId_UserId = new map<Id,Id>();
            map<Id,String> mapEmployeeId_Title = new map<Id,String>();
            map<String,set<Id>> mapEmployeeTitle_setUserIds = new map<String,set<Id>>();
            if(mapEmployeeId_Employee.keySet().size() > 0)
            {
                for(Id eId : mapEmployeeId_Employee.keySet())
                {
                    if(mapEmployeeId_Employee.get(eId).User_ID__c != null)
                            mapEmployeeId_UserId.put(eId,mapEmployeeId_Employee.get(eId).User_ID__c);
                    if(mapEmployeeId_Employee.get(eId).Title__c != null)
                            mapEmployeeId_Title.put(eId,mapEmployeeId_Employee.get(eId).Title__c);
                    if(mapEmployeeId_Employee.get(eId).Title__c != null && mapEmployeeId_Employee.get(eId).User_ID__c != null)
                    {
                        if(!mapEmployeeTitle_setUserIds.keySet().contains(mapEmployeeId_Employee.get(eId).Title__c))     mapEmployeeTitle_setUserIds.put(mapEmployeeId_Employee.get(eId).Title__c, new set<Id>());
                        mapEmployeeTitle_setUserIds.get(mapEmployeeId_Employee.get(eId).Title__c).add(mapEmployeeId_Employee.get(eId).User_ID__c);
                    }
                }
            }
           
            map<String,Set<Id>> mapSBankerTitle_setSBankerIds = new map<String,Set<Id>>(); // SeniorBankerTitle -> all Bankers with SeniorBankerTitle
            map<String,Set<Id>> mapSBankerTitle_setSBankerUserIds = new map<String,Set<Id>>(); // SeniorBankerTitle ->UserIds for all Bankers with SeniorBankerTitle
            map<String,Integer> mapSBankerTitle_countSBankers = new map<String,Integer>(); // SeniorBankerTitle -> count (all Bankers with SeniorBankerTitle)
            if(mapEmployeeId_Title.values().size() > 0)
            {
                for(Employee_Profile__c item : [SELECT Id,Title__c,User_ID__c 
                								FROM Employee_Profile__c 
                								WHERE 	Title__c IN : mapEmployeeId_Title.values() AND
                										/*MBS-52*/
                										Status__c = 'Active' AND 
		                								Business_Type__c = 'Advisory' AND
														Group__c NOT IN :listExcludeGroups  ])
                {
                    if(!mapSBankerTitle_setSBankerIds.keySet().contains(item.Title__c)) mapSBankerTitle_setSBankerIds.put(item.Title__c, new Set<Id>());
                    mapSBankerTitle_setSBankerIds.get(item.Title__c).add(item.Id);
                    
                    if(!mapSBankerTitle_setSBankerUserIds.keySet().contains(item.Title__c)) mapSBankerTitle_setSBankerUserIds.put(item.Title__c, new Set<Id>());
                    mapSBankerTitle_setSBankerUserIds.get(item.Title__c).add(item.User_ID__c);
                    //for avarage calculations
                    if(!mapSBankerTitle_countSBankers.keySet().contains(item.Title__c)) mapSBankerTitle_countSBankers.put(item.Title__c, 0);
                    mapSBankerTitle_countSBankers.put(item.Title__c, mapSBankerTitle_countSBankers.get(item.Title__c) + 1);
                }
                system.debug('mapSBankerTitle_setSBankerIds = '+mapSBankerTitle_setSBankerIds);
                system.debug('mapSBankerTitle_setSBankerUserIds = '+mapSBankerTitle_setSBankerUserIds);
                system.debug('mapSBankerTitle_countSBankers = '+mapSBankerTitle_countSBankers);
            }
            
            
                
            
            //New Business Meetings Calls (Banker – Current Period)
            map<Id,Set<Id>> mapEmployeeId_setEventIds = new map<Id,Set<Id>>();
            map<Id,Integer> mapEmployeeId_countEvents = new map<Id,Integer>();
            
            //map<Id,Set<Id>> mapUserId_setEventIds = new map<Id,Set<Id>>(); //RPT_BANKER_USERID is an “Event Invitee”
            //list<Id> listEventIds = new list<Id>(); // all EventIds where RPT_BANKER_USERID is an “Event Invitee”
            
            list<Id> WhoIds = new list<Id>();
            map<Id,String> mapWhoIdTitle = new map<Id,String>();
            map<Id,String> mapWhoIdAccountName = new map<Id,String>();
            
            map<Id,Set<Id>> mapCurrentPeriod_UserId_setEventIds = new map<Id,Set<Id>>(); //RPT_BANKER_USERID is an “Event Invitee” (Event.ActivityDate >=: curStartDate  AND Event.ActivityDate <=: curEndDate)
            map<Id,Set<Id>> mapCurrentYear_UserId_setEventIds = new map<Id,Set<Id>>(); //RPT_BANKER_USERID is an “Event Invitee” (Event.ActivityDate >=: THIS_YEAR AND Event.ActivityDate <= TODAY)
            map<Id,Set<Id>> mapAfterToday_UserId_setEventIds = new map<Id,Set<Id>>(); //RPT_BANKER_USERID is an “Event Invitee” (Event.ActivityDate > TODAY)
            set<Id> listEventIdsCurrentPeriod = new set<Id>(); // all EventIds where RPT_BANKER_USERID is an “Event Invitee” Event.ActivityDate >=: THIS_YEAR AND Event.ActivityDate <= TODAY)
            set<Id> listEventIdsCurrentYear = new set<Id>(); // all EventIds where RPT_BANKER_USERID is an “Event Invitee” (Event.ActivityDate >=: curStartDate  AND Event.ActivityDate <=: curEndDate)
            set<Id> listEventIdsAfterToday = new set<Id>(); // all EventIds where RPT_BANKER_USERID is an “Event Invitee” (Event.ActivityDate > TODAY)
            
            
            Date todayDate = date.today();
            //calculation mapEmployeeId_countEvents
            if(mapEmployeeId_UserId.values().size() > 0)
            {
            	for(EventAttendee item : [
               					SELECT EventId,AttendeeId,Event.ActivityDate
                				FROM EventAttendee 
                				WHERE 	AttendeeId IN : mapEmployeeId_UserId.values() AND Status != 'Declined'])  
                {
                	if(item.Event.ActivityDate != null)
                	{
	                	if(item.Event.ActivityDate > todayDate /*MBS-42*/&& item.Event.ActivityDate <= todayDate.addMonths(1))
	                	{
		                    if(!mapAfterToday_UserId_setEventIds.keySet().contains(item.AttendeeId))    mapAfterToday_UserId_setEventIds.put(item.AttendeeId, new set<Id>());
		                    mapAfterToday_UserId_setEventIds.get(item.AttendeeId).add(item.EventId);
	                	}
	                	if(item.Event.ActivityDate >= curStartDate  && item.Event.ActivityDate <= curEndDate)
	                	{
	                		if(!mapCurrentPeriod_UserId_setEventIds.keySet().contains(item.AttendeeId))    mapCurrentPeriod_UserId_setEventIds.put(item.AttendeeId, new set<Id>());
		                    mapCurrentPeriod_UserId_setEventIds.get(item.AttendeeId).add(item.EventId);
	                	}
	                	if(item.Event.ActivityDate.year() == todayDate.year() && item.Event.ActivityDate <= todayDate)
	                	{
	                		if(!mapCurrentYear_UserId_setEventIds.keySet().contains(item.AttendeeId))    mapCurrentYear_UserId_setEventIds.put(item.AttendeeId, new set<Id>());
		                    mapCurrentYear_UserId_setEventIds.get(item.AttendeeId).add(item.EventId);
	                	}
                	}
                }
            	if(mapCurrentPeriod_UserId_setEventIds.values().size() > 0)
                {
                    for(Id uId : mapCurrentPeriod_UserId_setEventIds.keySet())
                    {
                        if(mapCurrentPeriod_UserId_setEventIds.get(uId) != null) listEventIdsCurrentPeriod.addall(mapCurrentPeriod_UserId_setEventIds.get(uId));
                    }
                }
                if(mapAfterToday_UserId_setEventIds.values().size() > 0)
                {
                    for(Id uId : mapAfterToday_UserId_setEventIds.keySet())
                    {
                        if(mapAfterToday_UserId_setEventIds.get(uId) != null) listEventIdsAfterToday.addall(mapAfterToday_UserId_setEventIds.get(uId));
                    }
                }
                if(mapCurrentYear_UserId_setEventIds.values().size() > 0)
                {
                    for(Id uId : mapCurrentYear_UserId_setEventIds.keySet())
                    {
                        if(mapCurrentYear_UserId_setEventIds.get(uId) != null) listEventIdsCurrentYear.addall(mapCurrentYear_UserId_setEventIds.get(uId));
                    }
                }
            	for(Event item :[
                                SELECT Id,WhoId
                                FROM Event 
                                WHERE   Id IN : listEventIdsCurrentPeriod OR 
                                		Id IN : listEventIdsCurrentYear OR 
                                		Id IN : listEventIdsAfterToday OR 
                                		OwnerId IN : mapEmployeeId_UserId.values()])
                {
                        WhoIds.add(item.WhoId);
                }
                if(WhoIds.size() > 0)
                {
                        for(Contact item: [SELECT ID, Title, Account.Name FROM Contact WHERE Id IN : WhoIds])     
                        {
                        	mapWhoIdTitle.put(item.Id,item.Title);
                        	mapWhoIdAccountName.put(item.Id,item.Account.Name);
                        }
                }
                
                for(Event item :[SELECT Id,OwnerId 
                                FROM Event 
                                WHERE   ActivityDate >=: curStartDate  AND ActivityDate <=: curEndDate AND IsChild = false AND
                                        OwnerId IN : mapEmployeeId_UserId.values()])
                {
                    for(Id EmployeeId : mapEmployeeId_UserId.keySet())
                    {
                        if(mapEmployeeId_UserId.get(EmployeeId) != null &&  mapEmployeeId_UserId.get(EmployeeId) == item.OwnerId)
                        {
                            if(!mapEmployeeId_setEventIds.keySet().contains(EmployeeId))     mapEmployeeId_setEventIds.put(EmployeeId, new set<Id>());
                            mapEmployeeId_setEventIds.get(EmployeeId).add(item.Id);
                        }
                    }
                }
                system.debug('1 mapEmployeeId_setEventIds = '+mapEmployeeId_setEventIds);

                if(listEventIdsCurrentPeriod.size() > 0)
                {
                    for(Event item :[SELECT Id 
                                FROM Event 
                                WHERE   ActivityDate >=: curStartDate  AND ActivityDate <=: curEndDate AND IsChild = false AND
                                        Id IN : listEventIdsCurrentPeriod ])
                    {
                        for(Id EmployeeId : mapEmployeeId_UserId.keySet())
                        {
                            if(mapEmployeeId_UserId.get(EmployeeId) != null && 
                            	mapCurrentPeriod_UserId_setEventIds.keySet().contains(mapEmployeeId_UserId.get(EmployeeId)) &&
                            	mapCurrentPeriod_UserId_setEventIds.get(mapEmployeeId_UserId.get(EmployeeId)).contains(item.Id)
                            )
                            {
                                if(!mapEmployeeId_setEventIds.keySet().contains(EmployeeId))     mapEmployeeId_setEventIds.put(EmployeeId, new set<Id>());
                                mapEmployeeId_setEventIds.get(EmployeeId).add(item.Id);
                            }
                        }
                    }
                }
                system.debug('2 mapEmployeeId_setEventIds = '+mapEmployeeId_setEventIds);
               
                if(mapEmployeeId_setEventIds.keySet().size() > 0)
                {
                    for(Id eId : mapEmployeeId_setEventIds.keySet() )
                    {
                        if(mapEmployeeId_setEventIds.get(eId) != null)  mapEmployeeId_countEvents.put(eId,mapEmployeeId_setEventIds.get(eId).size());
                    }
                }
                system.debug('mapEmployeeId_countEvents = '+mapEmployeeId_countEvents);
            }
            
            //calculation mapEmployeeId_countCallLogs
            map<Id,Set<Id>> mapEmployeeId_setCallLogIds = new map<Id,Set<Id>>();
            map<Id,Integer> mapEmployeeId_countCallLogs = new map<Id,Integer>();
            /*MBS-43
            if(mapEmployeeId_Employee.keySet().size() > 0)
            {
                for(Call_Log__c item :[SELECT Id,Organizer__c
                                FROM Call_Log__c 
                                WHERE   Date__c >=: curStartDate  AND Date__c <=: curEndDate AND 
                                        Organizer__c IN : mapEmployeeId_Employee.keySet()])
                {
                    if(!mapEmployeeId_setCallLogIds.keySet().contains(item.Organizer__c))    mapEmployeeId_setCallLogIds.put(item.Organizer__c, new set<Id>());
                    mapEmployeeId_setCallLogIds.get(item.Organizer__c).add(item.Id);
                }
                system.debug('1 mapEmployeeId_setCallLogIds = '+mapEmployeeId_setCallLogIds);
                
                for(Call_Log_Moelis_Attendee__c item : [
                	SELECT Employee__c,Call_Log__c 
                	FROM Call_Log_Moelis_Attendee__c 
                	WHERE Call_Log__r.Date__c >=: curStartDate  AND Call_Log__r.Date__c <=: curEndDate AND 
                	Employee__c IN :  mapEmployeeId_Employee.keySet()])
                {
                    if(item.Call_Log__c != null)    
                    {
                        if(!mapEmployeeId_setCallLogIds.keySet().contains(item.Employee__c))     mapEmployeeId_setCallLogIds.put(item.Employee__c, new set<Id>());
                        mapEmployeeId_setCallLogIds.get(item.Employee__c).add(item.Call_Log__c);
                    }
                }
                system.debug('2 mapEmployeeId_setCallLogIds = '+mapEmployeeId_setCallLogIds);
                if(mapEmployeeId_setCallLogIds.keySet().size() > 0)
                {
                    for(Id eId : mapEmployeeId_setCallLogIds.keySet() )
                    {
                        if(mapEmployeeId_setCallLogIds.get(eId) != null)    mapEmployeeId_countCallLogs.put(eId,mapEmployeeId_setCallLogIds.get(eId).size());
                    }
                }
                system.debug('mapEmployeeId_countCallLogs = '+mapEmployeeId_countCallLogs);
            }
            */
            
            // “Client Meetings – Current Period” Section
            //listEventIds and mapUserId_setEventIds - calculated above (New Business Meetings Calls (Banker – Current Period))
           	set<Id> setEUserIds = new set<Id>();
           	set<Id> setEmployeeUserIds = new set<Id>();
           	list<Event> curListEvents = new list<Event>();
           	//map<Id,set<Id>> mapEventId_setAttendeeIds = new map<Id,set<Id>>();
           	set<Id> setAttendeeIds = new set<Id>();
            map<Id, list<clientMeetingsCurrentPeriod>> mapEmployeeId_listClientMeetingsCurrentPeriod = new map<Id, list<clientMeetingsCurrentPeriod>>();
            if(mapEmployeeId_UserId.values().size() > 0 || listEventIdsCurrentPeriod.size() > 0)
            {
            	for(Event item :[
                                SELECT ID,Who.Title,What.Name, Who.Name, WhoId, Description, WhatId,Type, Subject,OwnerId,ActivityDate,IsChild,
                                        (Select EventId,AttendeeId,Attendee.LastName From EventAttendees WHERE Status != 'Declined')
                                FROM Event 
                                WHERE   ActivityDate >=: curStartDate  AND ActivityDate <=: curEndDate AND IsChild = false AND
                                        (Id IN : listEventIdsCurrentPeriod OR OwnerId IN : mapEmployeeId_UserId.values())
                                ORDER BY What.Name])
                {
                    if(item.EventAttendees != null && item.EventAttendees.size() > 0)
                    {
                        for (EventAttendee attendee : item.EventAttendees) 
                        {
                            if(String.valueOf(attendee.AttendeeId).substring(0,3) == UserPrefix && attendee.Attendee.LastName != null)
                                setEUserIds.add(attendee.AttendeeId);
                        }
                    }
                    curListEvents.add(item);
                }
                system.debug('1 curListEvents = '+curListEvents);
                
                
                if(setEUserIds.size() > 0)
                {
                	for(Employee_Profile__c item : [
                					SELECT Id, User_ID__c 
                					FROM Employee_Profile__c 
                					WHERE 	User_ID__c IN : setEUserIds AND 
                							/*MBS-52*/
                							Status__c = 'Active' AND 
		                					Business_Type__c = 'Advisory' AND
											Group__c NOT IN :listExcludeGroups])
                	{
                		setEmployeeUserIds.add(item.User_ID__c);
                	}
                }
                if(curListEvents.size() > 0)
                {
                	for(Event item :curListEvents)
                	{
                		strAttendees = '';
                		setAttendeeIds = new set<Id>();
	                    if(item.EventAttendees != null && item.EventAttendees.size() > 0)
                    	{
	                        for (EventAttendee attendee : item.EventAttendees)  
	                        {
	                            if(setEmployeeUserIds.contains(attendee.AttendeeId) && attendee.Attendee.LastName != null)
	                            {
	                            	setAttendeeIds.add(attendee.AttendeeId);
	                            	//if(!mapEventId_setAttendeeIds.keySet().contains(attendee.AttendeeId)) mapEventId_setAttendeeIds.put(attendee.EventId,new set<Id>());
	                            	//mapEventId_setAttendeeIds.get(attendee.EventId).add(attendee.AttendeeId);
	                            	
	                            	if(strAttendees.length() == 0)  strAttendees = attendee.Attendee.LastName;
                                	else strAttendees += ', '+attendee.Attendee.LastName;
	                            }
	                        }
	                    }
	                    
                    	for(Id EmployeeId : mapEmployeeId_UserId.keySet())
                    	{
                        	if(     mapEmployeeId_UserId.get(EmployeeId) != null && 
                            	    (mapEmployeeId_UserId.get(EmployeeId) == item.OwnerId 
                             	       || 
                            	    mapCurrentPeriod_UserId_setEventIds != null && 
                            	    mapCurrentPeriod_UserId_setEventIds.keySet().contains(mapEmployeeId_UserId.get(EmployeeId)) && 
                            	    mapCurrentPeriod_UserId_setEventIds.get(mapEmployeeId_UserId.get(EmployeeId)).contains(item.Id)
                            		) 
                        		)
                        	{
                        		//if(mapEventId_setAttendeeIds.get(item.Id) != null && !mapEventId_setAttendeeIds.get(item.Id).contains(mapEmployeeId_UserId.get(EmployeeId)))
                        		if(!setAttendeeIds.contains(mapEmployeeId_UserId.get(EmployeeId)))
                        		{
                        		 	if(strAttendees.length() == 0)  strAttendees = mapEmployeeId_Employee.get(EmployeeId).Last_Name__c;
	                                else strAttendees += ', '+mapEmployeeId_Employee.get(EmployeeId).Last_Name__c;
                        		}
                           		if(!mapEmployeeId_listClientMeetingsCurrentPeriod.keySet().contains(EmployeeId))     mapEmployeeId_listClientMeetingsCurrentPeriod.put(EmployeeId, new list<clientMeetingsCurrentPeriod>());
                            	mapEmployeeId_listClientMeetingsCurrentPeriod.get(EmployeeId).add(
                            					new clientMeetingsCurrentPeriod(
                            								(item.WhoId != null && mapWhoIdTitle !=null && mapWhoIdTitle.get(item.WhoId)!=null?mapWhoIdTitle.get(item.WhoId):''),
                            								(item.WhatId != null && String.valueOf(item.WhatId).substring(0,3) == AccountPrefix ? item.What.Name : (mapWhoIdAccountName.get(item.WhoId) != null ? mapWhoIdAccountName.get(item.WhoId) : '')),
                            								item.Subject,
                            								item.Type,
                            								item.Description,
                            								(item.Who.Name  != null?item.Who.Name:''),
                            								strAttendees,
                            								item.ActivityDate));
                        	}
                    	}
                	}
                }
                system.debug('1 mapEmployeeId_listClientMeetingsCurrentPeriod = '+mapEmployeeId_listClientMeetingsCurrentPeriod);
               	/*
               	MBS-26
               	
               	//mapEmployeeId_setCallLogIds -  Id of  Call_Logs WHERE RPT_START_DATE <= Call_Log__c .Date__c <= RPT_END_DATE AND (Organizer__c = Organizer__c OR Call_Log__c in (select Call_Log__c from Call_Log_Moelis_Attendee__c
               	if(mapEmployeeId_setCallLogIds.keySet().size() > 0)
	            {
	            	system.debug('mapEmployeeId_setCallLogIds.keySet() = '+mapEmployeeId_setCallLogIds.keySet());
	               	system.debug('mapEmployeeId_setCallLogIds = '+mapEmployeeId_setCallLogIds);
	            	set<Id> setCallLogIds = new set<Id>();
	            	for(Id eId : mapEmployeeId_setCallLogIds.keySet())
	            	{
	            		setCallLogIds.addall(mapEmployeeId_setCallLogIds.get(eId));
	            	}
	            	system.debug('setCallLogIds = '+setCallLogIds);
	                for(Call_Log__c item :[
	                				SELECT Type__c, Organizer__r.Name, Organizer__r.Title__c, Subject__c, Detailed_Description__c,
                                     	(Select Employee__r.Last_Name__c From Call_Log_Moelis_Attendees__r)
	                                FROM Call_Log__c 
	                                WHERE   Date__c >=: curStartDate  AND Date__c <=: curEndDate AND 
	                                        Id IN : setCallLogIds])
	                {
	                	strAttendees = '';
	                    if(item.Call_Log_Moelis_Attendees__r != null && item.Call_Log_Moelis_Attendees__r.size() > 0)
	                    {
	                        for (Call_Log_Moelis_Attendee__c attendee : item.Call_Log_Moelis_Attendees__r) 
	                        {
	                            if(attendee.Employee__r.Last_Name__c!= null)
	                            {
	                                if(strAttendees.length() == 0)  strAttendees = attendee.Employee__r.Last_Name__c;
	                                else strAttendees += ', '+attendee.Employee__r.Last_Name__c;
	                            }
	                        }
	                    } 
	                    if(!mapEmployeeId_listClientMeetingsCurrentPeriod.keySet().contains(item.Organizer__c))     mapEmployeeId_listClientMeetingsCurrentPeriod.put(item.Organizer__c, new list<clientMeetingsCurrentPeriod>());
                        mapEmployeeId_listClientMeetingsCurrentPeriod.get(item.Organizer__c).add(new clientMeetingsCurrentPeriod(item.Organizer__r.Title__c,'',item.Subject__c,item.Type__c,item.Detailed_Description__c,item.Organizer__r.Name,strAttendees));
                       
	                }
	                system.debug('2 mapEmployeeId_listClientMeetingsCurrentPeriod = '+mapEmployeeId_listClientMeetingsCurrentPeriod);
	               
	            }
	            */
            }
            
            
            
            
            
            // New Business Meetings Calls (Average)
            map<String,Set<Id>> mapSBankerTitle_setEventIds = new map<String,Set<Id>>();
            map<String,Integer> mapSBankerTitle_countEvents = new map<String,Integer>();
            map<String,Set<Id>> mapSBankerTitle_setCallLogIds = new map<String,Set<Id>>();
            map<String,Integer> mapSBankerTitle_countCallLogs = new map<String,Integer>(); 
            
            set<Id> setUserIds = new set<Id>(); // UserIds of all Titles of All selecter SBankers
            // calculation mapSBankerTitle_countEvents          
            if(mapEmployeeId_Title.values().size() > 0)
            {
            	if(mapSBankerTitle_setSBankerUserIds.keySet().size() > 0)
            	{
            		for(String sTitle : mapSBankerTitle_setSBankerUserIds.keySet()) 
              			setUserIds.addall(mapSBankerTitle_setSBankerUserIds.get(sTitle));
              		system.debug('setUserIds = '+setUserIds);
	            	if(setUserIds.size() > 0)
	            	{
	                	for(Event item :[
	                				SELECT Id,OwnerId 
	                                FROM Event 
	                                WHERE   ActivityDate >=: curStartDate  AND ActivityDate <=: curEndDate AND IsChild = false AND
	                                        OwnerId IN : setUserIds])
	                	{
		                    for(String sTitle : mapSBankerTitle_setSBankerUserIds.keySet())
		                    {
		                        if(mapSBankerTitle_setSBankerUserIds.get(sTitle).contains(item.OwnerId))
		                        {
		                            if(!mapSBankerTitle_setEventIds.keySet().contains(sTitle))     mapSBankerTitle_setEventIds.put(sTitle, new set<Id>());
		                            mapSBankerTitle_setEventIds.get(sTitle).add(item.Id);
		                        }
		                    }
	                	}
	                	system.debug('1 mapSBankerTitle_setEventIds = '+mapSBankerTitle_setEventIds);
	                	for(EventAttendee item :[
	                			SELECT AttendeeId,EventId,Event.IsChild
                                FROM EventAttendee 
                                WHERE   Event.ActivityDate >=: curStartDate  AND Event.ActivityDate <=: curEndDate AND  Event.IsChild = false AND
                                        AttendeeId IN : setUserIds])
                    	{
                    		for(String sTitle : mapSBankerTitle_setSBankerUserIds.keySet())
		                    {
		                        if(mapSBankerTitle_setSBankerUserIds.get(sTitle).contains(item.AttendeeId) && !item.Event.IsChild)
		                        {
		                            if(!mapSBankerTitle_setEventIds.keySet().contains(sTitle))     mapSBankerTitle_setEventIds.put(sTitle, new set<Id>());
		                            mapSBankerTitle_setEventIds.get(sTitle).add(item.Id);
		                        }
		                    }
                    	}
                    	system.debug('2 mapSBankerTitle_setEventIds = '+mapSBankerTitle_setEventIds);
                    	for(String sTitle : mapSBankerTitle_setEventIds.keySet())
		                {
		                	mapSBankerTitle_countEvents.put(sTitle, mapSBankerTitle_setEventIds.get(sTitle).size());
		                }
		                system.debug('mapSBankerTitle_countEvents = '+mapSBankerTitle_countEvents);
	            	}
                }
                
                
              /*MBS-43
                for(Call_Log__c item : [SELECT Id,Organizer__c,Organizer__r.Title__c
                                        FROM Call_Log__c 
                                        WHERE   Date__c >=: curStartDate  AND Date__c <=: curEndDate AND 
                                        Status__c = 'Active' AND 
                                        		Organizer__r.Business_Type__c = 'Advisory' AND
												Organizer__r.Group__c NOT IN :listExcludeGroups AND
                                                Organizer__r.Title__c IN : mapEmployeeId_Title.values()])
                {
                    if(item.Organizer__c != null && item.Organizer__r.Title__c != null)
                    {
                    	if(!mapSBankerTitle_setCallLogIds.keySet().contains(item.Organizer__r.Title__c))    mapSBankerTitle_setCallLogIds.put(item.Organizer__r.Title__c,  new set<Id>());
                        mapSBankerTitle_setCallLogIds.get(item.Organizer__r.Title__c).add(item.Id);
                    }
                }
                system.debug('1 mapSBankerTitle_setCallLogIds = '+mapSBankerTitle_setCallLogIds);
                
                for(Call_Log_Moelis_Attendee__c item : [SELECT Id,Call_Log__c,Employee__c,Employee__r.Title__c
                                                        FROM Call_Log_Moelis_Attendee__c 
                                                        WHERE   Call_Log__r.Date__c >=: curStartDate  AND Call_Log__r.Date__c <=: curEndDate AND
                                                        Status__c = 'Active' AND 
                                                                Employee__r.Business_Type__c = 'Advisory' AND
																Employee__r.Group__c NOT IN :listExcludeGroups AND
                                                                Employee__r.Title__c IN : mapEmployeeId_Title.values()])
                {
                    if(item.Employee__c != null && item.Employee__r.Title__c != null && item.Call_Log__c != null)
                    {
                    	if(!mapSBankerTitle_setCallLogIds.keySet().contains(item.Employee__r.Title__c))    mapSBankerTitle_setCallLogIds.put(item.Employee__r.Title__c,  new set<Id>());
                        mapSBankerTitle_setCallLogIds.get(item.Employee__r.Title__c).add(item.Call_Log__c);
                    }
                }
                system.debug('2 mapSBankerTitle_setCallLogIds = '+mapSBankerTitle_setCallLogIds);
                
                for(String sTitle : mapSBankerTitle_setCallLogIds.keySet())
                {
                	mapSBankerTitle_countCallLogs.put(sTitle, mapSBankerTitle_setCallLogIds.get(sTitle).size());
                }
                system.debug('mapSBankerTitle_countCallLogs = '+mapSBankerTitle_countCallLogs);
                */
            }
            
            ////////////////////////////////////////////////////////////
            
            
            
            //YTD New Business Meetings/Call /////////////////////
            
            mapEmployeeId_setEventIds = new map<Id,Set<Id>>();
            map<Id,Integer> mapYTD_EmployeeId_countEvents = new map<Id,Integer>();
            //mapUserId_setEventIds = new map<Id,Set<Id>>(); //RPT_BANKER_USERID is an “Event Invitee”
           // listEventIds = new list<Id>(); // all EventIds where RPT_BANKER_USERID is an “Event Invitee”
            
            //calculation mapYTD_EmployeeId_countEvents
            if(mapEmployeeId_UserId.values().size() > 0)
            {
                for(Event item :[SELECT Id,OwnerId 
                                FROM Event 
                                WHERE   ActivityDate = THIS_YEAR  AND ActivityDate <= TODAY AND IsChild = false AND
                                        OwnerId IN : mapEmployeeId_UserId.values()])
                {
                    for(Id EmployeeId : mapEmployeeId_UserId.keySet())
                    {
                        if(mapEmployeeId_UserId.get(EmployeeId) != null &&  mapEmployeeId_UserId.get(EmployeeId) == item.OwnerId)
                        {
                            if(!mapEmployeeId_setEventIds.keySet().contains(EmployeeId))     mapEmployeeId_setEventIds.put(EmployeeId, new set<Id>());
                            mapEmployeeId_setEventIds.get(EmployeeId).add(item.Id);
                        }
                    }
                }
                system.debug('1 YTD mapEmployeeId_setEventIds = '+mapEmployeeId_setEventIds);

                if(listEventIdsCurrentYear.size() > 0)
                {
                    for(Event item :[SELECT Id 
                                FROM Event 
                                WHERE   ActivityDate = THIS_YEAR  AND ActivityDate <= TODAY AND IsChild = false AND
                                        Id IN : listEventIdsCurrentYear])
                    {
                        for(Id EmployeeId : mapEmployeeId_UserId.keySet())
                        {
                            if(	mapEmployeeId_UserId.get(EmployeeId) != null && 
                            	mapCurrentYear_UserId_setEventIds.keySet().contains(mapEmployeeId_UserId.get(EmployeeId)) &&
                            	mapCurrentYear_UserId_setEventIds.get(mapEmployeeId_UserId.get(EmployeeId)).contains(item.Id))
                            {
                                if(!mapEmployeeId_setEventIds.keySet().contains(EmployeeId))     mapEmployeeId_setEventIds.put(EmployeeId, new set<Id>());
                                mapEmployeeId_setEventIds.get(EmployeeId).add(item.Id);
                            }
                        }
                    }
                }
                system.debug('2 YTD mapEmployeeId_setEventIds = '+mapEmployeeId_setEventIds);
               
                if(mapEmployeeId_setEventIds.keySet().size() > 0)
                {
                    for(Id eId : mapEmployeeId_setEventIds.keySet() )
                    {
                        if(mapEmployeeId_setEventIds.get(eId) != null)  mapYTD_EmployeeId_countEvents.put(eId,mapEmployeeId_setEventIds.get(eId).size());
                    }
                }
                system.debug('mapYTD_EmployeeId_countEvents = '+mapYTD_EmployeeId_countEvents);
            }
            
            
            mapEmployeeId_setCallLogIds = new map<Id,Set<Id>>();
            map<Id,Integer> mapYTD_EmployeeId_countCallLogs = new map<Id,Integer>();
            //calculation mapEmployeeId_countCallLogs
            /*MBS-43
            if(mapEmployeeId_Employee.keySet().size() > 0)
            {
                for(Call_Log__c item :[SELECT Id,Organizer__c
                                FROM Call_Log__c 
                                WHERE   Date__c = THIS_YEAR  AND Date__c <= TODAY AND 
                                        Organizer__c IN : mapEmployeeId_Employee.keySet()])
                {
                    if(!mapEmployeeId_setCallLogIds.keySet().contains(item.Organizer__c))    mapEmployeeId_setCallLogIds.put(item.Organizer__c, new set<Id>());
                    mapEmployeeId_setCallLogIds.get(item.Organizer__c).add(item.Id);
                }
                system.debug('1 YTD mapEmployeeId_setCallLogIds = '+mapEmployeeId_setCallLogIds);
                
                for(Call_Log_Moelis_Attendee__c item : [
                				SELECT Employee__c,Call_Log__c 
                				FROM Call_Log_Moelis_Attendee__c 
                				WHERE 	Date__c = THIS_YEAR  AND Date__c <= TODAY AND 
                						Employee__c =: mapEmployeeId_Employee.keySet()])
                {
                    if(item.Call_Log__c != null)    
                    {
                        if(!mapEmployeeId_setCallLogIds.keySet().contains(item.Employee__c))     mapEmployeeId_setCallLogIds.put(item.Employee__c, new set<Id>());
                        mapEmployeeId_setCallLogIds.get(item.Employee__c).add(item.Call_Log__c);
                    }
                }
                system.debug('2 YTD mapEmployeeId_setCallLogIds = '+mapEmployeeId_setCallLogIds);
                if(mapEmployeeId_setCallLogIds.keySet().size() > 0)
                {
                    for(Id eId : mapEmployeeId_setCallLogIds.keySet() )
                    {
                        if(mapEmployeeId_setCallLogIds.get(eId) != null)    mapYTD_EmployeeId_countCallLogs.put(eId,mapEmployeeId_setCallLogIds.get(eId).size());
                    }
                }
                system.debug('mapYTD_EmployeeId_countCallLogs = '+mapYTD_EmployeeId_countCallLogs);
            }
            */
            
            
             
            mapSBankerTitle_setEventIds = new map<String,Set<Id>>();
            mapSBankerTitle_setCallLogIds = new map<String,Set<Id>>();
            map<String,Integer> mapYTD_SBankerTitle_countEvents = new map<String,Integer>();
            map<String,Integer> mapYTD_SBankerTitle_countCallLogs = new map<String,Integer>(); 
            
            //set<Id> setUserIds = new set<Id>(); - calculated above // UserIds of all Titles of All selecter SBankers
            // calculation mapYTD_SBankerTitle_countEvents            
            if(mapEmployeeId_Title.values().size() > 0)
            {
	            if(setUserIds.size() > 0)
	            {
	                	for(Event item :[
	                				SELECT Id,OwnerId 
	                                FROM Event 
	                                WHERE   Event.ActivityDate = THIS_YEAR AND Event.ActivityDate <= TODAY AND IsChild = false AND
	                                        OwnerId IN : setUserIds])
	                	{
		                    for(String sTitle : mapSBankerTitle_setSBankerUserIds.keySet())
		                    {
		                        if(mapSBankerTitle_setSBankerUserIds.get(sTitle).contains(item.OwnerId))
		                        {
		                            if(!mapSBankerTitle_setEventIds.keySet().contains(sTitle))     mapSBankerTitle_setEventIds.put(sTitle, new set<Id>());
		                            mapSBankerTitle_setEventIds.get(sTitle).add(item.Id);
		                        }
		                    }
	                	}
	                	system.debug('1 YTD mapSBankerTitle_setEventIds = '+mapSBankerTitle_setEventIds);
	                	for(EventAttendee item :[
	                			SELECT AttendeeId,EventId 
                                FROM EventAttendee 
                                WHERE   Event.ActivityDate = THIS_YEAR AND Event.ActivityDate <= TODAY AND Event.IsChild = false AND
                                        AttendeeId IN : setUserIds])
                    	{
                    		for(String sTitle : mapSBankerTitle_setSBankerUserIds.keySet())
		                    {
		                        if(mapSBankerTitle_setSBankerUserIds.get(sTitle).contains(item.AttendeeId))
		                        {
		                            if(!mapSBankerTitle_setEventIds.keySet().contains(sTitle))     mapSBankerTitle_setEventIds.put(sTitle, new set<Id>());
		                            mapSBankerTitle_setEventIds.get(sTitle).add(item.Id);
		                        }
		                    }
                    	}
                    	system.debug('2 YTD mapSBankerTitle_setEventIds = '+mapSBankerTitle_setEventIds);
                    	for(String sTitle : mapSBankerTitle_setEventIds.keySet())
		                {
		                	mapYTD_SBankerTitle_countEvents.put(sTitle, mapSBankerTitle_setEventIds.get(sTitle).size());
		                }
		                system.debug('mapYTD_SBankerTitle_countEvents = '+mapYTD_SBankerTitle_countEvents);
	            	}
                
                
                /*MBS-43
                for(Call_Log__c item : [SELECT Id,Organizer__c,Organizer__r.Title__c
                                        FROM Call_Log__c 
                                        WHERE   Date__c = THIS_YEAR  AND Date__c <= TODAY AND 
                                        Status__c = 'Active' AND 
                                        		Organizer__r.Business_Type__c = 'Advisory' AND
												Organizer__r.Group__c NOT IN :listExcludeGroups AND
                                                Organizer__r.Title__c IN : mapEmployeeId_Title.values()])
                {
                    if(item.Organizer__c != null && item.Organizer__r.Title__c != null)
                    {
                    	if(!mapSBankerTitle_setCallLogIds.keySet().contains(item.Organizer__r.Title__c))    mapSBankerTitle_setCallLogIds.put(item.Organizer__r.Title__c,  new set<Id>());
                        mapSBankerTitle_setCallLogIds.get(item.Organizer__r.Title__c).add(item.Id);
                    }
                }
                system.debug('1 YTD mapSBankerTitle_setCallLogIds = '+mapSBankerTitle_setCallLogIds);
                
                for(Call_Log_Moelis_Attendee__c item : [SELECT Id,Call_Log__c,Employee__c,Employee__r.Title__c
                                                        FROM Call_Log_Moelis_Attendee__c 
                                                        WHERE   Call_Log__r.Date__c = THIS_YEAR  AND Call_Log__r.Date__c <= TODAY AND 
                                                        Status__c = 'Active' AND 
                                                        		Employee__r.Business_Type__c = 'Advisory' AND
																Employee__r.Group__c NOT IN :listExcludeGroups AND
                                                                Employee__r.Title__c IN : mapEmployeeId_Title.values()])
                {
                    if(item.Employee__c != null && item.Employee__r.Title__c != null && item.Call_Log__c != null)
                    {
                    	if(!mapSBankerTitle_setCallLogIds.keySet().contains(item.Employee__r.Title__c))    mapSBankerTitle_setCallLogIds.put(item.Employee__r.Title__c,  new set<Id>());
                        mapSBankerTitle_setCallLogIds.get(item.Employee__r.Title__c).add(item.Call_Log__c);
                    }
                }
                system.debug('2 YTD mapSBankerTitle_setCallLogIds = '+mapSBankerTitle_setCallLogIds);
                
                for(String sTitle : mapSBankerTitle_setCallLogIds.keySet())
                {
                	mapYTD_SBankerTitle_countCallLogs.put(sTitle, mapSBankerTitle_setCallLogIds.get(sTitle).size());
                }
                system.debug('mapYTD_SBankerTitle_countCallLogs = '+mapYTD_SBankerTitle_countCallLogs);
                */
            }
                        
            
            
            
            
            
            
            
            
            
            
            
            //Forward Calendar – One Month
            setEUserIds = new set<Id>();
           	setEmployeeUserIds = new set<Id>();
           	curListEvents = new list<Event>();
           	setAttendeeIds = new set<Id>();
            map<Id, list<clientMeetingsCurrentPeriod>> mapEmployeeId_listForwardCalendarOneMonth = new map<Id, list<clientMeetingsCurrentPeriod>>();
            if(mapEmployeeId_UserId.values().size() > 0)
            {
            	
            	for(Event item : [
                                SELECT ID,Who.Title,What.Name, Who.Name, WhoId, Description, WhatId,Type, Subject,OwnerId,ActivityDate,IsChild,
                                        (Select Attendee.LastName From EventAttendees WHERE Status != 'Declined')
                                FROM Event 
                                WHERE   ActivityDate > TODAY AND 
                                		ActivityDate <= :todayDate.addMonths(1) AND  /*MBS-42*/ 
                                		IsChild = false AND 
                                        (Id IN : listEventIdsAfterToday OR OwnerId IN : mapEmployeeId_UserId.values())
                                ORDER BY What.Name])	
            	{
                    if(item.EventAttendees != null && item.EventAttendees.size() > 0)
                    {
                        for (EventAttendee attendee : item.EventAttendees) 
                        {
                            if(String.valueOf(attendee.AttendeeId).substring(0,3) == UserPrefix && attendee.Attendee.LastName != null)
                                setEUserIds.add(attendee.AttendeeId);
                        }
                    }
                    curListEvents.add(item);
                }
                if(setEUserIds.size() > 0)
                {
                	for(Employee_Profile__c item : [
                					SELECT Id, User_ID__c 
                					FROM Employee_Profile__c  
                					WHERE User_ID__c IN : setEUserIds])
                	{
                		setEmployeeUserIds.add(item.User_ID__c);
                	}
                }
                if(curListEvents.size() > 0)
                {
                	for(Event item :curListEvents)
                	{
                		strAttendees = '';
                		setAttendeeIds = new set<Id>();
                    	if(item.EventAttendees != null && item.EventAttendees.size() > 0)
                    	{
                        	for (EventAttendee attendee : item.EventAttendees) 
                        	{
                            	if(setEmployeeUserIds.contains(attendee.AttendeeId) && attendee.Attendee.LastName != null)
	                        	{
	                           		setAttendeeIds.add(attendee.AttendeeId);
	                            	if(strAttendees.length() == 0)  strAttendees = attendee.Attendee.LastName;
                                	else strAttendees += ', '+attendee.Attendee.LastName;
	                       		}
                        	}
                    	}
                    	for(Id EmployeeId : mapEmployeeId_UserId.keySet())
                    	{
                        	if(     mapEmployeeId_UserId.get(EmployeeId) != null && 
                                	(mapEmployeeId_UserId.get(EmployeeId) == item.OwnerId 
                                    || 
                                	mapAfterToday_UserId_setEventIds != null && 
                                	mapAfterToday_UserId_setEventIds.keySet().contains(mapEmployeeId_UserId.get(EmployeeId)) && 
                            	    mapAfterToday_UserId_setEventIds.get(mapEmployeeId_UserId.get(EmployeeId)).contains(item.Id)
                                ) 
                       		)
                        	{
                        	
                        	if(!setAttendeeIds.contains(mapEmployeeId_UserId.get(EmployeeId)))
                        	{
                        		 	if(strAttendees.length() == 0)  strAttendees = mapEmployeeId_Employee.get(EmployeeId).Last_Name__c;
	                                else strAttendees += ', '+mapEmployeeId_Employee.get(EmployeeId).Last_Name__c;
                        	}
            	
                            if(!mapEmployeeId_listForwardCalendarOneMonth.keySet().contains(EmployeeId))     mapEmployeeId_listForwardCalendarOneMonth.put(EmployeeId, new list<clientMeetingsCurrentPeriod>());
                            mapEmployeeId_listForwardCalendarOneMonth.get(EmployeeId).add(new clientMeetingsCurrentPeriod(
                            																(item.WhoId != null && mapWhoIdTitle.get(item.WhoId)!=null?mapWhoIdTitle.get(item.WhoId):''),
                            																(item.WhatId != null && String.valueOf(item.WhatId).substring(0,3) == AccountPrefix ? item.What.Name : (mapWhoIdAccountName.get(item.WhoId) != null ? mapWhoIdAccountName.get(item.WhoId) : '')),
                            																item.Subject,
                            																item.Type,
                            																item.Description,
                            																item.Who.Name,
                            																strAttendees,
                            																item.ActivityDate));
                        	}
                    	}
                   
                	}
                }
                system.debug('mapEmployeeId_listForwardCalendarOneMonth = '+mapEmployeeId_listForwardCalendarOneMonth);
            }
            
            
            
            
            ////////////////////////Pitches
            ///////////////////////////////////////////////////////////
            Decimal countDealsBankers = 0;
            Decimal count_MDBanker = 0;
            map<String,Integer> mapSBankerTitle_countBankerProjects = new map<String,Integer>();
            map<String,set<Id>> mapSBankerTitle_setBankers = new map<String,set<Id>>();
            map<String,Integer> mapSBankerTitle_countBankers = new map<String,Integer>();
            
            map<Id,Integer> mapEmployeeId_countProjects = new map<Id,Integer>();
            map<String,Decimal> mapSBankerTitle_averagePitches = new map<String,Decimal>();
            if(mapEmployeeId_Employee.keySet().size() > 0)
            {
            	groupedResults = new list<AggregateResult>();
                groupedResults = [  SELECT Banker__c banker, count(Project__c) countProjects
                                FROM Project_Resource__c 
                                WHERE   Banker__c IN : mapEmployeeId_Employee.keySet() AND
                                        Status__c = 'Active' AND 
                                        /*
                                        MBS-39
                                        (Project__r.MDSC_isPipeline__c = 1 OR Project__r.MDSC_isOther__c = 1) AND 
                                        Project__r.Latest_Invoice_Date__c >=: curStartDate  AND Project__r.Latest_Invoice_Date__c <=: curEndDate
                                        */
                                        DAY_ONLY(Project__r.CreatedDate) >=: curStartDate  AND DAY_ONLY(Project__r.CreatedDate) <=: curEndDate
                                GROUP BY Banker__c];
                for (AggregateResult ar : groupedResults)
                {
                    mapEmployeeId_countProjects.put((Id)ar.get('banker'), (Integer)ar.get('countProjects'));
                }
            }
            system.debug('mapEmployeeId_countProjects = '+mapEmployeeId_countProjects);
            if(mapEmployeeId_Title.values().size() > 0)
            {
                for(Project_Resource__c item :[ SELECT Id,Project__c,Banker__c,Banker__r.Title__c
                                                FROM Project_Resource__c 
                                                WHERE   Banker__r.Title__c IN : mapEmployeeId_Title.values() AND
                                                		/*MBS-52*/
                                                		Banker__r.Status__c = 'Active' AND 
                                                		Banker__r.Business_Type__c = 'Advisory' AND
														Banker__r.Group__c NOT IN :listExcludeGroups AND
                                                        Status__c = 'Active' AND 
                                                        /*
                                        				MBS-39
                                                        (Project__r.MDSC_isPipeline__c = 1 OR Project__r.MDSC_isOther__c = 1) AND
                                                        Project__r.Latest_Invoice_Date__c >=: curStartDate  AND Project__r.Latest_Invoice_Date__c <=: curEndDate
                                                        */
                                                        DAY_ONLY(Project__r.CreatedDate) >=: curStartDate  AND DAY_ONLY(Project__r.CreatedDate) <=: curEndDate
                                                ])
                {
                    if(!mapSBankerTitle_countBankerProjects.keySet().contains(item.Banker__r.Title__c)) mapSBankerTitle_countBankerProjects.put(item.Banker__r.Title__c, 0);
                    mapSBankerTitle_countBankerProjects.put(item.Banker__r.Title__c, mapSBankerTitle_countBankerProjects.get(item.Banker__r.Title__c) + 1);
                
                    if(!mapSBankerTitle_setBankers.keySet().contains(item.Banker__r.Title__c))  mapSBankerTitle_setBankers.put(item.Banker__r.Title__c, new set<Id>());
                    mapSBankerTitle_setBankers.get(item.Banker__r.Title__c).add(item.Banker__c);
                }
                if(mapSBankerTitle_setBankers.keySet().size() > 0)
                {
                    for(String sTitle : mapSBankerTitle_setBankers.keySet())
                    {
                        mapSBankerTitle_countBankers.put(sTitle,mapSBankerTitle_setBankers.get(sTitle).size());
                    }
                }
                
                for(Id eId : mapEmployeeId_Title.keySet())
                {
                    countDealsBankers = 0;
                    count_MDBanker = 0;
                    if(mapSBankerTitle_countBankerProjects.get(mapEmployeeId_Title.get(eId)) != null)
                        countDealsBankers = mapSBankerTitle_countBankerProjects.get(mapEmployeeId_Title.get(eId));
                        /*
                    MBS-56
                    if(mapSBankerTitle_countBankers.get(mapEmployeeId_Title.get(eId)) != null)
                        count_MDBanker = mapSBankerTitle_countBankers.get(mapEmployeeId_Title.get(eId));
                        */
                    count_MDBanker = mapSBankerTitle_countSBankers.get(mapEmployeeId_Title.get(eId));
                    mapSBankerTitle_averagePitches.put(mapEmployeeId_Title.get(eId),(count_MDBanker != 0 ? countDealsBankers / count_MDBanker : 0) );
                }
                
            system.debug('mapSBankerTitle_countBankerProjects = '+mapSBankerTitle_countBankerProjects);
            system.debug('mapSBankerTitle_countBankers = '+mapSBankerTitle_countBankers);
            system.debug('mapSBankerTitle_averagePitches = '+mapSBankerTitle_averagePitches);
            }
            //Pitches YTD//////////////////////////////
            mapSBankerTitle_countBankerProjects = new map<String,Integer>();
            mapSBankerTitle_setBankers = new map<String,set<Id>>();
            mapSBankerTitle_countBankers = new map<String,Integer>();
            map<Id,Integer> mapYTD_EmployeeId_countProjects = new map<Id,Integer>();
            map<String,Decimal> mapYTD_SBankerTitle_averagePitches = new map<String,Decimal>();
            if(mapEmployeeId_Employee.keySet().size() > 0)
            {
            	groupedResults = new list<AggregateResult>();
                groupedResults = [  SELECT Banker__c banker, count(Project__c) countProjects
                                FROM Project_Resource__c 
                                WHERE   Banker__c IN : mapEmployeeId_Employee.keySet() AND
                                        Status__c = 'Active' AND 
                                        /*MBS-39
                                        (Project__r.MDSC_isPipeline__c = 1 OR Project__r.MDSC_isOther__c = 1) AND
                                        /*MBS-31
                                        Project__r.Latest_Invoice_Date__c  = THIS_YEAR  AND Project__r.Latest_Invoice_Date__c <= TODAY*/
                                        DAY_ONLY(Project__r.CreatedDate)  = THIS_YEAR  AND DAY_ONLY(Project__r.CreatedDate) <= TODAY
                                GROUP BY Banker__c];
                for (AggregateResult ar : groupedResults)
                {
                    mapYTD_EmployeeId_countProjects.put((Id)ar.get('banker'), (Integer)ar.get('countProjects'));
                }
            }
            system.debug('mapYTD_EmployeeId_countProjects = '+mapYTD_EmployeeId_countProjects);
            if(mapEmployeeId_Title.values().size() > 0)
            {
                for(Project_Resource__c item :[ SELECT Id,Project__c,Banker__c,Banker__r.Title__c
                                                FROM Project_Resource__c 
                                                WHERE   Banker__r.Title__c IN : mapEmployeeId_Title.values() AND
                                                		/*MBS-52*/
                                                		Banker__r.Status__c = 'Active' AND 
                                                		Banker__r.Business_Type__c = 'Advisory' AND
														Banker__r.Group__c NOT IN :listExcludeGroups AND
                                                        Status__c = 'Active' AND 
                                                        /*MBS-39
                                                        (Project__r.MDSC_isPipeline__c = 1 OR Project__r.MDSC_isOther__c = 1) AND
                                                        /*MBS-31
                                                        Project__r.Latest_Invoice_Date__c  = THIS_YEAR  AND Project__r.Latest_Invoice_Date__c <= TODAY*/
                                                        DAY_ONLY(Project__r.CreatedDate)  = THIS_YEAR  AND DAY_ONLY(Project__r.CreatedDate) <= TODAY
                                                ])
                {
                    if(!mapSBankerTitle_countBankerProjects.keySet().contains(item.Banker__r.Title__c)) mapSBankerTitle_countBankerProjects.put(item.Banker__r.Title__c, 0);
                    mapSBankerTitle_countBankerProjects.put(item.Banker__r.Title__c, mapSBankerTitle_countBankerProjects.get(item.Banker__r.Title__c) + 1);
                
                    if(!mapSBankerTitle_setBankers.keySet().contains(item.Banker__r.Title__c))  mapSBankerTitle_setBankers.put(item.Banker__r.Title__c, new set<Id>());
                    mapSBankerTitle_setBankers.get(item.Banker__r.Title__c).add(item.Banker__c);
                }
                if(mapSBankerTitle_setBankers.keySet().size() > 0)
                {
                    for(String sTitle : mapSBankerTitle_setBankers.keySet())
                    {
                        mapSBankerTitle_countBankers.put(sTitle,mapSBankerTitle_setBankers.get(sTitle).size());
                    }
                }
                
                for(Id eId : mapEmployeeId_Title.keySet())
                {
                    countDealsBankers = 0;
                    count_MDBanker = 0;
                    if(mapSBankerTitle_countBankerProjects.get(mapEmployeeId_Title.get(eId)) != null)
                        countDealsBankers = mapSBankerTitle_countBankerProjects.get(mapEmployeeId_Title.get(eId));
                    /*
                    MBS-56
                    if(mapSBankerTitle_countBankers.get(mapEmployeeId_Title.get(eId)) != null)
                        count_MDBanker = mapSBankerTitle_countBankers.get(mapEmployeeId_Title.get(eId));
                     */
                    count_MDBanker = mapSBankerTitle_countSBankers.get(mapEmployeeId_Title.get(eId));
                    mapYTD_SBankerTitle_averagePitches.put(mapEmployeeId_Title.get(eId),(count_MDBanker != 0 ? countDealsBankers / count_MDBanker : 0) );
                }
                
            system.debug('mapSBankerTitle_countBankerProjects = '+mapSBankerTitle_countBankerProjects);
            system.debug('mapSBankerTitle_countBankers = '+mapSBankerTitle_countBankers);
            system.debug('mapYTD_SBankerTitle_averagePitches = '+mapYTD_SBankerTitle_averagePitches);
            }
            
            
            
            
            
            map<id,Set<Id>> mapEmployeeId_setProjectIds = new map<id,Set<Id>>();
            set<Id> setEmployeeIdProjectIds = new set<Id>();
            
            map<String,Set<Id>> mapSBankerTitle_setProjectIds = new map<String,Set<Id>>();
            set<Id> setEmployeeTitleProjectIds = new set<Id>();
            
                       
            if(mapEmployeeId_Employee.keySet().size() > 0)
            {
                for(Project_Resource__c item : [SELECT Banker__c,Project__c 
                								FROM Project_Resource__c 
                								WHERE 	Banker__c IN : mapEmployeeId_Employee.keySet()  AND 
                										Status__c = 'Active'])
                {
                    if(!mapEmployeeId_setProjectIds.keySet().contains(item.Banker__c))  mapEmployeeId_setProjectIds.put(item.Banker__c, new set<Id>());
                    mapEmployeeId_setProjectIds.get(item.Banker__c).add(item.Project__c);
                    setEmployeeIdProjectIds.add(item.Project__c);
                }
                  system.debug('mapEmployeeId_setProjectIds = '+mapEmployeeId_setProjectIds);
                  system.debug('setEmployeeIdProjectIds = '+setEmployeeIdProjectIds);
            }
            
            
            
            
            
            
            ///LiveMandates ///////////////////////////////////////////////////////
            map<Id,Integer> mapLM_EmployeeId_countProjects = new map<Id,Integer>();
            map<String,Integer> mapLM_SBankerTitle_countBankerProjects = new map<String,Integer>();
            map<String,set<Id>> mapLM_SBankerTitle_setBankers = new map<String,set<Id>>();
            map<String,Integer> mapLM_SBankerTitle_countBankers = new map<String,Integer>();
            map<String,Decimal> mapLM_SBankerTitle_averagePitches = new map<String,Decimal>();
            
            map<String,Decimal> mapAF_SBankerTitle_sumFees = new map<String,Decimal>();
            
            if(mapEmployeeId_Employee.keySet().size() > 0)
            {
                groupedResults = new list<AggregateResult>();
                groupedResults = [  SELECT Banker__c banker, count(Project__c) countProjects
                                FROM Project_Resource__c 
                                WHERE   Banker__c IN : mapEmployeeId_Employee.keySet() AND
                                        Status__c = 'Active' AND 
                                        /*MBS-38
                                        Project__r.MDSC_isPipeline__c = 1 AND
                                        Project__r.Latest_Invoice_Date__c = THIS_YEAR  AND Project__r.Latest_Invoice_Date__c <= TODAY*/
                                        
                                        /*MBS-40
                                        DAY_ONLY(Project__r.CreatedDate)  = THIS_YEAR  AND DAY_ONLY(Project__r.CreatedDate) <= TODAY
                                        */
                                        Project__r.Include_in_Pipeline__c = true
                                GROUP BY Banker__c];
                for (AggregateResult ar : groupedResults)
                {
                    mapLM_EmployeeId_countProjects.put((Id)ar.get('banker'), (Integer)ar.get('countProjects'));
                }
            }
            system.debug('mapLM_EmployeeId_countProjects = '+mapLM_EmployeeId_countProjects);
            if(mapEmployeeId_Title.values().size() > 0)
            {
                for(Project_Resource__c item :[ SELECT Id,Project__c,Banker__c,Banker__r.Title__c,Project__r.Estimated_Fee_Revenue__c
                                                FROM Project_Resource__c 
                                                WHERE   Banker__r.Title__c IN : mapEmployeeId_Title.values() AND
                                                		/*MBS-52*/
                                                		Banker__r.Status__c = 'Active' AND 
                                                		Banker__r.Business_Type__c = 'Advisory' AND
														Banker__r.Group__c NOT IN :listExcludeGroups AND
                                                        Status__c = 'Active' AND 
                                                        /*MBS-38
                                                        Project__r.MDSC_isPipeline__c = 1 AND
                                                        Project__r.Latest_Invoice_Date__c = THIS_YEAR  AND Project__r.Latest_Invoice_Date__c <= TODAY*/
                                                        
                                                        /*MBS-40
				                                        DAY_ONLY(Project__r.CreatedDate)  = THIS_YEAR  AND DAY_ONLY(Project__r.CreatedDate) <= TODAY
				                                        */
				                                        Project__r.Include_in_Pipeline__c = true
                                                ])
                {
                    if(!mapLM_SBankerTitle_countBankerProjects.keySet().contains(item.Banker__r.Title__c))  mapLM_SBankerTitle_countBankerProjects.put(item.Banker__r.Title__c, 0);
                    mapLM_SBankerTitle_countBankerProjects.put(item.Banker__r.Title__c, mapLM_SBankerTitle_countBankerProjects.get(item.Banker__r.Title__c) + 1);
                
                    if(!mapLM_SBankerTitle_setBankers.keySet().contains(item.Banker__r.Title__c))   mapLM_SBankerTitle_setBankers.put(item.Banker__r.Title__c, new set<Id>());
                    mapLM_SBankerTitle_setBankers.get(item.Banker__r.Title__c).add(item.Banker__c);
                    
                    
                    //for calculation Average Fee (Average)
                    if(!mapAF_SBankerTitle_sumFees.keySet().contains(item.Banker__r.Title__c))  mapAF_SBankerTitle_sumFees.put(item.Banker__r.Title__c, 0);
                    mapAF_SBankerTitle_sumFees.put(item.Banker__r.Title__c, mapAF_SBankerTitle_sumFees.get(item.Banker__r.Title__c) + (item.Project__r.Estimated_Fee_Revenue__c != null ? item.Project__r.Estimated_Fee_Revenue__c : 0));
                }
                if(mapLM_SBankerTitle_setBankers.keySet().size() > 0)
                {
                    for(String sTitle : mapLM_SBankerTitle_setBankers.keySet())
                    {
                        mapLM_SBankerTitle_countBankers.put(sTitle,mapLM_SBankerTitle_setBankers.get(sTitle).size());
                    }
                }
                
                for(Id eId : mapEmployeeId_Title.keySet())
                {
                    countDealsBankers = 0;
                    count_MDBanker = 0;
                    if(mapLM_SBankerTitle_countBankerProjects.get(mapEmployeeId_Title.get(eId)) != null)
                        countDealsBankers = mapLM_SBankerTitle_countBankerProjects.get(mapEmployeeId_Title.get(eId));
                    /*MBS-56
                    if(mapLM_SBankerTitle_countBankers.get(mapEmployeeId_Title.get(eId)) != null)
                        count_MDBanker = mapLM_SBankerTitle_countBankers.get(mapEmployeeId_Title.get(eId));
                    */
                    count_MDBanker = mapSBankerTitle_countSBankers.get(mapEmployeeId_Title.get(eId));
                    mapLM_SBankerTitle_averagePitches.put(mapEmployeeId_Title.get(eId),(count_MDBanker != 0 ? countDealsBankers / count_MDBanker : 0) );
                }
                
            system.debug('mapLM_SBankerTitle_countBankerProjects = '+mapLM_SBankerTitle_countBankerProjects);
            system.debug('mapLM_SBankerTitle_countBankers = '+mapLM_SBankerTitle_countBankers);
            system.debug('mapLM_SBankerTitle_averagePitches = '+mapLM_SBankerTitle_averagePitches);
            system.debug('mapAF_SBankerTitle_sumFees = '+mapAF_SBankerTitle_sumFees);
            }
            
            //AverageFee///////////////////////////////////////////////////
            map<Id,Decimal> mapAF_EmployeeId_countEFees = new map<Id,Decimal>();
            
            map<String,Decimal> mapAF_SBankerTitle_averageEFees = new map<String,Decimal>();
            map<String,Decimal> mapAF_SBankerTitle_sumAverageFees  = new map<String,Decimal>();
            map<String,Decimal> mapAF_SBankerTitle_sumLiveMandates  = new map<String,Decimal>();
            if(mapEmployeeId_Employee.keySet().size() > 0)
            {
            	groupedResults = new list<AggregateResult>();
                groupedResults = [  SELECT Banker__c banker, SUM(Project__r.Estimated_Fee_Revenue__c) sumEFR
                                FROM Project_Resource__c 
                                WHERE   Banker__c IN : mapEmployeeId_Employee.keySet() AND
                                        Status__c = 'Active' AND
                                        Banker__r.Status__c = 'Active' AND 
                                        Banker__r.Business_Type__c = 'Advisory' AND
										Banker__r.Group__c NOT IN :listExcludeGroups AND
                                        /*MBS-38 
                                        Project__r.MDSC_isPipeline__c = 1 AND
                                        Project__r.Latest_Invoice_Date__c = THIS_YEAR  AND Project__r.Latest_Invoice_Date__c <= TODAY*/
                                        
                                        /*MBS-40
                                        DAY_ONLY(Project__r.CreatedDate)  = THIS_YEAR  AND DAY_ONLY(Project__r.CreatedDate) <= TODAY
                                        */
                                        Project__r.Include_in_Pipeline__c = true
                                GROUP BY Banker__c];
                for (AggregateResult ar : groupedResults)
                {
                    mapAF_EmployeeId_countEFees.put((Id)ar.get('banker'), (Decimal)ar.get('sumEFR')); 
                }
            }
            system.debug('mapAF_EmployeeId_countEFees = '+mapAF_EmployeeId_countEFees);
            if(mapEmployeeId_Title.values().size() > 0)
            {
                //Average Fee (Average)
                map<Id,Decimal> mapAF_EmployeeId_AverageFee = new map<Id,Decimal>();
                groupedResults = new list<AggregateResult>();
                groupedResults = [  SELECT Banker__c banker, count(Project__c) countProjects, AVG(Project__r.Estimated_Fee_Revenue__c) avgEFR
                                FROM Project_Resource__c 
                                WHERE   Banker__r.Title__c IN : mapEmployeeId_Title.values() AND
                                        Status__c = 'Active' AND 
                                        Banker__r.Status__c = 'Active' AND 
                                        Banker__r.Business_Type__c = 'Advisory' AND
										Banker__r.Group__c NOT IN :listExcludeGroups AND
                                        /*MBS-38
                                        Project__r.MDSC_isPipeline__c = 1 AND
                                        Project__r.Latest_Invoice_Date__c = THIS_YEAR  AND Project__r.Latest_Invoice_Date__c <= TODAY*/
                                        
                                        /*MBS-40
                                        DAY_ONLY(Project__r.CreatedDate)  = THIS_YEAR  AND DAY_ONLY(Project__r.CreatedDate) <= TODAY
                                        */
                                        Project__r.Include_in_Pipeline__c = true
                                GROUP BY Banker__c];
                for (AggregateResult ar : groupedResults)
                {
                    mapAF_EmployeeId_AverageFee.put((Id)ar.get('banker'), (Decimal)ar.get('avgEFR'));
                }
                    
                for(String sTitle : mapSBankerTitle_setSBankerIds.keySet())
                {
                	if(mapSBankerTitle_setSBankerIds.get(sTitle).size() > 0)
                	{
	                	for(Id SBId : mapSBankerTitle_setSBankerIds.get(sTitle))
	                	{
		                	if(!mapAF_SBankerTitle_sumAverageFees.keySet().contains(sTitle))
		                		mapAF_SBankerTitle_sumAverageFees.put(sTitle,0);
		                	mapAF_SBankerTitle_sumAverageFees.put(sTitle, 
		                		mapAF_SBankerTitle_sumAverageFees.get(sTitle) + (mapAF_EmployeeId_AverageFee.get(SBId) != null ? mapAF_EmployeeId_AverageFee.get(SBId) : 0 ));
	                	}
                	}
                }
                system.debug('mapAF_SBankerTitle_sumAverageFees = '+mapAF_SBankerTitle_sumAverageFees);
                for(Id eId : mapEmployeeId_Title.keySet())
                {
                    countDealsBankers = 0;
                    count_MDBanker = 0;
                   
                    if(	mapAF_SBankerTitle_sumAverageFees.get(mapEmployeeId_Title.get(eId)) != null     )	
                    	countDealsBankers = mapAF_SBankerTitle_sumAverageFees.get(mapEmployeeId_Title.get(eId));
                    /*MBS-56*/
                    count_MDBanker = mapSBankerTitle_countSBankers.get(mapEmployeeId_Title.get(eId));
                    mapAF_SBankerTitle_averageEFees.put(mapEmployeeId_Title.get(eId), (count_MDBanker != 0 ? countDealsBankers / count_MDBanker : 0));
                }
            system.debug('mapAF_SBankerTitle_averageEFees = '+mapAF_SBankerTitle_averageEFees);
            }
            
            
            
            
            
            
            
            //Senior Banker Scorecard Detailed – Current Pipeline Section
            
            Decimal total_Invoice_Fees_YTD = 0;
            Decimal total_Invoice_Expenses_YTD = 0;
            map<Id,list<FeesInvoiced>> mapEmployeeId_FeesInvoiceds_CPS = new map<Id,list<FeesInvoiced>>();
            map<Id,Decimal> mapEmployeeId_subtotalFeeYTD_CPS = new map<Id,Decimal>();
            map<Id,Decimal> mapEmployeeId_subtotalExpansesYTD_CPS = new map<Id,Decimal>();
            map<Id,Decimal> mapEmployeeId_subtotalFeeRevenue_CPS = new map<Id,Decimal>();
            map<Id,Decimal> mapEmployeeId_subtotalPARevenue_CPS = new map<Id,Decimal>();
            
            String prMoelisRoles = '';
            map<Id,String> mapBanker_MoelisRoles = new map<Id,String>();
            if(setEmployeeIdProjectIds.size() > 0)
            {
                for(Ibanking_Project__c item : [
                            SELECT  Client__c,Client__r.Name, Expense_Code__c, /*Moelis_Role__c,Moelis_Roles__c,*/ Stage__c, Estimated_Fee_Revenue__c, Expected_Close_Date__c, Revenue_Probability__c,Probability_Adjusted_Revenue__c,
                                    (Select Invoice_Date__c, Fees_Invoiced__c, Expenses_Invoiced__c From Invoices__r WHERE Invoice_Date__c = THIS_YEAR  AND Invoice_Date__c <= TODAY),
                                    (Select Id,Role__c, Banker__c From Project_Resources__r)
                            FROM Ibanking_Project__c
                            WHERE   Include_in_Pipeline__c = true AND
                            		/*
                            		MBS-36 
                            		MDSC_isPipeline__c = 1 AND 
                                    Latest_Invoice_Date__c >=: curStartDate  AND Latest_Invoice_Date__c <=: curEndDate AND
                                    */
                                    ID IN : setEmployeeIdProjectIds
                            ORDER BY Client__r.Name])
                {
                    total_Invoice_Fees_YTD = total_Invoice_Expenses_YTD = 0;
                    for (Invoice__c inv : item.Invoices__r) 
                    {
                        if(inv.Fees_Invoiced__c != null)    total_Invoice_Fees_YTD = total_Invoice_Fees_YTD + inv.Fees_Invoiced__c;
                        if(inv.Expenses_Invoiced__c != null)    total_Invoice_Expenses_YTD = total_Invoice_Expenses_YTD + inv.Expenses_Invoiced__c;
                    }
                    mapBanker_MoelisRoles = new map<Id,String>();
                    for (Project_Resource__c pr : item.Project_Resources__r) 
                    {
                        if(pr.Role__c != null && pr.Banker__c != null) 	mapBanker_MoelisRoles.put(pr.Banker__c,pr.Role__c);
                    }
                    
                   
                    if(setEmployeeIdProjectIds.contains(item.Id) && mapEmployeeId_setProjectIds.keySet().size()>0)
                    {
                        for(Id eId : mapEmployeeId_setProjectIds.keySet())
                        {
                            if(mapEmployeeId_setProjectIds.get(eId).contains(item.Id))
                            {
                                if(!mapEmployeeId_FeesInvoiceds_CPS.keySet().contains(eId)) mapEmployeeId_FeesInvoiceds_CPS.put(eId, new list<FeesInvoiced>());
                                mapEmployeeId_FeesInvoiceds_CPS.get(eId).add(new FeesInvoiced(
                                												(item.Client__r.Name!=null?item.Client__r.Name:''),
                                												item.Expense_Code__c,
                                												(mapBanker_MoelisRoles.get(eId) != null ? mapBanker_MoelisRoles.get(eId) : ''),
                                												item.Stage__c,
                                												item.Estimated_Fee_Revenue__c,
                                												total_Invoice_Fees_YTD,
                                												total_Invoice_Expenses_YTD,
                                												item.Expected_Close_Date__c,
                                												item.Revenue_Probability__c,
                                												item.Probability_Adjusted_Revenue__c));
                                
                                if(!mapEmployeeId_subtotalFeeYTD_CPS.keySet().contains(eId))    mapEmployeeId_subtotalFeeYTD_CPS.put(eId, 0);
                                mapEmployeeId_subtotalFeeYTD_CPS.put(eId, mapEmployeeId_subtotalFeeYTD_CPS.get(eId) + total_Invoice_Fees_YTD);
                                
                                if(!mapEmployeeId_subtotalExpansesYTD_CPS.keySet().contains(eId))   mapEmployeeId_subtotalExpansesYTD_CPS.put(eId, 0);
                                mapEmployeeId_subtotalExpansesYTD_CPS.put(eId, mapEmployeeId_subtotalExpansesYTD_CPS.get(eId) + total_Invoice_Expenses_YTD);
                                
                                if(!mapEmployeeId_subtotalFeeRevenue_CPS.keySet().contains(eId))    mapEmployeeId_subtotalFeeRevenue_CPS.put(eId, 0);
                                mapEmployeeId_subtotalFeeRevenue_CPS.put(eId, mapEmployeeId_subtotalFeeRevenue_CPS.get(eId) + (item.Estimated_Fee_Revenue__c != null ? item.Estimated_Fee_Revenue__c : 0 ));
                                
                                if(!mapEmployeeId_subtotalPARevenue_CPS.keySet().contains(eId))    mapEmployeeId_subtotalPARevenue_CPS.put(eId, 0);
                                mapEmployeeId_subtotalPARevenue_CPS.put(eId, mapEmployeeId_subtotalPARevenue_CPS.get(eId) + (item.Probability_Adjusted_Revenue__c != null ? item.Probability_Adjusted_Revenue__c : 0 ));
                            }
                        }
                    }
                }
                system.debug('mapEmployeeId_FeesInvoiceds_CPS = '+mapEmployeeId_FeesInvoiceds_CPS);
            }   
            
            
            
            
                            
            //Senior Banker Scorecard Detailed – Other Fees Invoiced Section
            //Other YTD Fees Invoiced (MBS-24)
            map<Id,list<FeesInvoiced>> mapEmployeeId_FeesInvoiceds_OFI = new map<Id,list<FeesInvoiced>>();
            map<Id,Decimal> mapEmployeeId_subtotalFeeYTD_OFI= new map<Id,Decimal>();
            map<Id,Decimal> mapEmployeeId_subtotalExpansesYTD_OFI = new map<Id,Decimal>();
            map<Id,Decimal> mapEmployeeId_subtotalFeeRevenue_OFI = new map<Id,Decimal>();
            if(setEmployeeIdProjectIds.size() > 0)
            {
                for(Ibanking_Project__c item : [
                            SELECT  Client__c,Client__r.Name, Expense_Code__c, Stage__c, Estimated_Fee_Revenue__c, Expected_Close_Date__c, Revenue_Probability__c,
                                    (Select Invoice_Date__c, Fees_Invoiced__c, Expenses_Invoiced__c From Invoices__r WHERE Invoice_Date__c = THIS_YEAR  AND Invoice_Date__c <= TODAY),
                                    (Select Id,Banker__c,Role__c From Project_Resources__r)
                            FROM Ibanking_Project__c
                            WHERE   MDSC_isOther__c = 1 AND
                                    /*
                                    MBS-24
                                    Latest_Invoice_Date__c >=: curStartDate  AND Latest_Invoice_Date__c <=: curEndDate AND
                                    */
                                    Latest_Invoice_Date__c = THIS_YEAR  AND Latest_Invoice_Date__c <= TODAY AND 
                                    ID IN : setEmployeeIdProjectIds
                            ORDER BY Client__r.Name])
                {
                    total_Invoice_Fees_YTD = total_Invoice_Expenses_YTD = 0;
                    for (Invoice__c inv : item.Invoices__r) 
                    {
                        if(inv.Fees_Invoiced__c != null)    total_Invoice_Fees_YTD = total_Invoice_Fees_YTD + inv.Fees_Invoiced__c;
                        if(inv.Expenses_Invoiced__c != null)    total_Invoice_Expenses_YTD = total_Invoice_Expenses_YTD + inv.Expenses_Invoiced__c;
                    }
                    mapBanker_MoelisRoles = new map<Id,String>();
                    for (Project_Resource__c pr : item.Project_Resources__r) 
                    {
                        if(pr.Role__c != null && pr.Banker__c != null) 	mapBanker_MoelisRoles.put(pr.Banker__c,pr.Role__c);
                    }
                    if(setEmployeeIdProjectIds.contains(item.Id) && mapEmployeeId_setProjectIds.keySet().size()>0)
                    {
                        for(Id eId : mapEmployeeId_setProjectIds.keySet())
                        {
                            if(mapEmployeeId_setProjectIds.get(eId).contains(item.Id))
                            {
                                if(!mapEmployeeId_FeesInvoiceds_OFI.keySet().contains(eId)) mapEmployeeId_FeesInvoiceds_OFI.put(eId, new list<FeesInvoiced>());
                                mapEmployeeId_FeesInvoiceds_OFI.get(eId).add(new FeesInvoiced((item.Client__r.Name!=null?item.Client__r.Name:''),item.Expense_Code__c,(mapBanker_MoelisRoles.get(eId) != null ? mapBanker_MoelisRoles.get(eId) : ''),item.Stage__c,item.Estimated_Fee_Revenue__c,total_Invoice_Fees_YTD,total_Invoice_Expenses_YTD,item.Expected_Close_Date__c,item.Revenue_Probability__c, null));
                                
                                if(!mapEmployeeId_subtotalFeeYTD_OFI.keySet().contains(eId))    mapEmployeeId_subtotalFeeYTD_OFI.put(eId, 0);
                                mapEmployeeId_subtotalFeeYTD_OFI.put(eId, mapEmployeeId_subtotalFeeYTD_OFI.get(eId) + total_Invoice_Fees_YTD);
                                
                                if(!mapEmployeeId_subtotalExpansesYTD_OFI.keySet().contains(eId))   mapEmployeeId_subtotalExpansesYTD_OFI.put(eId, 0);
                                mapEmployeeId_subtotalExpansesYTD_OFI.put(eId, mapEmployeeId_subtotalExpansesYTD_OFI.get(eId) + total_Invoice_Expenses_YTD);
                                
                                if(!mapEmployeeId_subtotalFeeRevenue_OFI.keySet().contains(eId))    mapEmployeeId_subtotalFeeRevenue_OFI.put(eId, 0);
                                mapEmployeeId_subtotalFeeRevenue_OFI.put(eId, mapEmployeeId_subtotalFeeRevenue_OFI.get(eId) + (item.Estimated_Fee_Revenue__c != null ? item.Estimated_Fee_Revenue__c : 0 ));
                            }
                        }
                    }
                }
                system.debug('mapEmployeeId_FeesInvoiceds_OFI = '+mapEmployeeId_FeesInvoiceds_OFI);
            }   
            
            
            
            
            //Senior Banker Scorecard Detailed – “Near Term Transactions” Section
            map<Id,list<NearTermTransactions>> mapEmployeeId_NearTermTransactions = new map<Id,list<NearTermTransactions>>();
            if(mapEmployeeId_Employee.keySet().size() > 0)
            {
            	map<Id,list<Company_List_Member__c>> mapEmployeeId_CompanyListMembers = new map<Id,list<Company_List_Member__c>>();
            	
            	map<Id, set<Id>> mapEmployeeId_setAccountIds = new map<Id, set<Id>>();
            	map<Id, map<Id, set<Id>>> mapEmployeeId_mapAccountId_setEventIds = new map<Id, map<Id, set<Id>>>();
            	map<Id, map<Id, set<Id>>> mapEmployeeId_mapAccountId_setEventIds_YTD = new map<Id, map<Id, set<Id>>>();
            	
            	set<Id> listAccountIds = new set<Id>();
            	map<Id,set<Id>> map_accontId_setContactIds = new map<Id,set<Id>>();
    	
                for(Company_List_Member__c item : [
                        SELECT Company__r.Name,Company__c, Date__c, Tier__c, Deal_Type__c, Description__c,Company_List__c,Company_List__r.OwnerId,Company_List__r.Banker_Name__c 
                        FROM Company_List_Member__c
                        WHERE   /*MBS-52
                        		Date__c >=: curStartDate  AND Date__c <=: curEndDate AND  */
                        		Date__c >= THIS_YEAR AND
                                Company_List__r.Banker_Name__c  IN : mapEmployeeId_Employee.keySet() AND
                                Company_List__r.Status__c = 'Active' AND Company_List__r.Type__c = 'Near-Term Transaction List' /*MBS-51*/
                        ORDER BY Company__r.Name])
                {
                	if(item.Company__c != null && item.Company_List__r.Banker_Name__c != null)
                	{
                    if(!mapEmployeeId_CompanyListMembers.keySet().contains(item.Company__c)) mapEmployeeId_CompanyListMembers.put(item.Company__c,new list<Company_List_Member__c>());
                    mapEmployeeId_CompanyListMembers.get(item.Company__c).add(item);
                    
                    if(!mapEmployeeId_mapAccountId_setEventIds.keySet().contains(item.Company_List__r.Banker_Name__c )) 
                    	mapEmployeeId_mapAccountId_setEventIds.put(item.Company_List__r.Banker_Name__c, new map<Id, set<Id>>());
                    if(!mapEmployeeId_mapAccountId_setEventIds.get(item.Company_List__r.Banker_Name__c).keySet().contains(item.Company__c)) 
                    	mapEmployeeId_mapAccountId_setEventIds.get(item.Company_List__r.Banker_Name__c).put(item.Company__c, new set<Id>());
                    	
                    if(!mapEmployeeId_mapAccountId_setEventIds_YTD.keySet().contains(item.Company_List__r.Banker_Name__c )) 
                    	mapEmployeeId_mapAccountId_setEventIds_YTD.put(item.Company_List__r.Banker_Name__c, new map<Id, set<Id>>());
                    if(!mapEmployeeId_mapAccountId_setEventIds_YTD.get(item.Company_List__r.Banker_Name__c).keySet().contains(item.Company__c)) 
                    	mapEmployeeId_mapAccountId_setEventIds_YTD.get(item.Company_List__r.Banker_Name__c).put(item.Company__c, new set<Id>());
                    
                    
                    //if(!mapEmployeeId_setAccountIds.keySet().contains(item.Company_List__r.Banker_Name__c )) mapEmployeeId_setAccountIds.put(item.Company_List__r.Banker_Name__c, new set<Id>());
                    //mapEmployeeId_setAccountIds.get(item.Company_List__r.Banker_Name__c).add(item.Company__c);
                    if(!map_accontId_setContactIds.keySet().contains(item.Company__c)) 	map_accontId_setContactIds.put(item.Company__c, new set<Id>());
                    listAccountIds.add(item.Company__c);
                	}
                }
                
                Date dateStartYear = date.newInstance(date.today().year(), 1, 1);
                if(listAccountIds.size() > 0)
		    	{
		    		for(Event   item : [	
			    						SELECT Id,WhatId,ActivityDate,OwnerId
										FROM Event  
		    							WHERE 	WhatId IN : listAccountIds AND 
		    									isChild = false  AND 
		    									isDeleted = false AND
		    									/*MBS-50*/
		    									(OwnerId IN : mapEmployeeId_UserId.values()  OR
		    									Id IN : listEventIdsCurrentPeriod OR 
		    									Id IN : listEventIdsCurrentYear)
		    							ALL ROWS ])
		    		{
		    			for(Id EmployeeId : mapEmployeeId_UserId.keySet())
                    	{
                    		// for Owner = RPT_BANKER_USERID)
                        	if(	mapEmployeeId_UserId.get(EmployeeId) != null && 
                        		mapEmployeeId_UserId.get(EmployeeId) == item.OwnerId)
                        	{
						    	if(	item.ActivityDate >= curStartDate && item.ActivityDate <= curEndDate &&
	                        		mapEmployeeId_mapAccountId_setEventIds.get(EmployeeId) != null && 
	                        		mapEmployeeId_mapAccountId_setEventIds.get(EmployeeId).get(item.WhatId) != null)
						    			mapEmployeeId_mapAccountId_setEventIds.get(EmployeeId).get(item.WhatId).add(item.Id);
						    			
						    	if(	item.ActivityDate >= dateStartYear && item.ActivityDate <= date.today() &&
	                        		mapEmployeeId_mapAccountId_setEventIds_YTD.get(EmployeeId) != null && 
	                        		mapEmployeeId_mapAccountId_setEventIds_YTD.get(EmployeeId).get(item.WhatId) != null)
						    			mapEmployeeId_mapAccountId_setEventIds_YTD.get(EmployeeId).get(item.WhatId).add(item.Id);
                        	}
                        	// for RPT_BANKER_USERID is an “Event Invitee”
                        	if(	mapEmployeeId_UserId.get(EmployeeId) != null )
                        	{
						    	if(	item.ActivityDate >= curStartDate && item.ActivityDate <= curEndDate && 
						    	
	                        		mapEmployeeId_mapAccountId_setEventIds.get(EmployeeId) != null && 
	                        		mapEmployeeId_mapAccountId_setEventIds.get(EmployeeId).get(item.WhatId) != null &&
	                        		
						    		mapCurrentPeriod_UserId_setEventIds != null && 
                        			mapCurrentPeriod_UserId_setEventIds.keySet().contains(mapEmployeeId_UserId.get(EmployeeId)) &&
                        			mapCurrentPeriod_UserId_setEventIds.get(mapEmployeeId_UserId.get(EmployeeId)).contains(item.Id)
                        			)
						    			mapEmployeeId_mapAccountId_setEventIds.get(EmployeeId).get(item.WhatId).add(item.Id);
						    			
						    	if(	item.ActivityDate >= dateStartYear && item.ActivityDate <= date.today()  &&
						    	
	                        		mapEmployeeId_mapAccountId_setEventIds_YTD.get(EmployeeId) != null && 
	                        		mapEmployeeId_mapAccountId_setEventIds_YTD.get(EmployeeId).get(item.WhatId) != null &&
	                        		
	                        		mapCurrentYear_UserId_setEventIds != null && 
	                        		mapCurrentYear_UserId_setEventIds.keySet().contains(mapEmployeeId_UserId.get(EmployeeId)) &&
                        			mapCurrentYear_UserId_setEventIds.get(mapEmployeeId_UserId.get(EmployeeId)).contains(item.Id)
                        			)
						    			mapEmployeeId_mapAccountId_setEventIds_YTD.get(EmployeeId).get(item.WhatId).add(item.Id);
                        	}
                    	}
		    			
		    		}
		    				    		
		    		set<Id> setContacts = new set<Id>();
		    		for(Contact item: [SELECT ID, AccountId FROM Contact WHERE AccountId IN : listAccountIds])
		    		{
		    			map_accontId_setContactIds.get(item.AccountId).add(item.Id);
		    			setContacts.add(item.Id);
		    		}
		    		
		    		if(setContacts.size()>0)
		    		{
		    			for(Event   item : [SELECT Id,WhatId,ActivityDate,WhoId,OwnerId
										FROM Event  
		    							WHERE 	WhoId IN : setContacts AND 
		    									isChild = false AND 
		    									isDeleted = false AND
		    									/*MBS-50*/
		    									(OwnerId IN : mapEmployeeId_UserId.values()  OR
		    									Id IN : listEventIdsCurrentPeriod OR 
		    									Id IN : listEventIdsCurrentYear)
		    							ALL ROWS ])					
		    		{
		    			for(Id EmployeeId : mapEmployeeId_UserId.keySet())
                    	{
                    		// for Owner = RPT_BANKER_USERID)
                        	if(	mapEmployeeId_UserId.get(EmployeeId) != null && 
                        		mapEmployeeId_UserId.get(EmployeeId) == item.OwnerId)
                        	{
                        		for(Id accountId : map_accontId_setContactIds.keySet())
				    			{
				    				if(accountId != item.WhatId &&
				    				 map_accontId_setContactIds.get(accountId) != null && 
				    				 map_accontId_setContactIds.get(accountId).contains(item.WhoId))
				    				{
								    	if(	item.ActivityDate >= curStartDate && item.ActivityDate <= curEndDate &&
			                        		mapEmployeeId_mapAccountId_setEventIds.get(EmployeeId) != null && 
			                        		mapEmployeeId_mapAccountId_setEventIds.get(EmployeeId).get(accountId) != null)
								    			mapEmployeeId_mapAccountId_setEventIds.get(EmployeeId).get(accountId).add(item.Id);
								    			
								    	if(	item.ActivityDate >= dateStartYear && item.ActivityDate <= date.today() &&
			                        		mapEmployeeId_mapAccountId_setEventIds_YTD.get(EmployeeId) != null && 
			                        		mapEmployeeId_mapAccountId_setEventIds_YTD.get(EmployeeId).get(accountId) != null)
								    			mapEmployeeId_mapAccountId_setEventIds_YTD.get(EmployeeId).get(accountId).add(item.Id);
								    			
				    				}
				    			}
                        	}
                        	// for RPT_BANKER_USERID is an “Event Invitee”
                        	if(	mapEmployeeId_UserId.get(EmployeeId) != null )
                        	{
                        		for(Id accountId : map_accontId_setContactIds.keySet())
				    			{
				    				if(accountId != item.WhatId &&
				    				 map_accontId_setContactIds.get(accountId) != null && 
				    				 map_accontId_setContactIds.get(accountId).contains(item.WhoId))
				    				{
								    	if(	item.ActivityDate >= curStartDate && item.ActivityDate <= curEndDate && 
								    	
			                        		mapEmployeeId_mapAccountId_setEventIds.get(EmployeeId) != null && 
			                        		mapEmployeeId_mapAccountId_setEventIds.get(EmployeeId).get(accountId) != null &&
			                        		
								    		mapCurrentPeriod_UserId_setEventIds != null && 
		                        			mapCurrentPeriod_UserId_setEventIds.keySet().contains(mapEmployeeId_UserId.get(EmployeeId)) &&
		                        			mapCurrentPeriod_UserId_setEventIds.get(mapEmployeeId_UserId.get(EmployeeId)).contains(item.Id)
		                        			)
								    			mapEmployeeId_mapAccountId_setEventIds.get(EmployeeId).get(accountId).add(item.Id);
								    			
								    	if(	item.ActivityDate >= dateStartYear && item.ActivityDate <= date.today()  &&
								    	
			                        		mapEmployeeId_mapAccountId_setEventIds_YTD.get(EmployeeId) != null && 
			                        		mapEmployeeId_mapAccountId_setEventIds_YTD.get(EmployeeId).get(accountId) != null &&
			                        		
			                        		mapCurrentYear_UserId_setEventIds != null && 
			                        		mapCurrentYear_UserId_setEventIds.keySet().contains(mapEmployeeId_UserId.get(EmployeeId)) &&
		                        			mapCurrentYear_UserId_setEventIds.get(mapEmployeeId_UserId.get(EmployeeId)).contains(item.Id)
		                        			)
								    			mapEmployeeId_mapAccountId_setEventIds_YTD.get(EmployeeId).get(accountId).add(item.Id);
								    			
				    				}
				    			}
                        	}
                    	}
		    			
		    		}
		    	}
		    	} 
		    	if(mapEmployeeId_CompanyListMembers.keySet().size() > 0)
		    	{
		    		for(Id EmployeeId: mapEmployeeId_CompanyListMembers.keySet())
	    			{
	    				if( mapEmployeeId_CompanyListMembers.get(EmployeeId) != null)
	    				{
	    					for(Company_List_Member__c item : mapEmployeeId_CompanyListMembers.get(EmployeeId))
	    					{
	    						if(!mapEmployeeId_NearTermTransactions.keySet().contains(item.Company_List__r.Banker_Name__c))    mapEmployeeId_NearTermTransactions.put(item.Company_List__r.Banker_Name__c, new list<NearTermTransactions>());
                    			mapEmployeeId_NearTermTransactions.get(item.Company_List__r.Banker_Name__c).add(
                    												new NearTermTransactions(
                    														item.Company__r.Name,
                    														item.Date__c,
                    														item.Tier__c,
                    														item.Deal_Type__c,
                    														(	mapEmployeeId_mapAccountId_setEventIds.get(item.Company_List__r.Banker_Name__c) != null && 
                    															mapEmployeeId_mapAccountId_setEventIds.get(item.Company_List__r.Banker_Name__c).get(item.Company__c) != null 
                    															?
                    															mapEmployeeId_mapAccountId_setEventIds.get(item.Company_List__r.Banker_Name__c).get(item.Company__c).size() 
                    															: 
                    															0
                    														),
                    														(	mapEmployeeId_mapAccountId_setEventIds_YTD.get(item.Company_List__r.Banker_Name__c) != null && 
                    															mapEmployeeId_mapAccountId_setEventIds_YTD.get(item.Company_List__r.Banker_Name__c).get(item.Company__c) != null 
                    															?
                    															mapEmployeeId_mapAccountId_setEventIds_YTD.get(item.Company_List__r.Banker_Name__c).get(item.Company__c).size() 
                    															: 
                    															0
                    														),
                    														item.Description__c));
	    					}
	    				}
	    			}
		    	}
                system.debug('mapEmployeeId_NearTermTransactions = '+mapEmployeeId_NearTermTransactions);
            }
            
            
            
            //Senior Banker Scorecard Detailed – “Pitches YTD” Section
            map<Id,list<PitchesYTD>> mapEmployeeId_PitchesYTD = new map<Id,list<PitchesYTD>>();
            if(setEmployeeIdProjectIds.size() > 0)
            {
                for(Ibanking_Project__c item: [
                                SELECT  Id, Client__r.Name, Expense_Code__c, Moelis_Roles__c, RecordType.Name, Estimated_Fee_Revenue__c, Stage__c, Reason__c, Expected_Close_Date__c, Probability_Adjusted_Revenue__c,
                                        (Select Banker__c,Banker__r.Name,Role__c From Project_Resources__r WHERE Status__c = 'Active')
                                FROM Ibanking_Project__c
                                WHERE   /*MBS-39
                                		MDSC_isPipeline__c = 1 AND 
                                        /*MBS-31
                                        Latest_Invoice_Date__c = THIS_YEAR  AND Latest_Invoice_Date__c <= TODAY AND */
                                        DAY_ONLY(CreatedDate)  = THIS_YEAR  AND DAY_ONLY(CreatedDate) <= TODAY AND
                                        ID IN : setEmployeeIdProjectIds])
                {
                    strAttendees = '';
                    mapBanker_MoelisRoles = new map<Id,String>();
                    if(item.Project_Resources__r != null && item.Project_Resources__r.size() > 0)
                    {
                        for (Project_Resource__c pr : item.Project_Resources__r) 
                        {
                            if(pr.Banker__r.Name != null)
                            {
                                if(strAttendees.length() == 0)  strAttendees = pr.Banker__r.Name;
                                else strAttendees += ', '+pr.Banker__r.Name;
                            }
                        	if(pr.Role__c != null && pr.Banker__c != null) 	mapBanker_MoelisRoles.put(pr.Banker__c,pr.Role__c);
                        }
                    }
                    if(setEmployeeIdProjectIds.contains(item.Id) && mapEmployeeId_setProjectIds.keySet().size()>0)
                    {
                        for(Id eId : mapEmployeeId_setProjectIds.keySet())
                        {
                            if(mapEmployeeId_setProjectIds.get(eId).contains(item.Id))
                            {
                                if(!mapEmployeeId_PitchesYTD.keySet().contains(eId))    mapEmployeeId_PitchesYTD.put(eId, new list<PitchesYTD>());
                                mapEmployeeId_PitchesYTD.get(eId).add(new PitchesYTD(item.Client__r.Name,item.Expense_Code__c,(mapBanker_MoelisRoles.get(eId) != null ? mapBanker_MoelisRoles.get(eId) : ''),item.RecordType.Name,strAttendees,item.Estimated_Fee_Revenue__c,item.Stage__c,item.Reason__c,item.Probability_Adjusted_Revenue__c));
                            }
                        }
                    }
                }
                system.debug('mapEmployeeId_PitchesYTD = '+mapEmployeeId_PitchesYTD);
            }
          	
          	
          	
          	
          	
          	
          	
          	//Resource Utilization//////////////////////////////////////////////////////////////////
          	list<MDSC_Exclude_NonDealProjects__c> listMDSCExcludeNonDealProjects = MDSC_Exclude_NonDealProjects__c.getall().values();
          	set<String> MDSCExcludeNonDealProjects = new set<String>();
          	for(MDSC_Exclude_NonDealProjects__c item : listMDSCExcludeNonDealProjects)  MDSCExcludeNonDealProjects.add(item.Name);
          	//Resource Utilization Current Period - Summary///////
          	//Resource Utilization YTD - Summary///////
            map<id,Decimal> mapEmployeeId_sumDealHours = new map<id,Decimal>();
            map<id,Decimal> mapYTD_EmployeeId_sumDealHours = new map<id,Decimal>();
            
            map<String,Decimal> mapSBankerTitle_sumDealHours = new map<String,Decimal>();
            map<String,Decimal> mapSBankerTitle_sumDealHoursYTD = new map<String,Decimal>();
            map<String,Integer> mapSBankerTitle_countDeals = new map<String,Integer>();
            
          	if(mapEmployeeId_Employee.keySet().size() > 0)
            {     
                groupedResults = new list<AggregateResult>();
                groupedResults = [  
                                    SELECT /*Deal__c*/ Senior_Banker__c banker, SUM(Hours__c) sumHours
                                    FROM Time_Tracker__c
                                    WHERE   Time_Sheet_Summary__r.Week_Start_Date__c >=: curStartDate  AND Time_Sheet_Summary__r.Week_Start_Date__c <=: curEndDate AND
                                    		Senior_Banker__c IN : mapEmployeeId_Employee.keySet() AND
	                                        /*MBS-58*/
	                                        Non_Deal_Project__c NOT IN : MDSCExcludeNonDealProjects
                                            /*
                                            MBS-37
                                            Deal__c IN : setEmployeeIdProjectIds */
                                    GROUP BY Senior_Banker__c /*Deal__c*/];
                for (AggregateResult ar : groupedResults)
                {
                    if(!mapEmployeeId_sumDealHours.keySet().contains((Id)ar.get('banker'))) mapEmployeeId_sumDealHours.put((Id)ar.get('banker'), 0 );
                       mapEmployeeId_sumDealHours.put((Id)ar.get('banker'), mapEmployeeId_sumDealHours.get((Id)ar.get('banker')) + (Decimal)ar.get('sumHours') );
                }
                system.debug('mapEmployeeId_sumDealHours = '+mapEmployeeId_sumDealHours);
                
                // Resource Utilization YTD ///////
                groupedResults = new list<AggregateResult>();
                groupedResults = [  
                                    SELECT Senior_Banker__c banker, SUM(Hours__c) sumHours
                                    FROM Time_Tracker__c
                                    WHERE   Time_Sheet_Summary__r.Week_Start_Date__c = THIS_YEAR  AND Time_Sheet_Summary__r.Week_Start_Date__c <= TODAY AND
                                    		Senior_Banker__c IN : mapEmployeeId_Employee.keySet() AND
	                                       /*MBS-58*/
	                                       Non_Deal_Project__c NOT IN : MDSCExcludeNonDealProjects
                                    GROUP BY Senior_Banker__c];
                for (AggregateResult ar : groupedResults)
                {
                    if(!mapYTD_EmployeeId_sumDealHours.keySet().contains((Id)ar.get('banker'))) mapYTD_EmployeeId_sumDealHours.put((Id)ar.get('banker'), 0 );
                       mapYTD_EmployeeId_sumDealHours.put((Id)ar.get('banker'), mapYTD_EmployeeId_sumDealHours.get((Id)ar.get('banker')) + (Decimal)ar.get('sumHours') );
                }  
                  
            }
            if(mapEmployeeId_Title.values().size() > 0)
            {
            	//Resource Utilization (hrs) - Current Period - Average
           		groupedResults = new list<AggregateResult>();
           		groupedResults = [  
                                SELECT Senior_Banker__r.Title__c bankerTitle, SUM(Hours__c)     sumHours
                                FROM Time_Tracker__c
                                WHERE  Time_Sheet_Summary__r.Week_Start_Date__c >=: curStartDate  AND Time_Sheet_Summary__r.Week_Start_Date__c <=: curEndDate AND
                                       Senior_Banker__r.Title__c IN : mapEmployeeId_Title.values() AND
                                       Senior_Banker__r.Status__c = 'Active' AND 
                                       Senior_Banker__r.Business_Type__c = 'Advisory' AND
									   Senior_Banker__r.Group__c NOT IN :listExcludeGroups AND
                                       /*MBS-58*/
                                       Non_Deal_Project__c NOT IN : MDSCExcludeNonDealProjects
                                GROUP BY Senior_Banker__r.Title__c];
                for (AggregateResult ar : groupedResults)
                {
                	if(!mapSBankerTitle_sumDealHours.keySet().contains((String)ar.get('bankerTitle'))) mapSBankerTitle_sumDealHours.put((String)ar.get('bankerTitle'), 0 );
                    mapSBankerTitle_sumDealHours.put((String)ar.get('bankerTitle'), mapSBankerTitle_sumDealHours.get((String)ar.get('bankerTitle')) + (Decimal)ar.get('sumHours') );
                } 
                
                //Resource Utilization (hrs) - YTD - Average
           		groupedResults = new list<AggregateResult>();
             	groupedResults = [  
                                SELECT Senior_Banker__r.Title__c bankerTitle, SUM(Hours__c)     sumHours
                                FROM Time_Tracker__c
                                WHERE  Time_Sheet_Summary__r.Week_Start_Date__c = THIS_YEAR  AND Time_Sheet_Summary__r.Week_Start_Date__c <= TODAY AND
                                       /*Senior_Banker__c IN : mapEmployeeId_Employee.keySet()*/
                                       Senior_Banker__r.Title__c IN : mapEmployeeId_Title.values() AND
                                       /*MBS-52*/
                                       Senior_Banker__r.Status__c = 'Active' AND 
                                       Senior_Banker__r.Business_Type__c = 'Advisory' AND
									   Senior_Banker__r.Group__c NOT IN :listExcludeGroups AND
                                       /*MBS-58*/
                                       Non_Deal_Project__c NOT IN : MDSCExcludeNonDealProjects
                                GROUP BY Senior_Banker__r.Title__c];
                for (AggregateResult ar : groupedResults)
                {
                	if(!mapSBankerTitle_sumDealHoursYTD.keySet().contains((String)ar.get('bankerTitle'))) mapSBankerTitle_sumDealHoursYTD.put((String)ar.get('bankerTitle'), 0 );
                       mapSBankerTitle_sumDealHoursYTD.put((String)ar.get('bankerTitle'), mapSBankerTitle_sumDealHoursYTD.get((String)ar.get('bankerTitle')) + (Decimal)ar.get('sumHours') );
                } 
            }
            
           //Resources Utilization – Current Period – Detailed section
            map<Id,Set<String>> mapEmployeeId_setTitles = new map<Id,Set<String>>();
            
            Decimal tDealHours = 0;
            Decimal tDevHours = 0;
            Decimal tTotalHours = 0;
            Decimal tAverageUsage = 0;
            Decimal tVariance = 0;
            
            map<Id, map<String,Decimal>> mapEmployeeId_mapEmplTitle_SumDealHours = new map<Id, map<String,Decimal>>();
            map<Id, map<String,Decimal>> mapEmployeeId_mapEmplTitle_SumNonDealHours = new map<Id, map<String,Decimal>>();
            map<Id, list<Time_Tracker__c>> mapDealId_listTimeTracker = new map<Id, list<Time_Tracker__c>>();
           
           	map<String, Integer> mapSBankerTitle_SBankerTT =  new map<String, Integer>();
           	String sTitle = '';
            if(mapEmployeeId_Employee.keySet().size() > 0)
            {    
                for(Time_Tracker__c item : [  
                                SELECT Deal__r.Name,Time_Sheet_Summary__r.Employee__r.Title__c,Employee__c,Deal__c,Hours__c,Senior_Banker__c,Senior_Banker__r.Title__c
                                FROM Time_Tracker__c
                                WHERE   /*
                                		MBS-37
                                        (Employee__r.Title__c = 'Analyst' OR Employee__r.Title__c = 'Associate') AND
                                        */
                                        Time_Sheet_Summary__r.Week_Start_Date__c >=: curStartDate  AND Time_Sheet_Summary__r.Week_Start_Date__c <=: curEndDate AND
                                        /*
                                        MBS-23
                                        Deal__c IN : setEmployeeIdProjectIds
                                        */
                                        Senior_Banker__r.Status__c = 'Active' AND 
                                        Senior_Banker__r.Business_Type__c = 'Advisory' AND
										Senior_Banker__r.Group__c NOT IN :listExcludeGroups AND 
                                        Senior_Banker__c IN : mapEmployeeId_Employee.keySet() AND
                                        /*MBS-58*/
                                        Non_Deal_Project__c NOT IN : MDSCExcludeNonDealProjects
                               ORDER BY Deal__c,Senior_Banker__c])
                 {
                 	if(item.Time_Sheet_Summary__r.Employee__r.Title__c == 'Senior Vice President' || item.Time_Sheet_Summary__r.Employee__r.Title__c == 'Executive Director')
                 			sTitle = 'Senior Vice President/Executive Director';
                 	else 	sTitle = item.Time_Sheet_Summary__r.Employee__r.Title__c;
                 	
                 	if(item.Deal__r.Name == 'Non-Deal Project')
                 	{
                 		if(!mapEmployeeId_mapEmplTitle_SumNonDealHours.keySet().contains(item.Senior_Banker__c)) 
                 			mapEmployeeId_mapEmplTitle_SumNonDealHours.put(item.Senior_Banker__c, new map<String,Decimal>());
                 		if(!mapEmployeeId_mapEmplTitle_SumNonDealHours.get(item.Senior_Banker__c).keySet().contains(sTitle))
                 			mapEmployeeId_mapEmplTitle_SumNonDealHours.get(item.Senior_Banker__c).put(sTitle,0);
                 	
                 		mapEmployeeId_mapEmplTitle_SumNonDealHours.get(item.Senior_Banker__c).put(	sTitle, 
                 																				mapEmployeeId_mapEmplTitle_SumNonDealHours.get(item.Senior_Banker__c).get(sTitle) + (item.Hours__c != null ? item.Hours__c : 0 ));
                 	}
               		else
               		{
                 		if(!mapEmployeeId_mapEmplTitle_SumDealHours.keySet().contains(item.Senior_Banker__c)) 
                 			mapEmployeeId_mapEmplTitle_SumDealHours.put(item.Senior_Banker__c, new map<String,Decimal>());
                 		if(!mapEmployeeId_mapEmplTitle_SumDealHours.get(item.Senior_Banker__c).keySet().contains(sTitle))
                 			mapEmployeeId_mapEmplTitle_SumDealHours.get(item.Senior_Banker__c).put(sTitle,0);
                 	
                 		mapEmployeeId_mapEmplTitle_SumDealHours.get(item.Senior_Banker__c).put(	sTitle, 
                 																				mapEmployeeId_mapEmplTitle_SumDealHours.get(item.Senior_Banker__c).get(sTitle) + (item.Hours__c != null ? item.Hours__c : 0 ));
               		}
                    if(!mapEmployeeId_setTitles.keySet().contains(item.Senior_Banker__c))	mapEmployeeId_setTitles.put(item.Senior_Banker__c, new set<String>());
                 	mapEmployeeId_setTitles.get(item.Senior_Banker__c).add(sTitle);
                 }
                system.debug('mapEmployeeId_mapEmplTitle_SumDealHours = '+mapEmployeeId_mapEmplTitle_SumDealHours);
                system.debug('mapEmployeeId_mapEmplTitle_SumNonDealHours = '+mapEmployeeId_mapEmplTitle_SumNonDealHours);
            
            }
            
            //Resource Utilization – Current Period – Detailed section ("Average Usage")
            map<String,map<String,Decimal>> mapSBankerTitle_mapEmployeeTitle_countSBankerHours = new map<String,map<String,Decimal>>();
            map<String,map<String,Integer>> mapSBankerTitle_mapEmployeeTitle_countSBanker = new map<String,map<String,Integer>>();
            if(mapEmployeeId_Title.values().size() > 0)
            {
            	sTitle = '';
          		for(Time_Tracker__c item : [  
                                SELECT Time_Sheet_Summary__r.Employee__r.Title__c,Hours__c,Senior_Banker__r.Title__c
                                FROM Time_Tracker__c
                                WHERE  Time_Sheet_Summary__r.Week_Start_Date__c >=: curStartDate  AND Time_Sheet_Summary__r.Week_Start_Date__c <=: curEndDate AND
	                                   Senior_Banker__r.Title__c IN : mapEmployeeId_Title.values() AND
	                                   Senior_Banker__r.Status__c = 'Active' AND 
                                       Senior_Banker__r.Business_Type__c = 'Advisory' AND
									   Senior_Banker__r.Group__c NOT IN :listExcludeGroups AND
                                       /*MBS-58*/
                                       Non_Deal_Project__c NOT IN : MDSCExcludeNonDealProjects
                               ORDER BY Senior_Banker__r.Title__c,Time_Sheet_Summary__r.Employee__r.Title__c])
                 {
                 	if(item.Time_Sheet_Summary__r.Employee__r.Title__c == 'Senior Vice President' || item.Time_Sheet_Summary__r.Employee__r.Title__c == 'Executive Director')
                 			sTitle = 'Senior Vice President/Executive Director';
                 	else 	sTitle = item.Time_Sheet_Summary__r.Employee__r.Title__c;
                 	
                 	if(!mapSBankerTitle_mapEmployeeTitle_countSBankerHours.keySet().contains(item.Senior_Banker__r.Title__c)) 
                 		mapSBankerTitle_mapEmployeeTitle_countSBankerHours.put(item.Senior_Banker__r.Title__c, new map<String,Decimal>());
                 	if(!mapSBankerTitle_mapEmployeeTitle_countSBankerHours.get(item.Senior_Banker__r.Title__c).keySet().contains(sTitle))
                 		mapSBankerTitle_mapEmployeeTitle_countSBankerHours.get(item.Senior_Banker__r.Title__c).put(sTitle,0);
                 	mapSBankerTitle_mapEmployeeTitle_countSBankerHours.get(item.Senior_Banker__r.Title__c).put(	sTitle, mapSBankerTitle_mapEmployeeTitle_countSBankerHours.get(item.Senior_Banker__r.Title__c).get(sTitle) + (Decimal)(item.Hours__c != null ? item.Hours__c : 0));	
                 	
                 	if(!mapSBankerTitle_mapEmployeeTitle_countSBanker.keySet().contains(item.Senior_Banker__r.Title__c)) 
                 		mapSBankerTitle_mapEmployeeTitle_countSBanker.put(item.Senior_Banker__r.Title__c, new map<String,Integer>());
                 	if(!mapSBankerTitle_mapEmployeeTitle_countSBanker.get(item.Senior_Banker__r.Title__c).keySet().contains(sTitle))
                 		mapSBankerTitle_mapEmployeeTitle_countSBanker.get(item.Senior_Banker__r.Title__c).put(sTitle,0);
                 	mapSBankerTitle_mapEmployeeTitle_countSBanker.get(item.Senior_Banker__r.Title__c).put(	sTitle, mapSBankerTitle_mapEmployeeTitle_countSBanker.get(item.Senior_Banker__r.Title__c).get(sTitle) + 1);
                 }
            }
             
            
            
			////////////////////////////////////////////////////////////////////
            //generation of the report for all selected bankers
            for(curEmployee curEmployeeProfile : listSBS_Reports)
            {
                /* 
                Senior Banker Scorecard Summary 
                */
                
                //New Business Meetings/Calls//////////////////////////
                countEvents = 0;
                if(mapEmployeeId_countEvents.get(curEmployeeProfile.ID) != null) countEvents = mapEmployeeId_countEvents.get(curEmployeeProfile.ID);
                countCallLogs = 0;
                if(mapEmployeeId_countCallLogs.get(curEmployeeProfile.ID) != null) countCallLogs = mapEmployeeId_countCallLogs.get(curEmployeeProfile.ID);
                
                countEventsMD = 0;
                if(mapSBankerTitle_countEvents.get(curEmployeeProfile.Title) != null)   countEventsMD = mapSBankerTitle_countEvents.get(curEmployeeProfile.Title);
                countCallLogsMD = 0;
                if(mapSBankerTitle_countCallLogs.get(curEmployeeProfile.Title) != null) countCallLogsMD = mapSBankerTitle_countCallLogs.get(curEmployeeProfile.Title);
                /*MBS-56*/
                countMDBankers = 0;
                if(mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title) != null) countMDBankers = mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title);
                
                curEmployeeProfile.NBMC_Banker = countEvents + countCallLogs;
                if(countMDBankers != 0) curEmployeeProfile.NBMC_Average = (Decimal)((Decimal)countEventsMD + (Decimal)countCallLogsMD) / countMDBankers;
                curEmployeeProfile.NBMC_Variance = curEmployeeProfile.NBMC_Banker - curEmployeeProfile.NBMC_Average;
                
                //Pitches/////////////////////////////////////////////
                curEmployeeProfile.Pitches_Banker = (mapEmployeeId_countProjects.get(curEmployeeProfile.ID) != null ? mapEmployeeId_countProjects.get(curEmployeeProfile.ID) : 0);
                curEmployeeProfile.Pitches_Average = (mapSBankerTitle_averagePitches.get(curEmployeeProfile.Title) != null ? mapSBankerTitle_averagePitches.get(curEmployeeProfile.Title) : 0);
                curEmployeeProfile.Pitches_Variance = (curEmployeeProfile.Pitches_Banker != null ?curEmployeeProfile.Pitches_Banker:0) - (curEmployeeProfile.Pitches_Average != null ? curEmployeeProfile.Pitches_Average:0);
                            
                //Resource Utilization////////////////////////////////
                curEmployeeProfile.RU_Banker = (mapEmployeeId_sumDealHours.get(curEmployeeProfile.Id) != null ? mapEmployeeId_sumDealHours.get(curEmployeeProfile.Id) : 0);
                if(	mapSBankerTitle_sumDealHours.get(curEmployeeProfile.Title) != null && 
                		mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title) != null && 
                		mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title) != 0 )
                {
                	curEmployeeProfile.RU_Average = mapSBankerTitle_sumDealHours.get(curEmployeeProfile.Title) / mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title);
                }
                curEmployeeProfile.RU_Variance = (curEmployeeProfile.RU_Banker != null ? curEmployeeProfile.RU_Banker:0) - (curEmployeeProfile.RU_Average != null ? curEmployeeProfile.RU_Average:0);
                
                ///LiveMandates //////////////////////////////////////
                curEmployeeProfile.LiveMandates_Banker = (mapLM_EmployeeId_countProjects.get(curEmployeeProfile.ID) != null ? mapLM_EmployeeId_countProjects.get(curEmployeeProfile.ID) : 0 );
                curEmployeeProfile.LiveMandates_Average = (mapLM_SBankerTitle_averagePitches.get(curEmployeeProfile.Title) != null ? mapLM_SBankerTitle_averagePitches.get(curEmployeeProfile.Title) : 0);
                curEmployeeProfile.LiveMandates_Variance = (curEmployeeProfile.LiveMandates_Banker != null ?curEmployeeProfile.LiveMandates_Banker:0) - (curEmployeeProfile.LiveMandates_Average != null ? curEmployeeProfile.LiveMandates_Average:0);
                
                //AverageFee//////////////////////////////////////////
                if(curEmployeeProfile.LiveMandates_Banker!= null && curEmployeeProfile.LiveMandates_Banker != 0)curEmployeeProfile.AverageFee_Banker    = mapAF_EmployeeId_countEFees.get(curEmployeeProfile.ID) / curEmployeeProfile.LiveMandates_Banker;
                curEmployeeProfile.AverageFee_Average = (mapAF_SBankerTitle_averageEFees.get(curEmployeeProfile.Title) != null ? mapAF_SBankerTitle_averageEFees.get(curEmployeeProfile.Title) : 0 );
                curEmployeeProfile.AverageFee_Variance = (curEmployeeProfile.AverageFee_Banker != null ? curEmployeeProfile.AverageFee_Banker : 0) - (curEmployeeProfile.AverageFee_Average != null ?curEmployeeProfile.AverageFee_Average:0);
                
                //YTD New Business Meetings/Call /////////////////////
                countEvents = 0;
                if(mapYTD_EmployeeId_countEvents.get(curEmployeeProfile.ID) != null) countEvents = mapYTD_EmployeeId_countEvents.get(curEmployeeProfile.ID);
                countCallLogs = 0;
                if(mapYTD_EmployeeId_countCallLogs.get(curEmployeeProfile.ID) != null) countCallLogs = mapYTD_EmployeeId_countCallLogs.get(curEmployeeProfile.ID);
                countEventsMD = 0;
                if(mapYTD_SBankerTitle_countEvents.get(curEmployeeProfile.Title) != null)   countEventsMD = mapYTD_SBankerTitle_countEvents.get(curEmployeeProfile.Title);
                countCallLogsMD = 0;
                if(mapYTD_SBankerTitle_countCallLogs.get(curEmployeeProfile.Title) != null) countCallLogsMD = mapYTD_SBankerTitle_countCallLogs.get(curEmployeeProfile.Title);
               
                curEmployeeProfile.YTD_NBMC_Banker = countEvents + countCallLogs;
                /*MBS-56*/
                countMDBankers = 0;//countMDBankers - calculated as in New Business Meetings/Calls
                if(mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title) != null) countMDBankers = mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title);
                if(countMDBankers != 0) curEmployeeProfile.YTD_NBMC_Average = (Decimal)((Decimal)countEventsMD + (Decimal)countCallLogsMD) / countMDBankers;
                curEmployeeProfile.YTD_NBMC_Variance = curEmployeeProfile.YTD_NBMC_Banker - curEmployeeProfile.YTD_NBMC_Average;
                
                //YTD_Pitches////////////////////////////////////////
                curEmployeeProfile.YTD_Pitches_Banker = (mapYTD_EmployeeId_countProjects.get(curEmployeeProfile.ID) != null ? mapYTD_EmployeeId_countProjects.get(curEmployeeProfile.ID) : 0 );
                curEmployeeProfile.YTD_Pitches_Average = (mapYTD_SBankerTitle_averagePitches.get(curEmployeeProfile.Title) != null ? mapYTD_SBankerTitle_averagePitches.get(curEmployeeProfile.Title) : 0);
                curEmployeeProfile.YTD_Pitches_Variance = (curEmployeeProfile.YTD_Pitches_Banker != null ?curEmployeeProfile.YTD_Pitches_Banker:0) - (curEmployeeProfile.YTD_Pitches_Average != null ? curEmployeeProfile.YTD_Pitches_Average:0);
               
                //YTD Resource Utilization //////////////////////////
                curEmployeeProfile.YTD_RU_Banker = (mapYTD_EmployeeId_sumDealHours.get(curEmployeeProfile.Id) != null ? mapYTD_EmployeeId_sumDealHours.get(curEmployeeProfile.Id) : 0);
                if(	mapSBankerTitle_sumDealHoursYTD.get(curEmployeeProfile.Title) != null && 
                	mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title) != null && 
                	mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title) != 0 )
                {
                	curEmployeeProfile.YTD_RU_Average = mapSBankerTitle_sumDealHoursYTD.get(curEmployeeProfile.Title) / mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title);
                }
                curEmployeeProfile.YTD_RU_Variance = (curEmployeeProfile.YTD_RU_Banker != null ? curEmployeeProfile.YTD_RU_Banker:0) - (curEmployeeProfile.YTD_RU_Average != null ? curEmployeeProfile.YTD_RU_Average:0);
                
                /* 
                Senior Banker Scorecard Detail 
                */ 
                
                //Senior Banker Scorecard Detailed – Current Pipeline Section
                if(mapEmployeeId_FeesInvoiceds_CPS.get(curEmployeeProfile.Id) != null)
                {
                    for(FeesInvoiced item : mapEmployeeId_FeesInvoiceds_CPS.get(curEmployeeProfile.Id))
                    {
                        curEmployeeProfile.detailedCurrentPipeline.add(item);
                        if(mapEmployeeId_subtotalFeeYTD_CPS.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.subtotalFeeYTD_CPS = mapEmployeeId_subtotalFeeYTD_CPS.get(curEmployeeProfile.Id);
                        if(mapEmployeeId_subtotalExpansesYTD_CPS.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.subtotalExpansesYTD_CPS = mapEmployeeId_subtotalExpansesYTD_CPS.get(curEmployeeProfile.Id);
                        if(mapEmployeeId_subtotalFeeRevenue_CPS.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.subtotalFeeRevenue_CPS = mapEmployeeId_subtotalFeeRevenue_CPS.get(curEmployeeProfile.Id);
                        if(mapEmployeeId_subtotalPARevenue_CPS.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.subtotalPARevenue_CPS = mapEmployeeId_subtotalPARevenue_CPS.get(curEmployeeProfile.Id);    
                    } 
                }
                //Senior Banker Scorecard Detailed – Other Fees Invoiced Section
                if(mapEmployeeId_FeesInvoiceds_OFI.get(curEmployeeProfile.Id) != null)
                {
                    for(FeesInvoiced item : mapEmployeeId_FeesInvoiceds_OFI.get(curEmployeeProfile.Id))
                    {
                        curEmployeeProfile.detailedOtherFeesInvoiced.add(item);
                        if(mapEmployeeId_subtotalFeeYTD_OFI.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.subtotalFeeYTD_OFI = mapEmployeeId_subtotalFeeYTD_OFI.get(curEmployeeProfile.Id);
                        if(mapEmployeeId_subtotalExpansesYTD_OFI.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.subtotalExpansesYTD_OFI = mapEmployeeId_subtotalExpansesYTD_OFI.get(curEmployeeProfile.Id);
                        if(mapEmployeeId_subtotalFeeRevenue_OFI.get(curEmployeeProfile.Id) != null)
                            curEmployeeProfile.subtotalFeeRevenue_OFI = mapEmployeeId_subtotalFeeRevenue_OFI.get(curEmployeeProfile.Id);
                    }
                }
				// “Client Meetings – Current Period” Section
               	if(mapEmployeeId_listClientMeetingsCurrentPeriod.get(curEmployeeProfile.Id) != null)
                {
                    for(clientMeetingsCurrentPeriod item : mapEmployeeId_listClientMeetingsCurrentPeriod.get(curEmployeeProfile.Id))
                    {
                        curEmployeeProfile.listClientMeetingsCurrentPeriod.add(item);
                    }
                } 
                //“Near Term Transactions” Section
                if(mapEmployeeId_NearTermTransactions.get(curEmployeeProfile.Id) != null)
                {
                    for(NearTermTransactions item : mapEmployeeId_NearTermTransactions.get(curEmployeeProfile.Id))
                    {
                        curEmployeeProfile.listNearTermTransactions.add(item);
                    }
                }
                //“Pitches YTD” Section
                if(mapEmployeeId_PitchesYTD.get(curEmployeeProfile.Id) != null)
                {
                    for(PitchesYTD item : mapEmployeeId_PitchesYTD.get(curEmployeeProfile.Id))
                    {
                        curEmployeeProfile.listPitchesYTD.add(item);
                    }
                }
                //Forward Calendar – One Month
                if(mapEmployeeId_listForwardCalendarOneMonth.get(curEmployeeProfile.Id) != null)
                {
                    for(clientMeetingsCurrentPeriod item : mapEmployeeId_listForwardCalendarOneMonth.get(curEmployeeProfile.Id))
                    {
                        curEmployeeProfile.listForwardCalendarOneMonth.add(item);
                    }
                }
            	//Resources Utilization – Current Period	
            	tDealHours = 0;
                tDevHours = 0;
                tTotalHours = 0;
                tAverageUsage = 0;
                tVariance = 0;
               	set<String> employeeJuniorBankerTitles = new 	set<String>();
	        	employeeJuniorBankerTitles.add('Senior Vice President/Executive Director');
	        	employeeJuniorBankerTitles.add('Vice President');
	        	employeeJuniorBankerTitles.add('Associate');
	        	employeeJuniorBankerTitles.add('Analyst');
	        	employeeJuniorBankerTitles.add('Intern');
	           	Schema.DescribeFieldResult fieldResult = Employee_Profile__c.Title__c.getDescribe();
	        	List<Schema.PicklistEntry> employeeTitlePickilstValues = fieldResult.getPicklistValues();
	        	sTitle = '';
	        	for (Schema.PicklistEntry pVal : employeeTitlePickilstValues)
	        	{
	        		if(pVal.value == 'Senior Vice President')	sTitle = 'Senior Vice President/Executive Director';
	        		else sTitle = pVal.value;
	        		
					tDealHours = tDevHours = tTotalHours = tAverageUsage = 0;
					if(	mapEmployeeId_mapEmplTitle_SumDealHours.get(curEmployeeProfile.Id) != null &&
                      	  	mapEmployeeId_mapEmplTitle_SumDealHours.get(curEmployeeProfile.Id).get(sTitle)!= null
                     )	tDealHours = mapEmployeeId_mapEmplTitle_SumDealHours.get(curEmployeeProfile.Id).get(sTitle);
                       	
			        if(	mapEmployeeId_mapEmplTitle_SumNonDealHours.get(curEmployeeProfile.Id) != null &&
	                    	mapEmployeeId_mapEmplTitle_SumNonDealHours.get(curEmployeeProfile.Id).get(sTitle)!= null
	                )	tDevHours = mapEmployeeId_mapEmplTitle_SumNonDealHours.get(curEmployeeProfile.Id).get(sTitle);
	                              
					tTotalHours =   tDealHours + tDevHours;
			             
		            if(	mapSBankerTitle_mapEmployeeTitle_countSBankerHours.get(curEmployeeProfile.Title) != null &&
		            	mapSBankerTitle_mapEmployeeTitle_countSBankerHours.get(curEmployeeProfile.Title).get(sTitle) != null &&
		            	mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title) != null &&
			            mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title) != 0
			        )	tAverageUsage = mapSBankerTitle_mapEmployeeTitle_countSBankerHours.get(curEmployeeProfile.Title).get(sTitle) / mapSBankerTitle_countSBankers.get(curEmployeeProfile.Title); 
		            	
		            	tVariance = tTotalHours - tAverageUsage;
		                curEmployeeProfile.totDealHours += tDealHours;
		                curEmployeeProfile.totDevHours += tDevHours;
		                curEmployeeProfile.totTotalHours += tTotalHours;
		                curEmployeeProfile.totAverageUsage += tAverageUsage;
		                curEmployeeProfile.totVariance += tVariance;
		           /*mapEmployeeId_setTitles.get(curEmployeeProfile.Id) !=null && mapEmployeeId_setTitles.get(curEmployeeProfile.Id).contains(Stitle)*/
		           	if(	employeeJuniorBankerTitles.contains(sTitle) || tAverageUsage >0) 
	        		{
		             	curEmployeeProfile.listResourcesUtilizationCurrentPeriod.add(new ResourcesUtilizationCurrentPeriod(sTitle,tDealHours,tDevHours,tTotalHours,tAverageUsage,tVariance));
	        		}
	        	}
            }//end for : curEmployeeProfile
    	} //end if
    }  // end constructor 
    
    
    
    private void getEmployeeOrderedList()
    {
    	if(this.filter != null && this.subFilters != null && this.curStartDate != null && this.curEndDate != null)
        {
        	listMDSCTitles = SL_SeniorBankerScorecard_Dashboard.getSeniorBankerTitles();
    		listExcludeGroups = SL_SeniorBankerScorecard_Dashboard.getExcludeGroups();
            if(this.filter == 'banker')
            {
                for(Employee_Profile__c item : [ 
                        SELECT Id,Title__c,MD_Promotion_Date__c,Start_Date__c,User_ID__c, Office_Location__c,Last_Name__c, Group__c,First_Name__c
                        FROM Employee_Profile__c
                        WHERE 	Status__c = 'Active' AND 
                        		Title__c IN : listMDSCTitles AND 
                        		Business_Type__c = 'Advisory' AND
								Group__c NOT IN :listExcludeGroups AND 
                        		Id IN : this.subFilters
                        ORDER BY Last_Name__c, First_Name__c])
                {
                    mapEmployeeId_Employee.put(item.Id,item);
                    listSBS_Reports.add(new curEmployee(item.Id,item.Title__c,item.Last_Name__c,item.First_Name__c,item.Office_Location__c,item.User_ID__c,item.MD_Promotion_Date__c,item.Start_Date__c,item.Group__c));
                }
            }
            else if(this.filter == 'title')
            {
                for(Employee_Profile__c item : [ 
                        SELECT Id,Title__c,MD_Promotion_Date__c,Start_Date__c,User_ID__c, Office_Location__c,Last_Name__c, Group__c,First_Name__c
                        FROM Employee_Profile__c
                        WHERE 	Status__c = 'Active' AND 
                        		Title__c IN : listMDSCTitles AND 
                        		Business_Type__c = 'Advisory' AND
								Group__c NOT IN :listExcludeGroups AND 
                        		Title__c IN : this.subFilters
                        ORDER BY Title__c, Last_Name__c, First_Name__c])
                {
                    mapEmployeeId_Employee.put(item.Id,item);
                    listSBS_Reports.add(new curEmployee(item.Id,item.Title__c,item.Last_Name__c,item.First_Name__c,item.Office_Location__c,item.User_ID__c,item.MD_Promotion_Date__c,item.Start_Date__c,item.Group__c));
                }
            }
            else if(this.filter == 'group')
            {
                for(Employee_Profile__c item : [ 
                        SELECT Id,Title__c,MD_Promotion_Date__c,Start_Date__c,User_ID__c, Office_Location__c,Last_Name__c, Group__c,First_Name__c
                        FROM Employee_Profile__c
                        WHERE 	Status__c = 'Active' AND 
                        		Title__c IN : listMDSCTitles AND 
                        		Business_Type__c = 'Advisory' AND
								Group__c NOT IN :listExcludeGroups AND 
                        		Group__c IN : this.subFilters
                        ORDER BY Group__c, Last_Name__c, First_Name__c])
                {
                    mapEmployeeId_Employee.put(item.Id,item);
                    listSBS_Reports.add(new curEmployee(item.Id,item.Title__c,item.Last_Name__c,item.First_Name__c,item.Office_Location__c,item.User_ID__c,item.MD_Promotion_Date__c,item.Start_Date__c,item.Group__c));
                    
                }
            }
            else if(this.filter == 'location')
            {
                for(Employee_Profile__c item : [ 
                        SELECT Id,Title__c,MD_Promotion_Date__c,Start_Date__c,User_ID__c, Office_Location__c,Last_Name__c, Group__c,First_Name__c 
                        FROM Employee_Profile__c
                        WHERE 	Status__c = 'Active' AND 
                        		Title__c IN : listMDSCTitles AND 
                        		Business_Type__c = 'Advisory' AND
								Group__c NOT IN :listExcludeGroups AND 
                        		Office_Location__c IN : this.subFilters
                        ORDER BY Office_Location__c, Last_Name__c, First_Name__c])
                {
                    mapEmployeeId_Employee.put(item.Id,item);
                    listSBS_Reports.add(new curEmployee(item.Id,item.Title__c,item.Last_Name__c,item.First_Name__c,item.Office_Location__c,item.User_ID__c,item.MD_Promotion_Date__c,item.Start_Date__c,item.Group__c));
                }
            }
        }
    }
    
    
    
    
    
    
    //main class for one current Senior Banker
    public class curEmployee 
    {
        public Id Id {get; set;}
        public string Title {get; set;}
        public string Last_Name {get; set;}
        public string First_Name {get; set;}
        public string Office_Location {get; set;}
        public Id User_ID {get; set;}
        public Date MD_Promotion_Date {get; set;}
        public Date Start_Date {get; set;}
        public string Groups {get; set;}
        
        //Current Period Section 
        //NewBusinessMeetingsCalls
        public Integer NBMC_Banker {get; private set;}
        public Double NBMC_Average {get; private set;}
        public Double NBMC_Variance {get; private set;}
        //Pitches 
        public Integer Pitches_Banker {get; private set;}
        public Decimal Pitches_Average {get; private set;}
        public Decimal Pitches_Variance {get; private set;}
        //Resource Utilization  
        public Decimal RU_Banker {get; private set;}
        public Decimal RU_Average {get; private set;}
        public Decimal RU_Variance {get; private set;}
        //Year To Date Section 
        public Integer LiveMandates_Banker {get; private set;}
        public Decimal LiveMandates_Average {get; private set;}
        public Decimal LiveMandates_Variance {get; private set;}
        public Decimal AverageFee_Banker {get; private set;}
        public Decimal AverageFee_Average {get; private set;}
        public Decimal AverageFee_Variance {get; private set;}
        //NewBusinessMeetingsCalls
        public Integer YTD_NBMC_Banker {get; private set;}
        public Decimal YTD_NBMC_Average {get; private set;}
        public Decimal YTD_NBMC_Variance {get; private set;}
        //Pitches 
        public Integer YTD_Pitches_Banker {get; private set;} 
        public Decimal YTD_Pitches_Average {get; private set;}
        public Decimal YTD_Pitches_Variance {get; private set;}
        //Resource Utilization  
        public Decimal YTD_RU_Banker {get; private set;}
        public Decimal YTD_RU_Average {get; private set;}
        public Decimal YTD_RU_Variance {get; private set;}
        //Senior Banker Scorecard Detailed – Current Pipeline Section
        public list<FeesInvoiced> detailedCurrentPipeline {get; private set;}
        public Decimal subtotalFeeYTD_CPS   {get; private set;}
        public Decimal subtotalExpansesYTD_CPS  {get; private set;}
        public Decimal subtotalFeeRevenue_CPS   {get; private set;}
        public Decimal subtotalPARevenue_CPS   {get; private set;}
        //Senior Banker Scorecard Detailed – Other Fees Invoiced Section
        public list<FeesInvoiced> detailedOtherFeesInvoiced {get; private set;}
        public Decimal subtotalFeeYTD_OFI   {get; private set;}
        public Decimal subtotalExpansesYTD_OFI  {get; private set;}
        public Decimal subtotalFeeRevenue_OFI   {get; private set;}
        //Client Meetings – Current Period Section
        public list<clientMeetingsCurrentPeriod> listClientMeetingsCurrentPeriod {get; private set;}
        //“Pitches YTD” Section
        public list<PitchesYTD> listPitchesYTD  {get; private set;}
        //Forward Calendar – One Month
        public list<clientMeetingsCurrentPeriod> listForwardCalendarOneMonth {get; private set;}
        //Resources Utilization – Current Period
        public list<ResourcesUtilizationCurrentPeriod> listResourcesUtilizationCurrentPeriod {get; private set;}
        //Near Term Transactions
        public list<NearTermTransactions> listNearTermTransactions {get; private set;}
        public Decimal totDealHours     {get; private set;}
        public Decimal totDevHours  {get; private set;}
        public Decimal totTotalHours    {get; private set;}
        public Decimal totAverageUsage  {get; private set;}
        public Decimal totVariance  {get; private set;}
        
        public curEmployee(Id p_Id,string p_Title,string p_Last_Name,string p_First_Name,string p_Office_Location,Id p_User_ID,Date p_MD_Promotion_Date,Date p_Start_Date, String p_Groups)
        {
            Id = p_Id;
            Title = p_Title;
            Last_Name = p_Last_Name;
            First_Name = p_First_Name;
            Office_Location = p_Office_Location;
            User_ID = p_User_ID;
            MD_Promotion_Date = p_MD_Promotion_Date;
            Start_Date  = p_Start_Date;     
            Groups = p_Groups;  
            
            detailedCurrentPipeline = new list<FeesInvoiced>();
            detailedOtherFeesInvoiced = new list<FeesInvoiced>();
            listClientMeetingsCurrentPeriod = new list<clientMeetingsCurrentPeriod>();
            listPitchesYTD = new list<PitchesYTD>();
            listForwardCalendarOneMonth = new list<clientMeetingsCurrentPeriod>();
            listResourcesUtilizationCurrentPeriod = new list<ResourcesUtilizationCurrentPeriod>();
            listNearTermTransactions = new list<NearTermTransactions>();
            
            NBMC_Banker = 0;
            NBMC_Average = 0;
            NBMC_Variance = 0;
            Pitches_Banker = 0;
            Pitches_Average = 0;
            Pitches_Variance = 0;
            RU_Banker = RU_Average = RU_Variance = 0;
            YTD_NBMC_Banker = YTD_Pitches_Banker = LiveMandates_Banker = 0;
            AverageFee_Banker = AverageFee_Average = AverageFee_Variance = 0;
            LiveMandates_Average = LiveMandates_Variance = 0;
            YTD_NBMC_Average = YTD_NBMC_Variance = 0;
            YTD_Pitches_Average = YTD_Pitches_Variance = 0;
            YTD_RU_Banker = YTD_RU_Average = YTD_RU_Variance = 0;
            
            subtotalFeeYTD_CPS = subtotalExpansesYTD_CPS = subtotalFeeRevenue_CPS = subtotalPARevenue_CPS = 0;
            subtotalFeeYTD_OFI = subtotalExpansesYTD_OFI = subtotalFeeRevenue_OFI = 0;

            totDealHours = 0;
            totDevHours = 0;
            totTotalHours = 0;
            totAverageUsage = 0;
            totVariance = 0;
        }
    } 
    
    class FeesInvoiced
    {
        public String company {get; set;}
        public String projectCode {get; set;}
        public String role {get; set;}
        public String stage {get; set;}
        public Decimal revenue {get; set;}
        public Decimal revenueFees {get; set;}
        public Decimal revenueExpenses {get; set;}
        public String timing {get; set;}
        public String probability {get; set;}
        public Decimal PARevenu {get; set;}
        
        public FeesInvoiced(String p_company,String p_projectCode,String p_role,String p_stage,Decimal p_revenue,Decimal p_revenueFees,Decimal p_revenueExpenses,String p_timing,String p_probability,Decimal p_PARevenu)
        {
            company = p_company;
            projectCode = p_projectCode;
            role = p_role;
            stage = p_stage;
            revenue = (p_revenue != null ? p_revenue : 0);//p_revenue;
            revenueFees = p_revenueFees;
            revenueExpenses = p_revenueExpenses;
            timing = p_timing;
            probability = p_probability;
            PARevenu = p_PARevenu;
        }
    }
    
    class clientMeetingsCurrentPeriod
    {
        public String title {get; set;}
        public String company {get; set;}
        public String subject {get; set;}
        public String activityType {get; set;}
        public String description {get; set;}
        public String clientContact {get; set;}
        public String attendees {get; set;}
        public Date mdate {get; set;}
        public clientMeetingsCurrentPeriod(String p_title,String p_company,String p_subject,String p_activityType,String p_description,String p_clientContact,String p_attendees, Date p_date)
        {
            title = p_title;
            company = p_company;
            subject = p_subject;
            activityType = p_activityType;
            description = p_description;
            clientContact = p_clientContact;
            attendees = p_attendees;
            mdate = p_date;
        }
    }   
    
    class PitchesYTD
    {
        public String company {get; set;}
        public String projectCode {get; set;}
        public String role {get; set;}
        public String recordType {get; set;}
        public String team {get; set;}
        public Decimal revenue {get; set;}
        public String stage {get; set;}
        public String reason {get; set;}
        public Decimal PARevenu {get; set;}
        public PitchesYTD(String p_company,String p_projectCode,String p_role,String p_recordType,String p_team,Decimal p_revenue,String p_stage,String p_reason,Decimal p_PARevenu)
        {
            company = p_company;
            projectCode = p_projectCode;
            role = p_role;
            recordType = p_recordType;
            team = p_team;
            revenue = (p_revenue != null ? p_revenue : 0);//p_revenue;
            stage = p_stage;
            reason = p_reason;
            PARevenu = p_PARevenu;
        }
    }
    
    class ResourcesUtilizationCurrentPeriod
    {
        public String title {get; set;}
        public Decimal dealHours {get; set;}
        public Decimal devHours {get; set;}
        public Decimal totalHours {get; set;}
        public Decimal averageUsage {get; set;}
        public Decimal variance {get; set;}
        public ResourcesUtilizationCurrentPeriod(String p_title,Decimal p_dealHours,Decimal p_devHours,Decimal p_totalHours,Decimal p_averageUsage,Decimal p_Variance)
        {
            title = p_title;
            dealHours = p_dealHours;
            devHours = p_devHours;
            totalHours = p_totalHours;
            averageUsage = p_averageUsage;
            variance = p_Variance;
        }
    }
    
    class NearTermTransactions
    {
        public String Company {get; set;}
        public Date TargetYear {get; set;}
        public String Tier {get; set;}
        public String Type {get; set;}
        public Integer Meetings {get; set;}
        public Integer MeetingsYTD {get; set;}
        public String Description {get; set;}
        public NearTermTransactions(String p_Company,Date p_TargetYear,String p_Tier,String p_Type,Integer p_Meetings,Integer p_MeetingsYTD,String p_Description)
        {
            Company = p_Company;
	        TargetYear = p_TargetYear;
	        Tier = p_Tier;
	        Type = p_Type;
	        Meetings = p_Meetings;
	        MeetingsYTD = p_MeetingsYTD;
	        Description = p_Description;
        }
    }
    
}