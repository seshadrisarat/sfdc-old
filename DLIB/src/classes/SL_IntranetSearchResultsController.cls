/**
* @ClassName    : SL_IntranetSearchResultsController 
* @JIRATicket   : Socint-191
* @CreatedOn    : 20/June/13
* @ModifiedBy   : Pravin 
* @Description  : This is the controller of SL_IntranetSearchResults VF Component.
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

public virtual with sharing class SL_IntranetSearchResultsController extends ComponentControllerBase  
{
	/* Start : Constructor initialization */
	public SL_IntranetSearchResultsController() 
	{
		//Do-Nothing	
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - getMyImpl
	   @Parameters     - None 
	   @Return Type    - SL_IntranetSearchResults
	   @Description    - Function for implementing base class for this Controller.
	*/
	public SL_IntranetSearchResults getMyImpl() 
	{
		return (SL_IntranetSearchResults)CompImpl; 
	}
	/* End : SL_IntranetSearchResults method */
	
	
	/* @Name           - getSearchResults
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting search results.
	*/
	public void getSearchResults()
	{
		getMyImpl().getSearchResults();
	}
	/* End : getSearchResults method */
	
	
	/* @Name           - getMoreRecords
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting more search results.
	*/
	public void getMoreRecords()
	{
		getMyImpl().getMoreRecords();
	}
	/* End : getMoreRecords method */
	
	
	/* @Name           - getMoreRecordsForMobile
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting more search results for mobile view.
	*/
	public void getMoreRecordsForMobile()
	{
		getMyImpl().getMoreRecordsForMobile();
	}
	/* End : getMoreRecordsForMobile method */
	
	/* @Name           - prevRecords
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for rendering to previous result page.
	*/
	public void prevRecords()
	{
		getMyImpl().prevRecords();
	}
	/* End : prevRecords method */
	
	
	/* @Name           - nextRecords
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for rendering to next result page.
	*/
	public void nextRecords()
	{
		getMyImpl().nextRecords();
	}
	/* End : nextRecords method */
	
	
	/* @Name           - goToPage
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for rendering to particular result page.
	*/
	public void goToPage()
	{
		getMyImpl().goToPage();
	}
	/* End : goToPage method */
	
}