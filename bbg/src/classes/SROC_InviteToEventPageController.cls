public without sharing class SROC_InviteToEventPageController {
	
	
	public CORECONNECT__CC_Community_Content__c objEvent {get;set;}
	private string strEventId = '';
	public string strselctedUserId {get;set;}
	public string strcheckselected {get;set;}

	
	public string strUserName {get;set;}
	public string strPostalCode {get;set;}
	public string withinDistance {get;set;}
	public string strOrderBy {get;set;}
	public string strcheckSelectAllorDeselect  {get;set;}
	public string strMessage {get;set;}
	
	public boolean boolpeopleIfollow {get;set;}
	public boolean boolprefferedOwners {get;set;}
	public boolean boolselectAll {get;set;}
	public boolean boolDisableprefferedOwners { get{ return SROCUtilities.isDealer(); }}

	
	
	public Integer inttotalrecords {get;set;}
	public Integer selectedrecordcount {get;set;}
	public map<String,String> mapCheckSelectedUnselected {get;set;}
	private set<Id> setInvitedUsers;
	public list<User> filteredList  {get;set;}
	public map<Id,String> mapAccountIdToBoatDetails {get;set;}

	private final String USER_BASE_QUERY ;
    private final String PROFILE_IDS;
    private Set<String> profileIds = new Set<String>();
    
	public SROC_InviteToEventPageController() {
	    
	    filteredList = new list<User>();
	    PROFILE_IDS = CORECONNECT.CC_CommunityUtil.constructProfilesList(profileIds);
        USER_BASE_QUERY= 'select Id,AboutMe, Name, CommunityNickname, Contact.AccountId , Contact.Account.SROC_Preferred_Dealer__c, SmallPhotoUrl, Department,Division, Title, email, Phone,Username,UserType, CORECONNECT__Classification1__c from User' +  PROFILE_IDS + ' AND isActive = true AND Contact.AccountId != Null  AND Receive_Event_Invitations__c = true AND CORECONNECT__CC_List_In_Directory__c = TRUE';
		strselctedUserId = strcheckselected = strUserName = strPostalCode = withinDistance = strOrderBy = strcheckSelectAllorDeselect = strMessage = '';
		boolpeopleIfollow = boolprefferedOwners = boolselectAll  = false;
		inttotalrecords = selectedrecordcount = 0;
		mapCheckSelectedUnselected = new map<String,String>();
		setInvitedUsers = new set<Id>();
		strEventId = ApexPages.currentPage().getParameters().get('id');
		objEvent = [Select Name from CORECONNECT__CC_Community_Content__c Where Id =: strEventId];
		fetchInvitedUsers();
	}
	
	public ApexPages.StandardSetController setController {
        get {
            if(setController == null) {
                
                //QueryLocator will throw LimitException more than 10,000
                //requeiment: Up to ten thousand auctions with various states of status 
                //in case more than 10,000 records exist LIMIT 10,000
                filteredList = Database.Query(USER_BASE_QUERY);
                setController = new ApexPages.StandardSetController(filteredList);
                inttotalrecords = setController.getResultSize();
                setController.setPageSize(20);
            }
            return setController;
        }
        set;
    }
    
    public void fetchInvitedUsers() {
        
        for(CORECONNECT__CC_ScheduledContent_Registration__c objSR : [Select CORECONNECT__User__c 
                                                                      From CORECONNECT__CC_ScheduledContent_Registration__c 
                                                                      Where CORECONNECT__CC_Community_Content__c =:strEventId
                                                                      And CORECONNECT__Response__c = 'YES']) {
             setInvitedUsers.add(objSR.CORECONNECT__User__c);                                                             
        }
    }
    
   
    public void markUserSelectedUnselcted ()
    {
        if(String.isNotEmpty(strselctedUserId) && String.isNotEmpty(strcheckselected))
            
            if(strcheckselected == 'selected') {
                selectedrecordcount++;
                mapCheckSelectedUnselected.put(strselctedUserId,'true');
            }
            else {
                selectedrecordcount--;
                mapCheckSelectedUnselected.put(strselctedUserId,'false');
            }
    }
    
    private String userIdsString;
    private void queryEntitySubscription(){
        List<EntitySubscription> lisEnt = [select  ParentId from EntitySubscription 
                                            where CreatedById = :UserInfo.getUserId() 
                                            AND NetworkId = :CORECONNECT.CC_CommunityConstants.NETWORK_ID 
                                            AND ParentId In (select Id from User where isActive = true AND ProfileId in :profileIds ) limit 1000];
        if(lisEnt.size()>0){
            userIdsString ='(';
            Integer count = 0;
            for(EntitySubscription es : lisEnt){
                count++;
                if(count ==lisEnt.size()){
                    userIdsString += '\'' + es.ParentId +'\'' ;
                }else{
                    userIdsString += '\''+es.ParentId +'\',' ;
                }
            }
            userIdsString += ')'; 
            
        }else{
            userIdsString = '(\'\')';
        }
    }
    
    public void DeselectAll() {
        
        selectedrecordcount = 0;
        for(String key : mapCheckSelectedUnselected.keyset()) {
            if(mapCheckSelectedUnselected.get(key) == 'true')
                mapCheckSelectedUnselected.put(key,'false');
        }
    }
    
    public void clearFilters(){
        
        boolpeopleIfollow = false;
        boolprefferedOwners = false;
        boolselectAll = false;
        strPostalCode = '';
        withinDistance = '1';
        /*pending boattype*/
        strUserName = '';
        strOrderBy = '0';
        filterRecords();
    }
    
    public void filterRecords() {
        
        filteredList = new list<User>();
        string strTempQuery = USER_BASE_QUERY;
        queryEntitySubscription();
        if(boolpeopleIfollow & String.isNotEmpty(userIdsString))
             strTempQuery += ' AND Id in ' + userIdsString;
        
        
        if(String.isNotEmpty(strPostalCode)) {
        	Geocode_Data_Row__c gdr = SROCUtilities.postalCodeToGeocodeData(strPostalCode);
        	
        	if(gdr != null)
        	{
        		strTempQuery += ' AND DISTANCE(Contact.Account.GeoLocation__c, GEOLOCATION('+gdr.Geocode__Latitude__s+','+gdr.Geocode__Longitude__s+'),\'mi\') < ' + withinDistance;
        		
        		if(strOrderBy == '3')
                    strTempQuery += ' ORDER BY DISTANCE(Contact.Account.GeoLocation__c, GEOLOCATION('+gdr.Geocode__Latitude__s+','+gdr.Geocode__Longitude__s+'),\'mi\')';
        
                if(strOrderBy == '4')
                     strTempQuery += ' ORDER BY DISTANCE(Contact.Account.GeoLocation__c, GEOLOCATION('+gdr.Geocode__Latitude__s+','+gdr.Geocode__Longitude__s+'),\'mi\')';
        	}
        	else
        	{
        		strTempQuery += ' AND DISTANCE(Contact.Account.GeoLocation__c, GEOLOCATION(0,0), \'mi\') < 0';
        		
        		if(strOrderBy == '3')
                    strTempQuery += ' ORDER BY  DISTANCE(Contact.Account.GeoLocation__c, GEOLOCATION(0,0), \'mi\')';
        
                if(strOrderBy == '4')
                     strTempQuery += ' ORDER BY DISTANCE(Contact.Account.GeoLocation__c, GEOLOCATION(0,0), \'mi\')';
        	}
        	
        }
        
        if(String.isNotEmpty(strUserName)) {
            
            strTempQuery += ' And UserName Like \'%'+strUserName+'%\'';
        }
        
        if(boolprefferedOwners) {
            
            Id dealerAccountId = [Select AccountId from User where id =: Userinfo.getUserid()].AccountId;
            strTempQuery += ' And Contact.Account.SROC_Preferred_Dealer__c =: dealerAccountId';
        }
        
        if(strOrderBy == '1')
            strTempQuery += ' Order By UserName ASC';
        
        if(strOrderBy == '2')
            strTempQuery += ' Order By UserName DESC';
        
        filteredList = Database.Query(strTempQuery);
        setController = new ApexPages.StandardSetController(filteredList);
        inttotalrecords = setController.getResultSize();
    }
    
    public void markSelectAll() {
        
         if(boolselectAll) {
            
            for(User objUser : filteredList) {
                
                if(mapCheckSelectedUnselected.get(objUser.Id) != 'disabled' && mapCheckSelectedUnselected.get(objUser.Id) != 'true') {
                    mapCheckSelectedUnselected.put(objUser.Id,'true');
                    selectedrecordcount++;
                }
            }
        }
    }
        
    Public List<User> getlstUsers(){
        
        List<User> UserList = new List<User>();
        set<Id>  setAccountId  = new set<Id>();
        mapAccountIdToBoatDetails = new map<Id,string>();
        for(User objUser : (List<User>)setController.getRecords()){
            
            UserList.add(objUser);
            mapAccountIdToBoatDetails.put(objUser.Contact.AccountId,'No Boat found');
            
            if(!mapCheckSelectedUnselected.ContainsKey(objUser.Id)) {
            
                if(setInvitedUsers.contains(objUser.Id)) {
                    mapCheckSelectedUnselected.put(objUser.Id,'disabled');
                }
                else {
                    mapCheckSelectedUnselected.put(objUser.Id,'false');
                }
            }
        }
        fetchBoatDetails(mapAccountIdToBoatDetails.Keyset());
        return UserList;
    }
    
    private void fetchBoatDetails( set<Id>  setAccountId) {
               
        for(Owner_Boat_Relationship__c objBR : [Select Owner__c,HIN_Number__r.Boat_Model__c,HIN_Number__r.Model_Year__c 
                                                From Owner_Boat_Relationship__c
                                                Where Owner__c =: setAccountId]) {
                
                string strboatdetails = String.isNotEmpty(String.ValueOf(objBR.HIN_Number__r.Model_Year__c)) ? (String.isNotEmpty(objBR.HIN_Number__r.Boat_Model__c) ? String.ValueOf(objBR.HIN_Number__r.Model_Year__c)+' '+objBR.HIN_Number__r.Boat_Model__c : String.ValueOf(objBR.HIN_Number__r.Model_Year__c)) : (String.isNotEmpty(objBR.HIN_Number__r.Boat_Model__c) ? objBR.HIN_Number__r.Boat_Model__c  : '');
                mapAccountIdToBoatDetails.put(objBR.Owner__c,strboatdetails);
                                                    
        }
    }
    
	public Boolean hasNextSet {
        get {
            return setController.getHasNext();
        }
        set;
    }
 
    public Boolean hasPrevSet {
        get {
            return setController.getHasPrevious();
        }
        set;
    }
 
    public Integer PageNumber {
        get {
            return setController.getPageNumber();
        }
        set;
    }

    public Integer TotalPages{
            get{
                if(Math.mod(setController.getResultSize(),setController.getPageSize()) == 0){
                    return setController.getResultSize()/setController.getPageSize();
                }else{
                    return setController.getResultSize()/setController.getPageSize()+1; 
                } 

            }
    }
    
    public  Integer SpecifiedPageNumber{
        get;
        set;
    } 

    public void prevSet() {
            setController.previous();
    }
 
 
    public void nextSet() {
            setController.next();     
    }
 
    public void GoToPage () {
        
        if(SpecifiedPageNumber!=null){
            setController.setpageNumber(SpecifiedPageNumber);
        }
   }
   
   public void createSRandSendInvite() {
        list<CORECONNECT__CC_ScheduledContent_Registration__c> lstSRtoInsert = new list<CORECONNECT__CC_ScheduledContent_Registration__c>();
        for(String key : mapCheckSelectedUnselected.keyset()) {
            
            if(mapCheckSelectedUnselected.get(key) == 'true') {
                
                CORECONNECT__CC_ScheduledContent_Registration__c objSR = new CORECONNECT__CC_ScheduledContent_Registration__c(CORECONNECT__Response__c = 'YES',CORECONNECT__CC_Community_Content__c = strEventId,Custom_Message__c = strMessage,CORECONNECT__User__c = key);
                lstSRtoInsert.add(objSR);
            }
        }
        insert lstSRtoInsert; 
   }
}