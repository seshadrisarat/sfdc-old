/**
* @ClassName    : FeedFormatter 
* @JIRATicket   : SOCINT-769 && SOCINT-770
* @CreatedOn    : 25/June/14
* @ModifiedBy   : Hemant 
* @Description  : This is the generic class to format the connectAPI response and to display exactly the way we want it to in Visualforce.
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

global class FeedFormatter { 
	
	public static Set<Id> setExcludedUserId = new Set<Id>(); //This set will contain the users which are excluded from the TWC
	public static Set<Id> setOfContextUserId = new Set<Id>(); // This set will contain those users Id which Context user has access.
	
	static {
		//To get all the TWC Excluded user's Id to make them not clickable if mentioned in Feeds.
		for(User objExcludeUser : [Select id, Exclude_from_Intranet_Directory__c From User where Exclude_from_Intranet_Directory__c = true])
            setExcludedUserId.add(objExcludeUser.Id);
        
        String strNetworkId = Network.getNetworkId();
        //Getting all the users Id which are having community License and to make them non clickable when logged in as Admin
        if(String.isBlank(strNetworkId)){
			for(User objCommunityUser : [Select id, ContactId From User where ContactId = null])
           		setOfContextUserId.add(objCommunityUser.Id);
        }
        // Getting all the Network Members Id when Logged in as Admin in community. 
        else {
        	for(User objNW : Database.query('SELECT id FROM User WHERE Id IN (SELECT memberId FROM NETWORKMEMBER WHERE networkId =: strNetworkId)'))
        		setOfContextUserId.add(objNW.Id);
        }
	}
	
	//Receive FeedPost body as input from FeedItemInfo class iteratively 
	global static String formatBodyText(ConnectApi.FeedBody body, String widgetId) {
         
    	String formattedText = '';
        for (ConnectApi.MessageSegment seg : body.messageSegments) {
            
            //For @
            if (seg instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mention = (ConnectApi.MentionSegment)seg;
                
                //To differentiate if mentioned segment is for User or for Group
                if(mention.record.type == 'User'){
	                ConnectApi.UserSummary mentionedUser = (ConnectApi.UserSummary)mention.record;
	                
	                //Adding link to Profile page
	                if(setExcludedUserId.contains(mentionedUser.id) || !setOfContextUserId.contains(mentionedUser.id))
	                	formattedText += '@' + mentionedUser.name;
	                else
	                	formattedText += '<a style="color: #1f7edf;" href="SL_Intranet?page=Employee Profile&id=' + mentionedUser.id + '">@' + mentionedUser.name + '</a>';
                }
                else if(mention.record.type == 'CollaborationGroup'){
                	ConnectApi.ChatterGroupSummary  mentionedGroup = (ConnectApi.ChatterGroupSummary)mention.record;
                    formattedText += '<a style="color: #1f7edf;cursor:pointer;" onclick="interMediateChatterGroupCall'+widgetId+'(\''+mentionedGroup.id+'\');">@' + mentionedGroup.name + '</a>';
                }
                
            //For #    
            } else if (seg instanceof ConnectApi.HashtagSegment) {
                ConnectApi.HashtagSegment hashtag = (ConnectApi.HashtagSegment)seg;
                 formattedText += '<a style="color: #1f7edf;cursor:pointer;" onclick="chatterWidget'+widgetId+'.chatterTopicCall(\''+hashtag.tag+'\');">#'+hashtag.tag+'</a>';
            
            //For embedded links    
            } else if (seg instanceof ConnectApi.LinkSegment) {
                ConnectApi.LinkSegment link = (ConnectApi.LinkSegment)seg;
                formattedText += '<a href=\"' + link.url + '\" target="_blank">' + link.url + '</a>';
            
            // Default    
            } else {
                formattedText += seg.text;
            }
        }
        
        //To introdue the line break while rendering the post body
        formattedText = formattedText.replace('\n', '<br />');
        
     	Integer subtagCount = 0;
     	
        //To introdue the subjectTag, replacing all the <s> tag with 
        while(formattedText.toLowerCase().indexOf('<s>') > -1){
        	
        	subtagCount++;
        	
			if(Math.mod(subtagCount, 2) == 0)
				formattedText = formattedText.toLowerCase().replaceFirst('<s>', '</b>');
			else
				formattedText =  formattedText.toLowerCase().replaceFirst('<s>', '<b>');
        }
		
		if(Math.mod(subtagCount, 2) != 0) 
			formattedText = formattedText.substring(0, formattedText.lastIndexOf('<b>')) + formattedText.substring(formattedText.lastIndexOf('<b>') + 3, formattedText.length());
        
        return formattedText;
    }
    
    
    global static String formatFieldChange(ConnectApi.MessageBody header){
    	
    	String fieldChangedMsgShort='';
    	String fieldChangedMsgLong ='';
    	fieldChangedMsgShort = header.text;
    	List<String> lstFieldChangeMsg = new List<String>();
    	if(fieldChangedMsgShort.contains('and made'))
    	{
	 		for (ConnectApi.MessageSegment seg : header.messageSegments) {
			 	if(seg instanceof ConnectApi.MoreChangesSegment){
			 		ConnectApi.MoreChangesSegment moreFieldChanges = (ConnectApi.MoreChangesSegment)seg;
			 		fieldChangedMsgShort.replace(moreFieldChanges.text,'<a href="">'+moreFieldChanges.text+'</a>');
			 		/*for(ConnectApi.MoreChangesSegment moreSeg :moreFieldChanges.moreChanges){
			 			if(moreSeg.segments instanceof ConnectApi.FieldChangeSegment){
					 		ConnectApi.FieldChangeSegment fieldChangeMsg = (ConnectApi.FieldChangeSegment)moreSeg.segments;
					 		lstFieldChangeMsg.add(fieldChangeMsg.text);
			 			}
			 		}
			 		*/
			 	}
		 	}
    	}
    	return fieldChangedMsgShort;
    }
}