public with sharing class SL_IntranetStaffUpdatesController extends ComponentControllerBase
{
	/* Constructor initialization */
	public SL_IntranetStaffUpdatesController()    
	{

	}
	/* End : Constructor initialization */
	
	public SL_IntranetStaffUpdates getMyImpl() 
	{ 
		return (SL_IntranetStaffUpdates)compImpl; 
	} 
	
	/* 
     * Name: showMoreRecords
     * Parameters: NA
     * Description: To view all records
     */
    public void showMoreRecords()
	{
		getMyImpl().showMoreRecords();
	}
     /* End */
}