/**
* @ClassName    : SL_IntranetManageGroupsController 
* @JIRATicket   : Socint-195
* @CreatedOn    : 26/June/13
* @ModifiedBy   : Roshan 
* @Description  : This is the controller for The SL_IntranetManageGroups Component.
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

public with sharing class SL_IntranetManageGroupsController extends ComponentControllerBase  
{
	/* Constructor initialization */
	public SL_IntranetManageGroupsController() 
	{
		//Do-Nothing	
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - getMyImpl
	   @Parameters     - None 
	   @Return Type    - SL_IntranetManageGroups
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetManageGroups getMyImpl() 
	{
		return (SL_IntranetManageGroups)CompImpl;  
	}
	/* End : getMyImpl method */
	
	
	/* @Name           - joinNewGroupMember
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for joining a group via manage group page.
	*/
	public void joinNewGroupMember()
	{
		getMyImpl().joinNewGroupMember();
	}
	/* End : joinNewGroupMember method */
	
	
	/* @Name           - leaveTheGroup
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for leaving a group via manage group page.
	*/
	public void leaveTheGroup()
	{
		getMyImpl().leaveTheGroup();
	}
	/* End : leaveTheGroup method */
	
	
	/* @Name           - prevRecords
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for rendering to previous page.
	*/
	public void prevRecords()
	{
		getMyImpl().prevRecords();
	}
	/* End : prevRecords method */
	
	
	/* @Name           - nextRecords
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for moving on next page.
	*/
	public void nextRecords()
	{
		getMyImpl().nextRecords();
	}
	/* End : nextRecords method */
	
	
	/* @Name           - goToPage
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for moving to particular page.
	*/
	public void goToPage()
	{
		getMyImpl().goToPage();
	}
	/* End : goToPage method */
}