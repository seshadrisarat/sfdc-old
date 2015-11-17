/**
 * @ClassName    : SL_IntranetOfficeDetailsController 
 * @JIRATicket   : Socint-319
 * @CreatedOn    : 22/Nov/13
 * @ModifiedBy   : Anil 
 * @Description  : This is controller for SL_IntranetOfficeDetails to get detailed information about Intranet Offices.
 */
 
 /**
 @ Anil Kumar
 Percentage of best practices followed   : 100%
 No of SOQL queries used                 : 0
 No of collections used                  : 0
 Exception Handling implemented          : Not Required
 Coding standards followed               : Yes
 Naming conventions followed             : Yes
 Third party integrations                : No
 Maximum of No of records tested with    : 
 Customer Approval                       : 
 Last Modified Date                      : 
 Approved by                             : 
 */
 
public with sharing class SL_IntranetOfficeDetailsController extends ComponentControllerBase  
{
	/* 
	* Constructor calling
	*/
	public SL_IntranetOfficeDetailsController() 
	{
		//Do-Nothing	
	}
	
	
	/* 
	* Function for implementing base class for this Controller.
	*/
	public SL_IntranetOfficeDetails getMyImpl() 
	{
		return (SL_IntranetOfficeDetails)CompImpl;  
	}
	
	
	/* 
	* Function for getting detail of Intranet Office
	*/
	public void getOfficeDetail()
	{
		getMyImpl().getOfficeDetails();
	}
}