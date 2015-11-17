public with sharing class SL_IntranetChatterPlugInController  {
	
	public SL_IntranetChatterPlugIn chatImpl {get;set;}
	
	/* Constructor initialization */
	public SL_IntranetChatterPlugInController() 
	{
		//Do-Nothing	
	}
	/* End : Constructor initialization */
	
	/* @Name           - getChatterImpl
	   @Parameters     - None 
	   @Return Type    - SL_IntranetChatterPlugIn
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetChatterPlugIn getChatterImpl()  
	{
		return chatImpl;  
	}
	/* End : getChatter method */
	
	@RemoteAction
	public static List<String> getAssociatedTopics(String FeedItemId)
	{
		return SL_IntranetChatterPlugIn.getAssociatedTopics(FeedItemId);
	}
	
	@RemoteAction
	public static List<String> manageFeedItemTopics(String FeedItemId, String strSelectedTopicIds)
	{
		return SL_IntranetChatterPlugIn.manageFeedItemTopics(FeedItemId, strSelectedTopicIds);
	}
	
}