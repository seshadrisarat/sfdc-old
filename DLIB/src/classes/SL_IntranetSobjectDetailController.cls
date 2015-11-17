/**
* \arg ClassName  : SL_IntranetSobject
* \arg JIRATicket : SOCINT-326
* \arg CreatedOn  : Lodhi, 28/Oct/2013 
* \arg ModifiedBy : 
* \arg Description: 
*/
public with sharing class SL_IntranetSobjectDetailController extends ComponentControllerBase  
{
	/* Start - Variable*/
	/* End - Variables */
	
	/* Start - Contructor */
	public SL_IntranetSobjectDetailController() 
	{
		//Do-Nothing	
	}
	/* End - Contructor */
	
	/* 
     * Name: getMyImpl
     * Parameters: NA
     * Description: Function for implementing base class for this Controller.
     */
	public SL_IntranetSobjectDetail getMyImpl() 
	{
		return (SL_IntranetSobjectDetail)CompImpl;  
	}
	/* End */
	
	
	/* 
     * Name: getSobjectRecords
     * Parameters: NA
     * Description: Function to call Sobject records.
     */
	public void getSobjectRecords()
	{
		getMyImpl().sObjectConfig();
	} 
	/* End */
	/* 
     * Name: previous
     * Parameters: NA
     * Description: To go to the previous page.
     */
	public void prevRecords()
	{
		getMyImpl().strSobjectId = null;
		getMyImpl().prevRecords();
		getMyImpl().sObjectConfig();
		getMyImpl().initialState = true;
	}
	/* End */
	/* 
     * Name: next
     * Parameters: NA
     * Description: To go to the next page.
     */
	public void nextRecords()
	{
		getMyImpl().strSobjectId = null;
		getMyImpl().nextRecords();
		getMyImpl().sObjectConfig();
		getMyImpl().initialState = true;
	}
	/* End */
	/* 
     * Name: goToPage
     * Parameters: NA
     * Description: To go to particular page number.
     */
	public void goToPage()
	{
		getMyImpl().strSobjectId = null;
		getMyImpl().goToPage();
		getMyImpl().sObjectConfig();
		getMyImpl().initialState = true;
	}
	/* End */
	/* 
     * Name: showInitialState
     * Parameters: NA
     * Description: To initialise the widget on click of list view widget
     */
	public void showInitialState()
	{
		getMyImpl().showInitialState();
	}
	/* End */
	
	
}