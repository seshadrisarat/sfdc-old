public virtual with sharing class SL_IntranetNotificationsController extends ComponentControllerBase
{
	public SL_IntranetNotificationsController() {
		
	}
	
	public SL_IntranetNotifications getMyImpl() {
		return (SL_IntranetNotifications)compImpl; 
	} 
	 
	/* Calling Action function from Implementation class */
	public void getFilteredByDepartment()
	{
		getMyImpl().getFilteredByDepartment(); 
	} 
	
	/* 
     * Name: getNotificationRecords
     * Parameters: NA
     * Description: To view all records
     */
     public void showMoreRecords()
	{
		getMyImpl().showMoreRecords();
	}
     /* End */
}