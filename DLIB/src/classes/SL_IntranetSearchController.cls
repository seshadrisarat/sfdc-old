/**
* @ClassName    : SL_IntranetSearchController 
* @JIRATicket   : Socint-179
* @CreatedOn    : 14/June/13
* @ModifiedBy   : Pravin 
* @Description  : This is the Controller of SL_IntranetSearch VF Component.
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

public without sharing class SL_IntranetSearchController extends ComponentControllerBase
{
	/* Constructor initialization */
	public SL_IntranetSearchController()    
	{
		//Do nothing
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - getMyImpl
	   @Parameters     - None 
	   @Return Type    - SL_IntranetSearch
	   @Description    - Function for implementing the base class of this Controller.
	*/
	public SL_IntranetSearch getMyImpl() 
	{  
		return (SL_IntranetSearch)compImpl; 
	} 
	/* End : getMyImpl method */
}