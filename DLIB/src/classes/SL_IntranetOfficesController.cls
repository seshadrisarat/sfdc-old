public with sharing class SL_IntranetOfficesController extends ComponentControllerBase
{
	/* Constructor initialization */
	public SL_IntranetOfficesController()    
	{
		//Do nothing
	}
	/* End : Constructor initialization */
	
	public SL_IntranetOffices getMyImpl() 
	{ 
		return (SL_IntranetOffices)compImpl; 
	} 
}