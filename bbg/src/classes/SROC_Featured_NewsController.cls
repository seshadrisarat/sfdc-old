public with sharing class SROC_Featured_NewsController {
	
	public Integer numOfNews {get;set;}
	
	public List<CORECONNECT.CC_CommunityContentWrapper> ListOfNews {
		get{
			return queryFeaturedNews();
		}
		set;
		}
	
	/**
        query Personal Item to obtain Groups
    */
    public List<CORECONNECT.CC_CommunityContentWrapper> queryFeaturedNews(){
    	
    	Integer tmpNumOfNews = 3;
    	
    	if(this.numOfNews != null)
    	{
    		tmpNumOfNews = this.numOfNews;
    	}
    	
    	List<CORECONNECT.CC_CommunityContentWrapper> ListOfLargeFreeText = new List<CORECONNECT.CC_CommunityContentWrapper>();
    	
        List<CORECONNECT__CC_Home_Page_Item__c> lisPI = [select  CORECONNECT__Is_Large__c,
                                                    CORECONNECT__Community_ContentId__r.Name, 
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__Short_Description__c,
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__Description__c,
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__FreeText_End_Date__c,
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__FreeText_Desired_Publish_Date__c,
                                                    CORECONNECT__Community_ContentId__r.CreatedDate
                                            from    CORECONNECT__CC_Home_Page_Item__c 
                                            where RecordType.Name = 'Home Page Admin' 
                                                  AND CORECONNECT__Community_Content_Type__c = 'FreeText' AND CORECONNECT__Is_Large__c = true
                                                  ORDER BY CORECONNECT__Order__c 
                                                  limit :tmpNumOfNews];
      
        Map<Id, CORECONNECT.CC_CommunityContentWrapper> mapOfCommunityContentId = new Map<Id, CORECONNECT.CC_CommunityContentWrapper>();
        Integer smallCount = 0;
        if(lisPI.size()>0){
            for(CORECONNECT__CC_Home_Page_Item__c pi: lisPI){
                CORECONNECT.CC_CommunityContentWrapper w = new CORECONNECT.CC_CommunityContentWrapper();
                
                w.CC = pi.CORECONNECT__Community_ContentId__r;
                ListOfLargeFreeText.add(w);
               
                // put community content id with wrapper class so that later add attachment Id
                mapOfCommunityContentId.put(pi.CORECONNECT__Community_ContentId__r.id, w);
            }
            
            List<Attachment> lisAtt = [ select Id, ParentId
                                       from Attachment
                                        where ParentId in :mapOfCommunityContentId.keySet()];
            for(Attachment a: lisAtt){
                mapOfCommunityContentId.get(a.ParentId).AttachmentId = a.Id;
            }
        }
        
        return ListOfLargeFreeText; 
    }


}