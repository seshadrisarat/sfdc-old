/**
* @ClassName    : SL_IntranetLayoutEditorController
* @JIRATicket   : Socint-183
* @CreatedOn    : 2/Sep/13
* @ModifiedBy   : Anil 
* @Description  : This class is used for addition/removal of widgets and also for ordering of widget configuration.
*/

/**
@ Anil Kumar
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

global with sharing class SL_IntranetLayoutEditorController 
{
    public Map<String, String> jsonMapRegionToExistingWidget {get; set;} //Storing JSON data for existing widget corresponding to each region of current page
    public Map<String, String> mapDefaultWidgetConfiguration {get; set;}    //Used to store default widget configuration
    public Map<String, String> mapWidgetDescription {get; private set;} //Used to store widget's description
    public String strCurrentPage {get; set;}    //Used to store current page name.
    public String strCurrentPageLayout {get; set;}   //Used to store current page layout name.  
    public String strAllPages {get; private set;}   //String format of all available pages to use it for preparing an array of pages on page 
    public String jsonAllWidgets {get; set;}    //Used to store JSON format of all available widgets
    public String jsonAllLayouts {get; private set;}    //JSON data for all layouts
    public String jsonAllPages {get; private set;}  //JSON data for all available pages.
    
    
    //------Start------varibale used for custom setting page 
	
    
    public List<FieldDescribeResult> lstCustomSettingField		 			{	get;set;	}	//List to hold all custom setting fields wrapper object
	public SL_CustomizableComponent__c customSetting						{	get;set;	}	// custom setting object contains its field values
	public List<SelectOption> lstDocumentFolder								{	get;set;	} //To store all folder name of document
	public String strFolderId												{	get;set;	} //string to hold folder id value
	public Map<String, List<Document>> mapFolderToListDocument				{	get;set;	} //map of folder id to list of doucment stored inside that folder
	
	public List<SelectOption> lstFontSize									{	get;set;	} //To store font size
	public List<SelectOption> lstFontFamily									{	get;set;	} //To store font family
 	// To store help text of respective fields, which will be used to show description in description section of footer panel
	public Map<String, String> mapFieldNameToHelpText									{	get;set;	}
	private Set<String> setAllowedType = new Set<String>{'jpg','png','gif'};      				// allowed file type to be display for logo selection
	
	private List<String> lstAllowedFontSize = new List<String>{'8px', '9px', '10px', 
																'11px', '12px', '13px', '14px', '15px', '16px',
															 	'17px', '18px', '19px', '20px', '21px', '22px'}; // Set of font size to be displayed
															 	
	private List<String> lstAllowedFontFamily = new List<String>{'Arial', 'Book Antiqua', 'Verdana', 
																	'Times New Roman', 'Georgia', 'Tahoma', 'Lucida Sans Unicode', 
																	'Courier New' ,'Lucida Console'};		// Set of font family to be displayed
	
	private List<String> lstCustomSettingFieldNames  = new List<String>
														{	'ShowChat', 
	        												'Default Font Family', 'Default Font Size', 'Default Font Color',
	        												'Main Background Color', 'Header Background Color', 'Header Text Color',
	        												'Footer Background Color', 'Footer Text Color',
	        												'Page Headings Color', 'Page Headings Font Size', 'Page Headings Font Family',
	        												'Page Records Color', 'Page Records Font Size', 'Page Records Font Family',
	        												'Top Bar Background Color', 'Selected Group Color', 'Featured Group Highlight Color'
	        											};
	
	private Map<String, FieldDescribeResult> mapCustomSettingsFields ; //map of fieldName to field object
	
    
    //------END------varibale used for custom setting page
    
    // List of all regions (14)
    private static List<String> lstAllRegions = new List<String> 
    {
        'HeaderUserInfo',
        'HeaderLogoSection',
        'HeaderNavigationSection',
        'BannerRegion',
        'LeftSideBar',
        'MainSection',
        'RightSideBar',
        'FooterSection',
        'MobileMainSection',
        'LeftMainSection',
        'RightMainSection',
        'LeftHalfSection',
        'RightHalfSection',
        'MainFullSection'
    };
    
    // Map for extra Regions based on layouts
    private static Map<String, Map<String, String>> mapSubRegions = new Map<String, Map<String, String>> 
    {
        '2 Column Layout Right Main Page' => new Map<String, String> {'MainSection' => 'RightMainSection'},
        '2 Column Layout Left Main Page' => new Map<String, String> {'MainSection' => 'LeftMainSection'},
        '2 Column Layout Half Page' => new Map<String, String> {'LeftSideBar' => 'LeftHalfSection', 
                                                                'RightSideBar' => 'RightHalfSection'},
        '1 Column Layout Page' => new Map<String, String> {'MainSection' => 'MainFullSection'}
    };
    
    
    /* 
    * Inner class for binding JSON data for all available widgets
    */
    public class widget
    {
        public String name {get; set;}
        public String widgetId {get; set;}
        public String regions {get; set;}
        public String widgetType {get; set;}
        public Boolean isDesktop {get; set;}
        public Boolean isMobile {get; set;}
    } 
    
    
    /* 
    * Inner class for binding JSON data for existing widget information
    */
    public class widgetInstance
    {
        public String name {get; set;}
        public String widgetId {get; set;}
        public String widgetType {get; set;}
    }
    
    
    /* 
    * Inner class for binding JSON data for all pages and all layouts
    */
    public class dataStore
    {
        public String name {get; set;}
        public String abbr {get; set;}
    }
    
    
    /* 
    * Constructor calling
    */
    public SL_IntranetLayoutEditorController()
    {
        initializeVariables();  //Initializing all the local and global variables
        
        List<widget> lstAllWidgets = new List<widget>();    //Temporary list of widget for converting it into JSON
        
        for(Widget__c objWidget : SL_IntranetLayoutEditorController.getListAllWidgets())
        {   
            // Creating a map for storing default widget configuration
            mapDefaultWidgetConfiguration.put(objWidget.Id, formatConfigurationHelper(objWidget.Configuration__c));
            
            //Creating map for storing widget's information
            mapWidgetDescription.put(objWidget.Type__c, objWidget.Description__c != null ? objWidget.Description__c : 'No Information Available');
                        
            // Creating inner class object and adding to list for creating JSON format of all widgets
            widget oWidget = new widget();
            oWidget.name = objWidget.Name;
            oWidget.widgetId = objWidget.Id;
            oWidget.regions = objWidget.Regions__c;
            oWidget.widgetType = objWidget.Type__c;
            oWidget.isDesktop = objWidget.isDesktop__c;
            oWidget.isMobile = objWidget.isMobile__c;
            lstAllWidgets.add(oWidget);
        }
        
        // Create JSON format of all available widgets
        jsonAllWidgets = JSON.serialize(lstAllWidgets);
        
        lstAllWidgets = new List<widget>();
        
        //Temporary list of all Pages for converting it into JSON
        List<dataStore> lstAllPages = new List<dataStore>();
        
        //Query all page records for select page picklist value of editor page.
        for(Page__c objPage : [ SELECT Id, Name, LayoutType__c, Order__c 
                                        FROM Page__c WHERE Name != null
                                        ORDER BY Name])
        {
            dataStore oDataStore = new dataStore();
            oDataStore.name = objPage.name;
            oDataStore.abbr = objPage.name;
            lstAllPages.add(oDataStore);
            
            strAllPages += objPage.Name + ';' ;
        }
        
        strAllPages = (strAllPages.length() > 0) ? strAllPages.substring(0, strAllPages.length() - 1) : strAllPages;
        
        // Create JSON format of all available pages
        jsonAllPages = JSON.serialize(lstAllPages);
        
        //Loading existing widgets for the current page.
        loadExistingWidgets(); 
        
        
       	//-------------START------Code section to display Custom setting page view
        try
        {
        	lstFontSize = new List<SelectOption>();
        	lstFontFamily = new List<SelectOption>();
        	lstDocumentFolder = new List<SelectOption>();
        	mapCustomSettingsFields = new Map<String, FieldDescribeResult>();
        	lstCustomSettingField = new List<FieldDescribeResult>();

			mapFieldNameToHelpText = new Map<String, String>();
			mapFolderToListDocument = new Map<String, List<Document>>(); 
			
        	Set<String> setNotToInclude = new Set<String>{'Updated Static Resource Name', 'Navigation Bar Font Color', 'Navigation Bar Color', 'Navigation Bar Selected Color', 'Logo', 'Default'};
        	Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SL_CustomizableComponent__c.fields.getMap();
			for(Schema.SObjectField sobj : fieldMap.values())
			{
				Schema.DescribeFieldResult fieldResult = sobj.getDescribe();
				String helpText = fieldResult.getInlineHelpText() != null ? fieldResult.getInlineHelpText() :'';
				mapFieldNameToHelpText.put(fieldResult.getName(), helpText);
				//adding custom setting field to list in wrapper class obejct
				if(fieldResult.isCustom() && !setNotToInclude.contains(fieldResult.getLabel()) )
					mapCustomSettingsFields.put(fieldResult.getLabel(), new FieldDescribeResult( fieldResult ));
			}
			
			for(String field :lstCustomSettingFieldNames)
			{
				lstCustomSettingField.add(mapCustomSettingsFields.get(field));
			}
			
			for(Folder objFolder : [SELECT DeveloperName, Id, Name FROM Folder WHERE Type='Document' AND AccessType ='Public' ORDER by Name])
			{
				lstDocumentFolder.add(new SelectOption(objFolder.Id, objFolder.Name));
				mapFolderToListDocument.put(objFolder.Id, new List<Document>());
			}
			
			for(Document objDoc : [SELECT FolderId,Id,IsPublic,DeveloperName,  Name FROM Document where FolderId IN :mapFolderToListDocument.keyset() AND IsPublic = true AND Type IN :setAllowedType])
				mapFolderToListDocument.get(objDoc.FolderId).add(objDoc);
			
			strFolderId = lstDocumentFolder[0].getValue();
			
			customSetting = SL_CustomizableComponent__c.getOrgDefaults(); 
			
			if(String.isNotBlank(customSetting.Logo__c))
				strFolderId = [Select Id,FolderId,DeveloperName, Name from Document where Id =: customSetting.Logo__c limit 1][0].FolderId;
			
			lstFontSize.add(new SelectOption('', '--None--'));
			for(String fontSize : lstAllowedFontSize)
				lstFontSize.add(new SelectOption(fontSize, fontSize));
			
			lstFontFamily.add(new SelectOption('', '--None--'));
			for(String FontFamily : lstAllowedFontFamily)	
				lstFontFamily.add(new SelectOption(FontFamily, FontFamily));
			
        }
        catch(Exception ex)
        {
        	system.debug('::::exception::'+ex);
        }
        
        //-------------END------Code section to display Custom setting page view
    }
    
    
    /* 
    * Initializing all the local and global variables
    */
    private void initializeVariables()
    {   
        jsonMapRegionToExistingWidget = new Map<String, String>();
        mapDefaultWidgetConfiguration = new Map<String, String>();  
        mapWidgetDescription = new Map<String, String>();       
        strAllPages = '';
        jsonAllWidgets = '';    
        jsonAllLayouts = '';
        jsonAllPages = '';
        
        strCurrentPage = Apexpages.currentPage().getParameters().get('page');
        
        //Preparing Temporary list of all layouts for converting it into JSON
        List<String> lstLayoutsTemp = new List<String>
        {
            '3 Column Layout Page', 
            '2 Column Layout Right Main Page',
            '2 Column Layout Left Main Page',
            '2 Column Layout Half Page',
            '1 Column Layout Page'
        };
        
        //Temporary list of all layouts binded with inner class for converting it into JSON
        List<dataStore> lstLayouts = new List<dataStore>();
        for(String strObj : lstLayoutsTemp)
        {
            dataStore oDataStore = new dataStore();
            oDataStore.name = strObj;
            oDataStore.abbr = strObj;
            lstLayouts.add(oDataStore);
        }
        
        // Create JSON format of all Layouts
        jsonAllLayouts = JSON.serialize(lstLayouts);
    }
    
    
    /*
    	Wrapper class to create a object , has field Name and field Label
    */
    
    public class FieldDescribeResult
    {
    	public String fName 	{get;set;}
    	public String fLabel	{get;set;}
    	public Boolean isDefault {get;set;}
    	public FieldDescribeResult(Schema.DescribeFieldResult fieldResult )
    	{
    		this.fLabel = fieldResult.getLabel();
    		this.fName = fieldResult.getName(); 
    		this.isDefault = fieldResult.isDefaultedOnCreate();
    	}
    }
    
    /* ----START  Method: updateSetting -----/
    Method Name: updateSetting
    Parameter : None
    Return type: void
    Purpose: To update custom setting value
    */
    
    public void updateSetting()
	{
	 	update customSetting;
	}
    
    /* ----START  Method: updateSetting ------*/
    
    
    /* 
    * Loading existing widgets for the current page.
    */
    private void loadExistingWidgets()
    {
        strCurrentPageLayout = '3 Column Layout Page';  //Default selected layout for page.
        Map<String, String> mapSubRegion = new Map<String, String>();   // Map for replacing extra considered region with original regions
        
        // Getting layout type for current page
        for(Page__c objPage : [ SELECT Id, Name, LayoutType__c, Order__c 
                                        FROM Page__c 
                                        WHERE Name =: strCurrentPage LIMIT 1])
        {
            strCurrentPageLayout = objPage.LayoutType__c;
        }
        
        //getting corresponding map of extra defined regions for the current layout
        mapSubRegion = mapSubRegions.containskey(strCurrentPageLayout) ? mapSubRegions.get(strCurrentPageLayout) : new Map<String, String>();
        
        //Map for storing list of widgets corresponding to each region of page
        Map<String, List<widgetInstance>> mapRegionToAllWidgets = new Map<String, List<widgetInstance>>();  
        
        for(PageRegionWidget__c objPRW : WidgetRepository.getWidgetsRegionDataByPage(strCurrentPage, null))
        {
            // Creating a map for storing default widget configuration
            mapDefaultWidgetConfiguration.put(objPRW.Id, formatConfigurationHelper(objPRW.Configuration__c));
            
            String strKey = mapSubRegion.containskey(objPRW.Page_Region__r.Region__r.Name) 
                    ? mapSubRegion.get(objPRW.Page_Region__r.Region__r.Name) : objPRW.Page_Region__r.Region__r.Name;
            
            widgetInstance oWidgetInstance = new widgetInstance();
            oWidgetInstance.name = objPRW.Widget__r.Name;
            oWidgetInstance.widgetId = objPRW.Id;
            oWidgetInstance.widgetType = objPRW.Widget__r.Type__c;
            
            if(!mapRegionToAllWidgets.containskey(strKey))
                mapRegionToAllWidgets.put(strKey, new List<widgetInstance>{oWidgetInstance});
            else
                mapRegionToAllWidgets.get(strKey).add(oWidgetInstance);
        }
        
        //adding missing regions to map to avoid de-reference null pointer
        for(String strPR : lstAllRegions)
        {
            if(!mapRegionToAllWidgets.containskey(strPR))
                mapRegionToAllWidgets.put(strPR, new List<widgetInstance>());   
        }
        
        //creating JSON data and adding it to map with corresponding key region
        for(String strObj : mapRegionToAllWidgets.keySet())
        {
            jsonMapRegionToExistingWidget.put(strObj, JSON.serialize(mapRegionToAllWidgets.get(strObj)));
        }
    }
    
    
    /*
    * Loads all available widgets indexed by widgets' Type
    */
    public static Map<String, Widget__c> getMapAllWidgets() 
    {
        Map<String, Widget__c> m = new Map<String, Widget__c>();
        
        for(Widget__c widget : [    SELECT Name, Type__c, Description__c, Configuration__c, Regions__c 
                                        FROM Widget__c 
                                        WHERE Type__c != NULL
                                        ORDER BY Name ]) 
        {
            m.put(widget.Type__c, widget);
        }
        
        return m;
    }
    
    
    /*
    * Loads all available widgets in order by Name for displaying in available widget section
    */
    public static List<Widget__c> getListAllWidgets() 
    {
        List<Widget__c> lstW = new List<Widget__c>();
        
        for(Widget__c widget : [    
        	SELECT Name, Type__c, Description__c, Configuration__c, Regions__c, IsDesktop__c, isMobile__c 
                                        FROM Widget__c 
                                        WHERE Type__c != NULL
                                        ORDER BY Name ]) 
        {
            lstW.add(widget);
        }
        
        return lstW;
    }
    
    
    /*
    * Removing new line character from widget configuration part 
    */
    private String formatConfigurationHelper(String config) 
    {
        return config != null ? Utilities.removeNewLines(config) : 'null';          
    }
    
    
    /* 
    * Saving widget configuration
    */  
    @RemoteAction
    global static String saveWidgetConfigurations(String configurationJSON, String nPage, String oPage, Boolean isRedirectHome, String tabName, String tabViewed) 
    {   
        Integer intId = 0;  
        Map<String, Widget__c> mapWidgetTypeToWidget = SL_IntranetLayoutEditorController.getMapAllWidgets();    //Used to identify widget object records through widget Type.
        Map<String, Integer> mapWidgetOrder = new Map<String, Integer>(); // Map for Storing order of widgets
        Map<String, PageRegion__c> mapRegionNameToPageRegion = new Map<String, PageRegion__c>(); // Used to identify PageRegion record based on region name.                
        List<PageRegionWidget__c> pageWidgetsInstances = WidgetRepository.getWidgetsRegionDataByPage(oPage, null); // all widget's instances presented on the page        
        List<PageRegionWidget__c> lstPageRegionWidget_UPSERT = new List<PageRegionWidget__c>(); // Used to insert/update PageRegionWidget records in case of newly added widget or updated existing widgets     
        Set<Id> setExistingPageRegionWidgetIds = new Set<Id>(); // Used to store existing PageRegionWidget id to avoid deletion of these records after change in configuration.
        
        //creating map of all Regions corresponding to current page 
        for(PageRegion__c objPageRegion : [ SELECT Id, Page__c, Page__r.Name, Region__c, Region__r.Name 
                                                    FROM PageRegion__c 
                                                    WHERE Page__r.Name =: oPage])
        {
            mapRegionNameToPageRegion.put(objPageRegion.Region__r.Name, objPageRegion); 
        }
        
        //Map for certain regions which will replace extra considered region to original region while saving widget configuration
        Map<String, String> mapSubRegionsTemp = new Map<String, String> {
            'LeftMainSection' => 'MainSection',
            'LeftHalfSection' => 'LeftSideBar',
            'RightMainSection' => 'MainSection',
            'RightHalfSection' => 'RightSideBar',
            'MainFullSection' => 'MainSection'
        };  
        
        if(configurationJSON != '')
        {
            List<widgetInstance> lstWidgetConfigurationJSON = new List<widgetInstance>();
            lstWidgetConfigurationJSON = (List<widgetInstance>) JSON.deserialize(configurationJSON, List<widgetInstance>.class);
            
            for(widgetInstance strObj : lstWidgetConfigurationJSON)
            {
                String strKey = strObj.name;
                strKey = mapSubRegionsTemp.containsKey(strKey.trim()) ? mapSubRegionsTemp.get(strKey.trim()) : strKey;
                
                mapWidgetOrder.put(strKey, !mapWidgetOrder.containskey(strKey) ? 1 : mapWidgetOrder.get(strKey) + 1);
                
                PageRegionWidget__c objPageRegionWidget;
                
                if(strObj.widgetId == 'null')
                {   
                    objPageRegionWidget = new PageRegionWidget__c();
                    objPageRegionWidget.Widget__c = mapWidgetTypeToWidget.get(strObj.widgetType).Id;
                    objPageRegionWidget.Configuration__c = mapWidgetTypeToWidget.get(strObj.widgetType).Configuration__c;
                    objPageRegionWidget.Page_Region__c = mapRegionNameToPageRegion.get(strKey).Id;
                    objPageRegionWidget.Order__c = mapWidgetOrder.get(strKey);  
                    lstPageRegionWidget_UPSERT.add(objPageRegionWidget);
                }
                else
                {
                    objPageRegionWidget = new PageRegionWidget__c(Id = strObj.widgetId);
                    objPageRegionWidget.Order__c = mapWidgetOrder.get(strKey);                      
                    lstPageRegionWidget_UPSERT.add(objPageRegionWidget);
                    setExistingPageRegionWidgetIds.add(strObj.widgetId);
                }
            }
        }
        
        List<PageRegionWidget__c> lstPageRegionWidget_DELETE_Temp = new List<PageRegionWidget__c>();
        
        //Preparing list of all PageRegionWidget records that is removed from the layout editor page for respective page
        for(PageRegionWidget__c widgetInstanceData : pageWidgetsInstances)
        {
            if((!setExistingPageRegionWidgetIds.contains(widgetInstanceData.Id) 
                &&  (   
                        (widgetInstanceData.Page_Region__r.Region__r.Name != 'MobileMainSection' && tabName == '#Desktop')
                    ||  (widgetInstanceData.Page_Region__r.Region__r.Name == 'MobileMainSection' && tabName == '#Mobile')
                    ||  tabViewed == 'All'
                    )
                ))
            {
                lstPageRegionWidget_DELETE_Temp.add(widgetInstanceData);
            }
        }
        
        // Deleting corresponding records of Widgets that has been removed from layout
        if(!lstPageRegionWidget_DELETE_Temp.isEmpty()) delete lstPageRegionWidget_DELETE_Temp;
        
        // Inserting corresponding records of newly added Widgets and updating existing records of corresponding widgets
        if(!lstPageRegionWidget_UPSERT.isEmpty()) upsert lstPageRegionWidget_UPSERT;        
                
        // If it is redirecting back to Application corresponding page
        // else redirecting to selected page configuration
        return isRedirectHome ?
            '/apex/SL_Intranet?page=' + EncodingUtil.urlEncode(nPage, 'UTF-8')
             + (nPage == 'Employee Profile' ? '&id=' + UserInfo.getUserId() : '') : 
            '/apex/SL_IntranetLayoutEditor?page=' + EncodingUtil.urlEncode(nPage, 'UTF-8') + tabName;
    }
    
    
    /* 
    * Creating new page from Layout editor and also creating respective PageRegion records.
    */
    @RemoteAction
    global static String createNewPage(String pageName, String layoutName, String tabName)
    {
        List<PageRegion__c> lstPageRegionToBeInsert = new List<PageRegion__c>();    //List of new PageRegion records that will be created for new page.
        List<PageRegionWidget__c> lstPageRegionWidgetToInsert = new List<PageRegionWidget__c>();    //List of default PageRegionWidget records that will be created for new page.
        Map<String, PageRegion__c> mapRegionToPageRegion = new Map<String, PageRegion__c>();    // Used to get PageRegion records for certain region where we place default widget
        
        //Inserting new page records
        Page__c objPage = new Page__c(Name = pageName, LayoutType__c = layoutName);
        insert objPage;
        
        //Creating a list of PageRegion records for newly created page and each available regions.
        for(Region__c objRegion : [SELECT Id, Name from Region__c WHERE Name != null] )
        {
            PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.Id, Region__c = objRegion.Id);
            lstPageRegionToBeInsert.add(objPageRegion);
        }
        
        //Inserting PageRegion records
        if(!lstPageRegionToBeInsert.isEmpty())
            insert lstPageRegionToBeInsert;
        
        //Creating map for certain region to PageRegion Records for placing default widget in certain region of newly created page.
        for(PageRegion__c objPageRegion : [ SELECT Id, Page__c, Page__r.Name, Region__c, Region__r.Name 
                                                    FROM PageRegion__c 
                                                    WHERE Page__r.Name =: pageName
                                                    AND (Region__r.Name = 'HeaderUserInfo' OR Region__r.Name = 'HeaderNavigationSection')])
        {
            mapRegionToPageRegion.put(objPageRegion.Region__r.Name, objPageRegion);
        }
        
        //Query from widget and creating PageRegionWidget records for particular region of newly created page
        for(Widget__c objWidget : [ SELECT Name, Type__c, Description__c, Configuration__c, Regions__c 
                                            FROM Widget__c 
                                            WHERE (Type__c = 'SL_IntranetUserInfo' OR Type__c = 'SL_IntranetNavigationBar')])
        {
            PageRegionWidget__c objPREW = new PageRegionWidget__c(Widget__c = objWidget.Id, Order__c = 1, Configuration__c = objWidget.Configuration__c);
            //Creating record for HeaderUserInfo region
            if(objWidget.Type__c == 'SL_IntranetUserInfo' && mapRegionToPageRegion.containskey('HeaderUserInfo'))
                objPREW.Page_Region__c = mapRegionToPageRegion.get('HeaderUserInfo').Id;
            //Creating record for Navigation region
            else if(objWidget.Type__c == 'SL_IntranetNavigationBar' && mapRegionToPageRegion.containskey('HeaderNavigationSection'))
                objPREW.Page_Region__c = mapRegionToPageRegion.get('HeaderNavigationSection').Id;
            
            lstPageRegionWidgetToInsert.add(objPREW);
        }
        
        //Creating PageRegionWidget records.
        if(!lstPageRegionWidgetToInsert.isEmpty())
            insert lstPageRegionWidgetToInsert;
        
        //After creating all records, redirecting to newly created page for configuration.
        return '/apex/SL_IntranetLayoutEditor?page='+ EncodingUtil.urlEncode(pageName, 'UTF-8') + tabName;    
    }
    
    
    /* 
    * Editing page name from Layout editor.
    */
    @RemoteAction
    global static String editPageName(String newPageName, String oldPageName, String tabName)
    {
        if(newPageName != null && newPageName != '')    //If updated page name is not blank then update corresponding page name record.
        {
            Page__c objPage = [SELECT Id, Name FROM Page__c WHERE Name = : oldPageName]; //Query Page record
            objPage.Name = newPageName; //Updating page name with updated page name.
            update objPage;
        }   
        
        //After updating, redirecting to updated page for configuration.
        return '/apex/SL_IntranetLayoutEditor?page='+EncodingUtil.urlEncode(newPageName, 'UTF-8') + tabName;     
    }
    
    
    /* 
    * Deleting existing page from application and also deleting respective PageRegion records.
    */
    @RemoteAction
    global static String deleteExistingPage(String currentPageName)
    {
        List<PageRegionWidget__c> lstPRWToBeDelete = new List<PageRegionWidget__c>();   //List of existing PageRegionWidget records that will be deleted for selected page.
        
        //Query all PageRegionWidget records which we need to delete after deletion of Page record.
        lstPRWToBeDelete = [SELECT Id FROM PageRegionWidget__c WHERE Page_Region__r.Page__r.Name =: currentPageName]; 
        
        //Deleting all PageRegionWidget records related to ccurrent page records
        if(!lstPRWToBeDelete.isEmpty())
            delete lstPRWToBeDelete;
            
        //Deleting selected page records
        Page__c objPage = [SELECT Id from Page__c where Name =: currentPageName];
        delete objPage;
        
        //After deleting page record, redirecting to Intranet Home page.
        return '/apex/SL_Intranet?page=Home';   
    }
    
    
    /*
    * Updating widget configuration of selected widget or widget instance
    * widgetContextId - whether widget Id or widgetInstance Id
    */  
    @RemoteAction
    global static void updateWidgetConfiguration(String widgetContextId, String widgetContextType, String configurationJSON) 
    {
        if(widgetContextType == 'Widget')
        {
            Widget__c w = [SELECT Configuration__c FROM Widget__c WHERE Id=:widgetContextId];           
            w.Configuration__c = configurationJSON;
            update w;
        }
        else if(widgetContextType == 'PageRegionWidget')
        {
            PageRegionWidget__c w = [SELECT Configuration__c FROM PageRegionWidget__c WHERE Id=:widgetContextId];
            w.Configuration__c = configurationJSON;
            update w;
        }       
        else throw new InvalidArgumentException('Invalid widget context type: ' + widgetContextType);
    }
}