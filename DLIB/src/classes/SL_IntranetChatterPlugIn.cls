/**
* @ClassName    : SL_IntranetChatterPlugIn 
* @JIRATicket   : 
* @CreatedOn    : 22/July/14
* @ModifiedBy   : Ritika
* @Description  : This is the Implementation Class for Dynamic ChatterComponent.
*/

/**
@ Ritika
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 4
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

public with sharing class SL_IntranetChatterPlugIn {



	/* START public variable declaration*/
	public String nextPageToken 						{	get; private set;	}	// token which is used for next iteration of getting chatter feeds
	public List<FeedItemInfo> lstFeeds 					{	get; private set;	}	// List to store all chatter feed items
	public String strFeaturedPostsIDs					{	get;set;	}			//String to store feastured group id
	public Map<String, String> mapKeyPrefixAndObjectName 	{	get;set;}			//Map to store keyPrefix and their object name
	public String chatterSubjectId						{	get;set;	}			//Id by which we are getting chatter feeds
	public String strGroupName 							{	get; set;	}			// To store group name on click of chatter group widget
    public String strFeedPostText                       {   get; set;   }           // Feed Post Message    
    public String strLinkUrl                            {   get; set;   }           // post link url
    public String strUrlName                            {   get; set;   }           // post link url Name
    public String strFileName 							{	get;set;	}			// String to store file name
    public Blob attachmentBody 							{	get; set;	}			// Blob to store file
    public String strUserSmallPhotoUrl                  {   get; set;   }           // smallPhotoUrl for user
    public String strRecordId                        	{   get; set;   }           //Record Id for Record post and group post
    public String contentId                             {   get; set;   }			// To store id of uploaded file
    public String postBody                              {   get; set;   }			// To get post body in feedPostForFile()
    public Map<Id,String> mapContentParentIdAndTitle 	{	get;set;	}			//map to store content chatter id with document title
    public Map<String,String> mapContentChatterIdToContentId {	get;set;}			//map to store content chatter id for respective document id
    public String objectRecordId						{	get; set;	}			// To check generic chatter component relate to which object and widget
    public Map<Id, FeedItemInfo> mapFeedIdToFeedInfo	{	get;set;	}			//Map to save for-loop iteration, used for storing feedId to Feed Item
    public String strSearchText							{	get;set;	} 			//For Search Result widget
    public Boolean doSearchOperation					{	get;set;	}			// boolean variable to check operation for chatter are of search type
    public Boolean showPostSection						{	get;set;	}			//Boolean to identify post section availbility
    public String widgetId								{	get;set;	}			// To store current widget id, is used while formatting feed text
    public String commentBody							{	get;set;	}			// Comment text when post a comment
	
	//added for topic autocomplete feed List
    public map<string, list<TopicAssignment>> mapFeedItemIdTolstTopic   {get; set;}     //Map of feedItem to list of topic associated with each feed 
    public String topicNameToInsert                     {   get;set;    }           //new topic name need to be inserted
    public String topicFeedId                           {   get;set;    }           //to store feedItem Id on input hidden
    public String strUserIds                            {   get;set;    }           // Will Store the Excluded User Id
    public String strContextUsersId                    	{   get;set;    }			// Will Store UsedId which are accessible for Context users
    public String strCommunityId 						{   get;set;    }			// Used to store community Id when logged in Community
    /* END public variable declaration*/
    
    private String refSource ;
    private Set<Id> setContentChatterIds; 
	private Set<Id> setContentIdsForContentChatter = new Set<Id>();
    private Map<String,String> mapContentIdToContentChatterId = new Map<String,String>();
    private Boolean isFeedComment ;													// Boolean to decide post is for comment or feed
	private String parentFeedItemId;												// Used as a feed parent id,while doing comment
	private ConnectApi.FeedSortOrder feedOrder;										// decide order of display of chatter feeds
	private ConnectApi.FeedType  postFeedType;										// decide type of which type of feed need to display
	public String chatterParentId;													// Used as a subject Id for chatter post
	private Integer numOfFeedsInSearchPage;											// Default Values for variables
    private Integer numOfFeedPostPerPage;
    private static final String CVPREFIX = '068';
    
    /*----For Chatter Feed Post----*/
	
	/* Constructor initialization */
    public SL_IntranetChatterPlugIn()
    {	
    	system.debug('======Constructor========'+objectRecordId);
    }
    /* End : Constructor initialization */
    
    public void initializeParam(String sourceWidget, String id)
    {
    	/*For Chatter Connect API*/	
		refSource = sourceWidget;
		widgetId = id;
		nextPageToken = null;
		numOfFeedsInSearchPage  = 25;
		strFeaturedPostsIDs = commentBody = parentFeedItemId  = chatterParentId = strSearchText = objectRecordId = topicFeedId = topicNameToInsert = '';
		chatterSubjectId = strUserIds = '';
		strGroupName = 'My Feeds';
		strCommunityId = Network.getNetworkId();
		feedOrder = ConnectApi.FeedSortOrder.LastModifiedDateDesc;
		postFeedType  = ConnectApi.FeedType.News;
		lstFeeds = new List<FeedItemInfo>();
		setContentChatterIds = new Set<Id>();	
		mapKeyPrefixAndObjectName = new Map<String,String>();
		mapContentParentIdAndTitle = new Map<Id, String>();
		mapContentChatterIdToContentId = new Map<String,String>();
		isFeedComment = doSearchOperation = false;
		showPostSection = true;
		mapFeedIdToFeedInfo = new Map<Id, FeedItemInfo>();
		mapFeedItemIdTolstTopic =  new map<string, list<TopicAssignment>>();
		
		/*For Chatter Connect API*/
		numOfFeedPostPerPage = 25;
		for(SL_Intranet_PaginationSettings__c objPagination : [SELECT Name, FeedPost_PageSize__c FROM SL_Intranet_PaginationSettings__c limit 1])
        {
            if(objPagination.FeedPost_PageSize__c != NULL)
                numOfFeedPostPerPage = Integer.valueOf(objPagination.FeedPost_PageSize__c);
        } 
		/*----For Chatter Feed Post----*/
		contentId = postBody = ''; 
        strFeedPostText  = strLinkUrl = strUserSmallPhotoUrl = strRecordId = strContextUsersId = '';
        // Query current user record to fetch SmallPhotoURL 
        User objUser = [ SELECT SmallPhotoUrl, Name, LastName, Id, FullPhotoUrl, FirstName 
                         FROM User 
                         WHERE Id = :UserInfo.getUserId() LIMIT 1 ];
                         
        strUserSmallPhotoUrl = objUser.SmallPhotoUrl;
        /*----For Chatter Feed Post----*/
        
		for(SL_FeaturedGroups__c objFGroup : [SELECT GroupId__c, Name FROM SL_FeaturedGroups__c where GroupId__c != null Order By Name])
			strFeaturedPostsIDs += objFGroup.GroupId__c  +', ';
		
		for(User objExcludeUser : [Select id, Exclude_from_Intranet_Directory__c From User where Exclude_from_Intranet_Directory__c = true])
            strUserIds += objExcludeUser.Id + ' , ';
            
        //For Community Users
        if(String.isBlank(strCommunityId)) {
        	for(User objCommunityUser : [Select id, ContactId From User where ContactId = null])
            	strContextUsersId += objCommunityUser.Id + ' , ';
        }
        //For Getting all the users based on its Network Id
        else {
            for(User objCNW : Database.query('SELECT id FROM User WHERE Id IN (SELECT memberId FROM NETWORKMEMBER WHERE networkId =: strCommunityId)'))
                strContextUsersId += objCNW.Id + ',';
        }
		
		Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
		
		for(Schema.SObjectType objSobjectType : GlobalDescribeMap.values())
		{
			String strObjectName = String.valueOf(objSobjectType);
		   	String strKeyPrefix = objSobjectType.getDescribe().getKeyPrefix();
		   	if(strKeyPrefix != null)
		   		mapKeyPrefixAndObjectName.put(strKeyPrefix,strObjectName);
		}
		if(refSource == 'SearchResult')
            showPostSection = false;		//disabling postSection if, widget is SearchResult
            /*----- START -----This part of code is used for Employee Profile chatter and Custom chatter*/
        else if(objectRecordId == '' && refSource == 'CustomChatter')
        {
            if(String.isEmpty(Apexpages.currentPage().getParameters().get('id')))
                chatterSubjectId = 'me';
            else if(Apexpages.currentPage().getParameters().containsKey('id'))
            {  
                chatterSubjectId = Apexpages.currentPage().getParameters().get('id');
                for(User objUserCSN : [Select Id, Name, Profile.UserLicense.LicenseDefinitionKey From User Where id =: chatterSubjectId AND Profile.UserLicense.LicenseDefinitionKey = 'CSN_External_User'])
                    showPostSection = false;
                postFeedType = ConnectApi.FeedType.UserProfile;
            }
            getNewsFeedForDisplay();
            /*----END ----*/
        }
    }
    
    // build list of wrapped feed items for displaying chatter feeds 
    public void getNewsFeedForDisplay() 
    {	
    	if(!doSearchOperation)
    	{
	    	if(String.IsNotBlank(objectRecordId))
	    	{
	    		chatterParentId = objectRecordId;
	    		strGroupName = 'Related Feeds';
	    	}
	    	
	    	if(String.IsNotBlank(chatterParentId)){
	    		if(chatterParentId == UserInfo.getUserId()) {
	    			postFeedType = ConnectApi.FeedType.News;
	            	chatterSubjectId = 'me';
	    		}
	    		else {
	    			postFeedType = ConnectApi.FeedType.Record;
	            	chatterSubjectId = chatterParentId;
	    		}
	    	}
    	}
    	
    	setContentChatterIds = new Set<Id>();
        ConnectApi.FeedItemPage feed = getNewsFeed();   
                   
        for (ConnectApi.FeedItem item : feed.items) 
        {
        	if(lstFeeds.size() < 1000)
        	{
		    	Id parentId = (Id) item.parent.Id;
		    	if(String.valueOf(parentId.getSobjectType()) == 'Content_Chatter__c')
		    		setContentChatterIds.add(parentId);
		        
		        FeedItemInfo obj = new FeedItemInfo(item,widgetId);
		        lstFeeds.add(obj);
		        mapFeedIdToFeedInfo.put(obj.feedId, obj);
		        mapFeedItemIdTolstTopic.put(obj.feedId, new list<TopicAssignment>()); //Topic AutoComp
        	}
        }
        
        getFeedRelatedTopics(); //Topic AutoComp
        if(!setContentChatterIds.isEmpty())
        	getContentTitle();
        //Set the next page token for next iteration  
        nextPageToken = feed.nextPageToken;
    }
  
    
    
    public void getContentTitle()
    {
    	for(Content_Chatter__c objCC : [Select Id, Content_Id__c From Content_Chatter__c Where Id IN : setContentChatterIds ] )
        {
        	setContentIdsForContentChatter.add(objCC.Content_Id__c);
            mapContentIdToContentChatterId.put(objCC.Content_Id__c, objCC.Id);
            mapContentChatterIdToContentId.put(objCC.Id, objCC.Content_Id__c);
            mapContentParentIdAndTitle.put(objCC.Id,'');
        }

        for(ContentVersion objCV : [Select Id, Title From ContentVersion WHERE Id IN : setContentIdsForContentChatter])
        {
        	mapContentParentIdAndTitle.put(mapContentIdToContentChatterId.get(objCV.id),objCV.Title);
        }
    }
    
    //get first page of news feed
    public ConnectApi.FeedItemPage getNewsFeed() {      	
    	/*
    		URL for reference: 
    		https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_ConnectAPI_ChatterFeeds_static_methods.htm#apex_ConnectAPI_ChatterFeeds_getFeedItemsFromFeed_6
    	*/
    	if(!doSearchOperation)
			return ConnectApi.ChatterFeeds.getFeedItemsFromFeed(
				strCommunityId, postFeedType, chatterSubjectId, 3, ConnectApi.FeedDensity.AllUpdates, nextPageToken, numOfFeedPostPerPage, 
				feedOrder
			);
    	else 
			return ConnectApi.ChatterFeeds.searchFeedItems(
				strCommunityId, strSearchText, null, nextPageToken, numOfFeedsInSearchPage, ConnectApi.FeedSortOrder.CreatedDateDesc
			);
    } 
    
    
    /* Start - Method to get sorted feed 
	   @Name           - getFeedItemsSortBy
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting feed sort by date/Recent Activity 
   	*/
    public void getFeedItemsSortBy()
	{
		String strSortBy = ApexPages.currentPage().getParameters().get('sortBy');
		if(String.isNotBlank(strSortBy) && strSortBy == 'date' || strSortBy == 'popular')
		{
			nextPageToken = null;
			lstFeeds = new List<FeedItemInfo>();
			mapFeedIdToFeedInfo = new Map<Id, FeedItemInfo>();
			
			if(strSortBy == 'date')
				feedOrder = ConnectApi.FeedSortOrder.CreatedDateDesc;
			
			else if(strSortBy == 'popular')
				feedOrder = ConnectApi.FeedSortOrder.LastModifiedDateDesc;
		}
		
		if(objectRecordId.startsWith(CVPREFIX))
			objectRecordId = getContentChatterId(objectRecordId);		
		
		getNewsFeedForDisplay();
	}
	/*END Method: getFeedItemsSortBy*/
	
	
	/* Start - Method to get chatter feed Records for different-2 objects
	   @Name           - getFeedRecordsOnClick
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting feeds on loads and on click of object Record
   	*/
	public void getFeedRecordsOnClick()
	{
		showPostSection = true;
		nextPageToken = null;
		lstFeeds = new List<FeedItemInfo>();
		mapFeedIdToFeedInfo = new Map<Id, FeedItemInfo>();
		if(refSource != 'SearchResult' && objectRecordId.startsWith(CVPREFIX))
		{
			objectRecordId = getContentChatterId(objectRecordId);	
		}	
		
		if(String.isNotBlank(strSearchText))
		{
			doSearchOperation = true;
			strGroupName = 'Related Feeds';
			List<SL_Intranet_PaginationSettings__c> lstPaginationSettings = SL_Intranet_PaginationSettings__c.getAll().values();
			
			if(lstPaginationSettings[0].SearchResult_PageSize__c != null)
				numOfFeedsInSearchPage = Integer.valueOf(lstPaginationSettings[0].SearchResult_PageSize__c);
		}
		
		getNewsFeedForDisplay();
		
	}

	/*End Method: getFeedRecordsOnClick*/
	
	/* Start - Method to get related chatter feed for clicked Topic
	   @Name           - gtTopicFeeds
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting feeds on Topic click 
   	*/
	public void gtTopicFeeds() {	
		String topicName = ApexPages.currentPage().getParameters().get('prmTopicName');
		
		if(String.isBlank(topicName)) return;
		
		// Try catch block in case Topic has been deleted then showing page message
		try {			
			gtTopicFeedsByTopicId([
				Select Id From Topic Where Name =:topicName limit 1][0].id 
			);
		}
	 	catch(Exception ex ) {
            showPostSection = false;
            ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'Topic has been deleted') );
        }
	}
	/*End Method: gtTopicFeeds*/
	
	/*
	** TODO: Fix it soon
	** Quick and dirty soluction
	*/
	public void gtTopicFeedsByTopicId(Id topicId) {
		nextPageToken = null;
		showPostSection = true;
		mapFeedIdToFeedInfo = new Map<Id, FeedItemInfo>();
		lstFeeds = new List<FeedItemInfo>();
		feedOrder = ConnectApi.FeedSortOrder.LastModifiedDateDesc;
				
		objectRecordId = topicId;
		getNewsFeedForDisplay();
		strGroupName = 'Related Feeds';
	}
	
	/*
	** TODO: Fix it soon
	** Quick and dirty soluction
	*/
	public void gtTopicFeedsByTopicId()
	{
		gtTopicFeedsByTopicId(ApexPages.currentPage().getParameters().get('topicId'));
	}
	
	
	/* Start - Method to get content chatter id for document
	   @Name           - getContentChatterId
	   @Parameters     - Record id 
	   @Return Type    - String
	   @Description    - Function for getting content chatter id for document 
   	*/
	public String getContentChatterId(String recordId)
	{
		List<Content_Chatter__c> lstContentChatter = [select Id from Content_Chatter__c where Content_Id__c =: recordId limit 1];
		if(lstContentChatter.size() != 0)
			recordId = lstContentChatter[0].id;
	 	return recordId;
	}
	/*End Method: getContentChatterId*/
    
    
    /* Start - Method to get all comments for a feed
	   @Name           - viewAllComments
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting all comments
   	*/
    public void viewAllComments()
    {   
    	String parentFeedItemId = ApexPages.currentPage().getParameters().get('feedPostId');
    	list<CommentInfo> lstComments = new list<CommentInfo>();
    	
    	//Call an ConnectAPI method to all comments. Max we can get 100
    	ConnectApi.CommentPage feedComment = ConnectApi.ChatterFeeds.getCommentsForFeedItem(strCommunityId, parentFeedItemId, null, 100); 
    	
    	//Format the body for each comment iteratively
    	for(ConnectApi.Comment comment :feedComment.comments)
    	{
            lstComments.add(new CommentInfo(comment,widgetId));
    	}
    	
    	//Find the right Feed Item and then set the related comments again
    	for(FeedItemInfo item : lstFeeds)
    	{
            if(item.feedId == parentFeedItemId)
            {
                item.comments.clear();
                item.comments.addAll(lstComments);
            }
        }
        
    }
    /*END Method: viewAllComments*/
    
    
   	/* Start - Method for updating Like/Unlike of comments/Feeds
	   @Name           - updateLikeUnLikeFeeds
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for Like/Unlike of comments/Feeds 
   	*/
   	public void updateLikeUnLikeFeeds()
   	{
   		String strfeedType = ApexPages.currentPage().getParameters().get('Type');
   		String itemId = ApexPages.currentPage().getParameters().get('ItemId');
   		String likeId = ApexPages.currentPage().getParameters().get('LikedId');
   		String feedId = ApexPages.currentPage().getParameters().get('FeedId');
   		
   		FeedItemInfo item = mapFeedIdToFeedInfo.get(feedId);
   		if(item == null)
   			return;	
   		else if(strfeedType == 'like')
   		{ 
   			ConnectApi.ChatterLike chatterLike = ConnectApi.ChatterFeeds.likeFeedItem(strCommunityId, itemId);
	   		item.isLikedByCurrentUser = true;
	        item.myLikeId = chatterLike.id;
	        if(item.totalLikes == null)
	        	item.totalLikes = 0;
	        item.totalLikes++;
   		}
   		else if(strfeedType == 'unlike')
   		{ 
   			FeedLike objFL = new FeedLike(Id = likeId);
   			delete objFL;
        	item.isLikedByCurrentUser = false;
         	item.myLikeId =null;	//likeId is null in case on unLike of feed
         	if(item.totalLikes != null)
         		item.totalLikes--;
   		}
   		
   		else if(strfeedType == 'likeComment')
   		{
   			ConnectApi.ChatterLike chatterLike = ConnectApi.ChatterFeeds.likeComment(strCommunityId, itemId);
	        for (CommentInfo objComment : item.comments)
	        {
	        	if(objComment.feedCommentId == itemId)
        		{
        			objComment.commentLikeId = chatterLike.id;
        			objComment.isCommentLikeByCurrentUser = true;
        			if(objComment.totalLikes == null)
        				objComment.totalLikes = 0;
        			objComment.totalLikes++;
        			break;
        		}
	        }
   		}
   		
   		else if(strfeedType == 'unlikeComment')
   		{
   			FeedLike objFL = new FeedLike(Id = likeId);
			delete objFL;
	        for (CommentInfo objComment : item.comments)
	        {
	        	if(objComment.feedCommentId == itemId)
        		{
        			objComment.commentLikeId = null;
        			objComment.isCommentLikeByCurrentUser = false;
        			if(objComment.totalLikes != null)
        				objComment.totalLikes--;
        			break;
        		}
	        }
   		}
   	}
   	/*END Method: updateLikeUnLikeFeeds*/
   	
   	
   	/* Start - Method for delete FeedPost
	   @Name           - deleteFeedPost
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for delete feed post 
   	*/ 
    public  void deleteFeedPost()
    {
    	String strDeletedPostId = ApexPages.currentPage().getParameters().get('deletedPost');
	 	FeedItem objFI = new FeedItem(Id = strDeletedPostId);
     	delete objFI;
     	//removing Feed from map to avoid cross reference
     	mapFeedIdToFeedInfo.remove(strDeletedPostId);
    	Integer index = 0;
    	for(FeedItemInfo item : lstFeeds)
    	{
            if(item.feedId == strDeletedPostId)
            {
               lstFeeds.remove(index);
               return;
            }
            index++;
        }
    }
    /*End Method: deleteFeedPost*/
    
    
    /* Start - Method for deleting comments on Feed
	   @Name           - deleteFeedComment
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for deleting comments on Feeds 
   	*/
    public  void deleteFeedComment()
    {
    	String strDelCommentId = ApexPages.currentPage().getParameters().get('deletedCommentId');
    	String strFeedId = ApexPages.currentPage().getParameters().get('feedId');
    	
    	FeedComment objFC = new FeedComment(Id = strDelCommentId);
 		delete objFC;
    	List<CommentInfo> lstCommentForFeed = new List<CommentInfo>();
    	
    	FeedItemInfo feedObj =  mapFeedIdToFeedInfo.get(strFeedId);
    	if(feedObj == null)
   			return;	
    	lstCommentForFeed = feedObj.comments;
    	if(feedObj.commentCount != null)
    		feedObj.commentCount--;
        
        Integer index = 0;
        for(CommentInfo objComment :lstCommentForFeed)
        {
        	if(objComment.feedCommentId == strDelCommentId)
        	{
        		lstCommentForFeed.remove(index);
        		break;
        	}
    		index++;
        }
    }
    /*End Method: deleteFeedComment*/
    
    
    /* Start - Method for posting comment on records
	   @Name           - postComment
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for posting comments on Feeds 
   	*/	
    public void postComment()
    {
    	strFileName ='';
    	parentFeedItemId = ApexPages.currentPage().getParameters().get('parentFeedItemId');
	    
	    if((String.isNotBlank(commentBody) || String.isNotBlank(strFileName)) && String.isNotBlank(parentFeedItemId))
	    {
	    	isFeedComment = true;
    		feedPost(); //calling generic method to post comment
    	}
    }
    /* End :postComment  method */
    
    
    /* Start - Method for getting FeedItems records
	   @Name           - loadChatterGroupFeeds
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting FeedItems records for Chatter Groups widget
	*/	 
	public void loadChatterGroupFeeds()
	{
		String groupIdParam = ApexPages.currentPage().getParameters().get('GroupId');
		
		if(String.isBlank(groupIdParam)) return;
		
		loadChatterGroupFeedsByGroupId(groupIdParam);
	}	
	
	public void loadChatterGroupFeedsByGroupId(Id groupId)
	{
		showPostSection = true;
		chatterParentId = groupId;
		postFeedType = ConnectApi.FeedType.Record;
		nextPageToken = null;
		feedOrder = ConnectApi.FeedSortOrder.LastModifiedDateDesc;
		lstFeeds = new List<FeedItemInfo>();
		mapFeedIdToFeedInfo = new Map<Id, FeedItemInfo>();
		
		if(chatterParentId != UserInfo.getUserId())
			strGroupName = [select Name from CollaborationGroup  where id=:chatterParentId limit 1][0].Name;
		else
			strGroupName = 'My Feeds';
			
		getNewsFeedForDisplay();
	}
	
	
	/* Start - Method for posting feeds for Comment and Post
        @Name           - feedPost
        @Parameters     - None 
        @Return Type    - void
        @Description    - Function to post text and Link feeds for Feed Post and Comment post
    */
    public void feedPost() {
    
    	if(String.isNotBlank(strSearchText))
    		showPostSection = false;
        ConnectApi.FeedType feedType = ConnectApi.FeedType.UserProfile;
        String strSubjectId = UserInfo.getUserId();
        if(chatterSubjectId !='me')
        	strSubjectId = chatterSubjectId;
        //Checking GroupId/RecordId is present
        if(String.isNotBlank(chatterParentId)){
            feedType = ConnectApi.FeedType.Record;
            if(chatterParentId.startsWith(CVPREFIX)){
	            Content_Chatter__c objCC = new Content_Chatter__c(Content_Id__c = chatterParentId);
				insert objCC;
				chatterParentId = objCC.Id;
            }
            strSubjectId = chatterParentId;
    	}
        
        ConnectApi.FeedItemInput postInput = new ConnectApi.FeedItemInput();
    	ConnectApi.CommentInput commentInput = new ConnectApi.CommentInput();
        ConnectApi.BinaryInput binaryInput ;
        try {
            
            if(String.isNotBlank(strFeedPostText))
                postInput.body = FeedBodyParser.convertToMessageBodyInput(strFeedPostText);
            
            if(isFeedComment)
	        	commentInput.body = FeedBodyParser.convertToMessageBodyInput(commentBody);
            
            if(String.isNotBlank(strLinkUrl)) {
                //To add link attachment 
                ConnectApi.LinkAttachmentInput linkIn = new ConnectApi.LinkAttachmentInput();
                linkIn.urlName = strUrlName;
                linkIn.url = strLinkUrl;
                postInput.attachment = linkIn;
            }            
            
            if( String.isNotBlank(strFeedPostText) || String.isNotBlank(strLinkUrl) ){
                ConnectApi.FeedItem feedItemRep = ConnectApi.ChatterFeeds.postFeedItem(strCommunityId, feedType, strSubjectId, postInput, binaryInput );
            	
            	FeedItemInfo item = new FeedItemInfo(feedItemRep,widgetId);
                if(lstFeeds.size() != 0)
                	lstFeeds.add(0, item);
            	else
            		lstFeeds.add(item);
            		
            	if(String.valueOf(((Id)strSubjectId).getSobjectType()) == 'Content_Chatter__c')
					setContentChatterIds.add(strSubjectId); 
				getContentTitle();
                mapFeedIdToFeedInfo.put(item.feedId, item);
                getFeedRelatedTopics(item.feedId); //adding assciated topics to map of feedItemTopic
            } 
         	if(isFeedComment){
         		ConnectApi.Comment commentRep = ConnectApi.ChatterFeeds.postComment(strCommunityId, parentFeedItemId, commentInput, binaryInput);
         		//Find the right Feed Item and then set the related comments again
         		FeedItemInfo item =  mapFeedIdToFeedInfo.get(parentFeedItemId);
         		item.comments.add(new CommentInfo(commentRep,widgetId));
               	item.commentCount++;
               	getFeedRelatedTopics(parentFeedItemId); //adding associate topic to its feed
         	}
        }
        catch(DMLException ex) {
            ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()) );
        }       
        finally {
            strFeedPostText = strLinkUrl = strUrlName = commentBody = parentFeedItemId = '';
            isFeedComment = false;
        }
    }
    /* END Method : feedPost */
    
    
    /* Start - Method for posting feeds with file attachment
        @Name           - feedPostForFile
        @Parameters     - None 
        @Return Type    - void
        @Description    - Function to post feed with file attachments for feed post and comment post 
    */
    public void feedPostForFile()
    {
        try {           
            
           // Query the content created in File Upload page
            List<Attachment> lstAttachment = [ Select Id, Body, Name, contentType 
                                               From Attachment 
                                               Where Id =: contentId limit 1];
            
            if(String.isNotBlank(strSearchText))
    			showPostSection = false;
            String  feedType= ApexPages.currentPage().getParameters().get('prmFeedType');
            String  feedCommentPostId = ApexPages.currentPage().getParameters().get('prmFeedId');
            
            String strSubjectId =UserInfo.getUserId();
            if(chatterSubjectId !='me')
        		strSubjectId = chatterSubjectId;
            ConnectApi.BinaryInput feedBinary; 
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            ConnectApi.CommentInput commentInput = new ConnectApi.CommentInput();
            
            ConnectApi.FeedType connectFeedType = ConnectApi.FeedType.UserProfile;
            
            //Checking GroupId/RecordId is present
            if(String.isNotBlank(chatterParentId)){
                connectFeedType = ConnectApi.FeedType.Record;
                if(chatterParentId.startsWith(CVPREFIX)){
		            Content_Chatter__c objCC = new Content_Chatter__c(Content_Id__c = chatterParentId);
					insert objCC;
					chatterParentId = objCC.Id;
            	}
                strSubjectId = chatterParentId;
            }
                
            // If content exists and feed type is 'FeedPost', post the feed with file attachment
            if( !lstAttachment.isEmpty() && (feedType == 'FeedPost' || feedType == 'CommentPost')) {
                
                Attachment objAttachment = lstAttachment[0];          // get the content version queried                
                
                ConnectApi.NewFileAttachmentInput fileIn = new ConnectApi.NewFileAttachmentInput();     // create a new attachment for the inserting with the feed post
                fileIn.title = objAttachment.Name; 
                
                // Attach post body to the feed post
                if( String.isNotBlank( postBody ) && feedType == 'FeedPost')
                    input.body = FeedBodyParser.convertToMessageBodyInput( postBody );
                else if(feedType == 'CommentPost' && String.isNotBlank(commentBody))
                	commentInput.body = FeedBodyParser.convertToMessageBodyInput( commentBody );
                
                feedBinary = new ConnectApi.BinaryInput( objAttachment.Body, objAttachment.contentType, objAttachment.Name );     // ConnectApi.BinaryInput to be passed in postFeedItem method
                
                if( String.isNotBlank( feedType ) && feedBinary != null && feedType == 'FeedPost') {
                	input.attachment = fileIn;
                    ConnectApi.FeedItem feedItemRep = ConnectApi.ChatterFeeds.postFeedItem(strCommunityId, connectFeedType, strSubjectId, input, feedBinary );      // Post Feed Item
                    FeedItemInfo item = new FeedItemInfo(feedItemRep,widgetId);
	                if(lstFeeds.size() != 0)
                		lstFeeds.add(0, item);
                	else
                		lstFeeds.add(item);
                		
            		if(String.valueOf(((Id)strSubjectId).getSobjectType()) == 'Content_Chatter__c'){
        				setContentChatterIds.add(strSubjectId); //To update map of content chatter id, in case of content post
        				getContentTitle();
            		}
	                mapFeedIdToFeedInfo.put(item.feedId, item);
	                getFeedRelatedTopics(item.feedId); //adding associate topic to its feed
                }
                
                else if(String.isNotBlank( feedType ) && feedType == 'CommentPost' && feedCommentPostId !=''){
            	 	commentInput.attachment = fileIn;
	         		ConnectApi.Comment commentRep = ConnectApi.ChatterFeeds.postComment(strCommunityId, feedCommentPostId, commentInput, feedBinary);
	         		//Find the right Feed Item and then set the related comments again
	         		FeedItemInfo item =  mapFeedIdToFeedInfo.get(feedCommentPostId);
	         		item.comments.add(new CommentInfo(commentRep,widgetId));
	               	item.commentCount++;
	               	getFeedRelatedTopics(parentFeedItemId); //adding associate topic to its feed
         	}
                
                delete new Attachment( Id = objAttachment.Id );    // Delete attachment record created from File Upload page
            }
        }
        catch( DMLException ex ) {
            
            ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'Error uploading file') );
        }
    }
    
    /*END : feedPostForFile method*/
    
    /* Start - Method for posting feeds with file attachment
        @Name           - getFeedRelatedTopics
        @Parameters     - None
        @Return Type    - void
        @Description    - Function to get related topic based on feedId
    */
    private void getFeedRelatedTopics()
    {
        for(TopicAssignment objTopicAssignment :[Select Id, EntityId, TopicId, Topic.name
                                                 From TopicAssignment
                                                 Where EntityId In :mapFeedItemIdTolstTopic.keySet() ORDER By Topic.name])
            mapFeedItemIdTolstTopic.get(objTopicAssignment.EntityId).add(objTopicAssignment);                       
    }
    
   /* END- getFeedRelatedTopics*/
    
    
    /* Start - Method for posting feeds with file attachment
        @Name           - getFeedRelatedTopics (override method for getFeedRelatedTopics)
        @Parameters     - feedId
        @Return Type    - void
        @Description    - Function to get related topic based on feedId
    */
    private void getFeedRelatedTopics(String feedId)
    {
        List<TopicAssignment> lstTopicAssignToFeed = new List<TopicAssignment>();
        for(TopicAssignment objTopicAssignment :[Select Id, EntityId, TopicId, Topic.name
                                                 From TopicAssignment
                                                 Where EntityId =: feedId ORDER By Topic.name])
            lstTopicAssignToFeed.add(objTopicAssignment);                                
        mapFeedItemIdTolstTopic.put(feedId, lstTopicAssignToFeed);                       
    }
    /* END- getFeedRelatedTopics*/
    
    
    private class TopicSelection
    {
        String id;
        String name;
        
        private TopicSelection(String id, String name)
        {
            this.id = id;
            this.name = name;
        }
    }
    
    /* Start -Remote action Method for posting feeds with file attachment
        @Name           - getAssociatedTopics
        @Parameters     - FeedItemId
        @Return Type    - List<String>
        @Description    - Function to get Topic asssociated wth feedId
    */
    @RemoteAction
    public static List<String> getAssociatedTopics(String FeedItemId)
    {
    
        List<String> lstTopicSource = new List<String>();
        //at index 0 =>> alreadyAddedTopicsJson
        try
        {
            List<TopicSelection> lstTopics = new List<TopicSelection>();
            
            for(TopicAssignment objTopicAssignment :[Select Id, EntityId, TopicId, Topic.name
                                                     From TopicAssignment
                                                     Where EntityId = :FeedItemId])
                lstTopics.add(new TopicSelection(objTopicAssignment.TopicId, objTopicAssignment.Topic.name));
                
            lstTopicSource.add(JSON.serialize(lstTopics));
            return lstTopicSource;
        }
        catch(Exception e)
        {
            return lstTopicSource;
        }
            
    }
    /*END : getAssociatedTopics method*/
    
    
    
    /* Start -Method for posting feeds with file attachment
        @Name           - insertNewTopic
        @Parameters     - none
        @Return Type    - void
        @Description    - Function to insert new topic
    */
    // Action function being used on page for creating new Topic on click of Add topic Button 
    public void insertNewTopic()
    {
        try
        {
	        Topic objTopic = new Topic(Name = topicNameToInsert);
	        insert objTopic;
	        TopicAssignment objTopicAssignment = new TopicAssignment(EntityId=topicFeedId, TopicId = objTopic.Id);
	        insert objTopicAssignment;
	        getFeedRelatedTopics(topicFeedId);
        }
        catch(System.DMLException e)
        {
            system.debug('::::Exception:::'+e);
        }
    }
     /*END : insertNewTopic method*/
    
    
    /* Start -Remote action Method for posting feeds with file attachment
        @Name           - manageFeedItemTopics
        @Parameters     - FeedItemId, selectedFeedId
        @Return Type    - List<String>
        @Description    - Function to delete and add topic which are already exists
    */
    @RemoteAction
    public static List<String> manageFeedItemTopics(string FeedItemId, string strSelectedTopicIds)
    {
        
        List<String> lstTopicSource = new List<String>();
        try
        {
            if(strSelectedTopicIds != null && strSelectedTopicIds != '')
            {
                //To get the current associated Topics with FeedItem in context
                Set<String> setFinalTopicIds = new Set<String>();
                setFinalTopicIds.addAll(strSelectedTopicIds.split(','));
                
                //To insert and delete Feed Assinment
                List<TopicAssignment> lstTopicsNeedToBeAdded = new List<TopicAssignment>();
                List<TopicAssignment> lstTopicsNeedToBeDeleted = new List<TopicAssignment>();
                
                //Querying existing ones (Topics) to decide which need to be deleted and which are need to be added
                for(TopicAssignment objTopicAssignment :[Select Id, EntityId, TopicId, Topic.name
                                                         From TopicAssignment
                                                         Where EntityId = :FeedItemId])
                {
                    //If not in final set i.e user has already removed the tagging and need to be deleted
                    if(!setFinalTopicIds.contains(objTopicAssignment.TopicId))
                        lstTopicsNeedToBeDeleted.add(new TopicAssignment(Id = objTopicAssignment.Id));
                    //If present then don't need to do anything, remove them from set so won't be considered further
                    else
                        setFinalTopicIds.remove(objTopicAssignment.TopicId);
                }
                
                if(!lstTopicsNeedToBeDeleted.isEmpty())
                    delete lstTopicsNeedToBeDeleted;
                    
                //The remaining ones need to be created
                for(String strTopicId : setFinalTopicIds)
                    lstTopicsNeedToBeAdded.add(new TopicAssignment(EntityId = FeedItemId, TopicId = strTopicId));
                
                //Perform DMLs
                if(!lstTopicsNeedToBeAdded.isEmpty())
                    insert lstTopicsNeedToBeAdded;
                    
                List<TopicSelection> lstTopics = new List<TopicSelection>();
                for(TopicAssignment objTopicAssignment :[Select Id, EntityId, TopicId, Topic.name
                                                         From TopicAssignment
                                                         Where EntityId = :FeedItemId])
                    lstTopics.add(new TopicSelection(objTopicAssignment.TopicId, objTopicAssignment.Topic.name));
               
                lstTopicSource.add(JSON.serialize(lstTopics));
            }
            
            //else part will be executed when new topic is inserted/ all feeditem topic has been deleted so , no topic is assigned to current feed
            // in both way no topic id will be there
            else
            {
                //To insert and delete Feed Assinment
                List<TopicAssignment> lstTopicsNeedToBeDeleted = new List<TopicAssignment>();
                 
                //Querying existing ones (Topics) to decide which need to be deleted and which are need to be added
                for(TopicAssignment objTopicAssignment :[Select Id, EntityId, TopicId, Topic.name
                                                         From TopicAssignment
                                                         Where EntityId = :FeedItemId])
                    lstTopicsNeedToBeDeleted.add(new TopicAssignment(Id = objTopicAssignment.Id));
                
                if(!lstTopicsNeedToBeDeleted.isEmpty())
                    delete lstTopicsNeedToBeDeleted;
                 lstTopicSource.add(JSON.serialize(new List<TopicSelection>()));
            }
            strSelectedTopicIds = '';
            return lstTopicSource;     
        }
        catch(Exception e)
        {
            return lstTopicSource;
        }       
    }
    /*END : manageFeedItemTopics method*/
	
}