/**
* @ClassName    : SL_IntranetEmbeddedController 
* @JIRATicket   : Socint-233
* @CreatedOn    : 17/Sep/13
* @ModifiedBy   : Pravin 
* @Description  : This is the Implementation Class for SL_IntranetEmbedded.
*/
public class SL_IntranetEmbeddedController extends ComponentControllerBase
{
	/* Start - Variables */
	/* End Variables */
	
	/* Start - Constructor */
	public SL_IntranetEmbeddedController()
	{
		// Do nothing
	}
	/* End - Constructor */
	
	/* 
     * Name: getMyImpl
     * Parameters: NA
     * Description: This function is used to initialize the SL_IntranetEmbedded class.
     */
	public SL_IntranetEmbedded getMyImpl()  
	{
		return (SL_IntranetEmbedded)CompImpl;   
	}
	/* End */
	
	/*
	public SL_IntranetEmbedded getFilteredByDepartment()  
	{
		return (SL_IntranetEmbedded)getFilteredByDepartment();   
	}*/
	public void getFilteredByDepartment()
	{
		getMyImpl().getFilteredByDepartment();
	}

}