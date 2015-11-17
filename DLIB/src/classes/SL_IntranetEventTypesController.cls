public with sharing class SL_IntranetEventTypesController extends ComponentControllerBase  
{
	/* Start : Constructor initialization */
	public SL_IntranetEventTypesController() 
	{
		//Do-Nothing	
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - getMyImpl
	   @Parameters     - None 
	   @Return Type    - SL_IntranetCalendarTypes
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetEventTypes getMyImpl() 
	{
		return (SL_IntranetEventTypes)CompImpl;   
	}
	/* End : SL_IntranetCalendarTypes method */
}