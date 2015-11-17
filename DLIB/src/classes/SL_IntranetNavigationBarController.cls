/**
* @ClassName    : SL_IntranetNavigationBarController 
* @JIRATicket   : Socint-181
* @CreatedOn    : 19/June/13
* @ModifiedBy   : Roshan 
* @Description  : This is the controller class of SL_IntranetNavigationBarController SL_IntranetNavigationBar Component.
*/

/**
@ Roshan Pillai
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 
No of collections used                  : 
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 
*/

public with sharing class SL_IntranetNavigationBarController extends ComponentControllerBase
{
	/* Constructor initialization */
	public SL_IntranetNavigationBarController()    
	{
		
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - SL_IntranetNavigationBar
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetNavigationBar getMyImpl() 
	{  
		return (SL_IntranetNavigationBar)compImpl; 
	} 
}