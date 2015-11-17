public with sharing class SROC_CommunityHomeController {

    /*
    Home Page Section
    */
    String defaultValue = 'default';
    public String PathName {
        get{    
            if(setting==null){
                return defaultValue;
            }return setting.CORECONNECT__Community_Path_Name__c;}}
    public String GuestProfileName {
        get{    
            if(setting==null){
                return defaultValue;
            }return setting.CORECONNECT__Guest_Profile_Name__c;}}
	
	public Boolean ShowGettingStartedLink {
		get {
			if(setting == null) {
				return false;
			}return setting.CORECONNECT__Show_Getting_Started_Link__c;
		}
	}
	
	public Boolean showHighlights {
		get{
			Cookie dismissHL = ApexPages.currentPage().getCookies().get('dismissHighlights');
			if(dismissHL != null && !String.isempty(dismissHL.getValue()) && dismissHL.getValue() == 'dismissed')
			{
				return false;
			}
			else
			{
				return true;
			}
		}
	}
	
    // My Links
    public List<CORECONNECT__CC_Personal_Item__c> ListOfMyLinks {get;set;}

	public Map<Id,String> mapOfMyLinksIcons {get;set;}
		
    private CORECONNECT__CC_System_Settings__c setting; 
    
    private SROC_System_Settings__c settingSROC;
    
    public SROC_CommunityHomeController() {
            setting = CORECONNECT__CC_System_Settings__c.getInstance(Site.GetName());
            settingSROC = SROC_System_Settings__c.getInstance(Site.GetName());
            queryMyLinks();
            queryMyLinkIcons();
            
            if(isOwner)
            {
            	initializeBoatController();
            }
            
            String enableHighlights = ApexPages.CurrentPage().getParameters().get('enableHighlights');
            
            if(enableHighlights != null && enableHighlights == 'true')
            {
            	enableHighlights();
            }
    }
	
	public Boolean isOwner {
		get
		{
			return SROCUtilities.isOwner();
		}
	}
	
    public String homeBannerURL {
    	get {
    		if(setting != null && !String.isEmpty(settingSROC.Default_Home_Page_Banner_URL__c))
    		{
    			return settingSROC.Default_Home_Page_Banner_URL__c;
    		}
    		else
    		{
    			return '';
    		}
    	}
    }
    

    /**
        query My Links
    */
    private void  queryMyLinks (){
    	Id devRecordTypeId = Schema.SObjectType.CORECONNECT__CC_Personal_Item__c.getRecordTypeInfosByName().get('My Shortcuts').getRecordTypeId();   
    	
        ListOfMyLinks = [ select  CORECONNECT__My_Links_Title__c,
                                                    CORECONNECT__My_Links_URL__c,
                                                    CORECONNECT__Order__c, CORECONNECT__Category__c                
                                            from    CORECONNECT__CC_Personal_Item__c 
                                            where 
                                            OwnerId = :UserInfo.GetUserId() AND RecordTypeId = :devRecordTypeId
                                            ORDER BY CORECONNECT__Order__c];
            
    }
    
    private void queryMyLinkIcons() {
    	
    	if(this.ListOfMyLinks != null && this.ListOfMyLinks.size() > 0 && this.mapOfMyLinksIcons == null)
    	{
    		this.mapOfMyLinksIcons = new Map<Id,String>();
    		
    		List<CORECONNECT__CC_Link_Icons__c> linkIconList = [SELECT Name, CORECONNECT__Icon_Url__c FROM CORECONNECT__CC_Link_Icons__c];
    		Map<String,String> linkIconMap = new Map<String,String>();
    		
    		for(CORECONNECT__CC_Link_Icons__c li : linkIconList)
    		{
    			linkIconMap.put(li.Name,li.CORECONNECT__Icon_Url__c);
    		}
    		
    		for(CORECONNECT__CC_Personal_Item__c pi : this.ListOfMyLinks)
    		{
    			String url;
    			if(pi.CORECONNECT__Category__c != null)
    			{
    				url = linkIconMap.get(pi.CORECONNECT__Category__c);
    			}
    			
    			if(url == null || url == '')
    			{
    				url = linkIconMap.get('Default');
    			}
    			
    			mapOfMyLinksIcons.put(pi.Id,url);
    		}
    		
    	}
    	
    }

	
	public Boolean isError {
	get {
		if(ApexPages.getMessages().size() > 0)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}
	

    /**
        login logic
    */
    public PageReference forwardToLogin(){

       return CORECONNECT.CC_CommunityUtil.forwardToLogin(CORECONNECT.CC_CommunityConstants.EMPLOYEE_LOGIN_FULL_URL);
    
    }
	
	public PageReference dismissHighlights() {
		
		Cookie dismissHL = ApexPages.currentPage().getCookies().get('dismissHighlights');
		dismissHL = new Cookie('dismissHighlights','dismissed', null, -1, false);
		ApexPages.currentPage().setCookies(new Cookie[]{dismissHL});
		System.debug('dismiss highlights cookie: '+dismissHL);

		return null;
		
	}
	
	public void enableHighlights() {
		
		Cookie dismissHL = ApexPages.currentPage().getCookies().get('dismissHighlights');
		dismissHL = new Cookie('dismissHighlights',null, null, -1, false);
		ApexPages.currentPage().setCookies(new Cookie[]{dismissHL});
		
		System.debug('enable highlights cookie: '+dismissHL);
	}
	
	
    public PageReference forwardToStartURL(){
        
        String currentPage = ApexPages.currentPage().getUrl();
        String startURL;
        if(!String.isEmpty(currentPage)){
                startURL= currentPage.substringAfter('startURL=%2F'+PathName+'%2F');
                
        }
        
        Cookie acStartURL = ApexPages.currentPage().getCookies().get('acStartURL');
    
        if (acStartURL == null || String.isEmpty(acStartURL.getValue())) {
            if(!String.isEmpty(startURL)){
                acStartURL = new Cookie('acStartURL',startURL,null,-1,false);
                ApexPages.currentPage().setCookies(new Cookie[]{acStartURL});
            }
            
        } else {
            String cookieURL = acStartURL.getValue();
            if(!String.isEmpty(cookieURL)){
                acStartURL = new Cookie('acStartURL', null,null,-1,false);
                ApexPages.currentPage().setCookies(new Cookie[]{acStartURL});
                cookieURL = EncodingUtil.urlDecode(cookieURL, 'UTF-8');
                if(CORECONNECT.CC_CommunityConstants.User_Profile_Name == CORECONNECT__CC_System_Settings__c.getInstance(Site.getName()).CORECONNECT__Guest_Profile_Name__c){
                    return null;
                }
                return new PageReference ('/'+cookieURL);
            }
            
        }
       return null;
    
    }

    public List<CORECONNECT__CC_Page_Tour__c> getPageTours(){
        
        return [SELECT Id, Name, CORECONNECT__Animation__c, CORECONNECT__Content__c, CORECONNECT__Markup_Element__c, CORECONNECT__Order__c, CORECONNECT__Page_Name__c, CORECONNECT__Placement__c
                FROM CORECONNECT__CC_Page_Tour__c WHERE CORECONNECT__Page_Name__c = 'SROC_CommunityHome' ORDER BY CORECONNECT__Order__c ASC];
        
    }

	/*
	Boat Edit Page
	*/
	SROC_My_BoatController boatController {get;set;}
	public Attachment BannerImageAttachment{get;set;}
	public Attachment NewBannerImageAttachment{get;set;}
	public Owner_Boat_Relationship__c currOBR {get;private set;}
	public String dealerPostalCodeSearch {get;set;}
	public String selectedPreferredDealer {get;set;}
	public Integer withinDistance {get;set;}
	public List<Account> dealerSearchList {get; private set;}
	
	private void initializeBoatController() {
		this.boatController = new SROC_My_BoatController();
		this.BannerImageAttachment = this.boatController.BannerImageAttachment;
		this.NewBannerImageAttachment = this.boatController.NewBannerImageAttachment;
		this.currOBR = this.boatController.currOBR;
		this.dealerPostalCodeSearch = this.boatController.dealerPostalCodeSearch;
		this.selectedPreferredDealer = this.boatController.selectedPreferredDealer;
		this.withinDistance = this.boatController.withinDistance;
		this.dealerSearchList = this.boatController.dealerSearchList;
	}
	
	public void doDealerSearch() {
		
		this.boatController.dealerPostalCodeSearch = this.dealerPostalCodeSearch;
		this.boatcontroller.withinDistance = this.withinDistance;
		
		this.boatController.doDealerSearch();
		
		this.dealerSearchList = this.boatController.dealerSearchList;
		
	}
	
	public PageReference saveMyBoatInfo(){
		
		this.boatController.NewBannerImageAttachment = this.NewBannerImageAttachment;
		this.boatController.selectedPreferredDealer = this.selectedPreferredDealer;
		this.boatController.currOBR.SROC_Boat_Name__c = this.currOBR.SROC_Boat_Name__c;
		
        if(this.boatController.saveMyBoatInfo() != null || !isError)
        {
        	PageReference pr = new PageReference(Page.SROC_CommunityHome.getURL());
        	pr.setRedirect(true);
        
        	return pr;
        }
        else
        {
        	return null;
        }
        
    }
    
    public PageReference clearMyBoatImage() {
		
		if(this.boatController.clearMyBoatImage() != null && !isError)
		{
			PageReference pr = new PageReference(Page.SROC_CommunityHome.getURL());
        	pr.setRedirect(true);
        
        	return pr;
		}
		else
		{
			return null;
		}
		
	}
	
}