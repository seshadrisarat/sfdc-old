/**
* \arg ClassName  : SL_IntranetListViewsController
* \arg JIRATicket : 
* \arg CreatedOn  :  
* \arg ModifiedBy : 
* \arg Description: 
*/

public with sharing class SL_IntranetListViewsController extends ComponentControllerBase
{
	/* Start - Variables */
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_IntranetListViewsController()  
	{
		//Do-Nothing	
		
	}
	/* End - Constructor */
	
	/* 
     * Name: getMyImpl
     * Parameters: NA
     * Description: Function for implementing base class for this Controller.
     */
     
	public SL_IntranetListViews getMyImpl() 
	{
		return (SL_IntranetListViews)CompImpl;      
	}
	/* End */
}