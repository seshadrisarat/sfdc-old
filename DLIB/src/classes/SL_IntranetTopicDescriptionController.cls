public with sharing class SL_IntranetTopicDescriptionController extends ComponentControllerBase
{
	
	public SL_IntranetTopicDescriptionController() 
	{
		
	}

	@RemoteAction
	public static Topic getData(String widgetInstanceName,String chatterTopicId) 
	{
		SL_IntranetTopicDescription w = (SL_IntranetTopicDescription)WidgetRepository.getWidgetInstanceById(widgetInstanceName);
		return w.getTopicDescription(chatterTopicId); 
		
	}

	/* 
     * Name: getMyImpl
     * Parameters: NA
     * Description: Function for implementing base class for this Controller.
     */
	public SL_IntranetTopicDescription getMyImpl() 
	{
		return (SL_IntranetTopicDescription)CompImpl;        
	}
	/* End */

}