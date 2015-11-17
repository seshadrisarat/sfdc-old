public with sharing class SL_IntranetNotificationDetailsController extends ComponentControllerBase  
{
	public SL_IntranetNotificationDetailsController() 
	{
		//Do-Nothing	
	}
	
	public SL_IntranetNotificationDetails getMyImpl() 
	{
		return (SL_IntranetNotificationDetails)CompImpl; 
	}
	
	/* Calling Action function from Implementation class */
	public void getNotifications()
	{
		getMyImpl().getNotifications();
	} 

	public void toggleNotificationState()
	{
		getMyImpl().toggleNotificationState();
	}
	
	public void prevRecords()
	{
		getMyImpl().prevRecords();
	}
	
	public void nextRecords()
	{
		getMyImpl().nextRecords();
	}
	
	public void goToPage()
	{
		getMyImpl().goToPage();
	}
	
	public void getFilteredByDepartment()
	{
		getMyImpl().getFilteredByDepartment();
	}
	 
}