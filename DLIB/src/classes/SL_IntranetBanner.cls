/**
 * @ClassName    : SL_IntranetBanner 
 * @JIRATicket   : Socint-202
 * @CreatedOn    : 11/July/13
 * @ModifiedBy   : Anil 
 * @Description  : This is the Implementation Class for The SL_IntranetBannerController.
 */
 
 /**
 @ Anil Kumar
 Percentage of best practices followed   : 100%
Add a comment to this line
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
    
 public with sharing class SL_IntranetBanner extends WidgetAbstract implements IObservable
 {
    /*Start: public variables*/
    public String strDeptId {get;set;}
    public List<Document> lstDocumentToDisplay {get;set;}
    public BannerWidgetConfiguration bannerConfig {get;set;}
    private String strPageName;
    private Map<String, String> mapDeptIdToDeptName = new Map<String, String>();
    private Boolean isDepartmentWidgetExist; //To identify if Department widget exist on page or not to decide the behavior based on that.
    /* End : public variables*/ 
    
    /* Start : Constructor*/    
    public SL_IntranetBanner()
    {
        lstDocumentToDisplay = new List<Document>();
        bannerConfig = new BannerWidgetConfiguration();
        strPageName = '';
        strDeptId = '';
        isDepartmentWidgetExist = false;
        mapDeptIdToDeptName = new Map<String, String>();
        
        // get the page name
        strPageName = ApexPages.currentPage().getParameters().get('page');
        if(String.isBlank(strPageName))
            strPageName = 'Home';
    }
    /* End : Constructor*/  
    
    public override protected void initialize()
    {
    	// listen for department widget dependancy
		WidgetConfigurationListener.getInstance().addEventListener('SL_IntranetDepartments', this); 
    }
    
    // Depends on Department configuration, so is executed after post initializtion
    override public void postInitialize()
	{
		fetchBannerData();		//Query all the neccessary data for all Banner widgets
	}
	
	
	 //Used for getting department initialselection value
	public void notify(IWidget widget) 
	{
		if(widget == null) return;
			
		SL_IntranetDepartments departmentWidget = (SL_IntranetDepartments)widget;
		strDeptId = departmentWidget.strInitialDeptSelection;
		mapDeptIdToDeptName.putAll(departmentWidget.mapDeptIdToName); 
		isDepartmentWidgetExist = true;
	}

    //Inner Class
    public class BannerWidgetConfiguration
    {
        /*Configuration Variables*/
        public String strDepartment;
        public String strTargetFolderId;
        public Integer intTrasnitionSeconds {get;set;}
        public Integer intWidgetHeight      {get;set;}
        /*Extra Variables used on Component*/
        
        public Integer intMinWidth          {get; set;}
        public Decimal decMaxWidth          {get; set;}
        public Boolean showBanner           {get; set;}
        public Integer intMinHeight         {get; set;}

        public BannerWidgetConfiguration()
        {
        	this.intMinHeight = 250;
            this.intMinWidth  = 232;
            this.decMaxWidth  = 0;
            this.showBanner   = false;
        }
    }
    
    /* @Name           - fetchBannerData
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for query neccessary records for Banner
    */
    public void fetchBannerData()
    {
    	if(!getObjectAccess('read', new Document().getsObjectType()))
			return ;
    	String departmentName = '';
      	Set<String> setDepartment = new Set<String>();
        if(this.properties != null) 
        {
            Map<String, Object> configuration = (Map<String, Object>)this.properties;
            
            bannerConfig.strDepartment              = String.valueOf(configuration.get('department'));
            bannerConfig.strTargetFolderId          = String.valueOf(configuration.get('targetfolder'));
            bannerConfig.intTrasnitionSeconds       = configuration.get('trasnitionseconds') != null && String.valueOf(configuration.get('trasnitionseconds')).trim() !=''  ? Integer.valueOf(configuration.get('trasnitionseconds')) : 5;
			bannerConfig.intWidgetHeight            = configuration.get('widgetheight') != null && String.valueOf(configuration.get('widgetheight')).trim() !=''  ? Integer.valueOf(configuration.get('widgetheight')) : 250;          
		
        
	        if(String.isNotEmpty(bannerConfig.strDepartment))
			{
				for(String s: bannerConfig.strDepartment.split(','))
				{
					setDepartment.add(s.trim().toUpperCase());
				}
			}
                    
	        // check if folderid parameter is present
	        if(String.isNotBlank(bannerConfig.strTargetFolderId))
	        {
	        	Boolean isDeptMatch = false;
	        	if(setDepartment.contains('ALL DEPARTMENTS') && strDeptId !='')
	        		isDeptMatch = true;
				else if(strDeptId =='All' && new Set<String>(mapDeptIdToDeptName.values()).removeAll(setDepartment))
					isDeptMatch = true;
				else if(String.isNotBlank(strDeptId) && setDepartment.contains(mapDeptIdToDeptName.get(strDeptId)))
					isDeptMatch = true;
					
	            ///create a list of documents inner class values
	            if(!isDepartmentWidgetExist || (String.isBlank(strDeptId) && setDepartment.isEmpty()) || (!setDepartment.isEmpty() && isDeptMatch))
	            {   
	                lstDocumentToDisplay = [Select Name, Id,Description, folderid From Document where folderid=:bannerConfig.strTargetFolderId AND (Type ='jpeg' OR Type ='jpg' OR Type='png' OR Type='gif') ORDER BY Name];
	                if(!lstDocumentToDisplay.isEmpty())
	                {
	                   bannerConfig.showBanner = true;
	                }
	            }
	            else
	            {
	                bannerConfig.showBanner = false;
	            }
	            
	        }
        }
        // call method to create a map of widget name to width
        getWidgetWidth();
    }
    /* End : fetchBannerData */
    
    /* @Name           - getWidgetWidth
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for getting widget width
    */
    private void getWidgetWidth() 
    {
        // create a map to store widget width
        Map<String,Map<String,Decimal>> mapMaxWidthValues  = new Map<String,Map<String,Decimal>>{'3 Column Layout Page' => 
                                                                                                  new Map<String, Decimal>{'LeftSideBar'=> 232,'MainSection' => 468,
                                                                                                   'BannerRegion' => 998, 'RightSideBar' => 232},
                                                                                                  '2 Column Layout Right Main Page' =>
                                                                                                  new Map<String, Decimal>{'MainSection' => 732, 'LeftSideBar' => 232,
                                                                                                  'BannerRegion' => 998},
                                                                                                  '2 Column Layout Left Main Page' =>
                                                                                                  new Map<String, Decimal>{'MainSection' => 732, 'RightSideBar' => 232,
                                                                                                  'BannerRegion' => 998},
                                                                                                  '2 Column Layout Half Page' =>
                                                                                                  new Map<String, Decimal>{'LeftSideBar' => 482 ,'RightSideBar' => 482,
                                                                                                  'BannerRegion' => 998},
                                                                                                  '1 Column Layout Page' => 
                                                                                                  new Map<String, Decimal>{'MainSection' => 979, 'BannerRegion' => 979}};
       
        //check if page paramter is present in URL
        if(String.isNotBlank(strPageName))
        {
         
            for(PageRegionWidget__c objPageRegionWidget:[   Select Name,Page_Region__r.Region__r.Name, Page_Region__r.Page__r.Name, Page_Region__r.Page__r.LayoutType__c
                                                            FROM   PageRegionWidget__c 
                                                            WHERE Widget__r.Type__c =: 'SL_IntranetBanner' 
                                                            AND Name =: Id
                                                        ])
            {
                bannerConfig.decMaxWidth = mapMaxWidthValues.get(objPageRegionWidget.Page_Region__r.Page__r.LayoutType__c).get(objPageRegionWidget.Page_Region__r.Region__r.Name);
            }

        }
        
    }
    
    public void getFilteredByDepartment()
    {
        fetchBannerData();
    }
    
    
    /* @Name           - newComponent
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for creating Component dynamically. 
    */
    public override ApexPages.Component newComponent() 
    {
        Component.c.SL_IntranetBanner c = new Component.c.SL_IntranetBanner();   
        c.aComponentImpl = this;
        
        return c;
    }
    /* End : newComponent */
 }