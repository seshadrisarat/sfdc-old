/**
* @ClassName    : SL_IntranetEmployeeProfileController 
* @JIRATicket   : Socint-192
* @CreatedOn    : 21/June/13
* @ModifiedBy   : Roshan 
* @Description  : This is the controller of SL_IntranetEmployeeProfile VF Component.
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

public with sharing class SL_IntranetEmployeeProfileController extends ComponentControllerBase
{
	/* Constructor initialization */
	public SL_IntranetEmployeeProfileController()    
	{
		//Do nothing
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - getMyImpl
	   @Parameters     - None 
	   @Return Type    - SL_IntranetEmployeeProfile
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetEmployeeProfile getMyImpl()  
	{  
		return (SL_IntranetEmployeeProfile)compImpl; 
	} 
	/* End : SL_IntranetCalendarTypes method */
	
	public void deleteChatterPhoto()
	{
		getMyImpl().deleteChatterPhoto(); 
	}
	
	public void updateUserInfo() 
	{
		getMyImpl().updateUserInformation(); 
	}
	
	public void recetEditPopUpOnCancel()
	{
		getMyImpl().recetEditPopUpOnCancel();
	}
}