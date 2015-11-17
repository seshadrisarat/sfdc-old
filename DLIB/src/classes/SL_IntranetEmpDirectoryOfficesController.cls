/**
* @ClassName    : SL_IntranetEmpDirectoryOfficesController 
* @JIRATicket   : Socint-178
* @CreatedOn    : 10/June/13
* @ModifiedBy   : Pravin 
* @Description  : This is the controller of SL_IntranetEmpDirectoryOffices VF Component.
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

public with sharing class SL_IntranetEmpDirectoryOfficesController extends ComponentControllerBase  
{
	/* Start : Constructor initialization */
	public SL_IntranetEmpDirectoryOfficesController() 
	{
		//Do-Nothing	
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - getMyImpl
	   @Parameters     - None 
	   @Return Type    - SL_IntranetEmpDirectoryOffices
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetEmpDirectoryOffices getMyImpl() 
	{
		return (SL_IntranetEmpDirectoryOffices)CompImpl;  
	}
	/* End : SL_IntranetEmpDirectoryOffices method */
}