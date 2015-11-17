/**
* @ClassName    : SL_IntranetEmployeeDirectoryController 
* @JIRATicket   : Socint-178
* @CreatedOn    : 10/June/13 
* @ModifiedBy   : Pravin 
* @Description  : This is the controller of SL_IntranetEmployeeDirectory VF Component.
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

public virtual with sharing class SL_IntranetEmployeeDirectoryController extends ComponentControllerBase  
{
	/* Start : Constructor initialization */
	public SL_IntranetEmployeeDirectoryController() 
	{
		//Do-Nothing	
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - getMyImpl
	   @Parameters     - None  
	   @Return Type    - SL_IntranetEmployeeDirectory
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetEmployeeDirectory getMyImpl() 
	{
		return (SL_IntranetEmployeeDirectory)CompImpl; 
	}
	/* End : SL_IntranetEmployeeDirectory method */
	
	
	/* @Name           - gtLocationUsers
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting the user's records related to selected Location
	*/
	public void gtLocationUsers()
	{
		getMyImpl().gtLocationUsers();
	}
	/* End : gtLocationUsers method */
	
	/* @Name           - gtListViewUsers
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for getting the List View records.
    */
    public void gtListViewUsers()
    {
        getMyImpl().gtListViewUsers();
    }
    /* End : gtListViewUsers method */
	
	
	/* @Name           - gtRecentHires
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting the recent hires records.
	*/
	public void gtRecentHires()
	{
		getMyImpl().gtRecentHires();
	}
	/* End : gtRecentHires method */
	
	
	/* @Name           - gtSortPreference
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for sorting Users records.
	*/
	public void gtSortPreference()
	{
		getMyImpl().gtSortPreference();
	}
	/* End : gtSortPreference method */
	
	
	/* @Name           - getMoreRecords
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting more User records.
	*/
	public void getMoreRecords()
	{
		getMyImpl().getMoreRecords();
	}
	/* End : getMoreRecords method */
	
	
	/*  Name:  firstRecords()
	  	Param: None
	  	Description: To get the records of first page
	*/
	public void firstRecords()
	{
		getMyImpl().firstDirectoryRecords();
	}
	/* End : firstRecords Methods */ 
	
	
	/* @Name           - prevRecords
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for going back to previous page record.
	*/
	public void prevRecords()
	{
		getMyImpl().prevDirectoryRecords();
	}
	/* End : prevRecords method */
	
	
	/* @Name           - nextRecords
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for going to next page record.
	*/
	public void nextRecords()
	{
		getMyImpl().nextDirectoryRecords();
	}
	/* End : nextRecords method */
	
	
	/*  Name: lastRecords
		Param: None
		Description: To get the records of last page
	*/
	public void lastRecords()
	{
        getMyImpl().lastDirectoryRecords();
	}
	/* End : lastRecords Methods */ 
	
	
	/* @Name           - goToPage
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting records for specific page number.
	*/
	public void goToPage()
	{
		getMyImpl().goToDirectoryPage();
	}
	/* End : goToPage method */
	
	
	public void getFilteredByDepartment()
    {
        getMyImpl().getFilteredByDepartment();
    } 
    
}