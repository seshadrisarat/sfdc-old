/**
* @ClassName    : SL_IntranetRecentDocumentsController 
* @JIRATicket   : Socint-1040
* @CreatedOn    : 02/12/2014
* @ModifiedBy   : Anil 
* @Description  : This is the controller for the SL_IntranetRecentDocuments Component.
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
public with sharing class SL_IntranetRecentDocumentsController extends ComponentControllerBase {

	/* Constructor initialization */
	public SL_IntranetRecentDocumentsController() 
	{
		//Do-Nothing	
	}  
	/* End : Constructor initialization */
	   
	/* @Name           - getMyImpl  
	   @Parameters     - None 
	   @Return Type    - SL_IntranetRecentDocuments
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetRecentDocuments getMyImpl() 
	{  
		return (SL_IntranetRecentDocuments)CompImpl;  
	}
	/* End : getMyImpl method */
}