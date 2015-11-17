public class SL_Intranet_StandardChatterController extends ComponentControllerBase  
{
	/* Constructor initialization */
	public SL_Intranet_StandardChatterController() 
	{
		//Do-Nothing	
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - getMyImpl
	   @Parameters     - None 
	   @Return Type    - SL_IntranetChatterFeeds
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_Intranet_StandardChatter getMyImpl()  
	{
		return (SL_Intranet_StandardChatter)CompImpl;  
	}
	/* End : getMyImpl method */ 
}