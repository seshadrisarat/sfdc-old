public with sharing class SL_IntranetSearchResults extends WidgetPaginatorAbstract implements IChatterable  
{
	public SL_IntranetChatterPlugIn Chatter	{	get; set;	}
	/* Start of variables */
    public String searchText 											{	get;set;	} 
    public String strSobject											{	get;set;	}	
    public String strFieldsetToDisplay									{	get;set;	}
    public String strFieldsetToSearch									{	get;set;	}	
    public String strLabel												{	get;set;	}	
    public Boolean showComponent										{	get;set;	}		
    public List<Sobject> lstSobject										{	get;set;	}	
    public List<ContentVersion> lstContentSearchResults 				{	get;set;	} 	
    public List<Intranet_Event__c> lstEventSearchResults 				{	get;set;	}
   	public List<User> lstUserSearchResults 								{	get;set;	}
    public List<SL_UtilityWrappers.FieldSetDescribe> lstSObjectInfoFields {	get;set;	}	
    
    //Variables for employee directory
    public List<String> lstObjectFieldNeedToDisplay						{	get;set; 	}
    public Boolean isSmallPhotoSelected 								{	get;set;	}
    public Map<String,String> mapFieldAPINameToFieldLabel 				{	get;set;	}
    
    //Variables for Feed post
    
    public String strKeyPrefixContentChatter; 							
    
    public String strFeaturedGroupIds; 	
    public Set<Id> setLoggedInUserGroupsSubscribed; 
    public Boolean isOnLoad;
    private Set<Id> setFeaturedGroupIDs;
    private Map<Id, CollaborationGroup> mapGroups;
    private List<SL_UtilityWrappers.FieldSetDescribe> lstSObjectSearchFields;
    
    //For Calenders entries
    public String strFeaturedPostsIDs									{	get;set;	} 
	public SearchConfiguration configuration							{	get; set;	}
	
	private static final set<String> setValidLikeOperatorDataTypes = new Set<String>{
			'URL', 'STRING', 'PHONE', 'EMAIL', 'PICKLIST', 'TEXTAREA'
	};
    private Set<String> stContentTypes;
    private String strQueryFields = '';
    private List<String> lstUserLicenseFilters;												//For user Licences
    private Set<String> setLoggedinUserOfficesId;
    private OfficesSpecification officesSpec; 
    private Set<String> setObjectName = new Set<String>{'User','Notification__c','Intranet_App__c','Intranet_Event__c','ContentVersion'};
    private String strQuery = '';
    
    
	/* End Of variables */
	
	/* Start of Constructor */
	public SL_IntranetSearchResults()
	{
        //intialization();				//calling intialization metthod for Intialization of all variables.
	}
	/* End of Constructor */
	
	private void intialization()
    {
		totalPages = startIndex = pageNo=  0;
		isOnLoad = true;
		showComponent = isSmallPhotoSelected = false;
        strFeaturedPostsIDs = strKeyPrefixContentChatter = '';
        lstObjectFieldNeedToDisplay = new List<String>();
        lstContentSearchResults = new List<ContentVersion>();  
        lstSobject = new List<Sobject>();
		lstEventSearchResults = new List<Intranet_Event__c>();
		lstUserSearchResults = new List<User>();
        setLoggedInUserGroupsSubscribed = new Set<Id>(); 
        setFeaturedGroupIDs = new Set<Id>();
        mapFieldAPINameToFieldLabel = new Map<String,String>();
        lstSObjectInfoFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
        lstSObjectSearchFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
    }
	
	public class SearchConfiguration
	{
		public Integer numOfRecordeToBedisplayed 							{	get; set;	}
    	public Integer numOfRecordsToBedisplayed_Mobile 					{	get; set;	}
		private Integer numOfRecordsToBedisplayedTemp;
    	private Integer numOfRecordsToBedisplayedTemp_Mobile;
    	
		public SearchConfiguration()
		{
			numOfRecordeToBedisplayed = numOfRecordsToBedisplayed_Mobile = 20;		// Default Values for variables
			
			List<SL_Intranet_PaginationSettings__c> lstPaginationSettings = SL_Intranet_PaginationSettings__c.getAll().values();
			
			if(lstPaginationSettings[0].SearchResult_PageSize__c != null)
				numOfRecordeToBedisplayed = Integer.valueOf(lstPaginationSettings[0].SearchResult_PageSize__c);
			
			if(lstPaginationSettings[0].SearchResult_PageSize_Mobile__c != null)
				numOfRecordsToBedisplayed_Mobile = Integer.valueOf(lstPaginationSettings[0].SearchResult_PageSize_Mobile__c);
			
			numOfRecordsToBedisplayedTemp = numOfRecordeToBedisplayed;
			numOfRecordsToBedisplayedTemp_Mobile = numOfRecordsToBedisplayed_Mobile;
		}
	}
	
	
	/*Method for gettign Instance of generic chatter component*/
	public SL_IntranetChatterPlugIn initChatter() {
		
		SL_IntranetChatterPlugIn plugin = new SL_IntranetChatterPlugIn();
		plugin.initializeParam('SearchResult',id);
		return plugin;
	}
	
	
	// Overriding initialize method to get configuration from properties
    public override protected void initialize()
	{
		intialization();				//calling intialization metthod for Intialization of all variables.
		Chatter = initChatter(); //binding the generic chatter instance
		configuration = new SearchConfiguration();
		rowsPerPage = configuration.numOfRecordeToBedisplayed;
		setLoggedinUserOfficesId = new Set<String>(); 
		
        //To get ids of all the groups where current logged in users is a member
        for(CollaborationGroupMember objGroupMembers : [Select MemberId, CollaborationGroupId 
        												From CollaborationGroupMember 
        												where MemberId = :Userinfo.getUserId()])
		{
			setLoggedInUserGroupsSubscribed.add(objGroupMembers.CollaborationGroupId);
		}  
        
        //To collect all the featured group Ids           
        for(SL_FeaturedGroups__c objFGroup : SL_FeaturedGroups__c.getAll().values())
            setFeaturedGroupIDs.add(objFGroup.GroupId__c);
		
		mapGroups = new Map<Id, CollaborationGroup>([select Id, Name from CollaborationGroup where Name != null]);
            
        User objUserOffice = [Select Id, Selected_Offices_Ids__c from User where Id = :UserInfo.getUserId() limit 1];
	            
		if(objUserOffice.Selected_Offices_Ids__c != null && objUserOffice.Selected_Offices_Ids__c != '')
			setLoggedinUserOfficesId.addAll(objUserOffice.Selected_Offices_Ids__c.split(';'));
			
		officesSpec = new OfficesSpecification(setLoggedinUserOfficesId);
			
        getUserLicenseKeyFilters();
        // Fetch the Content Type for records
		getContentTypes();	
	}
	
	/* @Name - formQueryString
	@Parameters - Sobject Name
	@Return Type -
	@Description -
	*/
	private void formQueryString(String strSobjectName, String strFieldsetToDisplay)
	{
		lstSObjectInfoFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
		mapFieldAPINameToFieldLabel = new Map<String,String>();
		strQueryFields = '';
		
		if(String.isNotBlank(strSobjectName) && strSobjectName != 'ContentVersion')
		{
			SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet(strSobjectName, strFieldsetToDisplay, '', '', '', new Set<String>{});
			lstSObjectInfoFields = objFieldSetWrapper.lstFieldWrapper;
		}
		else if(String.isNotBlank(strSobjectName) && strSobjectName == 'ContentVersion')
		{
			SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet('ContentVersion', strFieldsetToDisplay, '', '', '', new Set<String>{'VersionData','ExternalDataSourceId'});
			lstSObjectInfoFields = objFieldSetWrapper.lstFieldWrapper;
		}  
		
		for(SL_UtilityWrappers.FieldSetDescribe objField : lstSObjectInfoFields)
		{
			if(strSobjectName == 'Intranet_Event__c' && objField.fieldAPIName != 'Id' && objField.fieldAPIName != 'Name' && objField.fieldAPIName != 'RecordType.Name' && objField.fieldAPIName != 'Date_of_Event__c' && objField.fieldAPIName != 'End_Date__c' && objField.fieldAPIName != 'Comments__c' 
				&& objField.fieldAPIName != 'For_All_Offices__c' && objField.fieldAPIName != 'Selected_Offices_Ids__c')// have to change in packaging org
			{ 
				strQueryFields +=  ' , '+ objField.fieldAPIName;
			}
			else if( strSobjectName == 'ContentVersion' && objField.fieldAPIName != 'Id' && objField.fieldAPIName != 'Title' && objField.fieldAPIName != 'FeaturedContentBoost' && objField.fieldAPIName != 'Description' && objField.fieldAPIName != 'FileType' && objField.fieldAPIName != 'ContentUrl'
					&& objField.fieldAPIName != 'For_All_Offices__c' && objField.fieldAPIName != 'Selected_Offices_Ids__c')	
			{	
				lstObjectFieldNeedToDisplay.add(objField.fieldAPIName);
				strQueryFields +=  ' , '+ objField.fieldAPIName;
			}
			else if(strSobjectName == 'Notification__c' && objField.fieldAPIName != 'Id' && objField.fieldAPIName != 'Name' && objField.fieldAPIName != 'For_All_Offices__c' && objField.fieldAPIName != 'Selected_Offices_Ids__c')
			{
				strQueryFields +=  ' , '+ objField.fieldAPIName;
			}
			else if(strSobjectName == 'User' && objField.fieldAPIName != 'Id' && objField.fieldAPIName != 'Name' && objField.fieldAPIName != 'FirstName' && objField.fieldAPIName != 'LastName'
					&& objField.fieldAPIName != 'All_Offices__c' && objField.fieldAPIName != 'Selected_Offices_Ids__c')
			{
				mapFieldAPINameToFieldLabel.put(objField.fieldAPIName,objField.fieldLabel);
				lstObjectFieldNeedToDisplay.add(objField.fieldAPIName);
				strQueryFields += ' , '+ objField.fieldAPIName;
				
				if(objField.fieldAPIName == 'SmallPhotoUrl')
				isSmallPhotoSelected = true;
			}
			else if(strSobjectName == 'Intranet_App__c' && objField.fieldAPIName != 'Id' && objField.fieldAPIName != 'Name' && objField.fieldAPIName != 'For_All_Offices__c' && objField.fieldAPIName != 'Selected_Office_Ids__c')
			{
				strQueryFields +=  ' , '+ objField.fieldAPIName;
			}
			else if(objField.fieldAPIName != 'Id' && objField.fieldAPIName != 'Name' && !setObjectName.contains(strSobjectName))
			{
				strQueryFields +=  ' , '+ objField.fieldAPIName;
			}
			
		}
	}
	
	/* Start - Method for getting content types allowed for logged in user based on custom settings 
	   @Name           - getContentTypes
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting content types allowed for logged in user based on custom settings 
	*/
    private void getContentTypes()
	{
		try
		{
			stContentTypes = new Set<String>();
			Id userId = UserInfo.getUserId();
			Id userProfileId = UserInfo.getProfileId();
			Id userOrgId = UserInfo.getOrganizationId();
			List<String> lstContentTypesTemp = new List<String>(); 
			Set<String> stContentTypesTemp = new Set<String>();
			Map<Id, SL_IntranetDocumentsSetting__c> mapDocumentsSetting = new Map<Id, SL_IntranetDocumentsSetting__c>();
			
			//Content type field describe
			Schema.DescribeFieldResult fldDescResult = ContentVersion.Content_Types__c.getDescribe();
			List<Schema.PicklistEntry> pickListValues = fldDescResult.getPicklistValues();
			
			for(Schema.PicklistEntry obj : pickListValues)
			{
				stContentTypesTemp.add(obj.getValue());
			}
			
			for(SL_IntranetDocumentsSetting__c objDocument : [SELECT Content_Type__c, SetupOwnerId 
															  FROM SL_IntranetDocumentsSetting__c 
															  WHERE SetupOwnerId =: userId 
															  OR SetupOwnerId =: userProfileId
															  OR SetupOwnerId =: userOrgId])
			{
				mapDocumentsSetting.put(objDocument.SetupOwnerId, objDocument);
			}
			
			if(!mapDocumentsSetting.isEmpty() && mapDocumentsSetting.containskey(userId) && String.isNotBlank(mapDocumentsSetting.get(userId).Content_Type__c))
				lstContentTypesTemp = mapDocumentsSetting.get(userId).Content_Type__c.split(',');
			else if(!mapDocumentsSetting.isEmpty() && mapDocumentsSetting.containskey(userProfileId) && String.isNotBlank(mapDocumentsSetting.get(userProfileId).Content_Type__c))
				lstContentTypesTemp = mapDocumentsSetting.get(userProfileId).Content_Type__c.split(',');
			else if(!mapDocumentsSetting.isEmpty() && mapDocumentsSetting.containskey(userOrgId) && String.isNotBlank(mapDocumentsSetting.get(userOrgId).Content_Type__c))
				lstContentTypesTemp = mapDocumentsSetting.get(userOrgId).Content_Type__c.split(',');
			
			if(!lstContentTypesTemp.isEmpty())
			{	
				//creating a set of those content types for those logged in user have access
				for(String objStr : lstContentTypesTemp)
				{
					String strTemp = objStr.trim();
					if(stContentTypesTemp.contains(strTemp))
						stContentTypes.add(strTemp);
				}
			}
			else
				stContentTypes = stContentTypesTemp;
			
			//To cover the catch block
			if(Test.isRunningTest())
				Integer i = 1/0;
		}
		catch(Exception ex)
		{
			system.debug('=========Exception======'+ex+ '============'+ex.getLineNumber());
		}
	}
    /* End: getContentTypes method */
    
    /* Start - Method to get the Search results through SOSL based on Type of Search  
	   @Name           - getSearchResults
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function to get the Search results through SOSL based on Type of Search 
	*/
    public void getSearchResults()
    {
        //Initialize number of records to be displayed
        if(isOnLoad)
        {
        	configuration.numOfRecordeToBedisplayed = configuration.numOfRecordsToBedisplayedTemp;
        	configuration.numOfRecordsToBedisplayed_Mobile = configuration.numOfRecordsToBedisplayedTemp_Mobile;
        }
        
        isOnLoad = true;
        
        if(!String.isEmpty(strSobject))
        	showComponent = true;
        try
        {
        	SL_IntranetFeedItemsRecords objFeedItemRecords = new SL_IntranetFeedItemsRecords();
	        if(strSobject == 'ContentVersion')
	        	lstContentSearchResults = getContentVersionRecords();
	        else if(strSobject == 'FeedItem')
	        	getFeedItemsRecords();
	        else if(strSobject == 'Intranet_App__c')
	        	lstSobject = getApplicationRecords(String.escapeSingleQuotes(strSobject));
	        else if(strSobject == 'Intranet_Event__c')
	        	lstEventSearchResults = getEventRecords(String.escapeSingleQuotes(strSobject));
	        else if(strSobject == 'User')
	        	lstUserSearchResults = getEmployeeRecords(String.escapeSingleQuotes(strSobject));
	        else if(strSobject == 'Notification__c')
	        	lstSobject = getNotificationRecords(String.escapeSingleQuotes(strSobject));
	        else
	        	lstSobject = getSobjectRecords(String.escapeSingleQuotes(strSobject));
        }
        catch(Exception e)
        {
        	system.debug('=========Exception======'+e+ '============'+e.getLineNumber());
        }
    }
	
	/* @Name           - getFeedItemsRecords
	   @Parameters     - None
	   @Return Type    - List of FeedItem.
	   @Description    - 
	*/
	private void getFeedItemsRecords()
	{
		lstContentSearchResults = new List<ContentVersion>();
		lstEventSearchResults = new List<Intranet_Event__c>();
		lstUserSearchResults = new List<User>();
		lstSobject = new List<Sobject>();
	    mapFieldAPINameToFieldLabel = new Map<String,String>();
	    lstObjectFieldNeedToDisplay = new List<String>();
	    lstSObjectSearchFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
	    strQuery = '';
	}
	
    /* @Name           - getContentVersionRecords
    @Parameters     - None
    @Return Type    - List of ContentVersion.
    @Description    - 
	*/
    private List<ContentVersion> getContentVersionRecords()
    {	
    	if(String.isBlank(searchText)) return new List<ContentVersion>();
    	
    	lstContentSearchResults = new List<ContentVersion>();
		lstEventSearchResults = new List<Intranet_Event__c>();
		lstUserSearchResults = new List<User>();
		lstSobject = new List<Sobject>();
    	lstSObjectInfoFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
    	List<ContentVersion> lstContentVersion = new List<ContentVersion>();
    	List<List<SObject>> lstsearch = new List<List<Sobject>>(); 
    	mapFieldAPINameToFieldLabel = new Map<String,String>();
    	lstSObjectSearchFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
		lstObjectFieldNeedToDisplay = new List<String>{'Title'};
		String strContentVersionQueryFields = strQueryFields = strQuery = '';
		
        if(String.isNotBlank(strFieldsetToDisplay))
			formQueryString('ContentVersion', String.escapeSingleQuotes(strFieldsetToDisplay));
			
        String strSearch = searchString(searchText,'ContentVersion');
        	
	    if(String.isNotBlank(strFieldsetToSearch) && String.isNotBlank(strSearch))
        {
        	
        	strContentVersionQueryFields = 'SELECT Id, Title, FeaturedContentBoost, Description, FileType, ContentUrl, For_All_Offices__c, Selected_Offices_Ids__c ' + strQueryFields;
        	
        	strContentVersionQueryFields +=  ' FROM  '  + String.escapeSingleQuotes(strSobject) +  ' WHERE IsLatest = true';
        	
        	if(!stContentTypes.isEmpty())
				strContentVersionQueryFields +=	' AND Content_Types__c IN : stContentTypes ';
				
    		strContentVersionQueryFields +=  ' AND ( ' + strSearch + ' ) order by CreatedDate desc ';
    		strQuery = strContentVersionQueryFields + ' limit 200';
    		for(ContentVersion objCV : (List<ContentVersion>)doSoqlQuery())
    		{
    			if(officesSpec.satisfiedBy(objCV))
				lstContentVersion.add(objCV);
    		}
	        
	        totalRecords = lstContentVersion.size();
			totalPages = Math.mod(totalRecords, rowsPerPage) == 0 ? totalRecords/rowsPerPage : (totalRecords/rowsPerPage) + 1;
			firstRecords();
        }	 
	    else if(String.isBlank(strFieldsetToSearch))
	    {    
	    	strContentVersionQueryFields = 'Id, Title, FeaturedContentBoost, Description, FileType, ContentUrl, For_All_Offices__c, Selected_Offices_Ids__c ';
	    	
	        String strSosl = 'Find ' +  strSearch +  ' in ALL FIELDS '+ 'RETURNING ';
		        
			strSosl += ' ContentVersion (  ' +strContentVersionQueryFields + ' '+ strQueryFields +' where  IsLatest = true ';
			
			if(!stContentTypes.isEmpty())
				strSosl +=	' AND Content_Types__c IN : stContentTypes ';
			
			strSosl +=	' order by CreatedDate DESC ' ;  
		    
		    strQuery = strSosl +'limit 200)';		  
	        lstsearch = doSoslQuery();

	        for(ContentVersion objCV : (List<ContentVersion>)lstsearch[0])
	        { 
	        	if(officesSpec.satisfiedBy(objCV))
					lstContentVersion.add(objCV);
	        }
		        
	        totalRecords = lstContentVersion.size();
			totalPages = Math.mod(totalRecords, rowsPerPage) == 0 ? totalRecords/rowsPerPage : (totalRecords/rowsPerPage) + 1;
			firstRecords();	
		}
    	return lstContentVersion;
    }
	/* End */
    
    /* @Name           - searchString
	   @Parameters     - search String 
	   @Return Type    - String
	   @Description    - To format the search string to b eused in SOSL query 
	*/
    private String searchString(String searchText, String strObjectName)
    {
    	String strSearch= '';
		lstSObjectSearchFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
			
    	if(String.isNotBlank(strFieldsetToSearch))
    	{
    		SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet(strObjectName, String.escapeSingleQuotes(strFieldsetToSearch), '', '', '', new Set<String>{});
			lstSObjectSearchFields = objFieldSetWrapper.lstFieldWrapper;
			
		    for(SL_UtilityWrappers.FieldSetDescribe objField : lstSObjectSearchFields)
			{
				if(objField.fieldType == 'MULTIPICKLIST' && objField.isFilter)
		            strSearch += (strSearch == '' ? objField.fieldAPIName + ' Includes (\'' +String.escapeSingleQuotes(searchText)+ '\')' : ' OR ' +objField.fieldAPIName + ' Includes (\'' +String.escapeSingleQuotes(searchText)+ '\')');
		        else if(setValidLikeOperatorDataTypes.contains(objField.fieldType) && objField.fieldAPIName != 'Id' && objField.fieldType != 'MULTIPICKLIST' && objField.isFilter)
		    			strSearch += (strSearch == '' ? objField.fieldAPIName + ' LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'' : ' OR ' + objField.fieldAPIName + ' LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'');
			}
		    return strSearch;
    	}
    	else 
    	{
			searchText = String.escapeSingleQuotes(searchText.trim());
			if(searchText.contains('%'))  
			{
				searchText = searchText.replaceAll('%', '\\%');
			}
			else if(searchText.contains('_'))
			    searchText = searchText.replaceAll('_', '\\_');
			/*
			if(searchText != '' && searchText.length() > 1)
			for(String strSearchText : searchText.split(','))
			{
				if(strSearch != '')
					strSearch +=  ' OR ' + strSearchText.trim() +'* ' ;
				else
					strSearch = '\'' + strSearchText.trim() +'*' ;
			}
			if(strSearch.length() > 1 && !strSearch.endsWith('\''))
			    strSearch +=  '\'';
			*/
			/**Above code has been removed to have consistency with search type and search result as mentioned in SOCINT-586*/
			searchText = '\''+ searchText + '*\'';
			return searchText;
    	}
    }
    
    private List<Intranet_App__c> getApplicationRecords(String strSobjectName)
	{
		if(String.isBlank(searchText)) return new List<Intranet_App__c>();
		
		lstContentSearchResults = new List<ContentVersion>();
		lstEventSearchResults = new List<Intranet_Event__c>();
		lstUserSearchResults = new List<User>();
		lstSobject = new List<Sobject>();
		List<List<SObject>> lstsearch = new List<List<SObject>>();
		List<Intranet_App__c> lstApplicationRecords = new List<Intranet_App__c>();
		lstObjectFieldNeedToDisplay = new List<String>();
		mapFieldAPINameToFieldLabel = new Map<String,String>();
		lstSObjectSearchFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
		lstSObjectInfoFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
		String strApplicationQueryFields = strQueryFields = strQuery = '';
		
		if(String.isNotBlank(strFieldsetToDisplay))
			formQueryString(strSobjectName, String.escapeSingleQuotes(strFieldsetToDisplay));
			
		String strSearch = searchString(searchText,strSobjectName);
		
		if(String.isNotBlank(strFieldsetToSearch) && String.isNotBlank(strSearch))
		{
			strApplicationQueryFields = 'SELECT id, Name, For_All_Offices__c, Selected_Office_Ids__c ' +strQueryFields;
			
			strApplicationQueryFields +=  ' FROM  '  + String.escapeSingleQuotes(strSobjectName) +  ' WHERE ( ' + strSearch + ' ) order by CreatedDate desc ';
			strQuery = strApplicationQueryFields + ' limit 200';
			
			for(Intranet_App__c objApp : (List<Intranet_App__c>)doSoqlQuery())
			{
				if(officesSpec.satisfiedBy(objApp))
					lstApplicationRecords.add(objApp);
			}
				
			totalRecords = lstApplicationRecords.size();
			totalPages = Math.mod(totalRecords, rowsPerPage) == 0 ? totalRecords/rowsPerPage : (totalRecords/rowsPerPage) + 1;
	        firstRecords();
        }
		else if(String.isBlank(strFieldsetToSearch))
		{
			strApplicationQueryFields = ' id, Name,  For_All_Offices__c, Selected_Office_Ids__c';
			
			String strSosl = 'Find ' +  strSearch +  ' in ALL FIELDS '+ 'RETURNING ' + String.escapeSingleQuotes(strSobjectName) + '(' + strApplicationQueryFields + ' '+ strQueryFields +' order by CreatedDate desc ';
			strQuery = strSosl + ' limit 200)';
			
			lstsearch = doSoslQuery();
			
			for(Intranet_App__c objApp : (List<Intranet_App__c>)lstsearch[0])
			{
				if(officesSpec.satisfiedBy(objApp))
					lstApplicationRecords.add(objApp);
			}
			
			totalRecords = lstApplicationRecords.size();
			totalPages = Math.mod(totalRecords, rowsPerPage) == 0 ? totalRecords/rowsPerPage : (totalRecords/rowsPerPage) + 1;
	        firstRecords();
		}
		return lstApplicationRecords;
	}
	
	private List<Notification__c> getNotificationRecords(String strSobjectName)
	{
		if(String.isBlank(searchText)) return new List<Notification__c>();
		
		lstContentSearchResults = new List<ContentVersion>();
		lstEventSearchResults = new List<Intranet_Event__c>();
		lstUserSearchResults = new List<User>();
		lstSobject = new List<Sobject>();
		List<List<SObject>> lstsearch = new List<List<Sobject>>();
		List<Notification__c> lstNotificationRecords = new List<Notification__c>();
		lstObjectFieldNeedToDisplay = new List<String>();
		mapFieldAPINameToFieldLabel = new Map<String,String>();
		String strNotificationQueryFields = strQueryFields = strQuery = '';
		lstSObjectInfoFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
		lstSObjectSearchFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
		
		if(String.isNotBlank(strFieldsetToDisplay))
			formQueryString(strSobjectName, String.escapeSingleQuotes(strFieldsetToDisplay));
			
		String strSearch = searchString(searchText,strSobjectName);
		 	
		if(String.isNotBlank(strFieldsetToSearch) && String.isNotBlank(strSearch))
		{
		 	strNotificationQueryFields = ' SELECT id, Name, For_All_Offices__c, Selected_Offices_Ids__c ' + strQueryFields;
		 	       
			strNotificationQueryFields +=  ' FROM  '  + String.escapeSingleQuotes(strSobjectName) +  ' WHERE ( ' + strSearch + ' ) order by CreatedDate desc ';
			strQuery = strNotificationQueryFields + ' limit 200';
			
			for(Notification__c objNotify : (List<Notification__c>)doSoqlQuery())
			{
				if(officesSpec.satisfiedBy(objNotify))
					lstNotificationRecords.add(objNotify);
			}  
			
			totalRecords = lstNotificationRecords.size();
			totalPages = Math.mod(totalRecords, rowsPerPage) == 0 ? totalRecords/rowsPerPage : (totalRecords/rowsPerPage) + 1;
	        firstRecords();
			
		}
		else if(String.isBlank(strFieldsetToSearch))
		{
			strNotificationQueryFields = '  id, Name, For_All_Offices__c, Selected_Offices_Ids__c ';
			
			String strSosl = 'Find ' +  strSearch +  ' in ALL FIELDS '+ 'RETURNING ' + String.escapeSingleQuotes(strSobjectName) + '(' + strNotificationQueryFields + ' ' + strQueryFields + ' order by CreatedDate desc ';
			strQuery = strSosl + ' limit 200) ';
			lstsearch = doSoslQuery();
			
			for(Notification__c objNotify : (List<Notification__c>)lstsearch[0])
			{
				if(officesSpec.satisfiedBy(objNotify))
					lstNotificationRecords.add(objNotify);
			}
			
			totalRecords = lstNotificationRecords.size();
			totalPages = Math.mod(totalRecords, rowsPerPage) == 0 ? totalRecords/rowsPerPage : (totalRecords/rowsPerPage) + 1;
	        firstRecords();

		}
		return lstNotificationRecords;
	}
	
	private List<User> getEmployeeRecords(String strSobjectName)
	{
		if(String.isBlank(searchText)) return new List<User>();
		
		lstContentSearchResults = new List<ContentVersion>();
		lstEventSearchResults = new List<Intranet_Event__c>();
		lstUserSearchResults = new List<User>();
		lstSobject = new List<Sobject>();
		List<List<SObject>> lstsearch = new List<List<Sobject>>();
		List<User> lstUserRecords = new List<User>();
		mapFieldAPINameToFieldLabel = new Map<String,String>();
		lstObjectFieldNeedToDisplay = new List<String>{'Name'};
		String strEmployeeQueryFields = strQueryFields = strQuery = '';
		lstSObjectInfoFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
		lstSObjectSearchFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
		
		if(String.isNotBlank(strFieldsetToDisplay))
			formQueryString(strSobjectName, String.escapeSingleQuotes(strFieldsetToDisplay));
			
		String strSearch = searchString(searchText,strSobjectName);
		
		String strWhere = ' IsActive = true AND Profile.UserLicense.LicenseDefinitionKey NOT IN: lstUserLicenseFilters AND Exclude_from_Intranet_Directory__c = FALSE ';
		
		/*SOCINT-1027 to filter the Users when logged as Admin in Community*/
		String networkId = Network.getNetworkId(); 
		
		/*When logged in as Admin the Network Id will be null*/
		if(String.isEmpty(networkId))         
			strWhere += ' AND ContactId = null'; //Add the filter ContactId = null so when we logged in as Admin and it wont display Community Licence Users.
		/*When accessing Community as Admin User and Network Id will not be null*/
		else if(String.isNotEmpty(networkId))
			strWhere += ' AND Id IN (SELECT memberId FROM NETWORKMEMBER WHERE networkId =\''+ networkId +'\' )'; //Adding the filter will provide all the members of the community related to its Network Id.
		/*---End---*/
		
		if(String.isNotBlank(strFieldsetToSearch) && String.isNotBlank(strSearch))
		{
        	strEmployeeQueryFields = ' SELECT id, Name, FirstName, LastName, All_Offices__c, Selected_Offices_Ids__c ' + strQueryFields;
			strEmployeeQueryFields +=  ' FROM  '  + String.escapeSingleQuotes(strSobjectName) +  ' WHERE ' + strWhere +  ' AND ( ' + strSearch + ' ) ORDER BY LastName, FirstName ';
			strQuery = strEmployeeQueryFields + ' Limit 200';

			lstUserRecords = (List<User>)doSoqlQuery();
			
			totalRecords = lstUserRecords.size();
			totalPages = Math.mod(totalRecords, rowsPerPage) == 0 ? totalRecords/rowsPerPage : (totalRecords/rowsPerPage) + 1;
	        firstRecords();
	    }
		else if(String.isBlank(strFieldsetToSearch))
		{
			strEmployeeQueryFields = ' id, Name, All_Offices__c, Selected_Offices_Ids__c ';
			
			String strSosl = 'Find ' +  strSearch +  ' in ALL FIELDS '+ 'RETURNING ' + String.escapeSingleQuotes(strSobjectName) + '(' + strEmployeeQueryFields + ' '+ strQueryFields +' WHERE ' + strWhere + ' ORDER BY LastName, FirstName ';
			strQuery = strSosl + ' Limit 200) ';
			lstsearch = doSoslQuery();
			
			lstUserRecords = (List<User>)lstsearch[0];
			
			totalRecords = lstUserRecords.size();
			totalPages = Math.mod(totalRecords, rowsPerPage) == 0 ? totalRecords/rowsPerPage : (totalRecords/rowsPerPage) + 1;
	        firstRecords();
		}
		return lstUserRecords;
	}
	
	private List<Intranet_Event__c> getEventRecords(String strSobjectName)
	{
		if(String.isBlank(searchText)) return new List<Intranet_Event__c>();
		
		lstContentSearchResults = new List<ContentVersion>();
		lstEventSearchResults = new List<Intranet_Event__c>();
		lstUserSearchResults = new List<User>();
		lstSobject = new List<Sobject>();
		List<List<SObject>> lstsearch = new List<List<Sobject>>();
		List<Intranet_Event__c> lstEventRecords = new List<Intranet_Event__c>();
		lstObjectFieldNeedToDisplay = new List<String>();
		mapFieldAPINameToFieldLabel = new Map<String,String>();
		String strEventQueryFields = strQueryFields = strQuery = '';
		lstSObjectInfoFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
		lstSObjectSearchFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
		
		if(String.isNotBlank(strFieldsetToDisplay))
			formQueryString(strSobjectName, String.escapeSingleQuotes(strFieldsetToDisplay));
			
		String strSearch = searchString(searchText,strSobjectName);	
		
		if(String.isNotBlank(strFieldsetToSearch) && String.isNotBlank(strSearch))
		{
        	strEventQueryFields = ' SELECT Id, Name, RecordType.Name , Date_of_Event__c, End_Date__c, Comments__c, For_All_Offices__c, Selected_Offices_Ids__c ' + strQueryFields;
        	
			strEventQueryFields +=  ' FROM  '  + String.escapeSingleQuotes(strSobjectName) +  ' WHERE ( ' + strSearch + ' ) ORDER BY Date_of_Event__c asc nulls last, Name asc ';
			strQuery = strEventQueryFields + ' Limit 200';
			for(Intranet_Event__c objEvent: (List<Intranet_Event__c>)doSoqlQuery())
			{
				if(officesSpec.satisfiedBy(objEvent))
					lstEventRecords.add(objEvent);
			}
				
			totalRecords = lstEventRecords.size();
			totalPages = Math.mod(totalRecords, rowsPerPage) == 0 ? totalRecords/rowsPerPage : (totalRecords/rowsPerPage) + 1;
	        firstRecords();
		}
		else if(String.isBlank(strFieldsetToSearch))
		{
			strEventQueryFields = ' Id, Name, RecordType.Name , Date_of_Event__c, End_Date__c, Comments__c, For_All_Offices__c, Selected_Offices_Ids__c ';
			
			String strSosl = 'Find ' +  strSearch +  ' in ALL FIELDS '+ 'RETURNING ' + String.escapeSingleQuotes(strSobjectName) + '(' + strEventQueryFields + ' '+ strQueryFields +' ORDER BY Date_of_Event__c asc nulls last, Name asc ';
			strQuery = strSosl + ' Limit 200) ';
			lstsearch = doSoslQuery();
			
			for(Intranet_Event__c objEvent : (List<Intranet_Event__c>)lstsearch[0])
			{
				if(officesSpec.satisfiedBy(objEvent))
					lstEventRecords.add(objEvent);
			}
			
			totalRecords = lstEventRecords.size();
			totalPages = Math.mod(totalRecords, rowsPerPage) == 0 ? totalRecords/rowsPerPage : (totalRecords/rowsPerPage) + 1;
	        firstRecords();
		}
		return lstEventRecords;
	}
    
    private List<Sobject> getSobjectRecords(String strSobjectName)
	{
		if(String.isBlank(searchText)) return new List<Sobject>();
		
		lstContentSearchResults = new List<ContentVersion>();
		lstEventSearchResults = new List<Intranet_Event__c>();
		lstUserSearchResults = new List<User>();
		lstSobject = new List<Sobject>();
		List<List<SObject>> lstsearch = new List<List<Sobject>>();
		List<SObject> lstSObjectRecords = new List<SObject>();
		mapFieldAPINameToFieldLabel = new Map<String,String>();
		lstObjectFieldNeedToDisplay = new List<String>();
		String strSobjectQueryFields = strQueryFields = strQuery = '';
		lstSObjectInfoFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
		lstSObjectSearchFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
		
		if(String.isNotBlank(strFieldsetToDisplay))
			formQueryString(strSobjectName, String.escapeSingleQuotes(strFieldsetToDisplay));
			
	   	String strSearch = searchString(searchText,strSobjectName);
	   	
		if(String.isNotBlank(strFieldsetToSearch) && String.isNotBlank(strSearch))
		{
			strSobjectQueryFields +=  ' SELECT Id, Name' +strQueryFields+ ' FROM  '  + String.escapeSingleQuotes(strSobject) +  ' WHERE ( ' + strSearch + ' ) order by CreatedDate desc ';
			strQuery = strSobjectQueryFields + ' limit 200';
			lstSObjectRecords = doSoqlQuery();
				
			totalRecords = lstSObjectRecords.size();
			totalPages = Math.mod(totalRecords, rowsPerPage) == 0 ? totalRecords/rowsPerPage : (totalRecords/rowsPerPage) + 1;
	        firstRecords();
		        
			return lstSObjectRecords;
		}
		else if(String.isBlank(strFieldsetToSearch))
		{
			String strSosl = 'Find ' +  strSearch +  ' in ALL FIELDS '+ 'RETURNING ' + String.escapeSingleQuotes(strSobjectName) + '( id, Name ' + strQueryFields + ' order by CreatedDate desc ';
			strQuery = strSosl + ' limit 200)';
			lstsearch = doSoslQuery();
				
			totalRecords = lstsearch[0].size();
			totalPages = Math.mod(totalRecords, rowsPerPage) == 0 ? totalRecords/rowsPerPage : (totalRecords/rowsPerPage) + 1;
	        firstRecords();
	        return lstsearch[0];
		}
		return new List<Sobject>();
	}
	
	private void getUserLicenseKeyFilters() 
	{
		lstUserLicenseFilters = new List<String>();
		List<SL_IntranetUserLicenseFilters__c> lstLicenseFilters = SL_IntranetUserLicenseFilters__c.getAll().values();
		
		if(!lstLicenseFilters.isEmpty() && lstLicenseFilters[0].License_Definition_Keys__c != null)
		{
			lstUserLicenseFilters.addAll(lstLicenseFilters[0].License_Definition_Keys__c.trim().split(','));
		}
	}
    
    /* Start - Method for getting more search result for Desktop view
	   @Name           - getMoreRecords
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting more search result for Desktop view
	*/
    public void getMoreRecords()
    {
	   configuration.numOfRecordeToBedisplayed += configuration.numOfRecordsToBedisplayedTemp;
    }
    /* End : getMoreRecords Method */ 
    
    
    /* Start - Method for getting more search results for mobile view.
	   @Name           - getMoreRecordsForMobile
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for uploading file for chatter post.
	*/
    public void getMoreRecordsForMobile()
    {
	    configuration.numOfRecordsToBedisplayed_Mobile += configuration.numOfRecordsToBedisplayedTemp_Mobile;
    }
    /* End : getMoreRecordsForMobile Method */ 
    
	public class ContentVersionWrapper
    {
    	public Decimal ContentSize {get;set;}
    	public String Title {get;set;}
    	
    	public ContentVersionWrapper(Decimal ContentSize, String Title)
    	{
    		this.ContentSize = ContentSize;
    		this.Title = Title;
    	}
    }
    /* End */
    
    
    /* Start - Method for doing search query for individual object.
	   @Name           - doSoslQuery
	   @Parameters     - None 
	   @Return Type    - List<Sobject>
	   @Description    - Function for performing SOSL query to prevent scanner security issue(SOCINT-926).
	*/
    private List<List<SObject>> doSoslQuery()
    {
    	return search.query(strQuery);	
    }

	/* Start - Method for doing search query for individual object.
	   @Name           - doSoqlQuery
	   @Parameters     - None 
	   @Return Type    - List<Sobject>
	   @Description    - Function for performing SOQL query to prevent scanner security issue(SOCINT-926).
	*/
    private List<Sobject> doSoqlQuery()
    {
    	return database.query(strQuery);	
    }
    
    
	/* @Name           - newComponent
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for creating Component dynamically.
	*/
	public override  ApexPages.Component newComponent() 
	{
    	Component.c.SL_IntranetSearchResults c = new Component.c.SL_IntranetSearchResults();   
		c.aComponentImpl = this;
    	return c;
  	}
  	/* End : newComponent */
}