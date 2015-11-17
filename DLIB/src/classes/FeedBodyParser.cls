public with sharing class FeedBodyParser {

  // use to extract the user id as a group
  // Put in double backslashes into regex because Apex doesn't recognize that its a regex 
  //variable used to parse Post text
	public static final String MentionPattern  = '\\@\\[[A-Za-z0-9]{15,18}\\]'; // use to extract the entire mention format 
	public static String MentionIdPattern = '[A-Za-z0-9]{15,18}'; 				//use to extract id of mention
    public static List<Mention> mentions;
  
  //Inner class used to store MentionAndTags extracted from the post
  	public class Mention {
	    public Integer groupStart ; 
	    public Integer groupEnd  ;
	    public String  text ;
  	}
  	  
 	// parse post text into a list of MentionAndTags
  	public static List<Mention> extractAllMentions(String post) {
	   	/*-- Mention parsing START--*/
	   	mentions = new List<Mention>();
	    Pattern pat = Pattern.compile(MentionPattern);
	    Matcher matchr = pat.matcher(post);
	   
	    while(matchr.find()) {
	    	Mention mention = new Mention();
	    	mention.text    = matchr.group(); 		// text of matched mention
	    	mention.groupStart  = matchr.start(); 	// position in string where mention starts
	    	mention.groupEnd = matchr.end() ;  		// position after the last char of the mention
	    	mentions.add(mention);
	    }
     	/*-- Mention parsing END--*/
	   	return mentions;
   	}
  
  
  // parse the post body, placing @mentions, #HashTag and text in segments list. 
  	public static void buildSegments(String postText, ConnectApi.MessageBodyInput messageBody) {
	    mentions = new List<Mention>();
	    mentions = extractAllMentions(postText); 
	    
		List <ConnectApi.MessageSegmentInput> segments = new List<ConnectApi.MessageSegmentInput>();
	    
	    if (mentions.size() > 0)
	    {
	    	// the cursor is the char position inside post
	      	Integer cursor = 0;
	      
	      	for (Mention mention: mentions) {               
	        	// cursor is maintained at the beginning of a mention/Tag or text segment by moving it one char past the current 
	        	// mention at every iteration of this loop.
	        	if (mention.groupStart > cursor) {
	        		// If there is text between where the cursor is and the start of this mention/Tag so store the text first. 
	          		ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
	          		textSegment.text = postText.subString(cursor, mention.groupStart);
	          		segments.add(textSegment);
          		}   
	          
	        	// next, store the mention
        		ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        		mentionSegment.id = parseOneMention(mention.text,MentionIdPattern);
        		segments.add(mentionSegment);
	       
	                
	        	cursor = mention.groupEnd;   // move cursor 1 char past where this mention ended                    
  			}
	        
	      	// After the last mention, there may be a text segment
	      	if (cursor < postText.length()) 
	      	{
	      		ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
		        textSegment.text = postText.subString(cursor, postText.length());
		        segments.add(textSegment); 
	      	}
	    }
	    else
	    {
	      	// no mentions in the post, just store the whole post as a text segment.
	      	ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
	      	textSegment.text = postText;
	      	segments.add(textSegment);
	  	}
	    
	    messageBody.messageSegments =segments;
  	}
	
  	// parse the user id out of a string that has one mention in it and return it.
  	public static String parseOneMention(String strMention, String strPattern) {
	    Pattern pat = Pattern.compile(strPattern);
	    Matcher matcher = pat.matcher(strMention);
	    matcher.find();
	    return matcher.group();
  	}
	  
  
	  // returns a corresponding FeedItemInput which can be used to post a new feed item
  	public static ConnectApi.MessageBodyInput convertToMessageBodyInput(String postText) {
    	// failsafe - postText size should be controlled by browser.
	    if (postText.length() > 2000) { ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'Error while posting') ); }    
	    
	 	ConnectApi.MessageBodyInput messageBody =  new ConnectApi.MessageBodyInput();
	    //ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
	    buildSegments(postText, messageBody);
	    return messageBody;
  	}
}