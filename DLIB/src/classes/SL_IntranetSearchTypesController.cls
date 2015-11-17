/**
* @ClassName    : SL_IntranetSearchTypesController 
* @JIRATicket   : Socint-191
* @CreatedOn    : 21/June/13
* @ModifiedBy   : Pravin 
* @Description  : This is the controller of SL_IntranetSearchTypes VF Component.
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

public with sharing class SL_IntranetSearchTypesController extends ComponentControllerBase  
{
	/* Start : Constructor initialization */
	public SL_IntranetSearchTypesController() 
	{
		//Do-Nothing	
	}
	/* End : Constructor initialization */
	
	 
	/* @Name           - getMyImpl
	   @Parameters     - None 
	   @Return Type    - SL_IntranetSearchTypes
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetSearchTypes getMyImpl() 
	{
		return (SL_IntranetSearchTypes)CompImpl; 
	}
	/* End : SL_IntranetChatterGroups method */
	
	
	/* @Name           - SL_IntranetChatterGroups
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for implementing base class for this Controller.
	*/
	public void getSearchResults() 
	{
		getMyImpl().getSearchResults(); 
	}
	/* End : SL_IntranetChatterGroups method */
}