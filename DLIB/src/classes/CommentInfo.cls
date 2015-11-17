/**
* @ClassName    : CommentInfo 
* @JIRATicket   : SOCINT-769 && SOCINT-770
* @CreatedOn    : 25/June/14
* @ModifiedBy   : Hemant 
* @Description  : This is the generic class and will be used as wrapper to hold the necessary properties for any comment.
				  This will be called iteratively by FeedItemInfo class while preparing Feed Item and its related comments. 
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


global class CommentInfo {
	 
	global String feedCommentId { get; private set; }
	
    //global String userName { get; private set; }
    global String formattedText { get; private set; }
    
    //User who created this comment
    global String createdByName { get; private set; }
    global String createdById { get; private set; }
    global String createdBySmallPhotoUrl { get; private set; }
    
    //First to show in user local and second to have GMT DateTime on page as well. 
	global Datetime feedCreatedDate  {get; private set;}
	global Datetime feedCreatedDateGMT  {get; private set;}
	
    //For Attachment post
	global String contentId { get; private set; }
	global String contentImageUrl { get; private set; }
	global String contentDescription { get; private set; }
    global String contentDownloadUrl { get; private set; }
    global String contentTitle { get; private set; }
	global String contentType { get; private set; }
	global String contentSize { get; private set; }
	global Boolean hasContentImagePreview { get; private set; }
	global Boolean hasDeleteAccess { get; set; }
	
	//For Comment
	global String commentLikeId { get; set; }
	global Boolean isCommentLikeByCurrentUser {	get; set; }
	global Integer totalLikes { get; set; }
     
    
    //Receive FeedComment as input from FeedItemInfo class iteratively
    global CommentInfo(ConnectApi.Comment inComment,String widgetId) {
        
    	feedCommentId = inComment.id;
    	
        //To set the created by user name and Id
        createdByName = inComment.user.name;
        createdById = inComment.user.id;
        createdBySmallPhotoUrl = ((ConnectApi.Photo)inComment.User.photo).smallPhotoUrl; 
        
        //To set the FeedComment body. This will call a FeedFormatter class to parse the API data and to show it in structured way on VF page
        formattedText = FeedFormatter.formatBodyText(inComment.body,widgetId);
        
        
        //To set the createdDate as per user locale
        feedCreatedDateGMT = inComment.CreatedDate;
        feedCreatedDate = datetime.valueOfGmt(String.valueOf(feedCreatedDateGMT.year()) + '-' + String.valueOf(feedCreatedDateGMT.month())
                                    + '-' + String.valueOf(feedCreatedDateGMT.day()) + ' ' + String.valueOf(feedCreatedDateGMT.hour()) + ':' + 
                                    String.valueOf(feedCreatedDateGMT.minute()) +  ':' + String.valueOf(feedCreatedDateGMT.second()) );
        
            
       	//For Attachment or ContentPost
       	contentImageUrl = '';
        if (inComment.attachment != null && inComment.attachment instanceof ConnectApi.ContentAttachment) {
            
            ConnectApi.ContentAttachment content = (ConnectApi.ContentAttachment)inComment.attachment;
            contentImageUrl = content.renditionUrl;
            contentDescription = content.description;
            contentTitle = content.title;
            //Different images can also be displayed based on the status. Processing/Failed/Success/Na
            hasContentImagePreview = (content.thumb120By90RenditionStatus == 'Success') ? true : false;
            contentId = content.versionId;
            contentDownloadUrl = '/sfc/servlet.shepherd/version/download/' + content.versionId + '?asPdf=false&operationContext=CHATTER';
            contentType = content.fileExtension;
            contentSize = content.fileSize;
        }
        
        //For Comment Like/Unlike
        if(inComment.myLike!=null)
       	{
       		isCommentLikeByCurrentUser = true;
       		commentLikeId = inComment.myLike.id;
       		totalLikes = inComment.likes.total;
       	}
    	else
    	{
    		isCommentLikeByCurrentUser = false;
    		totalLikes = inComment.Likes.total;
    	}
    	
    	//check user has access to delete a comment 
        hasDeleteAccess = !inComment.isDeleteRestricted;
    }
    
}