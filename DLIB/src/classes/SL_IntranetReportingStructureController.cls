/**
* @ClassName    : SL_IntranetReportingStructureController 
* @JIRATicket   : Socint-192
* @CreatedOn    : 24/June/13
* @ModifiedBy   : Roshan 
* @Description  : This is the controller for The SL_IntranetReportingStructure Component.
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

public with sharing class SL_IntranetReportingStructureController extends ComponentControllerBase  
{
	/* Constructor initialization */
	public SL_IntranetReportingStructureController() 
	{
		//Do-Nothing	
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - getMyImpl
	   @Parameters     - None 
	   @Return Type    - SL_IntranetReportingStructure
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetReportingStructure getMyImpl() 
	{
		return (SL_IntranetReportingStructure)CompImpl;  
	}
	/* End : getMyImpl method */
	
	/* 
	 * Name: showMoreRecords
	 * Parameters: NA
	 * Description: To Show more records
	*/
	public void showMoreRecords()
	{
		getMyImpl().showMoreRecords();
	}
	 /* End */
}