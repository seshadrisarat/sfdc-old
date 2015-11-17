public with sharing class SL_IntranetEventsController extends ComponentControllerBase  
{
	/* Constructor initialization */
	public SL_IntranetEventsController() 
	{
		//Do-Nothing	
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - getMyImpl
	   @Parameters     - None 
	   @Return Type    - SL_IntranetEvents
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetEvents getMyImpl() 
	{
		return (SL_IntranetEvents)CompImpl;  
	}
	/* End : getMyImpl method */
	
	
	/* @Name           - getMoreRecords
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting more records
	*/
	public void getMoreRecords()
	{
		getMyImpl().getMoreRecords();
	} 
	/* End : getMoreRecords method */
	
	
	/* @Name           - getIntranetevents
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting all records of calendars
	*/
	public void getIntranetevents()
	{
		getMyImpl().getIntranetevents();
	} 
	/* End : getIntranetevents method */
	
	/* Calling Action function from Implementation class */
    public void getFilteredByDepartment()
    {
        getMyImpl().getFilteredByDepartment();
    } 
}