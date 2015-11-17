/**
* @ClassName    : SL_IntranetContentTypes 
* @JIRATicket   : Socint-194
* @CreatedOn    : 24/June/13
* @ModifiedBy   : Pravin 
* @Description  : This is the Implementation class of SL_IntranetContentTypesController Controller.
*/

/**
@ Pravin Sapkal 
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
 


public with sharing class SL_IntranetContentTypes extends WidgetAbstract implements IObservable 
{	
	public List<String> lstContentTypes {get; set;}
	public Map<String, List<String>> mapContentTypesToLstFirstLevelCatg {get;set;}
	public Map<String, List<String>> mapFirstLevelCatgIdToLstSecondLevelCatg {get;set;}
	public Map<String, List<String>> mapSecondLevelCatgIdToLstThirdLevelCatg {get;set;}
	
	public String contentTypesToFirstLevelcategories {get; set;} 
	public String firstLevelToSecondLevelcategories {get;set;}
	public String secondLevelToThirdLevelcategories {get;set;} 
	
	private String documentType;
	private List<String> lstContentType = new List<String>();
	private Set<String> stContentTypes = new Set<String>();
	private Set<String> setLoggedinUserOfficesId = new Set<String>();
	private Boolean notToUseThisContentTypeList; 
	private Boolean isDepartmentWidgetExist; //To identify if Department widget exist on page or not to decide the behavior based on that. 
	
	/* Variables for mobile view */
	public String strFirstLevel {get; set;}
	public String strSecondLevel {get; set;}
	public String strThirdLevel {get; set;}
	public List<String> lstFirstLevelCategory {get;set;}
	public List<String> lstSecondLevelCategory {get;set;}
	public List<String> lstThirdLevelCategory {get;set;}
	public String strDeptId {get;set;}
	public String strContentIds {get;set;}
	/* Variables for mobile view */
	
	
	/* Start : Constructor initialization */
	public SL_IntranetContentTypes()
	{
		this.initializeVariables();
		
		User objUser = [Select Id, Selected_Offices_Ids__c, Name from User where Id = :UserInfo.getUserId() limit 1];
		if( objUser.Selected_Offices_Ids__c != null && objUser.Selected_Offices_Ids__c != '')
			setLoggedinUserOfficesId.addAll(objUser.Selected_Offices_Ids__c.split(';'));
		
		isDepartmentWidgetExist = false;
		//To get all the Content types allowed for logged in User on load of page
		getContentTypes();
		
		// listen for department widget dependancy
		WidgetConfigurationListener.getInstance().addEventListener('SL_IntranetDepartments', this); 
	}
	/* End : Constructor initialization */
	
	
	/* @Name           - initialize
	   @Parameters     - None 
	   @Return Type    - Void
	   @Description    - Function for initializing all local and global variables
	*/
	private void initializeVariables()
	{
		lstContentTypes = new List<String>();
		mapContentTypesToLstFirstLevelCatg = new Map<String, List<String>>(); 
		mapFirstLevelCatgIdToLstSecondLevelCatg = new Map<String, List<String>>();
		mapSecondLevelCatgIdToLstThirdLevelCatg = new Map<String, List<String>>();
		
		strDeptId = strContentIds = '';
		contentTypesToFirstLevelcategories = '';
		firstLevelToSecondLevelcategories = '';
	    secondLevelToThirdLevelcategories = '';
		
		documentType = '';
		lstContentType = new List<String>();
		stContentTypes = new Set<String>();
		setLoggedinUserOfficesId = new Set<String>();
		
		strFirstLevel = '';
		strSecondLevel = '';
		strThirdLevel = '';
		lstFirstLevelCategory = new List<String>();
		lstSecondLevelCategory = new List<String>();
		lstThirdLevelCategory = new List<String>();
	}
	/* End : initialize method */
	
	
	/* @Name           - getContentTypes
	   @Parameters     - None 
	   @Return Type    - Void
	   @Description    - Function for getting Content Type allowed for logged in user based on custom setting.
	*/
	public void getContentTypes()
	{
		Id userId = UserInfo.getUserId();
		Id userProfileId = UserInfo.getProfileId();
		List<String> lstContentTypesTemp = new List<String>(); 
		notToUseThisContentTypeList = false;
		
		Map<Id, SL_IntranetDocumentsSetting__c> mapDocumentsSetting = new Map<Id, SL_IntranetDocumentsSetting__c>();
		
		//Content Type picklist field describe
		Schema.DescribeFieldResult fldDescResult = ContentVersion.Content_Types__c.getDescribe();
		List<Schema.PicklistEntry> pickListValues = fldDescResult.getPicklistValues();
		
		for(Schema.PicklistEntry obj : pickListValues)
		{ 
			stContentTypes.add(obj.getValue());
		}
		
		//Getting Content Types allowed for logged in user from OWD. 
		SL_IntranetDocumentsSetting__c owdContentType = SL_IntranetDocumentsSetting__c.getOrgDefaults();
		
		//Getting Content Types allowed for logged in user from User defined or Profile defined hierarchical custom setting and creating a map of them. 
		for(SL_IntranetDocumentsSetting__c objDocument : [SELECT Content_Type__c, SetupOwnerId 
															FROM SL_IntranetDocumentsSetting__c 
															WHERE SetupOwnerId =: userId OR SetupOwnerId =: userProfileId])
		{
			mapDocumentsSetting.put(objDocument.SetupOwnerId, objDocument);
		}
		
		if(mapDocumentsSetting != null && mapDocumentsSetting.containskey(userId) && mapDocumentsSetting.get(userId).Content_Type__c != null && mapDocumentsSetting.get(userId).Content_Type__c != '')
			lstContentTypesTemp = mapDocumentsSetting.get(userId).Content_Type__c.split(',');
		else if(mapDocumentsSetting != null && mapDocumentsSetting.containskey(userProfileId) && mapDocumentsSetting.get(userProfileId).Content_Type__c != null && mapDocumentsSetting.get(userProfileId).Content_Type__c != '')
			lstContentTypesTemp = mapDocumentsSetting.get(userProfileId).Content_Type__c.split(',');
		else if(owdContentType != null && owdContentType.Content_Type__c != null && owdContentType.Content_Type__c != '')
			lstContentTypesTemp = owdContentType.Content_Type__c.split(',');
		else
		{
			lstContentTypesTemp.addAll(stContentTypes);
			notToUseThisContentTypeList = true;
		}	
			
		for(String objStr : lstContentTypesTemp)
		{
			String strTemp = objStr.trim();
			if(stContentTypes.contains(strTemp))
				lstContentType.add(strTemp);
		}
		
		stContentTypes = new Set<String>();
		
		//Setting default document type on load of page 
		if(lstContentType.size() > 0)
		{
			documentType = lstContentType[0];
			stContentTypes.addAll(lstContentType);
		}
		
	}
	/* End : getContentTypes method */
	
	public void notify(IWidget widget) {
		if(widget == null) return;
			
		SL_IntranetDepartments departmentWidget = (SL_IntranetDepartments)widget;
		
		strDeptId = departmentWidget.strInitialDeptSelection;
		isDepartmentWidgetExist = true;
		System.debug('SL_DEBUG: System set department from configuration: ' + strDeptId);
	}
	
	
	/* Start - Method for creating hierarchy of content type for left side bar
	   @Name           - getLeftSidebarContents
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for creating hierarchy of content type for left side bar
	*/
	public void getLeftSidebarContents()
	{
		lstContentTypes = new List<String>();
		//lstContentTypes.addAll(lstContentType);
		
		lstFirstLevelCategory = new List<String>();

		mapFirstLevelCatgIdToLstSecondLevelCatg = new Map<String, List<String>>();
		mapSecondLevelCatgIdToLstThirdLevelCatg = new Map<String, List<String>>();
		Set<String> setContentTypes = new Set<String>();
		
		mapContentTypesToLstFirstLevelCatg = new Map<String, List<String>>(); 
			
		Set<Id> setFirstLevelcategoryIds = new Set<Id>();
		Set<Id> setSecondLevelcategoryIds = new Set<Id>();

		Map<String, Id> mapCategoryHierarchyNameToRelatedContentId = new Map<String, Id>();
		
		
		
		//Creating map for displaying those category level that have atleast one content record 
				
		Set<Id> setContentIds = new Set<Id>();
		
		String strContentQuery = 
			'SELECT Id, Selected_Department_Ids__c, Select_Departments__c, Content_Types__c, Category_Level_1__c, Category_Level_2__c, Category_Level_3__c, Select_Offices__c, For_All_Offices__c,For_All_Departments__c, Selected_Offices_Ids__c ' + 
			'FROM ContentVersion WHERE Content_Types__c IN : stContentTypes and IsLatest = true';
		
		//if(strContentIds != '')
		//{
			for(String s : strContentIds.split(';'))
			{
				if(s.trim().length() > 1) 
					setContentIds.add(s.trim());
			}
			strContentQuery += ' AND Id IN: setContentIds'; 
		//}
		
		system.debug('SL_DEBUG: strContentQuery: ' + strContentQuery);
		system.debug('SL_DEBUG: stContentIds: ' + stContentTypes);		
		system.debug('SL_DEBUG: strContentIds: ' + strContentIds);		
		system.debug('SL_DEBUG: strDeptId: ' + strDeptId);
		
		IVisibilitySpecification officesSpec = new OfficesSpecification(setLoggedinUserOfficesId);
		IVisibilitySpecification departmentSpec = new DepartmentSpecification(strDeptId);
		
		Set<String> setContentTypeName = new Set<String>(); //For storing all the content type name in a set
		
		for(ContentVersion objCV : Database.query(strContentQuery))
		{
			if(officesSpec.satisfiedBy(objCV) && (!isDepartmentWidgetExist || departmentSpec.satisfiedBy(objCV)))
			{	
				if(!String.isEmpty(objCV.Content_Types__c))						
					setContentTypes.add(objCV.Content_Types__c);					
				
				if(!String.isEmpty(objCV.Category_Level_1__c))
					mapCategoryHierarchyNameToRelatedContentId.put(objCV.Content_Types__c + '_' + objCV.Category_Level_1__c, objCV.Id);
				if(!String.isEmpty(objCV.Category_Level_2__c))
					mapCategoryHierarchyNameToRelatedContentId.put(objCV.Content_Types__c + '_' + objCV.Category_Level_1__c + '_' + objCV.Category_Level_2__c, objCV.Id);
				if(!String.isEmpty(objCV.Category_Level_3__c))
					mapCategoryHierarchyNameToRelatedContentId.put(objCV.Content_Types__c + '_' + objCV.Category_Level_1__c + '_' + objCV.Category_Level_2__c + '_' + objCV.Category_Level_3__c, objCV.Id);
					
			}		
		}
		
		lstContentTypes.addAll(setContentTypes);
		setContentTypeName.addAll(setContentTypes);
				
		system.debug('SL_DEBUG: mapCategoryHierarchyNameToRelatedContentId: ' + mapCategoryHierarchyNameToRelatedContentId);
			
		Map<String, List<String>> mapContentTypeToFirstLevelDependentCatgs = new Map<String, List<String>>();  /* New One */
		
		Map<String, List<String>> mapFirstLevelCatgToSecondLevelDependentCatgs = new Map<String, List<String>>();
		Map<String, List<String>> mapSecondLevelCatgToThirdLevelDependentCatgs = new Map<String, List<String>>();
	
		system.debug('SL_DEBUG: contentTypesToFirstLevelcategories: ' + contentTypesToFirstLevelcategories );
		
		List<String> lstContentTypeName = new List<String>();//For storing the Content Type Name 
		
		//Creating map for content type to first level of category
		for(String strContentTypeToFirstLevelCategories : contentTypesToFirstLevelcategories.split('@#'))
		{
			lstContentTypeName.add(strContentTypeToFirstLevelCategories.split('::')[0]);
			mapContentTypeToFirstLevelDependentCatgs.put(strContentTypeToFirstLevelCategories.split('::')[0], new List<String>{});
			
			if(strContentTypeToFirstLevelCategories.split('::').size() > 1 && strContentTypeToFirstLevelCategories.split('::')[1] != 'NC' && strContentTypeToFirstLevelCategories.split('::')[1] != '')
				mapContentTypeToFirstLevelDependentCatgs.get(strContentTypeToFirstLevelCategories.split('::')[0]).addAll(strContentTypeToFirstLevelCategories.split('::')[1].split(',,'));
		}
		
		system.debug('SL_DEBUG: mapContentTypeToFirstLevelDependentCatgs: ' + mapContentTypeToFirstLevelDependentCatgs);

		//Creating map for first level category to second level of category
		for(String strFirstLevelToSecondLevelCategories : firstLevelToSecondLevelcategories.split('@#'))
		{
			mapFirstLevelCatgToSecondLevelDependentCatgs.put(strFirstLevelToSecondLevelCategories.split('::')[0], new List<String>{});
			if(strFirstLevelToSecondLevelCategories.split('::').size() > 1 && strFirstLevelToSecondLevelCategories.split('::')[1] != 'NC')
				mapFirstLevelCatgToSecondLevelDependentCatgs.get(strFirstLevelToSecondLevelCategories.split('::')[0]).addAll(strFirstLevelToSecondLevelCategories.split('::')[1].split(',,'));
		}

		//Creating map for second level category to third level of category
		for(String strSecondLevelTothirdLevelCategories : secondLevelToThirdLevelcategories.split('@#'))
		{
			mapSecondLevelCatgToThirdLevelDependentCatgs.put(strSecondLevelTothirdLevelCategories.split('::')[0], new List<String>{});
			if(strSecondLevelTothirdLevelCategories.split('::').size() > 1 && strSecondLevelTothirdLevelCategories.split('::')[1] != 'NC')
				mapSecondLevelCatgToThirdLevelDependentCatgs.get(strSecondLevelTothirdLevelCategories.split('::')[0]).addAll(strSecondLevelTothirdLevelCategories.split('::')[1].split(',,'));
		}
		
		List<String> lstTempContentType = new List<String>();
		if(notToUseThisContentTypeList)
		{
			for(String str : lstContentTypeName)
			{
				if(setContentTypeName.contains(str))
					lstTempContentType.add(str);
			}
			lstContentTypes = lstTempContentType;
		}
		else
		{
			for(String str : lstContentType)
			{
				if(setContentTypeName.contains(str))
					lstTempContentType.add(str);
			} 
			lstContentTypes = lstTempContentType;
		}

		//Inserting the categories ,which all having related contents, into list to display these on the page
		for(String strContentType : lstContentTypes)
		{
			if(mapContentTypeToFirstLevelDependentCatgs.containsKey(strContentType) && !mapContentTypeToFirstLevelDependentCatgs.get(strContentType).isEmpty())
			{
				system.debug('SL_DEBUG: mapContentTypeToFirstLevelDependentCatgs: ' + mapContentTypeToFirstLevelDependentCatgs);
				for(String strFirstLevelCatg : mapContentTypeToFirstLevelDependentCatgs.get(strContentType))
				{
					if(!mapContentTypesToLstFirstLevelCatg.containsKey(strContentType))
						mapContentTypesToLstFirstLevelCatg.put(strContentType, new List<String>());

					if(mapCategoryHierarchyNameToRelatedContentId.containsKey(strContentType + '_' + strFirstLevelCatg))
						mapContentTypesToLstFirstLevelCatg.get(strContentType).add(strFirstLevelCatg);
					
					if(mapFirstLevelCatgToSecondLevelDependentCatgs.containsKey(strFirstLevelCatg) && !mapFirstLevelCatgToSecondLevelDependentCatgs.get(strFirstLevelCatg).isEmpty())
					{
						for(String strSecondLevelCatg : mapFirstLevelCatgToSecondLevelDependentCatgs.get(strFirstLevelCatg))
						{
							if(!mapFirstLevelCatgIdToLstSecondLevelCatg.containsKey(strContentType + '_' + strFirstLevelCatg))
								mapFirstLevelCatgIdToLstSecondLevelCatg.put(strContentType + '_' + strFirstLevelCatg, new List<String>());
	
							if(mapCategoryHierarchyNameToRelatedContentId.containsKey(strContentType + '_' + strFirstLevelCatg + '_' + strSecondLevelCatg))
								mapFirstLevelCatgIdToLstSecondLevelCatg.get(strContentType + '_' + strFirstLevelCatg).add(strSecondLevelCatg);
							
							if(mapSecondLevelCatgToThirdLevelDependentCatgs.containsKey(strSecondLevelCatg) && !mapSecondLevelCatgToThirdLevelDependentCatgs.get(strSecondLevelCatg).isEmpty())
							{
								for(String strThirdLevelCatg : mapSecondLevelCatgToThirdLevelDependentCatgs.get(strSecondLevelCatg))
								{
									if(!mapSecondLevelCatgIdToLstThirdLevelCatg.containsKey(strContentType + '_' + strFirstLevelCatg + '_' + strSecondLevelCatg))
										mapSecondLevelCatgIdToLstThirdLevelCatg.put(strContentType + '_' + strFirstLevelCatg + '_' + strSecondLevelCatg, new list<String>());
	
									if(mapCategoryHierarchyNameToRelatedContentId.containsKey(strContentType + '_' + strFirstLevelCatg + '_' + strSecondLevelCatg + '_' + strThirdLevelCatg))
										mapSecondLevelCatgIdToLstThirdLevelCatg.get(strContentType + '_' + strFirstLevelCatg + '_' + strSecondLevelCatg).add(strThirdLevelCatg);
								}
							}
							else
								mapSecondLevelCatgIdToLstThirdLevelCatg.put(strContentType + '_' + strFirstLevelCatg + '_' + strSecondLevelCatg, new list<String>());
						}
					}
					else
						mapFirstLevelCatgIdToLstSecondLevelCatg.put(strContentType + '_' + strFirstLevelCatg, new List<String>());
				}
			}
			else
			{
				mapContentTypesToLstFirstLevelCatg.put(strContentType, new List<String>());
			}
		}
		
		/** Get List of Category Level for mobile **/
		if(mapContentTypesToLstFirstLevelCatg.containskey(documentType))
			lstFirstLevelCategory.addAll(mapContentTypesToLstFirstLevelCatg.get(documentType));
		if(mapFirstLevelCatgIdToLstSecondLevelCatg.containsKey(documentType + '_' + strFirstLevel))
			lstSecondLevelCategory.addAll(mapFirstLevelCatgIdToLstSecondLevelCatg.get(documentType + '_' + strFirstLevel));
		if(mapSecondLevelCatgIdToLstThirdLevelCatg.containsKey(documentType + '_' + strFirstLevel + '_' + strSecondLevel))
			lstThirdLevelCategory.addAll(mapSecondLevelCatgIdToLstThirdLevelCatg.get(documentType + '_' + strFirstLevel + '_' + strSecondLevel));	
		/** Get List of Category Level for mobile **/
		//lstContentTypes.sort();	
		
	}
	/* End : getLeftSidebarContents Method */
	
	
	public void getFilteredByDepartment()
	{
		//getLeftSidebarContents();
	}
	
	public void rerenderTheCategories()
	{
		getLeftSidebarContents();
	}
	
	
	
	/* @Name           - newComponent
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for creating Component dynamically.
	*/
	public override ApexPages.Component newComponent() 
	{
    	Component.c.SL_IntranetContentTypes c = new Component.c.SL_IntranetContentTypes();   
		c.aComponentImpl = this;
		
    	return c;
  	}
  	/* End : newComponent */
}