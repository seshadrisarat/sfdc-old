/**
* @ClassName    : SL_IntranetChatterFeedsController 
* @JIRATicket   : Socint-193
* @CreatedOn    : 28/June/13
* @ModifiedBy   : Roshan 
* @Description  : This is the controller for The SL_IntranetChatterFeeds Component.
*/

/**
@ Roshan Pillai 
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

public with sharing class SL_IntranetChatterFeedsController extends ComponentControllerBase  
{
	/* Constructor initialization */
	public SL_IntranetChatterFeedsController() 
	{
		//Do-Nothing	
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - getMyImpl
	   @Parameters     - None 
	   @Return Type    - SL_IntranetChatterFeeds
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetChatterFeeds getMyImpl()  
	{
		return (SL_IntranetChatterFeeds)CompImpl;  
	}
	/* End : getMyImpl method */
	
}