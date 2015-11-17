/**
* @ClassName    : SL_IntranetContentTypesController 
* @JIRATicket   : Socint-194
* @CreatedOn    : 24/June/13
* @ModifiedBy   : Pravin 
* @Description  : This is the controller of SL_IntranetContentTypes VF Component.
*/

/** 
@ Pravin Sapkal
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

public with sharing class SL_IntranetContentTypesController extends ComponentControllerBase  
{
	/* Start : Constructor initialization */
	public SL_IntranetContentTypesController() 
	{
		//Do-Nothing	
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - getMyImpl
	   @Parameters     - None 
	   @Return Type    - SL_IntranetContentTypes
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetContentTypes getMyImpl() 
	{
		return (SL_IntranetContentTypes)CompImpl;  
	}
	/* End : SL_IntranetCalendarTypes method */
	
	
	/* @Name           - getLeftSidebarContents
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting dependent picklist values.
	*/
	public void getLeftSidebarContents()
	{
		getMyImpl().getLeftSidebarContents();
	}
	/* End : getLeftSidebarContents method */
	
	public void getFilteredByDepartment()
	{
		getMyImpl().getFilteredByDepartment();
	}
}