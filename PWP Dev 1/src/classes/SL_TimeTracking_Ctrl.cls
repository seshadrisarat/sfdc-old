/**
    * \arg ClassName      : SL_TimeTracking_Ctrl
    * \arg JIRATicket     : PWP-188
    * \arg CreatedOn      : 20/August/2015
    * \arg LastModifiedOn : 08/Sep/2015
    * \arg CreatededBy    : Sandeep
    * \arg ModifiedBy     : Lodhi
    * \arg Description    : This class for the SL_TimeTracking page.
*/
public with sharing class SL_TimeTracking_Ctrl 
{
    /* Start - Variables */
    public List<wrapperTimeCard> lstWrapperTimeCard                 {get;set;} // list to store the Time card wrapper 
    public Date dtWeekStart                                         {get;set;} // Store week start date
    public Date dtWeekEnd                                           {get;set;} //Store week end date
    public Decimal decTotalHrs                                      {get;set;} // Total hrs
    public Decimal decTotalPerc                                     {get;set;} // total percentage hrs
    public String strJSONProjects                                   {get;set;} //JSON String to hold the projects
    public Id idSelectedTimeCardId                                  {get;set;} //Selected time card Id
    public Id idSelectedProject                                     {get;set;} // Select project id from auto complete
    public Integer intWeekCount                                     {get;set;} // Integer to count week 
    public Integer intIndexNo                                       {get;set;} // Integer to count index of list where user perform actions
    public string strLogTimeIn                                      {get;set;}
    public List<SelectOption> getItems                              {get;set;}
    public List<SelectOption> lstTimeLoginItems                     {get;set;}
    public Boolean isAdminUser                                      {get;set;}
    public Boolean isCurrentWeek                                    {get;set;}
    public Boolean isValidHrsPercentage                             {get;set;}
    public Boolean isEditPermission                                 {get;set;}
    public String strParterOrMDsId                                  {get;set;}
    public List<Id> lstParterOrMDsIds                               {get;set;}
    public Map<Id, Opportunity> mapIdToProject                      {get;set;}
    private Set<Id> setAdminUserIds;
    private Set<Id> setParterOrMDsIds;
    private Date dtToday;
    /* End - Variables */
    
     /* Start - Constructor */
    public SL_TimeTracking_Ctrl()
    {
        isCurrentWeek = isEditPermission = isValidHrsPercentage = true;
        dtToday = Date.today();
        dtWeekStart = dtToday.toStartofWeek();
        dtWeekEnd = dtWeekStart.addDays(6);
        intWeekCount = 0;
        strParterOrMDsId = '';
        lstTimeLoginItems = new List<SelectOption>();
        lstParterOrMDsIds = new List<Id>();
        lstWrapperTimeCard = new List<wrapperTimeCard>();
        fetchChangeTimeIn();
        setAdminUserIds = fetchUsersFromPublicGroup('Administrators'); 
        setParterOrMDsIds = fetchUsersFromPublicGroup('Managing_Directors');
        setParterOrMDsIds.addAll(fetchUsersFromPublicGroup('Partners'));
        setParterOrMDsIds.addAll(fetchUsersFromPublicGroup('Directors'));
        lstParterOrMDsIds.addAll(setParterOrMDsIds);
        isAdminUser = setAdminUserIds.contains(UserInfo.getUserId()) ? true : false;
    }
    /* End - Constructor */
    
    /**
        @JIRATicket : PWP-217
	    @MethodName : fetchTimeCardProjects
	    @CreatededBy: Lodhi, 07/SEP/2015
	    @Param 		: NA
	    @Description: This method is used to fetch all the project corrensponding to the Time_Card__c records
    **/
    private Map<Id, Opportunity> fetchTimeCardProjects()
    {
        Set<Id> setProjectId = new Set<Id>();
        for(Time_Card__c objTimeCard : [SELECT Id, Project__c FROM Time_Card__c WHERE Resource__c != null])
        {
            setProjectId.add(objTimeCard.Project__c);
        }
        return new Map<Id, Opportunity>([SELECT Id, Name FROM Opportunity WHERE Id IN : setProjectId]);
    }
    /* End */ 
    
    /**
        @JIRATicket : PWP-217
	    @MethodName : addTimeEntryForCurrentWeek
	    @CreatededBy: Lodhi, 01/SEP/2015
	    @Param 		: NA
	    @Description: This method is used to create default time entry records for the current loggedin users
	                  if he is on any project with atleaset one partner or managing Director
    **/
    public void addTimeEntryForCurrentWeek()
    {
        Set<Id> setProjectId = new Set<Id>();
        Set<Id> setFilteredProjectId = new Set<Id>();
        List<Time_Card__c> lstTimeCards = new List<Time_Card__c>();
        Set<String> setOppIdToUserId = new Set<String>();
        Map<Id, Set<Id>> mapOppIdToSetPartnerOrMDId = new Map<Id, Set<Id>>();
        
        //Iterating on Time_Card__c object to prepare a unique set of string to avoid creation of duplicate Time_Card__c records
        for(Time_Card__c objTimeCard : [SELECT Project__c, Resource__c
                                          FROM Time_Card__c 
                                         WHERE Start_Date__c >=: dtWeekStart 
                                           AND End_Date__c <=: dtWeekEnd
                                           AND Resource__c != null])
        {
            setOppIdToUserId.add(objTimeCard.Project__c +'_'+ objTimeCard.Resource__c);
        }                                         
        
        //Iterating on Project_Coverage_Team_Member__c to collect project ids
        for(Project_Coverage_Team_Member__c objPCTM : [SELECT Id, Project__c, User__c 
                                                         FROM Project_Coverage_Team_Member__c  
                                                        WHERE User__r.Coverage_Team_Role__c IN ('Partner', 'Managing Director')
                                                          AND Project__r.StageName IN ('Prospective Mandate', 'Active Mandate')])
        {
            if(!mapOppIdToSetPartnerOrMDId.containsKey(objPCTM.Project__c))
                mapOppIdToSetPartnerOrMDId.put(objPCTM.Project__c, new Set<Id>{objPCTM.User__c});
            else
                mapOppIdToSetPartnerOrMDId.get(objPCTM.Project__c).add(objPCTM.User__c);
        }
        
        //Iterating on Project__c records to create Time_Card__c entries for the current user.
        for(Opportunity objOpportunity : [SELECT Id, 
                                                 (SELECT Id, User__c 
                                                    FROM Coverage_Team_Members__r 
                                                   WHERE User__c != null)
                                            FROM Opportunity 
                                           WHERE Id IN : mapOppIdToSetPartnerOrMDId.keySet()])
        {
            if(objOpportunity.Coverage_Team_Members__r.size() > 0)
            {
                for(Project_Coverage_Team_Member__c objPCTM : objOpportunity.Coverage_Team_Members__r)
                {
                    if(!setOppIdToUserId.contains(objOpportunity.Id +'_'+ objPCTM.User__c))
                    {    
                        lstTimeCards.add(new Time_Card__c(Percentage_Worked__c = 0, Project__c = objOpportunity.Id, 
                                                          Resource__c = objPCTM.User__c, Worked_Hours__c = 0.00, Start_Date__c = dtWeekStart, 
                                                          End_Date__c = dtWeekEnd, OwnerId = objPCTM.User__c));
                    }                                                          
                }
                
            }    
        }
        
        //prepare a JSON for auto complete
        fetchValidProjects(Userinfo.getuserId());
        insert lstTimeCards;
        mapIdToProject = fetchTimeCardProjects();
        fetchTimeCards();  
    }
    /* End */
    
    /**
        @JIRATicket : PWP-221
	    @MethodName : fetchUsersFromPublicGroup
	    @CreatededBy: Lodhi, 31/AUG/2015
	    @ModifiedOn : Lodhi, 10/SEP/2015
	    @Param 		: NA
	    @Description: This method is used to fetch project json with some criteria
    **/
    private void fetchValidProjects(Id userId)
    {
        lstParterOrMDsIds = new List<Id>();
        setParterOrMDsIds = new Set<Id>();
        Set<Id> setProjectId = new Set<Id>();
        Set<Id> setFilteredProjectId = new Set<Id>();
        Map<Id, Set<String>> mapProjectIdToSetRole = new Map<Id, Set<String>>();
        for(Time_Card__c objTimeCard : [SELECT Project__c FROM Time_Card__c 
                                         WHERE Resource__c =: userId
                                           AND Project__r.StageName IN ('Prospective Mandate', 'Active Mandate')])
        {
            setProjectId.add(objTimeCard.Project__c);
        }
        
        if(setProjectId.isEmpty())
            return;
            
        for(Opportunity objOpportunity : [SELECT Id, 
                                                 (SELECT Id, User__r.Coverage_Team_Role__c 
                                                    FROM Coverage_Team_Members__r 
                                                   WHERE User__r.Coverage_Team_Role__c IN ('Partner', 'Managing Director')
                                                      OR User__c =: userId)
                                            FROM Opportunity 
                                            WHERE Id IN : setProjectId])
        {
            for(Project_Coverage_Team_Member__c objPCTM : objOpportunity.Coverage_Team_Members__r)
            { 
                if(!mapProjectIdToSetRole.containsKey(objOpportunity.Id))
                {
                    mapProjectIdToSetRole.put(objOpportunity.Id, new Set<String>{objPCTM.User__r.Coverage_Team_Role__c});
                    mapProjectIdToSetRole.get(objOpportunity.Id).add(objPCTM.User__c);
                }    
                else
                {
                    mapProjectIdToSetRole.get(objOpportunity.Id).add(objPCTM.User__r.Coverage_Team_Role__c);
                    mapProjectIdToSetRole.get(objOpportunity.Id).add(objPCTM.User__c);
                } 
            }    
        }
        
        for(Id projectId : mapProjectIdToSetRole.keySet())
        {
            Set<String> setRoleOrId = mapProjectIdToSetRole.get(projectId);
            if((setRoleOrId.contains('Partner') || setRoleOrId.contains('Managing Director')) && setRoleOrId.contains(userId))
                setFilteredProjectId.add(projectId);       
        }
        setParterOrMDsIds = fetchUsersFromPublicGroup('Managing_Directors');
        setParterOrMDsIds.addAll(fetchUsersFromPublicGroup('Partners'));
        setParterOrMDsIds.addAll(fetchUsersFromPublicGroup('Directors'));
        lstParterOrMDsIds.addAll(setParterOrMDsIds);
        lstParterOrMDsIds.addAll(setFilteredProjectId);
    }
    /* End */
    
    /**
        @JIRATicket : PWP-221
	    @MethodName : fetchUsersFromPublicGroup
	    @CreatededBy: Lodhi, 31/AUG/2015
	    @Param 		: public group name
	    @Description: This method is used to fetch all the user associated with the corresponding public group
    **/
    private Set<Id> fetchUsersFromPublicGroup(String strGroupName)
    {
        Set<Id> setGroupMemberIds = new Set<Id>();
        Set<Id> setUserIds = new Set<Id>();
        
        //Iterating on group member records based on group name and collecting group member ids
        for(GroupMember objGroupMember : [SELECT UserOrGroupId 
                                            FROM GroupMember 
                                           WHERE Group.DeveloperName =: strGroupName])
        {
            if(String.valueOf(objGroupMember.UserOrGroupId).startsWithIgnoreCase('00G'))
                setGroupMemberIds.add(objGroupMember.UserOrGroupId);
            else
                setUserIds.add(objGroupMember.UserOrGroupId);
        }
        
        //Used to get the user from group that are contained in parent group
        if(!setGroupMemberIds.isEmpty())
        {
            for(GroupMember objGroupMember : [SELECT UserOrGroupId 
                                                FROM GroupMember 
                                               WHERE GroupId IN : setGroupMemberIds])
            {
                setUserIds.add(objGroupMember.UserOrGroupId);
            }
        }
        return setUserIds;
    }
    /* End */
    
    /**
    @MethodName : fetchTimeCards
    @Param      : 
    @Description: This method will fetch the**** all time card entries 
    **/
    public void fetchTimeCards()
    {
        Id userId = (strParterOrMDsId == '') ? Userinfo.getuserId() : strParterOrMDsId;
        lstWrapperTimeCard = new List<wrapperTimeCard>();
        
        //get all the Timecard entry based on start and end date and also based on resource
        for(Time_Card__c objTimeCard:[SELECT Id, Percentage_Worked__c, Project__r.Name, Resource__r.Name, Worked_Hours__c 
                                        FROM Time_Card__c 
                                       WHERE Resource__c =: userId 
                                         AND Start_Date__c >=: dtWeekStart 
                                         AND End_Date__c <=: dtWeekEnd])
        {
            lstWrapperTimeCard.add(new wrapperTimeCard(objTimeCard, false));
        }
        fetchValidProjects(userId);
        calculateTotal(lstWrapperTimeCard);//calculate the total hrs and total percentage
        isEditPermission = isValidHrsPercentage = true;
    }
    
    /**
    @MethodName : newTimeCardEntry
    @Param      : 
    @Description: This method will add a new time card record in list.  
    **/
    public void newTimeCardEntry()
    {
        Id userId = (strParterOrMDsId == '') ? Userinfo.getuserId() : strParterOrMDsId;
        intIndexNo = lstWrapperTimeCard.size() + 1;
        lstWrapperTimeCard.add(new wrapperTimeCard(new Time_Card__c(Project__c = idSelectedProject, Resource__c = userId,
                                                                    Worked_Hours__c = strLogTimeIn == 'Hours' ?  0 : null, 
                                                                    Percentage_Worked__c = strLogTimeIn != 'Hours' ? 0 : null), true));
        isEditPermission = true;
    }
    
     /**
    @MethodName : editTimeCardEntry
    @Param      : 
    @Description: This method will check user have access to record or not.  
    **/
    public void editTimeCardEntry()
    {
        Integer intCounter = 1;
        isEditPermission = true;
        //if the current user has access to a record or not
        List<UserRecordAccess> lstUserRecordAccess = [SELECT RecordId FROM UserRecordAccess 
                                                       WHERE RecordId =:idSelectedTimeCardId 
                                                         AND UserId =:UserInfo.getUserId() 
                                                         AND HasEditAccess = true];
        
        //if user hasnot access to record then show an error msg else make the fields editable
        if(lstUserRecordAccess.isEmpty())
            isEditPermission = false;
        else
        {
            for(wrapperTimeCard objWrapper:lstWrapperTimeCard)
            {
                if(objWrapper.objTimeCard.id == idSelectedTimeCardId )
                {
                    objWrapper.isEditable = true;
                    intIndexNo = intCounter;
                    idSelectedProject = objWrapper.objTimeCard.Project__c;
                }    
                intCounter++;    
            }
        }
    }
    /**
    @MethodName : saveTimeCard
    @Param      : 
    @Description: This method will create/update a record.
    **/
    public pageReference saveTimeCard()
    {
        List<Time_Card__c> lstTime_Card = new List<Time_Card__c>();
        Integer intCounter = 1;
        
        for(wrapperTimeCard objWrapper:lstWrapperTimeCard)
        {
            Decimal decHours = objWrapper.objTimeCard.Worked_Hours__c;
            Decimal decPercent = objWrapper.objTimeCard.Percentage_Worked__c;
            
            if((objWrapper.objTimeCard.Id == idSelectedTimeCardId || (objWrapper.objTimeCard.Id == null && intCounter == intIndexNo)) 
            && ((strLogTimeIn == 'Hours' && (decHours == null || decHours < 0) ) || (strLogTimeIn != 'Hours' && (decPercent == null || decPercent < 0))))
            {
                isValidHrsPercentage = false;
                return null;
            }
            
            //if time card id equals to selected entry then add into list for update
            if(objWrapper.objTimeCard.Id == idSelectedTimeCardId && intCounter == intIndexNo)
            {
                objWrapper.isEditable = false;
                lstTime_Card.add(objWrapper.objTimeCard);
            }
            //if id is not present
            if(objWrapper.objTimeCard.Id == null && intCounter == intIndexNo)
            {
                objWrapper.isEditable = false;
                objWrapper.objTimeCard.Start_Date__c = dtWeekStart;
                objWrapper.objTimeCard.End_Date__c = dtWeekEnd;
                lstTime_Card.add(objWrapper.objTimeCard);
            }
            intCounter++;
        }
        try{
            upsert lstTime_Card;
            fetchTimeCards();
            calculateTotal(lstWrapperTimeCard);
        }
        catch(Exception ex){ 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        system.debug('==upsert=lstWrapperTimeCard==='+lstWrapperTimeCard);
        return null;
    }
    
    /**
    @MethodName : calculateTotal
    @Param      : 
    @Description: This method will calculate total
    **/
    public void calculateTotal(List<wrapperTimeCard> lstWrapper)
    {
        decTotalHrs = decTotalPerc = 0;
        
        for(wrapperTimeCard objWrapper:lstWrapperTimeCard)
        {
            decTotalHrs += objWrapper.objTimeCard.Worked_Hours__c == null ? 0: objWrapper.objTimeCard.Worked_Hours__c ;
            decTotalPerc += objWrapper.objTimeCard.Percentage_Worked__c == null ? 0: objWrapper.objTimeCard.Percentage_Worked__c;
        }
    }
    
    /**
    @MethodName : prevWeekTimeCard
    @Param      : NA
    @Description: Calculate week start and end date
    **/
    public void prevWeekTimeCard()
    {
        intWeekCount +=  1;
        dtWeekStart = dtWeekStart.addDays(-7);
        dtWeekEnd = dtWeekEnd.addDays(-7);
        isCurrentWeek = (dtToday > = dtWeekStart && dtToday <= dtWeekEnd) ? true : false;
        fetchTimeCards();
    }
    
     /**
    @MethodName : nxtWeekTimeCard
    @Param      : 
    @Description: Calculate week start and end date
    **/
    public void nxtWeekTimeCard()
    {
        intWeekCount -=  1;
        dtWeekStart = dtWeekStart.addDays(7);
        dtWeekEnd = dtWeekEnd.addDays(7);
        isCurrentWeek = (dtToday > = dtWeekStart && dtToday <= dtWeekEnd) ? true : false;
        fetchTimeCards();
    }
    
    //Wrapper class to maintain a boolean value with time card record for maintain the edit functionality
    public class wrapperTimeCard
    {
        public Time_Card__c objTimeCard                         {get;set;}
        public boolean isEditable                               {get;set;}
        
        public wrapperTimeCard(Time_Card__c objTimeCard, boolean isEditable)
        {
            this.objTimeCard = objTimeCard;
            this.isEditable = isEditable;
        }
    }
    
    /**
        @JIRATicket : PWP-226
	    @MethodName : fetchChangeTimeIn
	    @CreatededBy: Sandeep, 31/AUG/2015
	    @Param 		: NA
	    @Description: This method is used to fetch user preference for time card entry view
    **/
    public void fetchChangeTimeIn() 
    {
        Boolean isHours = [SELECT Id, isHours__c FROM User WHERE Id =: UserInfo.getUserId()].isHours__c;
        strLogTimeIn = isHours? 'Hours': 'Percentages';
        lstTimeLoginItems.add(new SelectOption('Hours','Hours')); 
        lstTimeLoginItems.add(new SelectOption('Percentages','Percentages'));
    }
    
    /**
        @JIRATicket : PWP-226
	    @MethodName : changeTimeIn
	    @CreatededBy: Sandeep, 31/AUG/2015
	    @Param 		: NA
	    @Description: This method is used to preserve the preference of time card view 
    **/
    public void changeTimeIn()
    {
        Boolean isHours = strLogTimeIn == 'Hours'? true: false;
        isEditPermission = isValidHrsPercentage = true;
        update new user(Id = UserInfo.getUserId(), isHours__c=  isHours);
    }
}