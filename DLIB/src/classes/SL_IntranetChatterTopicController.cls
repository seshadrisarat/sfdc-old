public with sharing class SL_IntranetChatterTopicController extends ComponentControllerBase  
{
	/* Start : Constructor initialization */
	public SL_IntranetChatterTopicController() 
	{
				
	}
	
	/* @Name           - getMyImpl
	   @Parameters     - None 
	   @Return Type    - SL_IntranetChatterTopic
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetChatterTopic getMyImpl() 
	{
		return (SL_IntranetChatterTopic)CompImpl;        
	}	
}