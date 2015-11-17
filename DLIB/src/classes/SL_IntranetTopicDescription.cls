public with sharing class SL_IntranetTopicDescription extends WidgetAbstract
{
	public SL_IntranetTopicDescription() 
	{
		
	}

	
	/* 
     * Name: getTopicDescription
     * Parameters: Topic Id
     * Description: This function is used to fetch the Topic Description.
     */
	public Topic getTopicDescription(String strchatterTopicId)
	{
		return [SELECT Name,Description FROM Topic WHERE Id =: strchatterTopicId Limit 1];
	}
	/*End*/

	/* 
     * Name: newComponent
     * Parameters: NA
     * Description: This function is used to create the dynamic component
     */
	public override ApexPages.Component newComponent() 
	{
    	//respective component name will be used here.
		Component.c.SL_IntranetTopicDescription c = new Component.c.SL_IntranetTopicDescription();   
		c.aComponentImpl = this;
    	return c;
  	}
  	/* End */ 
}