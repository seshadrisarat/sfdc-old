/**
* @ClassName    : SL_IntranetEmpDirectoryOffices 
* @JIRATicket   : Socint-178
* @CreatedOn    : 10/June/13
* @ModifiedBy   : Pravin 
* @Description  : This is the Implementation class of SL_IntranetEmpDirectoryOfficesController Controller.
*/

/**
@ Pravin Sapkal 
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 1
No of collections used                  : 1
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes 
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 
*/

public with sharing class SL_IntranetEmpDirectoryOffices extends WidgetPaginatorAbstract 
{
	public List<Office_Locations__c> lstLocations {get;set;}
	public UserListViewWidgetConfiguration objUserLV {get;set;}
	public String selLocation {get;set;}
    public String selLocationName {get;set;}
    private String strPageName;
	private List<PageRegionWidget__c> lstWidget = new List<PageRegionWidget__c>();
	
	/* Inner Class */
	public class UserListViewWidgetConfiguration
	{
		private String strViewName;			
		public List<String> lstUserListViewName  {get;set;}	// List of View Name that we are getting from the VF page for User Object.
		
		public UserListViewWidgetConfiguration()
		{
			lstUserListViewName = new List<String>();
		}
	}
	
	/* Start : Constructor initialization */
	public SL_IntranetEmpDirectoryOffices()
	{
		strPageName = '';
		selLocation = 'All Employees'; 
		selLocationName = 'All Employees'; 
		if(System.currentPageReference().getParameters().get('loc') != null)
			selLocationName = System.currentPageReference().getParameters().get('loc');
		
		lstLocations = new List<Office_Locations__c>();
		objUserLV = new UserListViewWidgetConfiguration();
		
		strPageName = ApexPages.currentPage().getParameters().get('page');
        if(String.isBlank(strPageName))
        	strPageName = 'Home';
    }

	// initialize method called on component's initialize
	public override protected void initialize()
	{
  		fetchEmpDirOffices();
	}
	
	public void fetchEmpDirOffices()
	{
		if(!getObjectAccess('read', new Office_Locations__c().getsObjectType()))
			return ;
		List<String> lstListViews = new List<String>();
		Set<String> setOfUserString = new Set<String>();
		Set<String> setViewsName = new Set<String>();
		
		
		// Fetch the configuration for the widget
		if(this.properties != null) 
		{
			Map<String, Object> configuration = (Map<String, Object>)this.properties;
			
			if(configuration.containsKey('Listviews'))		objUserLV.strViewName 		= String.valueOf(configuration.get('Listviews'));
		}

		if(objUserLV.strViewName != '')
        {
         	for(String s : objUserLV.strViewName.trim().split(','))
         	{
         		lstListViews.add(s.trim());
         	}
         	
         	setOfUserString.addAll(lstListViews);
        }
        
        //getting all the Office location records
     	lstLocations = [Select Id, Name From Office_Locations__c where Id != null order by Display_Order__c asc nulls last];
        	
        if(setOfUserString != null)
        {
	        ApexPages.Standardsetcontroller objSSC = new ApexPages.Standardsetcontroller(database.getQueryLocator('select Id,Name from User'));
	        
	        for(Selectoption viewOption :  objSSC.getListViewOptions())
			{
				if(setOfUserString.contains(viewOption.getLabel()))
		        	setViewsName.add(viewOption.getLabel());
			}
		}
		
		List<String> lstViewName = new List<String>();
		for(String str : lstListViews)
        {
        	if(setViewsName.contains(str))
        		objUserLV.lstUserListViewName.add(str); 
        }
    }
	/* End : Constructor initialization */
	
	/* @Name           - newComponent
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for creating Component dynamically.
	*/
	public override ApexPages.Component newComponent() 
	{
    	Component.c.SL_IntranetEmpDirectoryOffices c = new Component.c.SL_IntranetEmpDirectoryOffices();   
		c.aComponentImpl = this;
		
    	return c;
  	}
  	/* End : newComponent */
}