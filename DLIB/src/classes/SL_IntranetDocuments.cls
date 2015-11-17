/**
* @ClassName    : SL_IntranetDocuments 
* @JIRATicket   : Socint-194
* @CreatedOn    : 26/June/13
* @ModifiedBy   : Pravin 
* @Description  : This is the Implementation Class for The SL_IntranetDocumentsController.
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

public with sharing class SL_IntranetDocuments extends WidgetPaginatorAbstract implements IObservable,IChatterable
{
	final static String ALL_CATEGORIES = 'All Categories';
	
	/* Here i remove extends SL_IntranetChatter, so declaring some necessary variable here*/
	public  List<ContentVersion> lstContentsToBedisplayed {get;set;}
	//public transient Map<Id, List<FeedItem>> mapContentIdToLstFeedItems {get;set;}  //map to contain the FeedItems respective to each Content
	public String strListOfContentIdsToBeDisplayed {get;set;}
	public String strContentTypes;
	public String strFilteredItems		{	get; set;	}
	public String strContentsQuery;
	public String currentContentId {get;set;}
	/*END: variable declaration related after removing extends SL_IntranetChatter */
	
    /* Start of Global and Local Variables */ 
    public SL_IntranetChatterPlugIn Chatter	{	get; set;	}
    public Boolean showWidget {get;set;}
	public String userImage {get; set;}
	public String strDeptId {get;set;}
	
	/** Vars for List of Content and Category Level for mobile **/
	public String documentType {get; set;}
	/** End : Vars for List of Content and Category Level for mobile **/

	public String strContentType {get;set;}
	public String FirstLevelCatg {get;set;}
	public String SecondLevelCatg {get;set;}
	public String ThirdLevelCatg {get;set;}

	/* pagination settings variables */
	public Integer pageSizeResources_Mobile {get; set;}
	private Integer pageSizeResources;
	private Integer pageSize_Mobile;
	/* End : pagination settings variables */
	
	public boolean isOnCategoryPage {get; set;}
	
	private Set<String> stContentTypes = new Set<String>();
	private String currentUserOffice;
	private String strCat0;
	public boolean blnDisplayContentFilter {get; set;}
	
	private Set<String> setLoggedinUserOfficesId;
	private String strContentVersionId;
	
	private String strPageName;
    private String strLastCalledMethod = '';
    Boolean isPaginationMethod = false;
    public transient List<ContentVersion> lstContentsToBedisplayed_Mobile {get;set;}
    public Integer intListContentSizeMobile {get;set;}
    private Boolean isDepartmentWidgetExist; //To identify if Department widget exist on page or not to decide the behavior based on that. 
    private Set<String> setFieldsQuery = new Set<String>{'Id', 'Title', 'IsLatest', 'CreatedById', 'Content_Types__c', 'Select_Offices__c', 'Selected_Department_Ids__c', 'FeaturedContentBoost', 
    													'Description','FileType', 'ContentUrl', 'Selected_Offices_Ids__c', 'For_All_Offices__c', 'For_All_Departments__c'};
    													
	public List<SL_UtilityWrappers.FieldSetDescribe> lstDocumentFieldsName {get;set;}	
	
	public Boolean isChatterIconClicked {get;set;}						
    public Map<Id,Boolean> mapContentIdToChatterValue {get;set;}
    public String contentIdFromChatter {get;set;}
    private Boolean isCRMContentUser ;
	/* End of Global and Local Variables */
	
    
    /* Constructor initialization */
    public SL_IntranetDocuments()
    {
    	
    }
    /* End : Constructor initialization */
    
    override public void postInitialize() {
    	// Depends on Department configuration, so is executed after pre initializtion
		getFeaturedOrRecentContents();
    }
	
	public void notify(IWidget widget) {
		if(widget == null) return;
			
		SL_IntranetDepartments departmentWidget = (SL_IntranetDepartments)widget;
		strDeptId = departmentWidget.strInitialDeptSelection;
		isDepartmentWidgetExist = true;
	}
		
    public void getMoreContentsForMobile()
    {
    	lstContentsToBedisplayed_Mobile = new List<ContentVersion>();
    	//Getting all Content Records for Mobile view
		String strQueryMobile = 'Select Id, Title,For_All_Departments__c, Selected_Department_Ids__c, IsLatest, FeaturedContentBoost, Description, FileType, ContentUrl, For_All_Offices__c, Selected_Offices_Ids__c ' +
							  'From ContentVersion ' +
							  'where IsLatest = true ' ;
						  		
		if(!String.isEmpty(documentType) && documentType != ALL_CATEGORIES)
		{
			strQueryMobile += ' and Content_Types__c = ' + '\'' + String.escapeSingleQuotes(documentType) + '\'' ;
			
			if(FirstLevelCatg != '' && FirstLevelCatg != null)
				strQueryMobile += ' and Category_Level_1__c = ' + '\'' + String.escapeSingleQuotes(FirstLevelCatg) + '\'' ;
			
			if(SecondLevelCatg != '' && SecondLevelCatg != null)
				strQueryMobile += ' and Category_Level_2__c = ' + '\'' + String.escapeSingleQuotes(SecondLevelCatg) + '\'';
			
			if(ThirdLevelCatg != '' && ThirdLevelCatg != null)
				strQueryMobile += ' and Category_Level_3__c = ' + '\'' + String.escapeSingleQuotes(ThirdLevelCatg) + '\'';
		}
		
		strQueryMobile += ' LIMIT 1000 ';
		
		IVisibilitySpecification officesSpec = new OfficesSpecification(setLoggedinUserOfficesId);
		
		for(ContentVersion objCV : database.query(strQueryMobile))
		{
			if(officesSpec.satisfiedBy(objCV)) lstContentsToBedisplayed_Mobile.add(objCV);	
		}
		
		intListContentSizeMobile = lstContentsToBedisplayed_Mobile.size();
    }
    
    public SL_IntranetChatterPlugIn initChatter() 
    {
		SL_IntranetChatterPlugIn plugin = new SL_IntranetChatterPlugIn();
		plugin.initializeParam('Document',id);
		return plugin;
	}  
   
    /* @Name           - initialize
	   @Parameters     - None 
	   @Return Type    - void   
	   @Description    - Function for initializing local and public variables.
	*/
    public override protected void initialize()
    {
    	currentContentId = ''; //Decalring after remove extends SL_IntranetChatter
    	isChatterIconClicked = false;
    	mapContentIdToChatterValue = new Map<Id,Boolean>();
    	intListContentSizeMobile = pageSizeResources_Mobile = totalRecords = 0;
    	Chatter = initChatter();
    	showWidget = true;
		strContentType = 'Name';
		currentUserOffice = '';
		strContentVersionId = '';
		strDeptId = '';
		firstRecords();
		
		ThirdLevelCatg = SecondLevelCatg = FirstLevelCatg = '';
		
		blnDisplayContentFilter = false;
		strCat0 = '';
		isOnCategoryPage = false;
		lstContentsToBedisplayed = new List<ContentVersion>();
		lstContentsToBedisplayed_Mobile = new List<ContentVersion>();
		
		documentType = '';
		stContentTypes = new Set<String>();
		
		isDepartmentWidgetExist = false;
		//Initialize the list
		//mapContentIdToLstFeedItems = new map<Id, List<FeedItem>>();
		
		/* Start : Get the pageSizes from custom settings for pagination */
		pageSizeResources = 100; 
		pageSize_Mobile = 20;
		strPageName = ApexPages.currentPage().getParameters().get('page');
        
        if(String.isEmpty(strPageName)) strPageName = 'Home';

        //mapWidget_showFeed = new Map<String,Boolean>();
        lstDocumentFieldsName = new List<SL_UtilityWrappers.FieldSetDescribe>();
        /* overriding the Paginator class vars */
		totalPages = 0;
		pageNo = 0;
		/* End of overriding */
		
		isCRMContentUser = [Select UserPermissionsSFContentUser From User where Id =: UserInfo.getUserId()].UserPermissionsSFContentUser;
        //To check context user is CRM content user or not
        if(!isCRMContentUser) 
            return;
		
		for(SL_Intranet_PaginationSettings__c objPagination : [
				SELECT Name, Documents_PageSize__c, Documents_PageSize_Mobile__c 
				FROM SL_Intranet_PaginationSettings__c limit 1])
		{
			if(objPagination.Documents_PageSize__c != null)
				pageSizeResources = Integer.valueOf(objPagination.Documents_PageSize__c);
			if(objPagination.Documents_PageSize_Mobile__c != null)
				pageSize_Mobile = Integer.valueOf(objPagination.Documents_PageSize_Mobile__c);
		}
		
		pageSizeResources_Mobile = pageSize_Mobile;
		/* End : getting the pageSizes from custom settings for pagination */
		
		if(this.properties != null) {
			Map<String, Object> configuration = (Map<String, Object>)this.properties;
			
			if(configuration.get('showfeed') == null || configuration.get('showfeed') == '')
				((map<String, object>)properties).put('showfeed', false);
			if(configuration.get('showFieldLabel') == null || configuration.get('showFieldLabel') == '')
				((map<String, object>)properties).put('showFieldLabel', false);
			
			if(String.isNotBlank(String.valueOf(configuration.get('fieldset'))))  
	        {  
	     		SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( 'ContentVersion', String.valueOf(configuration.get('fieldset')), '', '', '', new Set<String>{'VersionData','ExternalDataSourceId'});
	     		lstDocumentFieldsName = objFieldSetWrapper.lstFieldWrapper;
	        
		        // Iterate through the fields returned previously to form a query
		    	for(SL_UtilityWrappers.FieldSetDescribe objFieldSetResult : lstDocumentFieldsName)
				{
					setFieldsQuery.add(objFieldSetResult.fieldAPIName);
				}
	        }
		}
		
		loadUserInfo();
				
		//To get all the Content types allowed for logged in User on load of page
		getContentTypes();
		
		// listen for department widget dependancy
		WidgetConfigurationListener.getInstance().addEventListener('SL_IntranetDepartments', this); 
		
		documentType = ALL_CATEGORIES;
		
		strCat0 = ApexPages.currentPage().getParameters().get('cat0');
		
		if(!String.isEmpty(strCat0))
		{
			documentType = String.escapeSingleQuotes(strCat0);
			isOnCategoryPage = true;
		}
		
		getMoreContentsForMobile();
		
		strListOfContentIdsToBeDisplayed = '';
        // Get the Content Ids to be passed to document Categories widget
        for(ContentVersion objCV : lstContentsToBedisplayed)
        {
            strListOfContentIdsToBeDisplayed += objCV.Id + ';' ;
        }
    }
    /* End  : initialization function */
    
    
    /* Start - Method for getting Content Type allowed for logged in user based on custom setting.
	   @Name           - getContentTypes
	   @Parameters     - None 
	   @Return Type    - Void
	   @Description    - Function for getting Content Type allowed for logged in user based on custom setting.
	*/
	public void getContentTypes()
	{
		if(!isCRMContentUser) 
            return;
		List<String> lstContentType = new List<String>();
		
		Id userId = UserInfo.getUserId();
		Id userProfileId = UserInfo.getProfileId();
		List<String> lstContentTypesTemp = new List<String>(); 
		
		Map<Id, SL_IntranetDocumentsSetting__c> mapDocumentsSetting = new Map<Id, SL_IntranetDocumentsSetting__c>();
		
		// Content Type picklist field describe
		Schema.DescribeFieldResult fldDescResult = ContentVersion.Content_Types__c.getDescribe();
		List<Schema.PicklistEntry> pickListValues = fldDescResult.getPicklistValues();
		
		for(Schema.PicklistEntry obj : pickListValues)
		{ 
			stContentTypes.add(obj.getValue());
		}
		
		//Getting Content Types allowed for logged in user from OWD. 
		SL_IntranetDocumentsSetting__c owdContentType = SL_IntranetDocumentsSetting__c.getOrgDefaults();
		
		//Getting Content Types allowed for logged in user from User defined or Profile defined hierarchical custom setting and creating a map of them. 
		for(SL_IntranetDocumentsSetting__c objDocument : [
			SELECT Content_Type__c, SetupOwnerId 
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
			lstContentTypesTemp.addAll(stContentTypes);
			
		for(String objStr : lstContentTypesTemp)
		{
			String strTemp = objStr.trim();
			
			if(stContentTypes.contains(strTemp)) lstContentType.add(strTemp);
		}
		
		stContentTypes = new Set<String>();
		
		// Setting default document type on load of page 
		if(lstContentType.size() > 0)
		{
			documentType = lstContentType[0];
			stContentTypes.addAll(lstContentType); 
		}
	}
	/* End : getContentTypes method */
	
	
	/* Start - Method for getting more records of contents for Mobile.
	   @Name           - getMoreContentRecords
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting more records of contents for Mobile.
	*/ 
	public void getMoreContentRecords()
	{
		pageSizeResources_Mobile += pageSize_Mobile;
		getMoreContentsForMobile();
	}
	/* End : getMoreContentRecords method */
			
	
	/* Start - Method for getting recent or featured content records.
	   @Name           - getFeaturedOrRecentContents
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting recent or featured content records.
	*/
	public void getFeaturedOrRecentContents()
	{
		if(!isCRMContentUser) 
            return;
		documentType = ALL_CATEGORIES; // search without categories criterion
		
		strLastCalledMethod = 'getFeaturedOrRecentContents';
		
		if(!isPaginationMethod) firstRecords();
		
		List<PageRegionWidget__c> lstPageRegionWidget = new List<PageRegionWidget__c>();
		lstContentsToBedisplayed = new List<ContentVersion>();
		//mapContentIdToLstFeedItems = new Map<Id, List<FeedItem>>();

		rowsPerPage = pageSizeResources;
		
		//creating Base of content query string
		String strQuery = 'Select ' + String.join(new List<String>(setFieldsQuery), ',') +' FROM ContentVersion WHERE IsLatest = true ';
						
		// Adding filter condition based on selection of Recent or Featured
		strQuery += buildWherePartBasedOnFilter(strContentType);
			
		List<ContentVersion> lstTempLstToCheckTotalContentRecords = new List<ContentVersion>();
		
		//Adding filter condition for content type based on selection of content type and quering contents records 
		if(!String.isEmpty(documentType) && documentType != ALL_CATEGORIES)
		{
			strQuery += ' and Content_Types__c = \'' + String.escapeSingleQuotes(documentType) + '\'';
		}
		else
        {            
			strQuery += buildWherePartBasedOnFilter(strContentType);			
			strQuery += ' AND Content_Types__c IN: stContentTypes ';
        }
        
        strContentTypes = '';
        for(String strCT : stContentTypes)
		{
			strContentTypes += strCT + '#';
		}
		
        lstTempLstToCheckTotalContentRecords = database.query(strQuery);
        
        Set<Id> setFilteredContentIdsForOffsetting = filterObjectsBasedOnSecurityRules(lstTempLstToCheckTotalContentRecords);		
		strFilteredItems = '';
		for(Id strFilteredCT : setFilteredContentIdsForOffsetting)
		{
			strFilteredItems += strFilteredCT + '#';
		}
		
		strQuery += ' AND ID in: setFilteredContentIdsForOffsetting ';		
		strQuery += buildOrderByPartBasedOnFilter(strContentType);
		
		for(ContentVersion objCV : database.query(strQuery + ' LIMIT '+ String.valueOf(rowsPerPage)+  ' Offset '+ startIndex))
		{
			lstContentsToBedisplayed.add(objCV);
			//mapContentIdToLstFeedItems.put(objCV.Id, new List<FeedItem>());
			mapContentIdToChatterValue.put(objCV.Id,false); 
		}
		strContentsQuery = strQuery + ' LIMIT '+ String.valueOf(rowsPerPage)+  ' Offset '+ startIndex;

            
		totalRecords = setFilteredContentIdsForOffsetting.size();
		totalPages = Math.mod(totalRecords, rowsPerPage) == 0 ? totalRecords/rowsPerPage : (totalRecords/rowsPerPage) + 1;
		
		isPaginationMethod = false;
		
		strListOfContentIdsToBeDisplayed = Utilities.extractJoinedIDs(setFilteredContentIdsForOffsetting, ';');
		
		strFilteredItems = '';
        // Get the Content Ids to be passed to document Categories widget
        for(ContentVersion objCV : lstContentsToBedisplayed)
        {
            strFilteredItems += objCV.Id + '#' ;
        }
	}
	/* End : getFeaturedOrRecentContents method */
	
	
	/* Start - Method for getting content related to selected category.
	   @Name           - getCategoryRelatedContent
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting content related to selected category.
	*/
	public void getCategoryRelatedContent()
	{
		if(!isCRMContentUser) 
            return;
		strLastCalledMethod = 'getCategoryRelatedContent'; 
		
		rowsPerPage = pageSizeResources;
		
		if(!isPaginationMethod) firstRecords();
		
		strContentType = 'Name';		
		lstContentsToBedisplayed = new List<ContentVersion>();
		//mapContentIdToLstFeedItems = new Map<Id, List<FeedItem>>();		
		Set<String> setFieldsToQuery = new Set<String>(setFieldsQuery);
		
		// creating basic query string for content records
		String strQuery = 'Select ' + String.join(new List<String>(setFieldsToQuery), ',') +' FROM ContentVersion WHERE IsLatest = true ';
			
		List<ContentVersion> lstTempLstToCheckTotalContentRecords = new List<ContentVersion>();
		strContentTypes = '';
		
		// If selected content type is not null then query content records for selected category level  
		if(!String.isEmpty(documentType) && documentType != ALL_CATEGORIES)
		{			
			strQuery += ' and Content_Types__c = ' + '\'' + String.escapeSingleQuotes(documentType) + '\'' ;
			
			if(FirstLevelCatg != '' && FirstLevelCatg != null)
				strQuery += ' and Category_Level_1__c = ' + '\'' + String.escapeSingleQuotes(FirstLevelCatg) + '\'' ;
			
			if(SecondLevelCatg != '' && SecondLevelCatg != null)
				strQuery += ' and Category_Level_2__c = ' + '\'' + String.escapeSingleQuotes(SecondLevelCatg) + '\'';
			
			if(ThirdLevelCatg != '' && ThirdLevelCatg != null)
				strQuery += ' and Category_Level_3__c = ' + '\'' + String.escapeSingleQuotes(ThirdLevelCatg) + '\''; 
			
			strContentTypes = documentType + '#';
			stContentTypes =  new Set<String>{documentType};
		}
		else
		{				
           	for(String strCT : stContentTypes)
			{
				strContentTypes += strCT + '#';
			}
		}	
		
		strQuery += buildWherePartBasedOnFilter(strContentType);
		strQuery += ' AND Content_Types__c IN: stContentTypes ';	
		strContentsQuery = strQuery;	
		lstTempLstToCheckTotalContentRecords = database.query(strQuery);
		strQuery += 'AND ID in: setFilteredContentIdsForOffsetting ';			
		strQuery += buildOrderByPartBasedOnFilter(strContentType);
		
		Set<Id> setFilteredContentIdsForOffsetting = filterObjectsBasedOnSecurityRules(lstTempLstToCheckTotalContentRecords);
				
		for(ContentVersion objCV : database.query(strQuery + ' LIMIT '+ String.valueOf(rowsPerPage)+  ' Offset '+ startIndex))
		{
			lstContentsToBedisplayed.add(objCV);
			//mapContentIdToLstFeedItems.put(objCV.Id, new List<FeedItem>());
			mapContentIdToChatterValue.put(objCV.Id,false);
		}
		
		totalRecords = setFilteredContentIdsForOffsetting.size();
		totalPages = Math.mod(totalRecords, rowsPerPage) == 0 ? totalRecords/rowsPerPage : (totalRecords/rowsPerPage) + 1;
			
		isPaginationMethod = false;
		
		showWidget = true;
		
		getMoreContentsForMobile();
		
		strListOfContentIdsToBeDisplayed = Utilities.extractJoinedIDs(setFilteredContentIdsForOffsetting, ';');
	}
	/* End : getCategoryRelatedContent method */

	
	public void getFilteredByDepartment()
	{
		documentType = ALL_CATEGORIES;
		strContentType = 'Name';
		getFeaturedOrRecentContents();	
		
		if(lstContentsToBedisplayed.size() > 0)
			showWidget = true;
		else
			showWidget = false;
	}
	
	public void getOffsetDocumentRecords()
	{
		isPaginationMethod = true;
		if(strLastCalledMethod == 'getCategoryRelatedContent')
			getCategoryRelatedContent();
		else if(strLastCalledMethod == 'getFeaturedOrRecentContents')
			getFeaturedOrRecentContents();
	}
	
	public void deleteDocument()
	{
		String documentId = ApexPages.currentPage().getParameters().get('docId');
		try
		{
			ContentVersion objContentVerion= [ Select Id, VersionData, PathOnClient, Title, FileType, ContentDocumentId
	                                                      From ContentVersion 
	                                                      Where Id =: documentId];
			delete new ContentDocument( Id = objContentVerion.ContentDocumentId );
			
			Integer index = 0;
			for(ContentVersion objDoc : lstContentsToBedisplayed)
			{
				if(objDoc.Id == documentId)
				{
					lstContentsToBedisplayed.remove(index);
					break;
				}
				index++;
			}
		}
		catch(Exception ex)
		{
			//ApexPages.addMessages(ex);
			ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'Delete failed: Insufficient Access or Read Only Access on selected Document'));
		} 
		
		//return new PageReference(ApexPages.currentPage().getHeaders().get('Referer')).setRedirect(true);
	}
	
	/**
	** Reads user info and fills necessary fields
	**/
	private void loadUserInfo() {
		User objUser = [Select Id, Selected_Offices_Ids__c , Name, SmallPhotoUrl from User where Id=:UserInfo.getUserId() limit 1];
		
		if(objUser.SmallPhotoUrl != null) userImage = objUser.SmallPhotoUrl;
		
		setLoggedinUserOfficesId = new Set<String>();
		if(!String.isEmpty(objUser.Selected_Offices_Ids__c)) {
			setLoggedinUserOfficesId.addAll(objUser.Selected_Offices_Ids__c.split(';'));
		}
	}
	
	/**
	** Adds Where filtering condition to the query
	**/	
	private String buildWherePartBasedOnFilter(String filter) {
		
		String q = '';
		
		if(filter == 'Feature') 
			q += ' AND FeaturedContentBoost = 1 ';
		else if(filter == 'Recent')
		{
			// To get the Contents from 30 days back to current date
			Date dtPostDate = system.today() - 30;
			DateTime dtConverted = Datetime.newInstance(dtPostDate.year(), dtPostDate.month(), dtPostDate.day(), 0, 0, 0);
			q += ' AND CreatedDate > ' +  dtConverted.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') ;
		}
		return q;
	}
	
	/**
	** Adds order condition to the query
	**/
	private String buildOrderByPartBasedOnFilter(String filter) {		
		return ' ORDER BY ' + (filter == 'Feature' || filter == 'Name' ? 'Title' : 'CreatedDate DESC');
	}
	
	private Set<Id> filterObjectsBasedOnSecurityRules(List<ContentVersion> items) {		
		IVisibilitySpecification officesSpec = new OfficesSpecification(setLoggedinUserOfficesId);
		IVisibilitySpecification departmentSpec = new DepartmentSpecification(strDeptId);
		Set<Id> filteredItems = new Set<Id>();	
			
		for(ContentVersion item : items)
		{	
			if(officesSpec.satisfiedBy(item) && (!isDepartmentWidgetExist|| departmentSpec.satisfiedBy(item)) ) {
            	filteredItems.add(item.Id);							
            }
		}
		return filteredItems; 
	}
	
	// Method to fetch Content records and related Feed Items
	public void fetchContentChatter()
	{
		isChatterIconClicked = true;
		mapContentIdToChatterValue.put(contentIdFromChatter,true);
		for(Id objId:  mapContentIdToChatterValue.keyset())
		{
			if(objId != contentIdFromChatter)
				mapContentIdToChatterValue.put(objId,false);
		}
	}
	
	/* @Name           - newComponent
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for creating Component dynamically.
	*/
	public override ApexPages.Component newComponent() 
	{		
    	Component.c.SL_IntranetDocuments c = new Component.c.SL_IntranetDocuments();   
		c.aComponentImpl = this;
    	return c;
  	}
  	/* End : newComponent */
}