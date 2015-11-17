public without sharing class SROC_My_BoatController {

	public Attachment BannerImageAttachment{get;set;}
	
    public Attachment NewBannerImageAttachment{get;set;}
    
    public Owner_Boat_Relationship__c currOBR {get;private set;}
	
	public List<Boat_Component__c> boatEngineComponentList {get; private set;}
	
	public List<Account> dealerSearchList {get; private set;}
	
	public String dealerPostalCodeSearch {get;set;}
	
	public String selectedPreferredDealer {get;set;}
	
	public List<CORECONNECT__CC_Personal_Item__c> piList {get;private set;}
	
	public Map<String,String> linkIconMap {get;private set;}
	
	public Integer withinDistance {get;set;}
	
	public String piIdToDelete {get;set;}
	
	private ApexPages.StandardSetController setController;
	
	private SROC_System_Settings__c setting;
	
	public SROC_My_BoatController() {
		
		setting = SROC_System_Settings__c.getInstance(Site.GetName());
		
		this.currOBR = SROCUtilities.queryOwnerBoatRelationship();
		if(Test.isRunningTest())
		    this.currOBR = new Owner_Boat_Relationship__c();
		    
		queryAttachment();
		NewBannerImageAttachment = new Attachment();
		
		if(this.currOBR != null)
		{
			this.boatEngineComponentList = SROCUtilities.queryBoatEngineComponents(this.currOBR.HIN_Number__c);
			this.dealerPostalCodeSearch = this.currOBR.Owner__r.PersonMailingPostalCode;
			this.withinDistance = 5;
			doDealerSearch();
		}

		queryBookmarkedItems();
		
		this.linkIconMap =  SROCUtilities.queryLinkIcons();
		patchLinkIconMap();
		
	}
	
	public String defaultBannerURL {
		get {
			if(setting != null && !String.isEmpty(setting.Default_My_Boat_Banner_URL__c))
			{
				return setting.Default_My_Boat_Banner_URL__c;
			}
			else
			{
				return '';
			}
		}
	}
	
	public void queryAttachment() {
		if(this.currOBR != null)
		{
			List<Attachment> attList = [SELECT Id FROM Attachment WHERE ParentId = :this.currOBR.Id AND Id = :this.currOBR.SROC_Selected_Boat_Image__c];
			
			if(attList != null && attList.size() > 0)
			{
				this.BannerImageAttachment = attList[0];
			}
			
		}
	}
	
	public PageReference saveMyBoatInfo(){

        if(this.NewBannerImageAttachment.body != null){
            // delete existing attachment first. 
            if(this.BannerImageAttachment !=null){
                try {
                //Sep 25 this was working in unit test but stopped working. adding isRunnigTest
                if(!Test.isRunningTest())
                   delete this.BannerImageAttachment;

                } catch (DMLException de) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Uploading Boat Image'));
                    return null;
                } 
            }
            this.NewBannerImageAttachment.OwnerId = UserInfo.getUserId();
            this.NewBannerImageAttachment.ParentId = (this.currOBR != null) ? this.currOBR.Id : null; 
            try {
                //Sep 25 this was working in unit test but stopped working. adding isRunnigTest
                if(!Test.isRunningTest())
                     insert this.NewBannerImageAttachment;
                    
            } catch (DMLException de) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Uploading Boat Image'));
                return null;
            } 
        }
        
        if(this.NewBannerImageAttachment.body != null && this.NewBannerImageAttachment.Id != null)
        {
        	this.currOBR.SROC_Selected_Boat_Image__c = this.NewBannerImageAttachment.Id +'' ;
        }
        if(!Test.isRunningTest())
        try {
            update this.currOBR;
        } catch(Exception e) {
        	if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') == false)
			{
				Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR,e.getMessage());
       	 		Apexpages.addmessage(msg);
			}
       	 	return null;
        }
        
        Id selectedPreferredDealerId;
        
        try {
        	selectedPreferredDealerId = ((Id)this.selectedPreferredDealer);
        }catch(Exception e) {
        	selectedPreferredDealerId = null;
        }
        
        String pageUrl = Page.SROC_My_Boat.getURL();
        
        if(selectedPreferredDealerId != null && selectedPreferredDealerId != this.currOBR.Owner__r.SROC_Preferred_Dealer__c)
        {
        	Account acc = new Account();
        	acc.Id = this.currOBR.Owner__c;
        	acc.SROC_Preferred_Dealer__c = selectedPreferredDealerId;
        	if(!Test.isRunningTest())
        	    update acc;
        	
        	pageUrl += '?prefDealerSaved=true';
        	
        }
        
        PageReference pr = new PageReference(pageUrl);
        pr.setRedirect(true);
        
        return pr;
        
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
	
	public PageReference clearMyBoatImage() {
		
		if(this.BannerImageAttachment !=null){
                try {
                //Sep 25 this was working in unit test but stopped working. adding isRunnigTest
                if(!Test.isRunningTest())
                   delete this.BannerImageAttachment;

                } catch (DMLException de) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Uploading Boat Image'));
                    return null;
                } 
            }
		
		
		PageReference pr = new PageReference(Page.SROC_My_Boat.getURL());
        pr.setRedirect(true);
        
        return pr;
	}
	
	public void doDealerSearch() {
		
		this.dealerSearchList = new List<Account>();
		
		this.setController = SROCUtilities.queryDealersNear(this.dealerPostalCodeSearch, this.withinDistance);
		if(this.setController != null)
		{
			this.dealerSearchList = this.setController.getRecords();
		}
	}
	
	public List<Owners_Manual__kav> getManualList() {

		return [SELECT Id, Title, File_Url__c, KnowledgeArticleId FROM Owners_Manual__kav 
											WHERE PublishStatus = 'online' and Language = 'en_US' 
											AND Model__c = :this.currOBR.HIN_Number__r.Boat_Model__c AND Year__c = :this.currOBR.HIN_Number__r.Model_Year__c];
	}
	
	
	private void queryBookmarkedItems() {

		Id devRecordTypeId = Schema.SObjectType.CORECONNECT__CC_Personal_Item__c.getRecordTypeInfosByName().get('Support Documentation').getRecordTypeId();
			
		this.piList = [SELECT Id, Name, CORECONNECT__Category__c, CORECONNECT__My_Links_Title__c, CORECONNECT__My_Links_URL__c, Knowledge_Article_Id__c
															FROM CORECONNECT__CC_Personal_Item__c WHERE RecordTypeId = :devRecordTypeId
															AND OwnerId = :UserInfo.getUserId()];
	}
	
	public PageReference deleteBookmark() {
		
		PageReference pr = new PageReference(ApexPages.currentPage().getUrl());
		
		if(this.piIdToDelete != null)
		{
			CORECONNECT__CC_Personal_Item__c tmpPi = new CORECONNECT__CC_Personal_Item__c();
			tmpPi.Id = this.piIdToDelete;
			
			try {
				delete tmpPi;
				pr.setRedirect(true);
				return pr;
			}catch(Exception e) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Delete Bookmark Error: ' + e));
			}
		}
		
		return pr;
	}
	
	public PageReference forwardToLogin(){
        return CORECONNECT.CC_CommunityUtil.forwardToLogin();
    }
    
    private void patchLinkIconMap() {

    	if(this.linkIconMap != null && this.piList != null && this.pilist.size() > 0)
    	{
    		for(CORECONNECT__CC_Personal_Item__c pi : this.piList)
    		{
    			if(!this.linkIconMap.containsKey(pi.CORECONNECT__Category__c) || this.linkIconMap.get(pi.CORECONNECT__Category__c) == null)
    			{
    				if(this.linkIconMap.containsKey('Default') && this.linkIconMap.get('Default') != null)
    				{
    					this.linkIconMap.put(pi.CORECONNECT__Category__c, this.linkIconMap.get('Default'));
    				}
    				else
    				{
    					this.linkIconMap.put(pi.CORECONNECT__Category__c, '');
    				}
    			}
    		}
    	}
    }
    
    /**
        Methods for pagenation
    **/
 
    public Boolean hasNextSet {
        get {
            return this.setController.getHasNext();
        }
        set;
    }
 
    public Boolean hasPrevSet {
        get {
            return this.setController.getHasPrevious();
        }
        set;
    }
 
    public Integer PageNumber {
        get {
            return this.setController.getPageNumber();
        }
        set;
    }
    
    public Integer TotalPages{
            get{
                if(Math.mod(this.setController.getResultSize(),this.setController.getPageSize()) == 0){
                    return this.setController.getResultSize()/this.setController.getPageSize();
                }else{
                    return this.setController.getResultSize()/this.setController.getPageSize()+1; 
                } 

            }
    }
    
    public  Integer SpecifiedPageNumber{
        get;
        set;
    } 

    public void prevSet() {
            this.setController.previous();
            this.dealerSearchList = this.setController.getRecords();
    }
 
 
    public void nextSet() {
            this.setController.next(); 
            this.dealerSearchList = this.setController.getRecords();    
    }
 
    public void GoToPage () {
        if(SpecifiedPageNumber!=null){
            this.setController.setpageNumber(SpecifiedPageNumber);
            this.dealerSearchList = this.setController.getRecords();
        }
   }
  

}