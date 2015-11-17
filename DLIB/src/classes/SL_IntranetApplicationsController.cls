public virtual with sharing class SL_IntranetApplicationsController extends ComponentControllerBase
{
	/* Constructor initialization */
	public SL_IntranetApplicationsController()    
	{
		//Do nothing
	}
	/* End : Constructor initialization */
	
	public SL_IntranetApplications getMyImpl() 
	{  
		return (SL_IntranetApplications)compImpl; 
	} 
	 /* Calling Action function from Implementation class */
    public void getFilteredByDepartment()
    {
        getMyImpl().getFilteredByDepartment();
    } 
	
}