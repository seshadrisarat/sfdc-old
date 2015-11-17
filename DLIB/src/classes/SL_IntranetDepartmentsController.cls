public with sharing class SL_IntranetDepartmentsController extends ComponentControllerBase
{
	/* Constructor initialization */
	public SL_IntranetDepartmentsController()    
	{
		//Do nothing
	}
	/* End : Constructor initialization */
	
	public SL_IntranetDepartments getMyImpl() 
	{  
		return (SL_IntranetDepartments)compImpl; 
	} 
}