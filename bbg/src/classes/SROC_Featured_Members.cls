public with sharing class SROC_Featured_Members {

	public Integer numOfMembers {get;set;}
	
	public String ownersOrDealers {get;set;}
	
	SROC_System_Settings__c setting;
	
	public SROC_Featured_Members() {
		
		setting = SROC_System_Settings__c.getInstance(Site.GetName());
		
	}
	
	public String ambassadorIndicatorImage {
		get {
			if(setting != null)
			{
				return setting.Ambassador_Indicator_Image__c;
			}else{return '';}}
	}
	
	public List<CORECONNECT.CC_CommunityContentWrapper> ListOfMembers {
		get {
			return queryFeaturedMembers();
		}
		set;
		
	}
	

	/**
        query Personal Item to obtain Members
    */
    private List<CORECONNECT.CC_CommunityContentWrapper>  queryFeaturedMembers(){
    	
    	Integer tmpNumOfMembers = 3;
    	
    	if(this.numOfMembers != null)
    	{
    		tmpNumOfMembers = this.numOfMembers;
    	}
    	
    	
        List<CORECONNECT__CC_Home_Page_Item__c> lisPI;
        
        if(!String.IsEmpty(this.ownersOrDealers) && this.ownersOrDealers.toLowerCase() == 'dealers')
        {
        	lisPI = [ select  CORECONNECT__Featured_Member__c,
                                                    CORECONNECT__Featured_Member__r.Name,
                                                    CORECONNECT__Featured_Member__r.CommunityNickname,
                                                    CORECONNECT__Featured_Member__r.AboutMe, 
                                                    CORECONNECT__Featured_Member__r.FullPhotoUrl,
                                                    CORECONNECT__Featured_Member__r.CORECONNECT__Classification1__c,
                                                    CORECONNECT__Featured_Member__r.CORECONNECT__CC_List_In_Directory__c, 
                                                    CORECONNECT__Featured_Member_Type__c
                                            from    CORECONNECT__CC_Home_Page_Item__c 
                                            where 
                                                    CORECONNECT__Featured_Member__c != null AND CORECONNECT__Featured_Member__r.CORECONNECT__Classification1__c = 'Dealers'
                                                    AND CORECONNECT__Featured_Member__r.CORECONNECT__CC_List_In_Directory__c = TRUE                                            		
                                            ORDER BY CORECONNECT__Order__c limit :tmpNumOfMembers];
        }
        else
        {
        	lisPI = [ select  CORECONNECT__Featured_Member__c,
                                                    CORECONNECT__Featured_Member__r.Name,
                                                    CORECONNECT__Featured_Member__r.CommunityNickname,
                                                    CORECONNECT__Featured_Member__r.AboutMe, 
                                                    CORECONNECT__Featured_Member__r.FullPhotoUrl,
                                                    CORECONNECT__Featured_Member__r.CORECONNECT__Classification1__c, 
                                                    CORECONNECT__Featured_Member_Type__c
                                            from    CORECONNECT__CC_Home_Page_Item__c 
                                            where 
                                                    CORECONNECT__Featured_Member__c != null AND (CORECONNECT__Featured_Member__r.CORECONNECT__Classification1__c = 'Owners'
                                                    OR CORECONNECT__Featured_Member__r.CORECONNECT__Classification1__c = 'Ambassadors') AND CORECONNECT__Featured_Member__r.CORECONNECT__CC_List_In_Directory__c = TRUE                                          		
                                            ORDER BY CORECONNECT__Order__c limit :tmpNumOfMembers];
        }
        
        List<CORECONNECT.CC_CommunityContentWrapper> tmpListOfMembers = new List<CORECONNECT.CC_CommunityContentWrapper> ();        
     
            for(CORECONNECT__CC_Home_Page_Item__c pi: lisPI){
                CORECONNECT.CC_CommunityContentWrapper w = new CORECONNECT.CC_CommunityContentWrapper();
                w.Mem = pi.CORECONNECT__Featured_Member__r;
                w.FeaturedMemberType = pi.CORECONNECT__Featured_Member_Type__c;
                tmpListOfMembers.add(w);
            }
            
            return tmpListOfMembers;
    }


}