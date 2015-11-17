public with sharing class SROC_Member_BenefitsController {
    
        // Featured FreeText
    public List<CORECONNECT.CC_CommunityContentWrapper> ListOfLargeFreeText {get;set;}
    public List<CORECONNECT.CC_CommunityContentWrapper> ListOfSmallFreeText {get;set;}
	
	private SROC_System_Settings__c setting;
	
    public String  AdminEmail {get{   return CORECONNECT__CC_System_Settings__c.getInstance(Site.getName()).CORECONNECT__Site_Admin_Email__c ;}}  
	
	public String launchpadImageUrl {
		get {
			if(setting != null && !String.isEmpty(setting.Launchpad_Image_URL__c))
			{
				return setting.Launchpad_Image_URL__c;
			}
			else
			{
				return '';
			}
		}
	}
	
	public String searayLivingImageUrl {
		get {
			if(setting != null && !String.isEmpty(setting.Sea_Ray_Living_Image_URL__c))
			{
				return setting.Sea_Ray_Living_Image_URL__c;
			}
			else
			{
				return '';
			}
		}
	}
	
    public List<CORECONNECT.CC_CommunityContentWrapper> ListOfMoreFreeText {
        get{
                Map<Id, CORECONNECT.CC_CommunityContentWrapper> mapOfCommunityContentId = new Map<Id, CORECONNECT.CC_CommunityContentWrapper>();
                List<CORECONNECT__CC_Community_Content__c> lisCon = (List<CORECONNECT__CC_Community_Content__c>) setController.getRecords();
                ListOfMoreFreeText = new List<CORECONNECT.CC_CommunityContentWrapper>();
                
                for(CORECONNECT__CC_Community_Content__c cc: lisCon){
                    CORECONNECT.CC_CommunityContentWrapper ccw = new CORECONNECT.CC_CommunityContentWrapper();
                    ccw.CC = cc;
                    ListOfMoreFreeText.add(ccw);
                    mapOfCommunityContentId.put(cc.Id, ccw);
                }

                List<Attachment> lisAtt = [ select Id, ParentId
                                       from Attachment
                                        where ParentId in :mapOfCommunityContentId.keySet()];
                for(Attachment a: lisAtt){
                    mapOfCommunityContentId.get(a.ParentId).AttachmentId = a.Id;
                }


              //}
            return ListOfMoreFreeText;
        }
        set;
    }
    public SROC_Member_BenefitsController() {
            ListOfLargeFreeText = new List<CORECONNECT.CC_CommunityContentWrapper> ();
            ListOfSmallFreeText = new List<CORECONNECT.CC_CommunityContentWrapper> ();
            CORECONNECT.CC_CommunityUtil.queryFeaturedFreeText(ListOfLargeFreeText, ListOfSmallFreeText);
            
            if(QUERY == null){
                 QUERY = BASE_QUERY + BASE_QUERY_ORDER_BY;
            }
            
            setting = SROC_System_Settings__c.getInstance(Site.GetName());
    }



    /**
 
        add standard set controller
    */
    private final Integer PAGE_SIZE = 12;
      // Testing time based work flow to set to Expired. If works switch to this
    //private final String BASE_QUERY = 'select id, Name, Short_Description__c, CreatedDate from CC_Community_Content__c where RecordType.Name = \'FreeText\' and Community_Content_Status__c = \'Approved\' and FreeText_Desired_Publish_Date__c < TOMORROW';
  
    private final String BASE_QUERY = 'select id, Name, CORECONNECT__FreeText_Desired_Publish_Date__c,CORECONNECT__Short_Description__c, CreatedDate from CORECONNECT__CC_Community_Content__c where RecordType.Name = \'Member Benefits\' and CORECONNECT__Community_Content_Status__c = \'Approved\' and CORECONNECT__FreeText_Desired_Publish_Date__c < TOMORROW and (CORECONNECT__FreeText_End_Date__c > YESTERDAY OR CORECONNECT__FreeText_End_Date__c = NULL)';
    
    private final String BASE_QUERY_ORDER_BY = ' order by CORECONNECT__FreeText_Desired_Publish_Date__c desc';
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
    
    /** 
     
     methods for filter
    */
    
    
    public List<SelectOption> getClassification1Values(){
            Schema.DescribeFieldResult fieldResult = CORECONNECT__CC_Community_Content__c.CORECONNECT__Classification1__c.getDescribe();
            return CORECONNECT.CC_CommunityUtil.constPicklistValues(fieldResult);
    }

    public String Classification1{
        get;set;
    }
    
    public void Filter(){
        
        if(Classification1 == 'All'){
            QUERY = BASE_QUERY +  BASE_QUERY_ORDER_BY;
        }
        else if (!CORECONNECT.CC_CommunityUtil.isNullOrEmpty(Classification1)){
            Classification1 = String.escapeSingleQuotes(Classification1);
            QUERY = BASE_QUERY + ' and CORECONNECT__Classification1__c in (\'' + Classification1 + '\',\'All\')' + BASE_QUERY_ORDER_BY;
            
        }else {
             QUERY = BASE_QUERY +  BASE_QUERY_ORDER_BY;
        }
        
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
   
   //Date format for today
   public String TodayString {
       get{
           return DateTime.now().format('EEEE, MMMM d');
       }
   }
   
   public void SaveCurrentToCookie(){
       CORECONNECT.CC_CommunityUtil.SaveCurrentToCookie();
   }



}