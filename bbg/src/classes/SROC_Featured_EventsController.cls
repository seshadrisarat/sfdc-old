public with sharing class SROC_Featured_EventsController {
	
	public Integer numOfEvents {get;set;}
	public Timezone tz {get;private set;}
	
	public List<CORECONNECT.CC_CommunityContentWrapper> ListOfEvents {
		get{
			return queryFeaturedEvents();
		}
		set;
		}
	
	/**
        query Personal Item to obtain Groups
    */
    public List<CORECONNECT.CC_CommunityContentWrapper> queryFeaturedEvents(){
    	tz = UserInfo.getTimeZone();
    	Integer tmpNumOfEvents = 3;
    	
    	if(this.numOfEvents != null)
    	{
    		tmpNumOfEvents = this.numOfEvents;
    	}
    	
        List<CORECONNECT__CC_Home_Page_Item__c> lisPI = [select  CORECONNECT__Community_ContentId__r.Name, 
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__Location__c, 
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__Location_Street_1__c,
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__Location_Street_2__c,
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__Location_Street_3__c,
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__Location_City__c,
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__Location_State_Province__c,
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__Location_Country__c,
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__Start_Date__c,
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__End_Date__c,
                                                    CORECONNECT__Community_ContentId__r.CreatedDate,
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__Is_All_Day_ScheduledContent__c
                                            from    CORECONNECT__CC_Home_Page_Item__c 
                                            where RecordType.Name = 'Home Page Admin' 
                                            AND CORECONNECT__Order__c !=null
                                                  AND CORECONNECT__Community_Content_Type__c = 'ScheduledContent' ORDER BY CORECONNECT__Order__c LIMIT :tmpNumOfEvents];
        
        lisPI.addAll([select    CORECONNECT__Community_ContentId__r.Name, 
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__Location__c, 
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__Start_Date__c,
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__End_Date__c,
                                                    CORECONNECT__Community_ContentId__r.CreatedDate,
                                                    CORECONNECT__Community_ContentId__r.CORECONNECT__Is_All_Day_ScheduledContent__c
                                            from    CORECONNECT__CC_Home_Page_Item__c
                                            where RecordType.Name = 'Home Page Admin' 
                                            AND CORECONNECT__Order__c =null
                                            AND CORECONNECT__Community_Content_Type__c = 'ScheduledContent' 
                                            ORDER BY CORECONNECT__Community_ContentId__r.CORECONNECT__Start_Date__c ]);

        List<CORECONNECT.CC_CommunityContentWrapper> ListOfScheduledContent = new List<CORECONNECT.CC_CommunityContentWrapper> ();     
        Map<Id, CORECONNECT.CC_CommunityContentWrapper> mapOfCommunityContentId = new Map<Id, CORECONNECT.CC_CommunityContentWrapper>();
        
        if(lisPI.size()>0){
            for(CORECONNECT__CC_Home_Page_Item__c pi: lisPI){
                CORECONNECT.CC_CommunityContentWrapper w = new CORECONNECT.CC_CommunityContentWrapper();
                w.CC = pi.CORECONNECT__Community_ContentId__r;
                ListOfScheduledContent.add(w);
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
        // for now ScheduledContent records are limit to 4
        List<CORECONNECT.CC_CommunityContentWrapper> ListOfScheduledContentLimit4 = new List<CORECONNECT.CC_CommunityContentWrapper> ();
        for (CORECONNECT.CC_CommunityContentWrapper w: ListOfScheduledContent){
            if(ListOfScheduledContentLimit4.size()<4){
                ListOfScheduledContentLimit4.add(w);
            }
        }
        ListOfScheduledContent = ListOfScheduledContentLimit4;

        return ListOfScheduledContent; 
    }


}