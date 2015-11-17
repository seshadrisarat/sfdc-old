public with sharing class SROC_CommunitySearchController {
    
    public String SearchString{
        get;set;
    }
    public String EscapedSearchString{
        get;set;
    }
    
    public String SearchType {
        get;set;
    }
    
    private List<CORECONNECT__CC_Community_Content__c> listOfCC;
    private Integer userCount;
    private Boolean firstTime;
    private Boolean isNext;
    public List<CORECONNECT.CC_CommunityContentWrapper> LisOfCCForALL{
        get;set;
    }
   
    
    public SROC_CommunitySearchController() {
        
        this.SearchString = ApexPages.currentPage().getParameters().get('SearchString');
        this.SearchType = ApexPages.currentPage().getParameters().get('SearchType');
        
        if(SearchString != null &&  SearchString.trim() != '' && !String.isEmpty(SearchString)){
            EscapedSearchString = String.escapeSingleQuotes(SearchString.trim().replace(' ','%'));
        }
        
        
        if(this.SearchType == null &&  !String.isEmpty(SearchString)) {
            this.SearchType = 'All';
            PROFILE_IDS = CORECONNECT.CC_CommunityUtil.constructProfilesList(profileIds);
            USER_BASE_QUERY= 'select Id,AboutMe, Name, SmallPhotoUrl, Department,Division, Title, Username,UserType,CommunityNickname from User' +  PROFILE_IDS + ' AND isActive = true AND CORECONNECT__CC_List_In_Directory__c = TRUE';
            
            LisOfCCForALL = this.queryFreeText();
            LisOfCCForALL.addAll(this.queryScheduledContent());
            LisOfCCForALL.addAll(this.queryPeople());
            LisOfCCForALL.addAll(this.queryGroup());
            
        }else if (this.SearchType == 'FreeText' && !String.isEmpty(SearchString)){
            LisOfCCForALL = this.queryFreeText();
        }else if (this.SearchType == 'ScheduledContent' && !String.isEmpty(SearchString)){
            LisOfCCForALL = this.queryScheduledContent();
        }
        else if (this.SearchType == 'People' && !String.isEmpty(SearchString)){
            PROFILE_IDS = CORECONNECT.CC_CommunityUtil.constructProfilesList(profileIds);
            USER_BASE_QUERY= 'select Id,AboutMe, Name, SmallPhotoUrl, Department,Division, Title, Username,UserType,CommunityNickname from User' +  PROFILE_IDS + ' AND isActive = true AND CORECONNECT__CC_List_In_Directory__c = TRUE';
            LisOfCCForALL = this.queryPeople();
        }else if (this.SearchType == 'Group' && !String.isEmpty(SearchString)){
            LisOfCCForALL = this.queryGroup();
        }
        else {
            listOfCC = new List<CORECONNECT__CC_Community_Content__c> ();
        }
    }
    
    // for user queries
     private final String USER_BASE_QUERY;
    private final String PROFILE_IDS;
    private Set<String> profileIds = new Set<String>();
    
    /**
     *  Query for FreeText, ScheduledContent, People
    */
    private final String FREETEXT_BASE_QUERY = 'select id, Name, RecordType.Name, CORECONNECT__Short_Description__c, CORECONNECT__FreeText_Desired_Publish_Date__c from CORECONNECT__CC_Community_Content__c where RecordType.Name = \'FreeText\' AND CORECONNECT__Community_Content_Status__c = \'Approved\'';
    private List<CORECONNECT.CC_CommunityContentWrapper> queryFreeText(){
        String QUERY = FREETEXT_BASE_QUERY;
        if(!String.isEmpty(SearchString)){
             QUERY +=  ' AND (Name Like \'%' + EscapedSearchString + '%\' or CORECONNECT__Short_Description__c Like \'%' + EscapedSearchString + '%\' ) LIMIT 100';
        }else{
            return new List<CORECONNECT.CC_CommunityContentWrapper>();
        }
       
        List<CORECONNECT__CC_Community_Content__c> lisCC =Database.query(QUERY) ;
        List<CORECONNECT.CC_CommunityContentWrapper> lisW = new List<CORECONNECT.CC_CommunityContentWrapper>();
        for(CORECONNECT__CC_Community_Content__c cc: lisCC ){
            CORECONNECT.CC_CommunityContentWrapper w = new CORECONNECT.CC_CommunityContentWrapper();
            w.CCType = 'FreeText';
            w.CC = cc;
            lisW.add(w);
        }
        return lisW ;
    }
    
    private final String ScheduledContent_BASE_QUERY = 'select id, Name,RecordType.Name,CORECONNECT__Location__c,CORECONNECT__Classification1__c, CORECONNECT__Start_Date__c,CORECONNECT__End_Date__c, CORECONNECT__Is_All_Day_ScheduledContent__c from CORECONNECT__CC_Community_Content__c where RecordType.Name = \'ScheduledContent\' AND CORECONNECT__Community_Content_Status__c = \'Approved\'';
    private List<CORECONNECT.CC_CommunityContentWrapper> queryScheduledContent(){
        String QUERY = ScheduledContent_BASE_QUERY;
        if(!String.isEmpty(SearchString)){
             QUERY +=  ' AND (Name Like \'%' + EscapedSearchString + '%\' or CORECONNECT__Short_Description__c Like \'%' + EscapedSearchString + '%\' ) LIMIT 100';
        }else{
            return new List<CORECONNECT.CC_CommunityContentWrapper>();
        }
        List<CORECONNECT__CC_Community_Content__c> lisCC =Database.query(QUERY) ;
        List<CORECONNECT.CC_CommunityContentWrapper> lisW = new List<CORECONNECT.CC_CommunityContentWrapper>();
        for(CORECONNECT__CC_Community_Content__c cc: lisCC ){
            CORECONNECT.CC_CommunityContentWrapper w = new CORECONNECT.CC_CommunityContentWrapper();
            w.CCType = 'ScheduledContent';
            w.CC = cc;
            lisW.add(w);
        }
        return lisW ;
    }
    
   
   
    private List<CORECONNECT.CC_CommunityContentWrapper> queryPeople(){
        String QUERY = USER_BASE_QUERY;
        if(!String.isEmpty(SearchString)){
             QUERY +=  ' AND CommunityNickname Like \'%' + EscapedSearchString + '%\' LIMIT 333';
        }else{
            return new List<CORECONNECT.CC_CommunityContentWrapper>();
        }
        
        List<User> lisUser =  (List<User>)Database.query(QUERY);
        List<CORECONNECT.CC_CommunityContentWrapper> lisW = new List<CORECONNECT.CC_CommunityContentWrapper>();
        for(User u: lisUser){
            CORECONNECT.CC_CommunityContentWrapper w = new CORECONNECT.CC_CommunityContentWrapper();
            w.CCType = 'People';
            w.u = u;
            lisW.add(w);
        }
        return lisW; 
    }
    
    
    private final String GROUP_BASE_QUERY = 'select Name, Description from CollaborationGroup where Network.Name = \'' + CORECONNECT.CC_CommunityConstants.THIS_COMMUNITY_NAME +'\'';
    private List<CORECONNECT.CC_CommunityContentWrapper> queryGroup() {
        String QUERY = GROUP_BASE_QUERY;
        if(!String.isEmpty(SearchString)){
             QUERY +=  ' AND ( Name Like \'%' + EscapedSearchString + '%\' or Description Like \'%' + EscapedSearchString +'%\') LIMIT 100';
        }else{
            return new List<CORECONNECT.CC_CommunityContentWrapper>();
        }
        
        List<CollaborationGroup> lisGroup =  (List<CollaborationGroup>)Database.query(QUERY);
        List<CORECONNECT.CC_CommunityContentWrapper> lisW = new List<CORECONNECT.CC_CommunityContentWrapper>();
        for(CollaborationGroup g: lisGroup){
            CORECONNECT.CC_CommunityContentWrapper w = new CORECONNECT.CC_CommunityContentWrapper();
            w.CCType = 'Group';
            w.cg = g;
            lisW.add(w);
        }
        return lisW; 
    }
    
    

    
    
    

}