/**
* @ClassName    : SL_IntranetNavigationBar 
* @JIRATicket   : Socint-181
* @CreatedOn    : 19/June/13
* @ModifiedBy   : Roshan 
* @Description  : This is the Implementation class of SL_IntranetNavigationBarController.
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

public with sharing abstract class SL_IntranetNavigationBar extends WidgetAbstract
{
	public  List<String> lstPages 													{get;set;}				//List to store page names from pageorder configuration	
	private  List<String> lstAllPages;																	 //This list is use to store all Page names   	
	private String currentPageName;																		  //To store the page name
	private Set<String> setPages = new Set<String>();												  	//Set to remove duplicate page names	
	private String pageOrder; 																			//to store page order given at configuration side
																			
	
	/* Constructor initialization */
	public SL_IntranetNavigationBar()
	{
		
	}
	/* End : Constructor initialization */
	
	// initialize method called on component's initialize
	public override protected void initialize()
	{
		currentPageName = ApexPages.currentPage().getParameters().get('page');
		if(String.isBlank(currentPageName))
			currentPageName = 'Home';
		lstAllPages = new List<String>();
		lstPages = new List<String>();
		pageOrder = '';
		if(!getObjectAccess('read', new Page__c().getsObjectType()))
			return ;
		fetchAllPageName();
		fetchingNavConfiguration();
	}
	
	private void fetchAllPageName()
	{
		for(Page__c objPage : [SELECT Id, Name, Order__c FROM Page__c WHERE Name != null ORDER BY Order__c NULLS LAST, Name])
		{
			lstAllPages.add(objPage.Name); 
		}
		
		setPages.addAll(lstAllPages);
	}
	
	/* @Name           - fetchingNavConfiguration
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for creating page order for navigation bar.
	*/
	
	public void fetchingNavConfiguration()
	{
		// Fetch the configuration for the widget
		if(this.properties != null) 
		{
			Map<String, Object> configuration = (Map<String, Object>)this.properties;
	
			if(configuration.containsKey('pageOrder'))
				pageOrder = String.valueOf(configuration.get('pageOrder'));
    	}
    	
    	Set<String> setFilteredpage = new Set<String>();
    	List<String> lstFilteredPage = new List<String>(); //local List for taking page name from Set to List
    	
    	if(String.isNotBlank(pageOrder))
    	{
			pageOrder = pageOrder + ',' + currentPageName; //adding current page name to pageOrder
    		for(String str : pageOrder.split(','))
			{
				if(setPages.contains(str) && !setFilteredpage.contains(str)){
					setFilteredpage.add(str);
					lstFilteredPage.add(str);	
				}	
			}
			
			if(setFilteredpage.size()==0)	//page order is not blank as well not contains atleast one correct page name
				lstFilteredPage.addAll(lstAllPages);
    	}
    	
    	
    	//Checking if pageOrder contain only 1 page name and if it is correct than showing only that page in navigation bar else showing all page
    	// as well if pageOrder is blank then also showing all pages in navigation bar.
    	lstPages = String.isNotBlank(pageOrder) ? lstFilteredPage : lstAllPages; 	
	}
	
	
	/* @Name           - newComponent
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for creating Component dynamically.
	*/
	public override ApexPages.Component newComponent() 
	{
    	Component.c.SL_IntranetNavigationBar c = new Component.c.SL_IntranetNavigationBar();   
		c.aComponentImpl = this;
		
    	return c;
  	}
  	/* End : newComponent */
}