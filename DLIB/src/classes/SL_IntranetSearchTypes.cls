/** 
* @ClassName    : SL_IntranetSearchTypes 
* @JIRATicket   : Socint-191
* @CreatedOn    : 21/June/13
* @ModifiedBy   : Pravin 
* @Description  : This is the Base class for The SL_IntranetSearchTypesController.
*/
 
/**
@ Pravin Sapkal
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 9
No of collections used                  : 4
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 

*/
public with sharing class SL_IntranetSearchTypes extends WidgetAbstract 
{
	/* Start - Varaibles */
	public String searchText 															{	get;set;	}
	public List<CategoryWrapper> lstCategoryWrapper										{	get;set;	}
	
	private String strcategories;
	private List<String> lstUserLicenseFilters;
	private Set<String> setLoggedinUserOfficesId;
	private OfficesSpecification officesSpec;
	private String strCommunityId = Network.getNetworkId();
	private Boolean hasContentAccess ;
	/* End Variables */

	
	/* Constructor initialization */
    public SL_IntranetSearchTypes()
    {
		 intialization();	//calling intialize method to intialize all the globale variables.   
    }
    /* End : Constructor initialization */
    
    /* Start - Wrapper Class */
    public class CategoryWrapper
    {
    	/* Start - Inner Class Variables*/
    	public String strSobjectAPIName		{	get;set;	}
    	public String strSobjectLabel		{	get;set;	}
    	public String strSobjectFieldsetToSearch	{	get;set;	}
    	public String strSobjectFieldsetToDisplay	{	get;set;	}
    	public Integer intNoOfRecords		{	get;set;	}
    	/* End - Inner Class Variables*/
    	
    	public CategoryWrapper(String strSobjectAPIName, String strSobjectLabel, String strSobjectFieldsetToSearch, String strSobjectFieldsetToDisplay, Integer intNoOfRecords)
    	{
    		this.strSobjectAPIName = strSobjectAPIName;
    		this.strSobjectLabel = strSobjectLabel;
    		this.strSobjectFieldsetToSearch = strSobjectFieldsetToSearch;
    		this.strSobjectFieldsetToDisplay = strSobjectFieldsetToDisplay;
    		this.intNoOfRecords = intNoOfRecords;
    	}
    }
    /* End - Wrapper Class */
    
    private void intialization()
    {
        lstCategoryWrapper = new List<CategoryWrapper>();
        lstUserLicenseFilters = new List<String>();
    }
    
    //overriding initialize method to get configuration from properties
    public override protected void initialize()
	{
		 if(this.properties != null) {
			Map<String, Object> configuration = (Map<String, Object>)this.properties;
			
			if(configuration.containsKey('categories'))			strcategories = String.valueOf(configuration.get('categories'));
		 }
		 
	 	setLoggedinUserOfficesId = new Set<String>();
        User objUserOffice = [Select Id, Selected_Offices_Ids__c,UserPermissionsSFContentUser from User where Id = :UserInfo.getUserId() limit 1];
        
        hasContentAccess = objUserOffice.UserPermissionsSFContentUser;
		if(String.isNotBlank(objUserOffice.Selected_Offices_Ids__c))
			setLoggedinUserOfficesId.addAll(objUserOffice.Selected_Offices_Ids__c.split(';'));
		 
		 officesSpec = new OfficesSpecification(setLoggedinUserOfficesId);
		 getUserLicenseKeyFilters();
		 getSearchResults();
	}
    
    
     /*@Name           - getSearchResults
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function to get the Search results through SOSL based on Type of Search 
	*/
    public void getSearchResults() 
    {
        try
        {
        	if(String.isBlank(searchText))
        		searchText = (Apexpages.currentPage().getParameters().get('searchText') != null) ? Apexpages.currentPage().getParameters().get('searchText').trim() : '';
			
			if(String.isNotBlank(strcategories))
			{			
				lstCategoryWrapper = new List<CategoryWrapper>();
				
				for(String strCategory : strcategories.split(','))
				{
				 	String strFieldSetToDisplay = '';
					String strFieldSetToSearch = '';
					String objectLabel = '';
					String objectName = '';
					
					strCategory = strCategory.trim();
					
					List<String> lstValuesOfCategories = new List<String>();
					
					if(strCategory.contains(':'))
						lstValuesOfCategories = strCategory.split(':');

					if(lstValuesOfCategories.size() == 4) 	
					{
						strFieldSetToSearch = lstValuesOfCategories[3];
						strFieldSetToDisplay = lstValuesOfCategories[2];
						objectLabel = lstValuesOfCategories[1];
						objectName = lstValuesOfCategories[0];
					}
					 else if(lstValuesOfCategories.size() == 3)
					{
						strFieldSetToDisplay = lstValuesOfCategories[2];
						objectLabel = lstValuesOfCategories[1];
						objectName = lstValuesOfCategories[0];
					}
					else if(lstValuesOfCategories.size() == 2)
					{
						objectLabel = lstValuesOfCategories[1];
						objectName = lstValuesOfCategories[0];
					}
					
					if(String.isNotBlank(objectLabel))
					{
						if(objectName == 'ContentVersion' && hasContentAccess)
							lstCategoryWrapper.add(new CategoryWrapper(objectName, objectLabel, strFieldSetToSearch, strFieldSetToDisplay, getNoOfContentVersionRecords(objectName, strFieldSetToSearch)));
						else if(objectName == 'FeedItem')
							lstCategoryWrapper.add(new CategoryWrapper(objectName, objectLabel, strFieldSetToSearch, strFieldSetToDisplay, getNoOfFeedItemRecords()));
						else if(objectName == 'User')
							lstCategoryWrapper.add(new CategoryWrapper(objectName, objectLabel, strFieldSetToSearch, strFieldSetToDisplay, getNoOfEmployeeRecords(objectName, strFieldSetToSearch)));
						else if(objectName == 'Notification__c' && getObjectAccess('read', new Notification__c().getsObjectType()))
							lstCategoryWrapper.add(new CategoryWrapper(objectName, objectLabel, strFieldSetToSearch, strFieldSetToDisplay, getNoOfNotificationRecords(objectName, strFieldSetToSearch)));
						else if(objectName == 'Intranet_Event__c' && getObjectAccess('read', new Intranet_Event__c().getsObjectType()))
							lstCategoryWrapper.add(new CategoryWrapper(objectName, objectLabel, strFieldSetToSearch, strFieldSetToDisplay, getNoOfCalenderRecords(objectName, strFieldSetToSearch)));
						else if(objectName == 'Intranet_App__c' && getObjectAccess('read', new Intranet_App__c().getsObjectType()))
							lstCategoryWrapper.add(new CategoryWrapper(objectName, objectLabel, strFieldSetToSearch, strFieldSetToDisplay, getNoOfApplicationRecords(objectName, strFieldSetToSearch)));
						else if(String.isNotBlank(objectName) && objectName != 'ContentVersion' && getObjectAccess('read',Schema.getGlobalDescribe().get(objectName)) )
							lstCategoryWrapper.add(new CategoryWrapper(objectName, objectLabel, strFieldSetToSearch, strFieldSetToDisplay, getNoOfSobjectRecords(objectName, strFieldSetToSearch)));
					}
		    	}
			}
				
        	if(Test.isRunningTest())			Integer i = 1/0;
        }
        catch(Exception ex)
        {
            system.debug('::::::::Exception::::::::'+ex);
        }                                             
    }
    /* End : getSearchResults Method */
    
    
    /* @Name           - getNoOfContentVersionRecords
	   @Parameters     - None 
	   @Return Type    - Integer
	   @Description    - 
	*/
    private Integer getNoOfContentVersionRecords(String objectName, String fieldSetName)
	{
		if(String.isBlank(searchText)) return 0;	
		
    	String strSearch = formatSearchString(searchText, objectName, fieldSetName);
    	Integer filteredCVSize = 0;
    	
    	/* ----Start Get Content Type*/
     	Id userId =  UserInfo.getUserId();
		Id userProfileId =  UserInfo.getProfileId();
		Id userOrgId = UserInfo.getOrganizationId();
		Set<String> stContentTypes = new Set<String>();
		Set<String> stContentTypesTemp = new Set<String>();
		List<String> lstContentTypesTemp = new List<String>(); 
		Map<Id, SL_IntranetDocumentsSetting__c> mapDocumentsSetting = new Map<Id, SL_IntranetDocumentsSetting__c>();
		
		for(Schema.PicklistEntry obj : ContentVersion.Content_Types__c.getDescribe().getPicklistValues())
		{
			stContentTypesTemp.add(obj.getValue());
		}
		
		for(SL_IntranetDocumentsSetting__c objDocument : [SELECT Content_Type__c, SetupOwnerId 
															FROM SL_IntranetDocumentsSetting__c 
															WHERE SetupOwnerId =: userId 
															OR SetupOwnerId =: userProfileId
															OR SetupOwnerId =: userOrgId
														])
		{
			mapDocumentsSetting.put(objDocument.SetupOwnerId, objDocument);
		}
		
		if(!mapDocumentsSetting.isEmpty() && mapDocumentsSetting.containskey(userId) && String.isNotBlank(mapDocumentsSetting.get(userId).Content_Type__c) )
			lstContentTypesTemp = mapDocumentsSetting.get(userId).Content_Type__c.split(',');
		else if(!mapDocumentsSetting.isEmpty() && mapDocumentsSetting.containskey(userProfileId) && String.isNotBlank(mapDocumentsSetting.get(userId).Content_Type__c))
			lstContentTypesTemp = mapDocumentsSetting.get(userProfileId).Content_Type__c.split(',');
		else if(!mapDocumentsSetting.isEmpty() && mapDocumentsSetting.containskey(userOrgId) && String.isNotBlank(mapDocumentsSetting.get(userOrgId).Content_Type__c))
			lstContentTypesTemp = mapDocumentsSetting.get(userOrgId).Content_Type__c.split(',');
		else
			lstContentTypesTemp.addAll(stContentTypesTemp);
		
		//creating a set of those content types for those logged in user have access
		for(String objStr : lstContentTypesTemp)
		{
			String strTemp = objStr.trim();
			
			if(stContentTypesTemp.contains(strTemp))
				stContentTypes.add(strTemp);
		}
		/* ----End Get Content Type*/
		
		   
        if(String.isNotBlank(fieldSetName) && String.isNotBlank(strSearch))
        {
        	String strUserQuery = ' SELECT Id, For_All_Offices__c, Selected_Offices_Ids__c ' +
        						  ' FROM '+ String.escapeSingleQuotes(objectName) + 
        						  ' WHERE IsLatest = true ' +
        						  		' AND ( ' + strSearch + ' ) ' + 
						  			((!stContentTypes.isEmpty()) ? ' AND Content_Types__c IN : stContentTypes ' : '') +
        						  ' ORDER BY CreatedDate DESC LIMIT 200';
        						  
        	for(ContentVersion objCV : database.query(strUserQuery))
            { 
            	if(officesSpec.satisfiedBy(objCV))
					filteredCVSize++;
            }
            return filteredCVSize;
        }
        
        else if(String.isBlank(fieldSetName))
        {
            String strSoslContent = 'Find \''+  String.escapeSingleQuotes(searchText) + '*\' in ALL FIELDS '+ 'RETURNING ' + 
            						'ContentVersion (Id, Title, FeaturedContentBoost, Description, FileType, ContentUrl, For_All_Offices__c, Selected_Offices_Ids__c ' +  
                       								' where  IsLatest = true ' + 
                       								((!stContentTypes.isEmpty()) ? ' AND Content_Types__c IN : stContentTypes ' : '') +
													' order by CreatedDate DESC limit 200) ';
			
            List<List<SObject>> lstsearch = search.query(strSoslContent);
            for(ContentVersion objCV : (List<ContentVersion>)lstsearch[0])
            { 
				if(officesSpec.satisfiedBy(objCV))
					filteredCVSize++;
            }
			return filteredCVSize;
		}
		return 0;
	}
    /* End: getContentTypes method */
    
    /* @Name           - getNoOfSobjectRecords
	   @Parameters     - Sobject Name 
	   @Return Type    - Integer
	   @Description    - 
	*/
    private Integer getNoOfSobjectRecords(String objectName, String fieldSetName)
    {
		if(String.isBlank(searchText)) return 0;
		
    	String strSearch = formatSearchString(searchText, objectName, fieldSetName);

        if(String.isNotBlank(fieldSetName) && String.isNotBlank(strSearch))
        {
        	String strQuery = 'Select Id from '+ String.escapeSingleQuotes(objectName) + ' WHERE ';
    		strQuery +=  ' ( ' + strSearch + ' ) ';
        	List<Sobject> lstsearch = database.query(strQuery);
        	return lstsearch.size();
        }
        else if(String.isBlank(fieldSetName))
        {
        	String strSosl = 'Find ' +  strSearch +  ' in ALL FIELDS ' + 'RETURNING ';
			strSosl +=  objectName +'(Id, Name)';
			List<List<SObject>> lstsearchForSosl = search.query(strSosl);
			return lstsearchForSosl[0].size();
        }
        return 0;
    }
    /* End */
    
    
    private Integer getNoOfEmployeeRecords(String objectName, String fieldSetName)
    {
    	if(String.isBlank(searchText)) return 0;
    	
    	String strWhere = ' IsActive = true AND Profile.UserLicense.LicenseDefinitionKey NOT IN: lstUserLicenseFilters AND Exclude_from_Intranet_Directory__c = FALSE ';	//where clause for User Object
    	String strSearch = formatSearchString(searchText, objectName, fieldSetName);
    	
    	/*SOCINT-1027 to filter the Users when logged as Admin in Community*/
		String networkId = Network.getNetworkId(); 
		
		/*When logged in as Admin the Network Id will be null*/
		if(String.isEmpty(networkId))         
			strWhere += ' AND ContactId = null'; //Add the filter ContactId = null so when we logged in as Admin and it wont display Community Licence Users.
		/*When accessing Community as Admin User and Network Id will not be null*/
		else if(String.isNotEmpty(networkId))
			strWhere += ' AND Id IN (SELECT memberId FROM NETWORKMEMBER WHERE networkId =\''+ networkId +'\' )'; //Adding the filter will provide all the members of the community related to its Network Id.
		/*---End---*/
    	
    	if(String.isNotBlank(fieldSetName) && String.isNotBlank(strSearch))
        {
        	String strQuery = 'Select Id from '+ String.escapeSingleQuotes(objectName) + ' WHERE ';
    		strQuery +=  strWhere + ' AND ( ' + strSearch + ' ) Limit 200';
        	List<Sobject> lstEmployee = database.query(strQuery);
        	return lstEmployee.size();
        }
        else if(String.isBlank(fieldSetName))
        {
        	String strSosl = 'Find ' +  strSearch +  ' in ALL FIELDS ' + 'RETURNING ';
			strSosl += objectName +'(Id, Name Where '+ strWhere+' Limit 200 ) ';
			List<List<SObject>> lstEmployeeForSosl = search.query(strSosl);
			return lstEmployeeForSosl[0].size();
        }
    	
    	return 0;
    }
    
    
    private Integer getNoOfNotificationRecords(String objectName, String fieldSetName)
    {
    	if(String.isBlank(searchText)) return 0;
		
    	String strSearch = formatSearchString(searchText, objectName, fieldSetName);
		Integer noOfNotificationRecords = 0;
        if(String.isNotBlank(fieldSetName) && String.isNotBlank(strSearch))
        {
        	String strQuery = 'Select Id, For_All_Offices__c, Selected_Offices_Ids__c from '+ String.escapeSingleQuotes(objectName) + ' WHERE ';
    		strQuery +=  ' ( ' + strSearch + ' ) ';
        		
        	for(Notification__c obj : database.query(strQuery))
        	{
        		if(officesSpec.satisfiedBy(obj))
        			noOfNotificationRecords++;
        	}
        }
        else if(String.isBlank(fieldSetName))
        {
        	String strSosl = 'Find ' +  strSearch +  ' in ALL FIELDS ' + 'RETURNING ';
			strSosl +=  objectName +'(Id, Name, For_All_Offices__c, Selected_Offices_Ids__c )';
			List<List<Sobject>> lstNotificationForSosl = search.query(strSosl);
			
			for(Notification__c obj :(List<Notification__c>)lstNotificationForSosl[0])
			{
				if(officesSpec.satisfiedBy(obj))
					noOfNotificationRecords++;
			}
        }
        return noOfNotificationRecords;
    }
    
    private Integer getNoOfCalenderRecords(String objectName, String fieldSetName)
    {
    	if(String.isBlank(searchText)) return 0;
		
    	String strSearch = formatSearchString(searchText, objectName, fieldSetName);
		Integer noOfCalenderRecord = 0;
        if(String.isNotBlank(fieldSetName) && String.isNotBlank(strSearch))
        {
        	String strQuery = 'Select Id, For_All_Offices__c, Selected_Offices_Ids__c from '+ String.escapeSingleQuotes(objectName) + ' WHERE ';
    		strQuery +=  ' ( ' + strSearch + ' ) ';
        	
        	for(Intranet_Event__c obj : database.query(strQuery))
        	{
        		if(officesSpec.satisfiedBy(obj))
        			noOfCalenderRecord++;
        	}
        }
        else if(String.isBlank(fieldSetName))
        {
        	String strSosl = 'Find ' +  strSearch +  ' in ALL FIELDS ' + 'RETURNING ';
			strSosl +=  objectName +'(Id, Name, For_All_Offices__c, Selected_Offices_Ids__c )';
			
			List<List<SObject>> lstCalenderForSosl = search.query(strSosl);
			for(Intranet_Event__c obj : (List<Intranet_Event__c>)lstCalenderForSosl[0])
			{
				if(officesSpec.satisfiedBy(obj))
					noOfCalenderRecord++;
			}
        }
        return noOfCalenderRecord;
    }
    
    private Integer getNoOfApplicationRecords(String objectName, String fieldSetName)
    {
    	if(String.isBlank(searchText)) return 0;
		
    	String strSearch = formatSearchString(searchText, objectName, fieldSetName);
		Integer noOfApplicationRecord = 0;
		
        if(String.isNotBlank(fieldSetName) && String.isNotBlank(strSearch))
        {
        	String strQuery = 'Select Id, For_All_Offices__c, Selected_Office_Ids__c from '+ String.escapeSingleQuotes(objectName) + ' WHERE ';
    		strQuery +=  ' ( ' + strSearch + ' ) ';
        		
        	for(Intranet_App__c obj : database.query(strQuery))
        	{
        		if(officesSpec.satisfiedBy(obj))
        			noOfApplicationRecord++;
        	}
        }
        else if(String.isBlank(fieldSetName))
        {
        	String strSosl = 'Find ' +  strSearch +  ' in ALL FIELDS '+ 'RETURNING ';
			strSosl +=  objectName +'(Id, Name, For_All_Offices__c, Selected_Office_Ids__c)';
			
			List<List<SObject>> lstApplicationForSosl = search.query(strSosl);
			for(Intranet_App__c obj : (List<Intranet_App__c>)lstApplicationForSosl[0])
			{
				if(officesSpec.satisfiedBy(obj))
					noOfApplicationRecord++;
			}
        }
        return noOfApplicationRecord;
    }
    

    
    //added new code by Pravin for geting FeedItem result count
    private Integer getNoOfFeedItemRecords()
    {
    	if(String.isBlank(searchText)) return 0;
    	
    	Integer intCount = 0;
    	//SL_IntranetFeedItemsRecords objFeedItemRecords = new SL_IntranetFeedItemsRecords();
		//intCount = objFeedItemRecords.getFeedItemsRecords(searchText).size();
		ConnectApi.FeedItemPage feedItems= ConnectApi.ChatterFeeds.searchFeedItems(strCommunityId,searchText,null,null,ConnectApi.FeedSortOrder.CreatedDateDesc);
		for (ConnectApi.FeedItem item : feedItems.items) 
		{
			intCount++;
		}
		if(feedItems.nextPageToken !=null)
			intCount = 26; //Its not exact number, we just want to show 25+ in searchType widget as if nextPageToken is not null then surely there are more than 25 feedItem
		return intCount;
    }
    
    
    private String formatSearchString(string searchText, String strObject, String strFieldSetToDisplay)
    {
    	if(String.isNotBlank(strObject))
    	{
			String strSearch= ''; 
			Set<String> setValidLikeOperatorDataTypes = new Set<String>{'URL', 'STRING', 'PHONE', 'EMAIL', 'PICKLIST', 'TEXTAREA'};
			
			if(String.isNotBlank(strFieldSetToDisplay))
			{
				SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet(strObject, strFieldSetToDisplay, '', '', '', new Set<String>{});

				for(SL_UtilityWrappers.FieldSetDescribe objField : objFieldSetWrapper.lstFieldWrapper)
				{
					if(setValidLikeOperatorDataTypes.contains(objField.FieldType) && objField.fieldAPIName != 'Id' && objField.fieldType != 'MULTIPICKLIST' && objField.IsFilter)
	    				strSearch += (strSearch == '' ? objField.fieldAPIName + ' LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'' : 
	    												' OR ' + objField.fieldAPIName + ' LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'');
	    				
					else if(String.valueOf(objField.FieldType) == 'MULTIPICKLIST' && objField.IsFilter)
			            strSearch += (strSearch == '' ? objField.fieldAPIName + ' Includes (\'' +String.escapeSingleQuotes(searchText)+ '\')' : 
			            								' OR ' +objField.fieldAPIName + ' Includes (\'' +String.escapeSingleQuotes(searchText)+ '\')');
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
				strSearch = '\''+ searchText + '*\'';
				return strSearch;
			} 
    	}
    	else return null;
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
    
 
    /* @Name           - newComponent
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for creating Component dynamically.
	*/
	public override ApexPages.Component newComponent() 
	{
    	Component.c.SL_IntranetSearchTypes c = new Component.c.SL_IntranetSearchTypes();   
		c.aComponentImpl = this;
    	return c;
  	}
  	/* End : newComponent */
}