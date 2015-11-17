/**
* @ClassName    : SL_IntranetUserInfoController 
* @JIRATicket   : Socint-181
* @CreatedOn    : 1/July/13
* @ModifiedBy   : Roshan 
* @Description  : This is the controller for The SL_IntranetUserInfo Component.
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

public with sharing class SL_IntranetUserInfoController extends ComponentControllerBase  
{
	/* Constructor initialization */
	public SL_IntranetUserInfoController() 
	{
		//Do-Nothing	
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - getMyImpl
	   @Parameters     - None 
	   @Return Type    - SL_IntranetUserInfo
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetUserInfo getMyImpl() 
	{
		return (SL_IntranetUserInfo)CompImpl;  
	}
	/* End : getMyImpl method */
}