public without sharing class SROC_CommunityPeopleController {
    
    SROC_System_Settings__c setting;
    private final String USER_BASE_QUERY ;
    private final String PROFILE_IDS;
    private Set<String> profileIds = new Set<String>();
    
    public SROC_CommunityPeopleController() {
        
            if(!Test.isRunningTest())
                PROFILE_IDS = CORECONNECT.CC_CommunityUtil.constructProfilesList(profileIds);
            else
            {
                Id profileId = [SELECT Id, UserLicense.LicenseDefinitionKey FROM Profile WHERE UserLicense.LicenseDefinitionKey = 'PID_Customer_Community_Login' LIMIT 1].Id;
                PROFILE_IDS = ' where ProfileId = \''+profileId + '\'';
            }
            USER_BASE_QUERY= 'select Id,AboutMe, Name, CommunityNickname, SmallPhotoUrl, Department,Division, Title, email, Phone,Username,UserType, CORECONNECT__Classification1__c from User' +  PROFILE_IDS + ' AND isActive = true AND CORECONNECT__CC_List_In_Directory__c = TRUE';

            queryEntitySubscription();
            if(setController == null) {
                PeopleIFollow = false;
                setController = new ApexPages.StandardSetController(Database.getQueryLocator(queryPeopleString()));
            }
            
            setController.setPageSize(PAGE_SIZE);
            setting = SROC_System_Settings__c.getInstance(Site.GetName());
            if(Test.isRunningTest())
            {
                setting = SROC_System_Settings__c.getInstance('SROC'); 
            }
    }
    
    public String ambassadorIndicatorImage {
		get {
			if(setting != null)
			{
				return setting.Ambassador_Indicator_Image__c;
			}else{return '';}}
	}
    
    public List<CORECONNECT.CC_CommunityContentWrapper> ListOfUsers {
        get{
            List<User> lis= setController.getRecords();
            List<CORECONNECT.CC_CommunityContentWrapper> lisW = new List<CORECONNECT.CC_CommunityContentWrapper>();
            for(User u: lis){
                CORECONNECT.CC_CommunityContentWrapper w = new CORECONNECT.CC_CommunityContentWrapper();
                w.u = u;
                if(setOfPeopleIFollow.contains(u.Id)){
                    w.followed = true;
                }else {
                    w.followed = false;
                }
               
                    lisW.add(w);
                
            }
            
            return lisW;
        }
    }
    
    
    public String SearchString {
        get;set;
    }
    
    public String locationString {
    	get;set;
    }
    
    public Integer withinDistance {
    	get;set;
    }
    
    public String FilterOption{
        get;set;
    }
    
    public Boolean PeopleIFollow{
        get;set;
    }
    public Id FollowId{
        get;set;
    }
    
    private transient List<User> lisUser = new List<User>();
    private List<User> lisUserIFollow = new List<User>();
    private Set<Id> setOfPeopleIFollow = new set<Id>();
    
    private final Integer LIMIT_FOR_OTHERS = 10000;
    private final Integer PAGE_SIZE = 12;
    public ApexPages.StandardSetController setController {
        get;
        set;
    }
    
    
    /**
     * Action methods
     */
    public PageReference Filter(){
        if(PeopleIFollow){
            System.Debug('#### query='+ queryOnlyPeopleIFollowString());
            setController = new ApexPages.StandardSetController(Database.getQueryLocator(queryOnlyPeopleIFollowString()));
        }else{
            setController = new ApexPages.StandardSetController(Database.getQueryLocator(queryPeopleString()));
        }
        setController.setPageSize(PAGE_SIZE);
        return null;
    }
    
    public PageReference Follow(){
        
        if(!String.isEmpty(FollowId)){
            EntitySubscription es = new EntitySubscription();
            es.ParentId = FollowId;
            es.SubscriberId= UserInfo.getUserId();
            es.NetworkId = CORECONNECT.CC_CommunityConstants.NETWORK_ID;
            try{
                if(Schema.sObjectType.EntitySubscription.isCreateable()){
                    insert es;
                }
            }catch (DMLException de){ ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'not able to follow: error='+ de.getMessage() )); }
            
            queryEntitySubscription();
        }
        return null;    
    }
    
    public PageReference Unfollow(){
        
        if(!String.isEmpty(FollowId)){
            List<EntitySubscription> lisEs = [select id from EntitySubscription where ParentId = :FollowId AND SubscriberId = :UserInfo.getUserId()];
            if(lisEs.size() > 0)
            try{
                if(Schema.sObjectType.EntitySubscription.isDeletable()){
                 delete lisEs[0];
               }
            }catch (DMLException de){ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'not able to unfollow: error='+ de.getMessage() ));}

            // same way doing Follow, however for unfollow needs to add this line makes rerender works. 
            setOfPeopleIFollow.remove(FollowId);
            queryEntitySubscription();
        }
        return null;    
    }
    
    private String queryPeopleString(){
        String QUERY = USER_BASE_QUERY;
        if( !String.isEmpty(SearchString)){
             QUERY +=  ' AND CommunityNickname Like \'%' + String.escapeSingleQuotes(SearchString) + '%\'';
        }
        if( !String.isEmpty(FilterOption) && FilterOption != 'ALL'){
             QUERY +=  ' AND CORECONNECT__Classification1__c = \''+ String.escapeSingleQuotes(FilterOption) +'\'';
        }
        
        if(!String.isEmpty(locationString) && withinDistance != null && withinDistance > 0)
        {
        	Geocode_Data_Row__c gdr = SROCUtilities.postalCodeToGeocodeData(locationString);
        	if(gdr != null)
        	{
        		QUERY += ' AND DISTANCE(Contact.Account.GeoLocation__c, GEOLOCATION('+gdr.Geocode__Latitude__s+','+gdr.Geocode__Longitude__s+'),\'mi\') < ' + withinDistance;
        	}
        	else
        	{
        		QUERY += ' AND DISTANCE(Contact.Account.GeoLocation__c, GEOLOCATION(0,0), \'mi\') < 0';
        	}
        }
        
        QUERY += ' ORDER BY CreatedDate DESC';
        
        
        return QUERY;
    }
    
    private String userIdsString;
    private void queryEntitySubscription(){
        if(Test.isRunningTest()) return;
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
                setOfPeopleIFollow.add(es.ParentId);
            }
            userIdsString += ')'; 
            
        }else{
            userIdsString = '(\'\')';
        }
        
    }

 private String queryOnlyPeopleIFollowString(){
        
        String QUERY = USER_BASE_QUERY + ' AND Id in ' + userIdsString;
        
        if( !String.isEmpty(SearchString)){
             QUERY +=  ' AND CommunityNickname Like \'%' + String.escapeSingleQuotes(SearchString) + '%\'';
        }
        if( !String.isEmpty(FilterOption) && FilterOption != 'ALL'){
             QUERY +=  ' AND CORECONNECT__Classification1__c = \''+ String.escapeSingleQuotes(FilterOption) +'\'';
        }
        
        if(!String.isEmpty(locationString) && withinDistance != null && withinDistance > 0)
        {
        	Geocode_Data_Row__c gdr = SROCUtilities.postalCodeToGeocodeData(locationString);
        	
        	if(gdr != null)
        	{
        		QUERY += ' AND DISTANCE(Contact.Account.GeoLocation__c, GEOLOCATION('+gdr.Geocode__Latitude__s+','+gdr.Geocode__Longitude__s+'),\'mi\') < ' + withinDistance;
        	}
        	else
        	{
        		QUERY += ' AND DISTANCE(Contact.Account.GeoLocation__c, GEOLOCATION(0,0), \'mi\') < 0';
        	}
        }
        
        QUERY += ' ORDER BY CreatedDate DESC';
        
        return  QUERY;
    }
    /**
        Picklist Values and Action
     */
    public List<SelectOption> getUserDepartmentsValues(){
            Schema.DescribeFieldResult fieldResult = User.CORECONNECT__Classification1__c.getDescribe();
            return CORECONNECT.CC_CommunityUtil.constPicklistValues(fieldResult);
    }
     /**
        Methods for pagenation
    */
 
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
   
    public PageReference forwardToLogin(){
        return CORECONNECT.CC_CommunityUtil.forwardToLogin();
    }
    
}