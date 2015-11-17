/**
* @ClassName    : SL_IntranetFeedItemsRecords 
* @JIRATicket   : 
* @CreatedOn    : 
* @ModifiedBy   :  
* @Description  : 
*/

/**

Percentage of best practices followed   : 100%
No of SOQL queries used                 : 9
No of collections used                  : 4
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 

*/

public without sharing class SL_IntranetFeedItemsRecords 
{
	private static final transient set<String> setFilteredFeedType = new Set<String>{'TrackedChange', 'ActivityEvent', 'ApprovalPost', 'ReplyPost'};
	
	public SL_IntranetFeedItemsRecords()
	{

	}
	
	public Integer getNoOfFeedItemRecords(String searchText)
    {
    	List<FeedItem> lstFeedItemsSearchResults = getFeedItemsRecord(searchText);
	    
	    return lstFeedItemsSearchResults != null ? lstFeedItemsSearchResults.size() : 0 ;
    }
    
    public List<FeedItem> getFeedItemsRecords(String searchText)
    {
    	return getFeedItemsRecord(searchText);
    }
    
    private List<FeedItem> getFeedItemsRecord(String searchText)
    {
		Set<Id> setFeedCommentsFeedItems = new Set<Id>();
        Set<Id> setFeedItemsId = new Set<Id>();
        Set<Id> setLoggedInUserGroupsSubscribed = fetchGroupMembers(); 
        Set<Id> setEntitiesSubscribed = fetchEntitySubscriptions();
        List<FeedItem> lstFeedItemsSearchResults = new List<FeedItem>();
        
        String strSearch= '';
        searchText = String.escapeSingleQuotes(searchText.trim());
        
		searchText = searchText.replaceAll('%', '\\%').replaceAll('_', '\\_');
		
		for(String strSearchText : searchText.split(','))
		{
			strSearch +=  strSearchText.trim() + '* OR ';
		}
        
        strSearch = strSearch.substring(0, strSearch.length() - 4);
        
    	if(String.isNotBlank(strSearch) && strSearch.length() > 2)
        {
	        String strSosl = 'Find \'' + strSearch + '\' in ALL FIELDS RETURNING ' +
	        				 'FeedItem (Id, Title, Body, CreatedById, ParentId, CreatedDate,  RelatedRecordId, ContentFileName, ContentSize, LinkUrl, Type), ' +
	        				 'FeedComment (Id, parentId, CommentBody, CreatedById, FeedItemId, CreatedDate order by CreatedDate desc)';
	        
	        List<List<SObject>> lstsearch = search.query(strSosl);
	        
	        //To collect the IDs of founded Feed items
	        for(FeedItem objFI : (List<FeedItem>)lstsearch[0])
	        {
	            setFeedItemsId.add(objFI.Id);
	        }
	        
	        for(FeedComment objFC : (List<FeedComment>)lstsearch[1])
	        {
	            //To collect all the Feed posts id so all those posts can also be displayed on the page
	            setFeedCommentsFeedItems.add(objFC.FeedItemId);
	        }   
	        
	        //To query all the Feed items for founded Feed comments and 
	        lstFeedItemsSearchResults =  [select Id, Title, Body, CreatedById, ParentId, CreatedDate, (Select Id From FeedLikes),
		                              	  RelatedRecordId, ContentFileName, ContentSize, LinkUrl, Type
			                              from FeedItem
			                              where (Id in : setFeedCommentsFeedItems or Id in : setFeedItemsId) and
			                              		  (CreatedById = :userInfo.getUserId() or							// feeds created by user
			                              		  ParentId In : setLoggedInUserGroupsSubscribed or					// group feeds
			                              		  (CreatedById IN : setEntitiesSubscribed and 						// feeds created by subscribed/followed ppl
			                              		  	(ParentId IN : setEntitiesSubscribed or ParentId In : setLoggedInUserGroupsSubscribed))) and
			                              		  Type Not in :setFilteredFeedType AND
			                              		  Parent.Type != 'Notification__c'
			                              order by CreatedDate desc
			                              limit 1000];
	                              
	        return lstFeedItemsSearchResults;
        }
        
        return null;
    }
    
    public List<FeedComment> getFeedCommentRecords(Set<Id> setFeedItemsId)
    {
    	List<FeedComment> lstFeedComments = new List<FeedComment>();
    	
    	for(FeedComment objFC : [select Id, parentId, CommentBody, CreatedById, FeedItemId, CreatedDate, RelatedRecordId
		                                 from FeedComment
		                                 where FeedItemId in : setFeedItemsId order by CreatedDate desc]) 
        {
        	lstFeedComments.add(objFC);
        }
    	return lstFeedComments;
    }
    
    private Set<Id> fetchEntitySubscriptions()
    {
    	Set<Id> setEntitiesSubscribed = new Set<Id>();
    	
    	//Query the people whom current logged in user follows
		for(EntitySubscription entitySubscribed : [Select SubscriberId, ParentId 
													From EntitySubscription 
													Where SubscriberId = :Userinfo.getUserId() LIMIT 1000])
		{
			setEntitiesSubscribed.add(entitySubscribed.ParentId);
		}
		
		return setEntitiesSubscribed;
    }
    
    private Set<Id> fetchGroupMembers()
    {
    	Set<Id> setLoggedInUserGroupsSubscribed = new Set<Id>();
    	
    	//To get ids of all the groups where current logged in users is a member
        for(CollaborationGroupMember objGroupMembers : [Select MemberId, CollaborationGroupId 
        												From CollaborationGroupMember 
        												where MemberId = :Userinfo.getUserId()])
		{
			setLoggedInUserGroupsSubscribed.add(objGroupMembers.CollaborationGroupId);
		}
		
		return setLoggedInUserGroupsSubscribed;
    }
}