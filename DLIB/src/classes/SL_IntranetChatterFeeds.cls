/**
* @ClassName    : SL_IntranetChatterFeeds 
* @JIRATicket   : Socint-829
* @CreatedOn    : 28/July/14
* @ModifiedBy   : Ritika 
* @Description  : This is the Implementation Class for The SL_IntranetChatterFeedsController.
*/

/**
@ Roshan Pillai 
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 
No of collections used                  : 
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 
*/

public with sharing class SL_IntranetChatterFeeds extends WidgetPaginatorAbstract implements IChatterable
{
	public SL_IntranetChatterPlugIn Chatter	{	get; set;	}
	
	private Id topicId;
	private Id groupId;
	
	public SL_IntranetChatterFeeds() {
			
	}
	
	/* Method for getting Instance of generic chatter component */
	public SL_IntranetChatterPlugIn initChatter() {
		
		SL_IntranetChatterPlugIn plugin = new SL_IntranetChatterPlugIn();
		plugin.initializeParam('CustomChatter', id);
		return plugin;
	}
	
	/**
	* Configutation:
	* {"topicId":"","GroupId":""}
	**/
	private void configure() {
		
		String topicIdParam;
		String chatterGroupParam;
				
		if(this.properties != null) {	
			if(this.properties.containsKey('topicId')) {
				// set default
				topicIdParam = String.valueOf(this.properties.get('topicId'));					
			}			
			
			if(this.properties.containsKey('GroupId')) {
				chatterGroupParam = String.valueOf(this.properties.get('GroupId'));
			}
		}	
		
		// checking for overridable parram from the page
		String pageTopicIdParam = ApexPages.currentPage().getParameters().get('topicId');
		if(!String.isBlank(pageTopicIdParam)) topicIdParam = pageTopicIdParam;
		
		if(!String.isBlank(topicIdParam)) topicId = (Id)topicIdParam;
		
		String pageGroupIdParam = ApexPages.currentPage().getParameters().get('GroupId');
		if(!String.isBlank(pageGroupIdParam)) chatterGroupParam = pageGroupIdParam;
		
		if(!String.isBlank(chatterGroupParam)) groupId = (Id)chatterGroupParam;
	}
	
	public override protected void initialize()
	{
		Chatter = initChatter(); //binding the generic chatter instance
				
		configure();
		
		if(groupId != null) {
			// some overhead in initChatter() method
			Chatter.loadChatterGroupFeedsByGroupId(groupId);
		}
		else if(topicId != null) {
			// some overhead in initChatter() method 
			Chatter.gtTopicFeedsByTopicId(String.valueOf(topicId));
		}	
	}
	
	
	/* @Name           - newComponent
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for creating Component dynamically.
	*/
	public override ApexPages.Component newComponent() 
	{
    	Component.c.SL_IntranetChatterFeeds c = new Component.c.SL_IntranetChatterFeeds();  
		c.aComponentImpl = this;
		
    	return c;
  	}  	
}