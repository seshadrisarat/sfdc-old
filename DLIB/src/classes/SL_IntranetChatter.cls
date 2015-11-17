/**
* @ClassName    : SL_IntranetChatter 
* @JIRATicket   : Socint-193
* @CreatedOn    : 1/Aug/13
* @ModifiedBy   : Pravin 
* @Description  : This is the class for accessing chatter feeds
*/

/**
@ Pravin Sapkal
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 
No of collections used                  : 
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      :   
Approved by                             : 
*/

public abstract without sharing class SL_IntranetChatter extends WidgetPaginatorAbstract 
{
    public  List<ContentVersion> lstContentsToBedisplayed {get;set;}
    public transient Map<Id, List<FeedItem>> mapContentIdToLstFeedItems {get;set;}  //map to contain the FeedItems respective to each Content
    public Map<Id, ContentVersion> mapFeedItemIdToContent {get;set;}
    public Integer lstFeedItemsSize {get; set;}
    public String logoURL {get; set;}
    public String userImage {get; set;}
    public Set<Id> setContentVersionId {get;set;}
    
    public String deletedPostId {get;set;}
    public String deletedCommentId  {get;set;}
    public String strFeaturedPostsIDs   {get;set;}

    /* Vars for posting */
    public String strPostBody {get;set;}
    public string strLinkPost {get;set;}
    public String strLinkName {get;set;}
    public String feedParentId {get;set;}
    public String feedItemOrderBy {get;set;}
    public Boolean hasPostAccess {get;set;}
    public Boolean hasDeleteAccess  {get;set;}
    /* End Of vars */
    
    /* Vars for display of Feed posts */
    public List<FeedItem> lstFeedItemsSearchResults {get;set;}
    public Map<Id, List<FeedComment>> mapFeedItemIdToRelatedlstComments {get;set;}
    public Map<Id, User> mapFeedIdToUser {get;set;}
    public Map<Id, String> mapFeedItemIdToGroupName {get;set;}
    public Map<Id, Datetime> mapFeedIdToCreatedDate {get;set;}
    public Map<Id, Datetime> mapFeedIdToCreatedDateGMT {get;set;}
    public Map<Id, Integer> mapFeedIdToNumOfLikes {get;set;}
    public Map<Id, String> mapFeedIdToFeedLikeId {get;set;} 
    public Integer numOfRecordeToBedisplayed {get;set;}
    public String currentContentId {get;set;}
    /* End of Vars for feed posts */
    
    public String strEntityId {get; set;}
    public String selectedGroupName {get;set;} 
    
    public Integer numOfFeedPostPerPage; 
    public static Map<Integer, String> mapMonths;
    
    private Map<Id, String> mapGroupIdToName;  
    private Map<Id, Integer> mapFeedItemIdToIndex   ;
    
    private Set<String> setLoggedinUserOfficesId;
    private Set<Id> setAllUserIds = new Set<Id>();
    
    public String strContentVersionId {get; set;}
    
    public String strContentsQuery;
    public String strContentTypes;
    public String strFilteredItems		{	get; set;	}
    public String strListOfContentIdsToBeDisplayed {get;set;}
    
    private static final set<String> setFilteredFeedType = new Set<String>{'TrackedChange', 'ActivityEvent', 'ApprovalPost', 'ReplyPost'}; 
    
    static
    {
        //Initializing the map to identify the current month in the Notifications widget
        mapMonths = new Map<Integer, String>{
            1 => 'January', 2 => 'February', 3 => 'March', 4 => 'April', 5 => 'May', 6 => 'June',
            7 => 'July', 8 => 'August', 9 => 'September', 10 => 'October', 11 => 'November', 12 => 'December'
        };
    }
    
    /* Constructor initialization */
    public SL_IntranetChatter()
    {
        this.initializeSL_IntranetChatterController();
    }
    /* End : Constructor initialization */
    
    
    
    
    private void initializeSL_IntranetChatterController()
    {
        lstFeedItemsSize = 0;
        
        strContentTypes = '';
        strFilteredItems = '';
        strEntityId = UserInfo.getUserId();
        feedParentId = Userinfo.getUserId();
        
        strPostBody = '';
        strLinkPost = '';
        strLinkName = ''; 
        currentContentId = '';  
        strFeaturedPostsIDs = deletedCommentId = deletedPostId = '';
        
        strContentVersionId = '';
        
        hasPostAccess = false;
        
        selectedGroupName = 'My Feed';
        feedItemOrderBy = 'CreatedDate';
        
        //lstContentsToBedisplayed = new List<ContentVersion>();
        setContentVersionId = new Set<Id>();
        mapFeedItemIdToIndex = new Map<Id, Integer>();
        mapFeedItemIdToRelatedlstComments = new Map<Id, List<FeedComment>>();
        mapFeedIdToUser = new Map<Id,User>();
        mapFeedItemIdToGroupName = new Map<Id, String>();
        mapFeedIdToCreatedDate = new map<Id, Datetime>();
        mapFeedIdToCreatedDateGMT = new map<Id, Datetime>();
        mapGroupIdToName = new Map<Id, String>();
        mapFeedIdToNumOfLikes = new Map<Id, Integer>();
        mapFeedIdToFeedLikeId = new Map<Id, String>(); 
        mapFeedItemIdToContent = new Map<Id, ContentVersion>();
        setAllUserIds = new Set<Id>();
        
        userImage = [select Name, SmallPhotoUrl from User where id =: userinfo.getUserId() and SmallPhotoUrl != NULL].SmallPhotoUrl; 
        
        //This section is used due to 'Automated Process' user which is not a part of individual Organization
        for(User objUser : [select Id, Name, SmallPhotoUrl from User where Id != null])
        {
            setAllUserIds.add(objUser.Id);
        }
        
        /* Start : Get the pageSizes from custom settings for pagination */
        numOfFeedPostPerPage = 20;
        for(SL_Intranet_PaginationSettings__c objPagination : [SELECT Name, FeedPost_PageSize__c FROM SL_Intranet_PaginationSettings__c limit 1])
        {
            if(objPagination.FeedPost_PageSize__c != NULL)
                numOfFeedPostPerPage = Integer.valueOf(objPagination.FeedPost_PageSize__c);
        }
        numOfRecordeToBedisplayed = numOfFeedPostPerPage;
        /* End : Get the pageSizes from custom settings for pagination */
        
        //To collect all the GroupId and Its name to display it on tha page for related post
        for(CollaborationGroup objCG : [select Id, Name from CollaborationGroup where Name != null])
        {
            mapGroupIdToName.put(objCG.Id, objCG.Name);
        }
        
        // getFeedItems();      //To get the Feed posts
        
        hasDeleteAccess = false;    //Check whether the user has administrative access rights
        
        String strProfileName = [SELECT Name FROM Profile WHERE Id = : Userinfo.getProfileId()].Name;
        if(strProfileName == 'System Administrator')
            hasDeleteAccess = true;
        
        logoURL = '';

        String userOfficeLocationIds = [Select Id, Selected_Offices_Ids__c from User where Id = :Userinfo.getUserId()].Selected_Offices_Ids__c;
        
        setLoggedinUserOfficesId = new Set<String>();
        if(userOfficeLocationIds != '' && userOfficeLocationIds != null) 
            setLoggedinUserOfficesId.addAll(userOfficeLocationIds.split(';'));
        
        for(SL_CustomizableComponent__c objCC : [select Updated_Static_Resource_Name__c, Logo__c 
                                                        from SL_CustomizableComponent__c where Default__c = false limit 1])
        {
            if(objCC.Logo__c != null && objCC.Logo__c != '')
                logoURL = '/servlet/servlet.ImageServer?id=' + objCC.Logo__c + '&oid=' + UserInfo.getOrganizationId();    
        }
    }
    
    
    /* Start - Method for getting more records for feedpost
       @Name           - getMoreRecords
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for getting more records for feedpost
    */  
    public void getMoreRecords()
    {
        numOfRecordeToBedisplayed += numOfFeedPostPerPage;
        
        if(!String.isBlank(strContentsQuery))
	       	 queryContentsToBeDisplayed();
    }
    /* End : getMoreRecords Method */
    
    private Set<Id> getSubscribedGroups(String strUserId) {
		Set<Id> setGroupsSubscribed = new Set<Id>();
		
		// Getting the people whom current logged in user follows
		Set<Id> setLoggedInUserGroupsSubscribed = new Set<Id>();
		for(CollaborationGroupMember objGroupMembers : [
			Select MemberId, CollaborationGroupId From CollaborationGroupMember where MemberId =: Userinfo.getUserId()])
		{
			setLoggedInUserGroupsSubscribed.add(objGroupMembers.CollaborationGroupId);
		}
		
		if(!String.isEmpty(strUserId) && strUserId != Userinfo.getUserId())
		{
			for(CollaborationGroupMember objGroupMembers : [
				Select MemberId, CollaborationGroupId From CollaborationGroupMember where MemberId =: strUserId]) 
			{
				if(setLoggedInUserGroupsSubscribed.contains(objGroupMembers.CollaborationGroupId))
					setGroupsSubscribed.add(objGroupMembers.CollaborationGroupId);
			}	
		}
		else
			setGroupsSubscribed.addAll(setLoggedInUserGroupsSubscribed);
		
		return setGroupsSubscribed;
	}
	
    /* Start - Method for getting FeedItems for logged in user
       @Name           - getFeedItems
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for getting FeedItems for logged in user
    */  
     public void getFeedItems()
     {
            Map<Id, Id> mapFeedIdToCreatedBYId = new Map<Id,Id>();
            mapFeedItemIdToIndex = new Map<Id, Integer>();
            Set<Id> setFeedItemsId = new Set<Id>();
            
            if(feedParentId == Userinfo.getUserId())
                selectedGroupName = 'My Feed';
            else if(feedParentId != Userinfo.getUserId())
                selectedGroupName = mapGroupIdToName.get(feedParentId); 

            //Initialize number of records to be displayed
            lstFeedItemsSearchResults = new List<FeedItem>();
            mapFeedItemIdToGroupName = new Map<Id, String>();
            mapFeedIdToCreatedDate = new Map<Id, Datetime>();
            mapFeedIdToCreatedDateGMT = new Map<Id, Datetime>();
            mapFeedIdToNumOfLikes = new Map<Id, Integer>();
            mapFeedItemIdToRelatedlstComments = new Map<Id, List<FeedComment>>();
            Map<Id, List<Id>> mapContentIdToFeedId = new Map<Id, List<Id>>();

            //To query all the Feed items for Feed comments
            String strQuery = 'select Id, Title, Body, CreatedById, ParentId, CreatedDate, (Select Id From FeedLikes),' + 
                                ' RelatedRecordId, ContentFileName, ContentSize, LinkUrl, Type' + 
                                ' from FeedItem' ;
                               
            Set<Id> setEntitiesSubscribed = new Set<Id>();
            Set<Id> setUserEntitiesSubscribed = new Set<Id>();
            
            Set<Id> setGroupsSubscribed = new Set<Id>();
            
            String strSubscriberId;
            String strUserId = Apexpages.currentPage().getParameters().get('id');
            
            if(strUserId != null)
                strUserId = String.escapeSingleQuotes(strUserId);
            
            if(strUserId != null && strUserId != '')
                strSubscriberId = strUserId;
            else
                strSubscriberId = Userinfo.getUserId(); 
            
            //Query the people whom current logged in user follows
            for(EntitySubscription entitySubscribed : [Select SubscriberId, ParentId From EntitySubscription Where SubscriberId =: strSubscriberId LIMIT 1000])
            {
                if(String.valueOf(entitySubscribed.ParentId.getSObjectType()) == 'User')
                    setUserEntitiesSubscribed.add(entitySubscribed.ParentId);
                else    
                    setEntitiesSubscribed.add(entitySubscribed.ParentId);
                
                if(entitySubscribed.ParentId == UserInfo.getUserId())
                    hasPostAccess = true;
            }           
            
            if(strSubscriberId == UserInfo.getUserId())
                hasPostAccess = true;   
            
            Set<Id>  setLoggedInUserGroupsSubscribed = new Set<Id>();
            
            //Query the groups where the current logged in user is a member 
            for(CollaborationGroupMember objGroupMembers : [Select MemberId, CollaborationGroupId From CollaborationGroupMember where MemberId =: Userinfo.getUserId()])
            {
                setLoggedInUserGroupsSubscribed.add(objGroupMembers.CollaborationGroupId);
            }
            
            if(strUserId != null && strUserId != '')
            {
                for(CollaborationGroupMember objGroupMembers : [Select MemberId, CollaborationGroupId From CollaborationGroupMember where MemberId =: strUserId])//strUserId
                {
                    if(setLoggedInUserGroupsSubscribed.contains(objGroupMembers.CollaborationGroupId))
                        setGroupsSubscribed.add(objGroupMembers.CollaborationGroupId);
                }   
            }
            else
                setGroupsSubscribed.addAll(setLoggedInUserGroupsSubscribed);
            
            Set<Id> subsribedGroups = getSubscribedGroups(strUserId);	
            Set<Id> setFeaturedGroupIDs = new Set<Id>();
            
            for(SL_FeaturedGroups__c objFGroup : [SELECT GroupId__c,Name FROM SL_FeaturedGroups__c where GroupId__c != null Order By Name])
            {
                setFeaturedGroupIDs.add(objFGroup.GroupId__c);
            }

            //This section is used if user is looking the feed post of own profile or othe Employee profile
            if(strUserId != null && strUserId != '')
            {
                strQuery += ' where (Type Not in :setFilteredFeedType) ';
                strQuery += ' and ((CreatedById ='  + '\'' + String.escapeSingleQuotes(strUserId) + '\' or ParentId =' + '\'' + String.escapeSingleQuotes(strUserId) + '\')';
                strQuery += ' or (CreatedById ='    + '\'' + String.escapeSingleQuotes(strUserId) + '\' and parentId IN : setGroupsSubscribed)';
                strQuery += ' or (CreatedById ='    + '\'' + String.escapeSingleQuotes(strUserId) + '\' and ParentId IN : setEntitiesSubscribed))' ;
            }
            else
            {
                //This section is used to display feed post under My feed section of Home page
                if(feedParentId == UserInfo.getUserId())
                {             
                    // TODO: this block should be refactored by creating one combined set from queries (without adding different sets)
					Set<Id> combinedSet = new Set<Id>(subsribedGroups); 
					combinedSet.addAll(setUserEntitiesSubscribed);
					combinedSet.addAll(setEntitiesSubscribed);
					combinedSet.add(feedParentId);
					
					strQuery += ' WHERE Type Not IN :setFilteredFeedType AND ParentId IN : combinedSet';
                }
                else    //This section is used to display feed post while looking for particular records
                {
                    strQuery += ' where (Type Not in :setFilteredFeedType) ';
                    strQuery += ' and ParentId =' + '\'' + String.escapeSingleQuotes(feedParentId) + '\' ' ;
                }   
            }

            if(feedItemOrderBy == 'CreatedDate')                   
                strQuery += ' order by ' +  String.escapeSingleQuotes(feedItemOrderBy) +  ' Desc'; 
            else if(feedItemOrderBy == 'CommentCount')
                strQuery += ' order by ' +  String.escapeSingleQuotes(feedItemOrderBy) +  ' Desc' + ', ' + 'CreatedDate Desc'; 
            
            strQuery += ' limit 200';
            
            //To query the feed Items
            for(FeedItem objFI : database.query(strQuery))
            {
                if(setAllUserIds.contains(objFI.CreatedById))
                {
                //To collect all the Feed Items id to get the related feed comments 
                    setFeedItemsId.add(objFI.Id);
                    
                    //Push objects into list to display Feed items on the page
                    lstFeedItemsSearchResults.add(objFI);
                    
                    //push objects into the map to delete the feeds and feedlikes
                    //mapFeedItemIdToObject.put(objFI.Id, objFI);
                    mapFeedItemIdToIndex.put(objFI.Id, lstFeedItemsSearchResults.size()-1);
                    
                    //To display the User photo on the page
                    mapFeedIdToCreatedBYId.put(objFI.Id, objFI.CreatedById);
                    
                    //To format the date as per logged in User locale
                    Datetime feedCreatedDate = objFI.CreatedDate;
                    
                    Datetime feedCreatedDate1 = datetime.valueOfGmt(String.valueOf(feedCreatedDate.year()) + '-' + String.valueOf(feedCreatedDate.month())
                                                + '-' + String.valueOf(feedCreatedDate.day()) + ' ' + String.valueOf(feedCreatedDate.hour()) + ':' + 
                                                String.valueOf(feedCreatedDate.minute()) +  ':' + String.valueOf(feedCreatedDate.second()) );
                    
                    mapFeedIdToCreatedDate.put(objFI.Id, feedCreatedDate1);
                    mapFeedIdToCreatedDateGMT.put(objFI.Id, feedCreatedDate);
                    
                    //To calculate the number of likes per Feed Item
                    mapFeedIdToNumOfLikes.put(objFI.Id, (objFI.FeedLikes).size());
                    
                    //To push the Group name correspond to feed items so it can be displayed on the page
                    if(mapGroupIdToName.containsKey(objFI.ParentId))
                    {
                        if(setFeaturedGroupIDs.contains(objFI.ParentId))
                            strFeaturedPostsIDs += objFI.Id  +', ';
                            
                        mapFeedItemIdToGroupName.put(objFI.Id, mapGroupIdToName.get(objFI.ParentId));
                    }
                    else
                        mapFeedItemIdToGroupName.put(objFI.Id, 'NG');
                    
                    mapFeedItemIdToContent.put(objFI.Id, new ContentVersion());
                }       
            }   

            //To get the related Feed comments for Feed items which all are displayed
            for(FeedComment objFC : [select Id, parentId, CommentBody, CreatedById, FeedItemId, CreatedDate, RelatedRecordId, CommentType 
                                     from FeedComment
                                     where FeedItemId in : setFeedItemsId 
                                     order by CreatedDate desc]) 
            {
                //For mapping of Feed Items and realted Feed comments
                if(!mapFeedItemIdToRelatedlstComments.containsKey(objFC.FeedItemId))
                    mapFeedItemIdToRelatedlstComments.put(objFC.FeedItemId, new List<FeedComment>{objFC});
                else
                    mapFeedItemIdToRelatedlstComments.get(objFC.FeedItemId).add(objFC);
                    
                //To display the User photo on the page
                mapFeedIdToCreatedBYId.put(objFC.Id, objFC.CreatedById);
                
                //To format the date as per logged in User locale
                Datetime feedCreatedDate = objFC.CreatedDate;
                
                Datetime feedCreatedDate1 = datetime.valueOfGmt(String.valueOf(feedCreatedDate.year()) + '-' + String.valueOf(feedCreatedDate.month())
                                    + '-' + String.valueOf(feedCreatedDate.day()) + ' ' + String.valueOf(feedCreatedDate.hour()) + ':' + 
                                    String.valueOf(feedCreatedDate.minute()) +  ':' + String.valueOf(feedCreatedDate.second()) );
                
                mapFeedIdToCreatedDate.put(objFC.Id, feedCreatedDate1);
                mapFeedIdToCreatedDateGMT.put(objFC.Id, feedCreatedDate);
                
                if(objFC.RelatedRecordId != null)
				{
					if(mapContentIdToFeedId.containsKey(objFC.RelatedRecordId))
						mapContentIdToFeedId.get(objFC.RelatedRecordId).add(objFC.Id);
					else
						mapContentIdToFeedId.put(objFC.RelatedRecordId, new List<Id>{objFC.Id});
				}
				
				mapFeedItemIdToContent.put(objFC.Id, new ContentVersion());
            }
            
            set<Id> setRelatedUserId = new Set<Id>();
            setRelatedUserId.addAll(mapFeedIdToCreatedBYId.values());
                
            Map<Id, User> mapUserIdUser = new Map<Id, User>();
            
            //To get the User's photo url to display on the page
            for(User objUser : [select Id, SmallPhotoUrl, Name from User where Id in :setRelatedUserId])
            {
                mapUserIdUser.put(objUser.Id, objUser);
            }                   

            for(Id feedId : mapFeedIdToCreatedBYId.keySet())
            {
                mapFeedIdToUser.put(feedId, mapUserIdUser.get(mapFeedIdToCreatedBYId.get(feedId)));
            }
            
            //To calculate the logged in user Feed likes correspond to Feed items
            for(FeedItem objFI : [select Id, body,(Select Id From FeedLikes where InsertedById = :UserInfo.getUserId())
                                  from FeedItem
                                  where Id in : setFeedItemsId])
            {
                if(!objFI.FeedLikes.isEmpty())
                    mapFeedIdToFeedLikeId.put(objFI.Id, objFI.FeedLikes[0].Id);
                else
                    mapFeedIdToFeedLikeId.put(objFI.Id, 'No');    
                
                //Pushing the blank entries into map , otherwise it will through an Exception while using on page 
                if(!mapFeedItemIdToRelatedlstComments.containsKey(objFI.Id))
                    mapFeedItemIdToRelatedlstComments.put(objFI.Id, new List<FeedComment>{});
            }  
            
            for(ContentVersion objCV : [Select Id, Title, ContentSize From ContentVersion WHERE Id IN : mapContentIdToFeedId.keyset()])
            // OR Id IN: setContentIdsForContentChatter
            {
                for(Id feedId : mapContentIdToFeedId.get(objCV.Id))
                {
                     mapFeedItemIdToContent.put(feedId, objCV);
                }
            }
            
            if(!String.isBlank(strContentsQuery))
            	queryContentsToBeDisplayed();
     }  
    /* End : getFeedItems Method */
    
    
    /* Start - Method to Insert or delete a FeedLike record for FeedItem 
       @Name           - feedLikeUnlike
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function to Insert or delete a FeedLike record for FeedItem 
    */
    public void feedLikeUnlike()
    {
            String likeUnlike = ApexPages.currentPage().getParameters().get('LikeOrUnlike');
            //Inserting of FeedLike record
            if(likeUnlike == 'like')
            {
                String feedItemId = ApexPages.currentPage().getParameters().get('feedLikeOrUnlikeId');
                FeedLike objFL = new FeedLike(FeedItemId = feedItemId);
                insert objFL;
            }
            else if(likeUnlike == 'unlike')
            {
                String feedLikeId = ApexPages.currentPage().getParameters().get('feedLikeOrUnlikeId');
                FeedLike objFL = new FeedLike(Id = feedLikeId);
                delete objFL;
            }
            
            getFeedItems();
            
    }   
    /* End : feedLikeUnlike Method */
    
    
    /* Start - Method to add the Feed comment
       @Name           - insertFeedComment
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function to add the Feed comment
    */
    public void insertFeedComment()
    {
            String feedPostId = '';
            String feedcommentBody = '';
            
            feedPostId = ApexPages.currentPage().getParameters().get('feedPostId');
            feedcommentBody = ApexPages.currentPage().getParameters().get('feedCommentBody');
            
            FeedComment objFC = new FeedComment(FeedItemId = feedPostId, CommentBody = feedcommentBody, CommentType = 'TextComment');
            insert objFC;
            
            getFeedItems();
            
    }
    /* End : insertFeedComment Method */
    
    
    /* Start - Method to Insert the New Feed posts
       @Name           - insertFeedPost
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function to Insert the New Feed posts
    */
    public void insertFeedPost()
    {
            FeedItem feedToBeInsert = new FeedItem();
            
            feedToBeInsert.parentId = feedParentId;
            
            String strPostValue = strPostBody.replaceAll('\\n', '');
            
            if(strPostBody != '' && strPostBody != null)
                feedToBeInsert.Body = strPostBody;
            else
                feedToBeInsert.Body = '';   
            
            if(strLinkPost != '' && strLinkPost != null)
            {
                feedToBeInsert.Title = (strLinkName != '' && strLinkName != null) ? strLinkName : '';
                feedToBeInsert.LinkUrl = strLinkPost;
            }
            
            if(!Test.isRunningTest())   
                insert feedToBeInsert;
            
            getFeedItems();
            
    }
    /* End : insertFeedPost Method */
    
    
    /* Start - Method to Delete the posts
       @Name           - deleteFeedPost
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function to Delete the posts
    */
    public void deleteFeedPost()
    {
	    //Delete the FeedItem record
	    getFeedItems();
            
        //Remove the id from collections which are used to display on the page
        lstFeedItemsSearchResults.remove(mapFeedItemIdToIndex.get(deletedPostId));
		
		FeedItem objFeedToDelete = new FeedItem(Id = deletedPostId);
        Database.delete(objFeedToDelete, false);
        
        Integer numCount = 0;
           
        for(FeedItem objFeedItem : lstFeedItemsSearchResults)
        {
            mapFeedItemIdToIndex.put(objFeedItem.Id, numCount++);
        }

        mapFeedIdToUser.remove(deletedPostId);
        mapFeedItemIdToGroupName.remove(deletedPostId);
        mapFeedIdToCreatedDateGMT.remove(deletedPostId);
        mapFeedIdToCreatedDate.remove(deletedPostId);
        mapFeedIdToFeedLikeId.remove(deletedPostId);
        mapFeedIdToNumOfLikes.remove(deletedPostId);
    }
    /* End : deleteFeedPost Method */
    
    
    /* Start - Method to Delete the post comments
       @Name           - deleteFeedPostComment
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function to Delete the post comments
    */
    public void deleteFeedPostComment()
    {
        try{
            FeedComment objFCToDelete = new FeedComment(Id = deletedCommentId);
            delete objFCToDelete;
            
            //Remove the List of FeedComment related to a feed post
            List<FeedComment> lstFeedComment = mapFeedItemIdToRelatedlstComments.get(deletedPostId);
            mapFeedItemIdToRelatedlstComments.remove(deletedPostId);
            
            //Recreate the List of FeedComments related to a Feed Post 
            for(FeedComment objFeedComment : lstFeedComment)
            {
                if(objFeedComment.Id != deletedCommentId && mapFeedItemIdToRelatedlstComments.containskey(deletedPostId))
                    mapFeedItemIdToRelatedlstComments.get(deletedPostId).add(objFeedComment);
                else if(objFeedComment.Id != deletedCommentId)
                    mapFeedItemIdToRelatedlstComments.put(deletedPostId, new List<FeedComment>{objFeedComment});
            }
            
            //If there is only one comment for that feedPost
            if(lstFeedComment.size() == 1)
                mapFeedItemIdToRelatedlstComments.put(deletedPostId, new List<FeedComment>{});
            
            //Remove the id from collections which are used to display on the page
            mapFeedIdToCreatedDate.remove(deletedCommentId);
            mapFeedIdToCreatedDateGMT.remove(deletedCommentId);
            
            if(!String.isBlank(strContentsQuery))
            	queryContentsToBeDisplayed();
        }
        catch(Exception ex)
        {
            system.debug('Exception at : '+ex.getLineNumber());
        }
            
    }
    /* End : deleteFeedPostComment Method */
    
    
    /* Start - Method to create New Entity Subscription
       @Name           - createEntitySubscription
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function to create New Entity Subscription
    */
    public void createEntitySubscription()
    {
        List<EntitySubscription> lstES = new List<EntitySubscription>();
        lstES = [select id, ParentId, SubscriberId from EntitySubscription where ParentId =: feedParentId and SubscriberId =: UserInfo.getUserId()];
        if(lstES.size() == 0)
        {
            EntitySubscription objES = new EntitySubscription();
            objES.ParentId = feedParentId;
            objES.SubscriberId = UserInfo.getUserId();
            insert objES;
        }
    }
    /* End : createEntitySubscription Method */
    
    
    /* @Name           - getContentFeedItems
       @Parameters     - None 
       @Return Type    - void
       @Description    - Method to get the feed items corresponding to selected Content
    */
    public void getContentFeedItems()
    {
    	//Initializing the variables
        mapContentIdToLstFeedItems = new map<Id, List<FeedItem>>();
        lstFeedItemsSearchResults = new List<FeedItem>();
        lstContentsToBedisplayed = new List<ContentVersion>();
        
        //Get the contentId for which lstFeedItems need to be fetched and display on the page 
        strContentVersionId = Apexpages.currentPage().getParameters().get('ContentVersionId');
        String strContentChatterId = getContentChatterRecord();
		
        //To get the feedItems for selected content
        if(!String.isBlank(strContentChatterId))
            feedParentId = strContentChatterId;
        else
        	feedParentId = strContentVersionId;
        
        if(!String.isBlank(feedParentId))
        	getFeedItems();
        else if(!String.isBlank(strContentsQuery))
        {
        	lstFeedItemsSearchResults = new List<FeedItem>();
        	queryContentsToBeDisplayed();
        }
          
        lstFeedItemsSize = lstFeedItemsSearchResults.size();
        numOfRecordeToBedisplayed = numOfFeedPostPerPage;
        
        //To create the Map between ContentVersion Id and List of Feed items 
        for(ContentVersion objCV : lstContentsToBedisplayed)
        {
            if(strContentVersionId != objCV.Id)
                mapContentIdToLstFeedItems.put(objCV.Id, new List<FeedItem>());
            else
                mapContentIdToLstFeedItems.put(objCV.Id, lstFeedItemsSearchResults);    
        }
    } 
    /* End : getContentFeedItems Method */
    
    
    /* @Name           - getContentChatterRecord
       @Parameters     - None 
       @Return Type    - void
       @Description    - Method to get the intermediate content chatter record for the content record
    */
    private String getContentChatterRecord()
    {
        //Query the intermediate Content Chatter record to get the actual record Id (for which the feed items have been created) respective to content version
        List<Content_Chatter__c> lstContentChatter = [Select Id, Content_Id__c
                                                            from Content_Chatter__c
                                                            where Content_Id__c = :strContentVersionId
                                                            limit 1];
        if(lstContentChatter.size() > 0)
            return lstContentChatter[0].Id;
        else
            return null;                                                            
    }
    /* End : getContentChatterRecord Method */
    
    
    /* @Name           - createContentChatterRecord
       @Parameters     - None 
       @Return Type    - void
       @Description    - Method to create the intermediate content chatter record for the content record if already not present
    */
    public void createContentChatterRecord()
    {
    	mapContentIdToLstFeedItems = new map<Id, List<FeedItem>>();
    	
        if(!String.isBlank(strContentsQuery))
        {
        	//Initializing the variables
        	lstFeedItemsSearchResults = new List<FeedItem>();
        	
        	queryContentsToBeDisplayed();
        }
		
        //Get the content chatter Id if already exist
        String strContentChatterId = getContentChatterRecord();

        //If content chatter is not present then create the new Chatter content record
        if(strContentChatterId == null)
        {
            Content_Chatter__c objNewContentChatter = new Content_Chatter__c(Content_Id__c = strContentVersionId);
            insert objNewContentChatter;
            
            //Assign the newly created content chatter record Id  
            strContentChatterId = objNewContentChatter.Id;
        }       
        feedParentId = strContentChatterId;
        strPostBody += '\n' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + strContentVersionId;
        insertFeedPost();
        createEntitySubscription();

        lstFeedItemsSize = lstFeedItemsSearchResults.size();
        
        //To create the Map between ContentVersion Id and List of Feed items 
        if(lstContentsToBedisplayed == null)  {
            lstContentsToBedisplayed = new List<ContentVersion>();
        }
        
        for(ContentVersion objCV : lstContentsToBedisplayed)
        {
            if(strContentVersionId != objCV.Id)
                mapContentIdToLstFeedItems.put(objCV.Id, new List<FeedItem>());
            else
                mapContentIdToLstFeedItems.put(objCV.Id, lstFeedItemsSearchResults);    
        }
    }
    /* End : createContentChatterRecord Method */
    
    public void queryContentsToBeDisplayed()
    {
    	Set<String> stContentTypes = new Set<String>();
    	Set<Id> setFilteredContentIdsForOffsetting = new Set<Id>();
    	String docType = Apexpages.currentPage().getParameters().get('docType');
    	
    	if(!String.isEmpty(docType) && docType != 'All Categories')
    	{
    		stContentTypes.add(Apexpages.currentPage().getParameters().get('docType'));
    	}
    	else if(String.isNotBlank(strContentTypes))
    	{
	    	for(String strContent : strContentTypes.split('#'))
	    	{
	    		stContentTypes.add(strContent);
	    	}
    	}

    	if(String.isNotBlank(strFilteredItems))
    	for(Id filteredItemId : strFilteredItems.split('#'))
    	{
    		setFilteredContentIdsForOffsetting.add(filteredItemId);
    	}

    	lstContentsToBedisplayed = database.query(strContentsQuery);
    }
}