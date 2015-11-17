public with sharing class SL_IntranetEventSummaryDetailsController extends ComponentControllerBase
{
	public SL_IntranetEventSummaryDetailsController() 
	{
		//Do-Nothing	
	}
	
	public SL_IntranetEventSummaryDetails getMyImpl() 
	{
		return (SL_IntranetEventSummaryDetails)CompImpl; 
	}
	
  	/*Calling Action function from Implementation class*/
	public void getEventSummaryDetail()
	{
		getMyImpl().getEventSummaryDetailData();
	} 
}