/**
* @ClassName    : FeedItemInfo 
* @JIRATicket   : SOCINT-769 && SOCINT-770
* @CreatedOn    : 25/June/14
* @ModifiedBy   : Hemant 
* @Description  : This is the generic class and will be used as wrapper to hold the necessary properties for any Feed Item.
				  This will call FeedFormatter and CommentInfo classes and assembles the Apex output to display @mentions, hashtags, embedded links and other rich text in HTML.
*/

/**
@ Hemant Shukla 
Percentage of best practices followed   : 
No of SOQL queries used                 : 
No of collections used                  : 
Exception Handling implemented          : 
Coding standards followed               : 
Naming conventions followed             : 
Third party integrations                : 
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 
*/


global class FeedItemInfo {

    //This will be removed later on
    //global ConnectApi.FeedItem feedItem { get; private set; }
    
    //To store the Formatted body of FeedItem
    global String formattedText { get; private set; }
    
    //FeedItem Id
    global String feedId {get; private set; }
	
	//To identify if this has been posted under Group/Record/User  {We'll need to have some mechanism to get the name on page}. Additional boolean value may require later on
	global String feedParentId {get; private set;}
	global String feedParentName {get; private set;}
	global String feedType {get; private set;}
	
	
	//First to show in user local and second to have GMT DateTime on page as well. 
	global Datetime feedCreatedDate  {get; private set;}
	global Datetime feedCreatedDateGMT  {get; private set;}
	
	//User who created this post
	global String createdById { get; private set; }
	global String createdByName { get; private set; }
	global String createdBySmallPhotoUrl { get; private set; }
	
	//Should be removed after used on page directly
	global Boolean canDelete {get; private set;}
	
	//To set the type as TextPost/ContentPost/LinkPost
	/*global enum ConnectApi.​FeedItemType {get; private set;}*/
	
	//For Link post 
	global String linkUrl { get; private set; }
    global String linkTitle { get; private set; }
	
	//For Attachment post
	global String contentId { get; private set; }
	global String contentImageUrl { get; private set; }
	global String contentDescription { get; private set; }
    global String contentDownloadUrl { get; private set; }
    global String contentTitle { get; private set; }
	global String contentType { get; private set; }
	global String contentSize { get; private set; }
	global Boolean hasContentImagePreview { get; private set; }
	global Boolean hasDeleteAccess { get; private set; }
	
	//FeedLike Info 
	global Boolean isLikedByCurrentUser {get; set; }
	global String myLikeId{get; set; }
	global Integer totalLikes {get; set; }
	
	
	//Related Feed Comment Infor
    global Integer commentCount {get; private set;}  
    global List<CommentInfo> comments { get; set; }
    
     
    global FeedItemInfo(ConnectApi.FeedItem inFeedItem, String widgetId) { 
    	 
        feedId = inFeedItem.id; 
        //If Group post
        if(inFeedItem.parent != null && inFeedItem.parent instanceof ConnectApi.ChatterGroupSummary){
        	feedParentId = ((ConnectApi.ChatterGroupSummary)inFeedItem.parent).id;
        	feedParentName = ((ConnectApi.ChatterGroupSummary)inFeedItem.parent).name;
        	feedType = ((ConnectApi.ChatterGroupSummary)inFeedItem.parent).type;
        }	
        //If Posted for any object record
        else if(inFeedItem.parent != null && inFeedItem.parent instanceof ConnectApi.RecordSummary){	
        	feedParentId = ((ConnectApi.RecordSummary)inFeedItem.parent).id;
        	feedParentName = ((ConnectApi.RecordSummary)inFeedItem.parent).name;
        	feedType = String.valueOf(((Id)feedParentId).getSobjectType());
        }	
        //If posted under user
        else if(inFeedItem.parent != null && inFeedItem.parent instanceof ConnectApi.UserSummary){	
        	feedParentId = ((ConnectApi.UserSummary)inFeedItem.parent).id;
        	feedParentName = ((ConnectApi.UserSummary)inFeedItem.parent).name;
        	feedType = ((ConnectApi.UserSummary)inFeedItem.parent).type;
        }	
           
        //To set the createdDate as per user locale
        feedCreatedDateGMT = inFeedItem.CreatedDate;
        feedCreatedDate = datetime.valueOfGmt(String.valueOf(feedCreatedDateGMT.year()) + '-' + String.valueOf(feedCreatedDateGMT.month())
                                    + '-' + String.valueOf(feedCreatedDateGMT.day()) + ' ' + String.valueOf(feedCreatedDateGMT.hour()) + ':' + 
                                    String.valueOf(feedCreatedDateGMT.minute()) +  ':' + String.valueOf(feedCreatedDateGMT.second()) );
        
        //Created By user name and its Id
        if (inFeedItem.actor != null && inFeedItem.actor instanceof ConnectApi.UserSummary) {
            createdByName = ((ConnectApi.UserSummary)inFeedItem.actor).name;
            createdById = ((ConnectApi.UserSummary)inFeedItem.actor).id;
            
            //createdBySmallPhotoUrl = ((ConnectApi.Photo)(((ConnectApi.UserSummary)inFeedItem.actor).photo)).smallPhotoUrl;
            
        }    
		createdBySmallPhotoUrl = inFeedItem.photoUrl;
		 
		//To set the FeedItem body. This will call a FeedFormatter class to parse the API data and to show it in structured way on VF page
		formattedText = FeedFormatter.formatBodyText(inFeedItem.body,widgetId);
		if(String.isBlank(formattedText) && feedParentId != null)
			formattedText = FeedFormatter.formatFieldChange(inFeedItem.header);
        if(feedParentId == null) // when new version of file is uploaded
        formattedText ='uploaded a new version of this file.';
		//Set the type
		//feedPostType = ((ConnectApi.​FeedItemType)inFeedItem).type;
		
        contentImageUrl = ''; 
        
        //To set the properties for File and link post 
        if (inFeedItem.attachment != null) {
        	//For Attachment or ContentPost 
            if (inFeedItem.attachment instanceof ConnectApi.ContentAttachment) {
                
                ConnectApi.ContentAttachment content = (ConnectApi.ContentAttachment)inFeedItem.attachment;
                contentImageUrl = content.renditionUrl;
                contentDescription = content.description;
                contentTitle = content.title;
                
                //Different images can also be displayed based on the status. Processing/Failed/Success/Na
                hasContentImagePreview = (content.thumb120By90RenditionStatus == 'Success') ? true : false;
                contentId = content.versionId;
                // contentDownloadUrl = content.downloadUrl; // not cookie enabled so unusable
                contentDownloadUrl = '/sfc/servlet.shepherd/version/download/' + content.versionId + '?asPdf=false&operationContext=CHATTER';
                contentType = content.fileExtension;
                contentSize = content.fileSize;
                
            //For Link post    
            } else if (inFeedItem.attachment instanceof ConnectApi.LinkAttachment) {
                
                ConnectApi.LinkAttachment link = (ConnectApi.LinkAttachment)inFeedItem.attachment;
                linkUrl = link.url;
                linkTitle = link.title;
            } 
        }
        
        if(inFeedItem.myLike!=null)
       	{
       		isLikedByCurrentUser = true;
       		myLikeId = ((ConnectApi.Reference)inFeedItem.myLike).id;
       	}
    	else
    	{
    		isLikedByCurrentUser = false;
    		myLikeId = '';
    	}  
    	
		//Total Like
		totalLikes = ((ConnectApi.ChatterLikePage)inFeedItem.likes).total;
		
		commentCount = inFeedItem.comments.total;
        comments = new List<CommentInfo>();
        for (ConnectApi.Comment comment : inFeedItem.comments.comments) {
            comments.add(new CommentInfo(comment,widgetId));
        } 
        //check user has access to delete a FeedItem
        hasDeleteAccess = !inFeedItem.isDeleteRestricted;
    }
  
}