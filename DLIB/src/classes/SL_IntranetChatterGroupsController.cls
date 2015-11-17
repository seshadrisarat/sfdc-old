/**
* @ClassName    : SL_IntranetChatterGroupsController 
* @JIRATicket   : Socint-180
* @CreatedOn    : 18/June/13
* @ModifiedBy   : Roshan 
* @Description  : This is the controller of SL_IntranetChatterGroups VF Component.
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

public with sharing class SL_IntranetChatterGroupsController extends ComponentControllerBase  
{
	/* Start : Constructor initialization */
	public SL_IntranetChatterGroupsController() 
	{
		//Do-Nothing	
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - SL_IntranetChatterGroups
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetChatterGroups getMyImpl() 
	{
		return (SL_IntranetChatterGroups)CompImpl; 
	}
	/* End : SL_IntranetChatterGroups method */
}