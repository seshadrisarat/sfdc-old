public with sharing class SL_IntranetKeyContactsController extends ComponentControllerBase
{
	/* Constructor initialization */
	public SL_IntranetKeyContactsController()    
	{

	}
	/* End : Constructor initialization */
	
	public SL_IntranetKeyContacts getMyImpl() 
	{ 
		return (SL_IntranetKeyContacts)compImpl; 
	}
	
	/* Calling Action function from Implementation class */
	public void getFilteredByDepartment()
	{
		getMyImpl().getFilteredByDepartment(); 
	} 
}