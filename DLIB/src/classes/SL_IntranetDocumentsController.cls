/**
* @ClassName    : SL_IntranetDocumentsController 
* @JIRATicket   : Socint-194
* @CreatedOn    : 26/June/13
* @ModifiedBy   : Pravin 
* @Description  : This is the controller for The SL_IntranetDocuments Component.
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

public with sharing class SL_IntranetDocumentsController extends ComponentControllerBase  
{
	/* Constructor initialization */
	public SL_IntranetDocumentsController() 
	{
		//Do-Nothing	
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - getMyImpl
	   @Parameters     - None 
	   @Return Type    - SL_IntranetDocuments
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetDocuments getMyImpl() 
	{
		return (SL_IntranetDocuments)CompImpl;  
	}
	/* End : getMyImpl method */
	
	
	/* @Name           - getFeaturedOrRecentContents
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting Recent and Featured Contents.
	*/
	public void getFeaturedOrRecentContents() 
	{
		getMyImpl().getFeaturedOrRecentContents();  
	}
	/* End : getFeaturedOrRecentContents method */
	
	
	/* @Name           - getCategoryRelatedContent
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting contents of selected category.
	*/
	public void getCategoryRelatedContent() 
	{
		getMyImpl().getCategoryRelatedContent();  
	}
	/* End : getCategoryRelatedContent method */
	
	
	/* @Name           - prevRecords
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for rendering to previous page
	*/
	public void prevRecords()  
	{
		getMyImpl().prevRecords();  
	}
	/* End : prevRecords method */
	 
	
	/* @Name           - nextRecords
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for moving to next page
	*/
	public void nextRecords() 
	{
		getMyImpl().nextRecords();  
	}
	/* End : nextRecords method */
	
	
	/* @Name           - goToPage
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for moving to particular page
	*/
	public void goToPage() 
	{
		getMyImpl().goToPage();  
	}
	/* End : goToPage method */
	 /* Calling Action function from Implementation class */
    public void getFilteredByDepartment()
    {
        getMyImpl().getFilteredByDepartment(); 
    } 
}