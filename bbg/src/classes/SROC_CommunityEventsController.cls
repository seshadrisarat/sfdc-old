public with sharing class SROC_CommunityEventsController {

    public String  AdminEmail {get{   return CORECONNECT__CC_System_Settings__c.getInstance(Site.getName()).CORECONNECT__Site_Admin_Email__c ;}}  
    public List<CORECONNECT.CC_CommunityContentWrapper> ListOfScheduledContent {get;set;}

	public Timezone tz {get;private set;}
	public Boolean includePastScheduledContent {get;set;}
	public String orderScheduledContent {get;set;}
	public String locationString {get;set;}
	public Integer withinDistance {get;set;}
    public List<CORECONNECT.CC_CommunityContentWrapper> ListOfMoreScheduledContent {
        get{
                List<CORECONNECT__CC_Community_Content__c> lisCon = (List<CORECONNECT__CC_Community_Content__c>) setController.getRecords();
                ListOfMoreScheduledContent = new List<CORECONNECT.CC_CommunityContentWrapper>();
                for(CORECONNECT__CC_Community_Content__c cc: lisCon){
                    CORECONNECT.CC_CommunityContentWrapper ccw = new CORECONNECT.CC_CommunityContentWrapper();
                    ccw.CC = cc;
                    ListOfMoreScheduledContent.add(ccw);
                }
            
            return ListOfMoreScheduledContent;
        }
        set;
    }

    public String FilterString {get;set;}


    /**
 
        add standard set controller
    */
    private final Integer PAGE_SIZE = 12;
    private final String BASE_QUERY = 'select id, Name, CORECONNECT__Location__c, CORECONNECT__Location_Street_1__c, CORECONNECT__Location_Street_2__c, CORECONNECT__Location_Street_3__c, CORECONNECT__Location_City__c, CORECONNECT__Location_State_Province__c, CORECONNECT__Location_Country__c, CORECONNECT__Classification1__c, CORECONNECT__Start_Date__c, CORECONNECT__End_Date__c, CORECONNECT__Is_All_Day_ScheduledContent__c, CORECONNECT__RSVP_Link__c from CORECONNECT__CC_Community_Content__c where RecordType.Name = \'ScheduledContent\' and CORECONNECT__Community_Content_Status__c = \'Approved\'';
    private final String BASE_QUERY_NEAR_FUTURE = ' and CORECONNECT__Start_Date__c > Yesterday';
    private final String BASE_QUERY_ORDER_BY = ' order by CORECONNECT__Start_Date__c'; 
    private String QUERY; 
   
    public ApexPages.StandardSetController setController {
        get {
            if(setController == null) {
                //QueryLocator will throw LimitException more than 10,000
                //requeiment: Up to ten thousand auctions with various states of status 
                //in case more than 10,000 records exist LIMIT 10,000
                setController = new ApexPages.StandardSetController(Database.getQueryLocator(QUERY));
            }
            setController.setPageSize(PAGE_SIZE);

            return setController;
        }
        set;
    }
    
 

    public SROC_CommunityEventsController() {
        //if(QUERY == null){
          //  QUERY = BASE_QUERY + BASE_QUERY_ORDER_BY;
        //}
        this.orderScheduledContent = 'ASC';
        ListOfScheduledContent = CORECONNECT.CC_CommunityUtil.queryFeaturedScheduledContent();
        tz = UserInfo.getTimeZone();
        this.includePastScheduledContent = false;
        filter();
    }

    /**
       Method for filters
    */


    public String ScheduledContentType{
        get;set;
    }

    public List<SelectOption> getScheduledContentTypeValues(){
            Schema.DescribeFieldResult fieldResult = CORECONNECT__CC_Community_Content__c.CORECONNECT__ScheduledContent_Type__c.getDescribe();
            return CORECONNECT.CC_CommunityUtil.constPicklistValues(fieldResult);
    }
    
    public void Filter(){
        
        QUERY = BASE_QUERY;
        
        if(!this.includePastScheduledContent)
        {
        	QUERY += BASE_QUERY_NEAR_FUTURE;
        }
        
        if (ScheduledContentType != null && ScheduledContentType != ''){
            ScheduledContentType = String.escapeSingleQuotes(ScheduledContentType);
            QUERY += ' and CORECONNECT__ScheduledContent_Type__c = \'' + ScheduledContentType + '\'';
        } 
        
        if(!String.isEmpty(locationString) && withinDistance != null && withinDistance > 0)
        {
        	Geocode_Data_Row__c gdr = SROCUtilities.postalCodeToGeocodeData(locationString);
        	
        	if(gdr != null)
        	{
        		QUERY += ' AND DISTANCE(CORECONNECT__Location_Geocode__c, GEOLOCATION('+gdr.Geocode__Latitude__s+','+gdr.Geocode__Longitude__s+'),\'mi\') < ' + withinDistance;
        	}
        	else
        	{
        		QUERY += ' AND DISTANCE(CORECONNECT__Location_Geocode__c, GEOLOCATION(0,0), \'mi\') < 0';
        	}
        }
        
        QUERY += BASE_QUERY_ORDER_BY + ' ' + this.orderScheduledContent;
        
        // refresh setController
        setController = new ApexPages.StandardSetController(Database.getQueryLocator(QUERY));
        
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

   //for datetime format

   public String TodayString {
       get{
           return DateTime.now().format('EEEE, MMMM d');
       }
   }
    public void SaveCurrentToCookie(){
       CORECONNECT.CC_CommunityUtil.SaveCurrentToCookie();
   }
}