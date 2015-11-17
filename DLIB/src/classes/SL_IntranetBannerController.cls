/**
* @ClassName    : SL_IntranetBannerController 
* @JIRATicket   : Socint-202
* @CreatedOn    : 11/July/13
* @ModifiedBy   : Anil 
* @Description  : This is the controller for The SL_IntranetBanner Component.
*/

/**
@ Anil Kumar
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 0
No of collections used                  : 0
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 
*/

public with sharing class SL_IntranetBannerController extends ComponentControllerBase  
{
	/* Constructor initialization */
	public SL_IntranetBannerController() 
	{
		//Do-Nothing	
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - getMyImpl
	   @Parameters     - None 
	   @Return Type    - SL_IntranetBanner
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetBanner getMyImpl() 
	{
		return (SL_IntranetBanner)CompImpl;  
	}
	/* End : getMyImpl method */
	/*
	public SL_IntranetBanner getFilteredByDepartment() 
	{
		return (SL_IntranetBanner)getFilteredByDepartment();  
	}*/
	
	public void getFilteredByDepartment()
	{
		getMyImpl().getFilteredByDepartment();
	}
	
}