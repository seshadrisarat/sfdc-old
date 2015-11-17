public with sharing class SROC_Featured_GroupsController {

	public Integer numOfGroups {get;set;}

	
	public List<CORECONNECT.CC_CommunityContentWrapper> ListOfGroups {
		get{
			return queryFeaturedGroups();
		}
		set;
		}
	
	/**
        query Personal Item to obtain Groups
    */
    public List<CORECONNECT.CC_CommunityContentWrapper>  queryFeaturedGroups(){
    	
    	Integer tmpNumOfGroups = 3;
    	
    	if(this.numOfGroups != null)
    	{
    		tmpNumOfGroups = this.numOfGroups;
    	}
    	
        List<CORECONNECT__CC_Home_Page_Item__c> lisPI = [ select  CORECONNECT__Featured_Group__r.CORECONNECT__Collaboration_GroupId__c
                                            from    CORECONNECT__CC_Home_Page_Item__c 
                                            where  CORECONNECT__Featured_Group__c != null ORDER BY CORECONNECT__Order__c limit :tmpNumOfGroups];
        
        

        Set<Id> setOfCollabGroupId  = new Set<Id>();
        for(CORECONNECT__CC_Home_Page_Item__c pi: lisPI){
            setOfCollabGroupId.add(pi.CORECONNECT__Featured_Group__r.CORECONNECT__Collaboration_GroupId__c);
        }

        List<CollaborationGroup> lisCG = [  select Id,
                                                   Name,
                                                   Description
                                            from CollaborationGroup 
                                            where Id in :setOfCollabGroupId];
        // create map. we need to keep order
        Map<Id, CollaborationGroup> mapIdAndCollabGroup = new Map<Id, CollaborationGroup>();
        for(CollaborationGroup cg: lisCG){
            mapIdAndCollabGroup.put(cg.id,cg);
        }

        List<CORECONNECT.CC_CommunityContentWrapper> tmpListOfGroups = new List<CORECONNECT.CC_CommunityContentWrapper> ();     
        // go trough again to keep order 
        for(CORECONNECT__CC_Home_Page_Item__c pi: lisPI){
                CORECONNECT.CC_CommunityContentWrapper w = new CORECONNECT.CC_CommunityContentWrapper();
                w.CollabGroup = mapIdAndCollabGroup.get(pi.CORECONNECT__Featured_Group__r.CORECONNECT__Collaboration_GroupId__c);
                tmpListOfGroups.add(w);
        }
        
        return tmpListOfGroups;  
    }


}