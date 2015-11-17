public with sharing class SL_IntranetEventSummaryController extends ComponentControllerBase
{
	public SL_IntranetEventSummaryController() 
	{
		//Do-Nothing	
	}

	//Function for implementing base class for this Controller.
	public SL_IntranetEventSummary getMyImpl() 
	{
		return (SL_IntranetEventSummary)CompImpl; 
	}
	
	public void loadEventSummaryData()
	{
		getMyImpl().loadEventSummaryData();
	}
	
	/* 
     * Name: showMoreRecords 
     * Parameters: NA
     * Description: Show More functionality
     */
	public void showMoreRecords()
	{
		getMyImpl().showMoreRecords();
	}
	 /* End */
	 
	
}