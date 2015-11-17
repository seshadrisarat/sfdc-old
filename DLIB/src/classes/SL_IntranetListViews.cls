/**
* \arg ClassName  : SL_IntranetListViews
* \arg JIRATicket : 
* \arg CreatedOn  :  
* \arg ModifiedBy : 
* \arg Description: 
*/

public with sharing class SL_IntranetListViews extends WidgetAbstract
{
	/* Start - Variables */
	public listViewWidgetConfiguration listViewConfig 						{	get;set;	}	//Store all the configuration
	private String strPageName;																	// Page name
	
	/* Start Constructor */
	public SL_IntranetListViews()
	{
		listViewConfig = new listViewWidgetConfiguration();
		
		strPageName = ApexPages.currentPage().getParameters().get('page');
		
		if(String.isBlank(strPageName))
            strPageName = 'Home';
		
	}
	/* End */
	
	// initialize method called on component's initialize
	public override protected void initialize()
	{
  		getAllListViews();
	}
	
	/* Inner Class */
	public class listViewWidgetConfiguration
	{
		public String sObjectName         {get;set;}											// variable is used to display the Sobject Name.
		public String strHeading          {get;set;}											// variable is used to store Header Name.
		private String strViewName;			
		public List<String> lstViewsName  {get;set;}											// List of View Name that we are getting from the VF page for an Object.
		
		public listViewWidgetConfiguration()
		{
			lstViewsName = new List<String>();
		}
	}
	
	public void getAllListViews()
    {
		List<String> lstListViews = new List<String>();
		Set<String> setOfUserString = new Set<String>();										
		
	    // Fetch the configuration for the widget
		if(this.properties != null) 
		{
			Map<String, Object> configuration = (Map<String, Object>)this.properties;
			
			if(configuration.containsKey('sobjectname'))	listViewConfig.sObjectName 		= String.valueOf(configuration.get('sobjectname'));
			if(String.isBlank(listViewConfig.sObjectName) || !getObjectAccess('read', Schema.getGlobalDescribe().get(listViewConfig.sObjectName)))
				return ;
			if(configuration.containsKey('heading'))		listViewConfig.strHeading 		= String.valueOf(configuration.get('heading'));
			if(configuration.containsKey('Listviews'))		listViewConfig.strViewName 		= String.valueOf(configuration.get('Listviews'));
		}
		
		if(String.isNotBlank(listViewConfig.strViewName))
		{
			for(String s : listViewConfig.strViewName.trim().split(','))
         	{
         		lstListViews.add(s.trim());
         	}
         	setOfUserString.addAll(lstListViews);
		}
			
	    Set<String> setViewsName = new Set<String>();
	         
        if(String.isNotBlank(listViewConfig.sObjectName) && setOfUserString != null)
        {
        	ApexPages.Standardsetcontroller objSSC = new ApexPages.Standardsetcontroller(database.getQueryLocator('SELECT Id FROM ' + listViewConfig.sObjectName + ' Limit 1'));
        	for(Selectoption viewOption :  objSSC.getListViewOptions())
			{
				if(setOfUserString.contains(viewOption.getLabel()))
		        	setViewsName.add(viewOption.getLabel());
			}
        }	
        
        //This iterartion is done to get all the List View Name in Order the way they are given in Config
        List<String> lstVName = new List<String>();
        for(String str : lstListViews)
        {
        	if(setViewsName.contains(str))
        		listViewConfig.lstViewsName.add(str);
        }
        
	}
	
	/* 
     * Name: newComponent
     * Parameters: NA
     * Description: This function is used to create the dynamic component
     */
	public override ApexPages.Component newComponent()   
	{
    	//respective component name will be used here.
		Component.c.SL_IntranetListViews c = new Component.c.SL_IntranetListViews();    
		c.aComponentImpl = this; 
    	return c;
  	} 
  	/* End */
  	
}