/**
* @ClassName    : SL_IntranetRecentDocuments 
* @JIRATicket   : Socint-1040
* @CreatedOn    : 02/12/2014
* @ModifiedBy   : Anil 
* @Description  : This is the Implementation Class for the SL_IntranetRecentDocumentsController.
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
public with sharing class SL_IntranetRecentDocuments extends WidgetAbstract {
	
	/*public variables declaration*/
    public List<RecentlyViewed> lstContentDocument 					{	get;set;	}	// List will contain all the recently viewed, downloaded and created/updated records
    public Integer noOfRecordToDisplay								{	get;set;	}	// This is used to display the records on load of page
    public Integer totalRecordToDisplay								{	get;set;	}	// Total records that need to be displayed on the page
    public Map<String,String> mapCDIdToCVId							{	get;set;	}	// Map which will store contentVersion Id related to contentDocumentId
    public Map<String,String> mapContentDocumentIdToFileType		{ 	get;set;	}	// Map of ContentDocumentId to File Type
    /*private variables declaration*/
    private Integer intNumberToDisplay;													// It is used to store the noOfRecordToDisplay value which will be used during showMore records
	private Set<String> stContentTypes = new Set<String>();								// Set is used to store the content types which are allowed for logged in User
	private Set<String> setLoggedinUserOfficesId;
	
	/* Constructor initialization */
    public SL_IntranetRecentDocuments()
    {
    	system.debug('-----SL_IntranetRecentDocuments------');
    }
    /* End : Constructor initialization */
    
    /* @Name           - initialize
	   @Parameters     - None 
	   @Return Type    - void   
	   @Description    - Function for initializing local and public variables.
	*/
    public override protected void initialize()
    {
    	noOfRecordToDisplay = intNumberToDisplay = 5;
    	totalRecordToDisplay = 10;
    	lstContentDocument = new List<RecentlyViewed>();
    	mapCDIdToCVId = new Map<String,String>();
    	mapContentDocumentIdToFileType = new Map<String,String>(); 
    	setLoggedinUserOfficesId = new Set<String>();
    	
    	if(this.properties != null) {
			
			Map<String, Object> configuration = (Map<String, Object>)this.properties;
			
			if(configuration.containsKey('numbertodisplay') && configuration.get('numbertodisplay') != '' && configuration.get('numbertodisplay') != null) 
				noOfRecordToDisplay = Integer.valueOf(configuration.get('numbertodisplay'));
				
			if(configuration.containsKey('TotalRecords') && configuration.get('TotalRecords') != '' && configuration.get('TotalRecords') != null) 	 
				totalRecordToDisplay = Integer.valueOf(configuration.get('TotalRecords'));
				
			if(configuration.get('heading') == null || configuration.get('heading') == '')
					((map<String, object>)properties).put('heading', Label.SL_Recent_Document);
			
			intNumberToDisplay = noOfRecordToDisplay;
		}
		
		User objUser = [SELECT Id, Selected_Offices_Ids__c, Selected_Department_Ids__c, Name FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        
        if(String.isNotBlank(objUser.Selected_Offices_Ids__c))
            setLoggedinUserOfficesId.addAll(objUser.Selected_Offices_Ids__c.split(';'));
		
    	//To get all the Content types allowed for logged in User on load of page
		getContentTypes();
		//To get all the Recently Viewed records.
		recentContentDocument();
    }
    
    /* Start - Method for getting Content Type allowed for logged in user based on custom setting.
	   @Name           - getContentTypes
	   @Parameters     - None 
	   @Return Type    - Void
	   @Description    - Function for getting Content Type allowed for logged in user based on custom setting.
	*/
	private void getContentTypes()
	{
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
		if(lstContentType.size() > 0) stContentTypes.addAll(lstContentType); 
	}
	/* End : getContentTypes method */
	
	/* @Name           - recentContentDocument
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting all the content document.
	*/
	public void recentContentDocument()
	{
		Set<String> setContentDocumentId = new Set<String>();   								// Set to store all the contentDocumentId
		Map<String,ContentVersion> mapContentDocumentIdToContentVersionId = new Map<String,ContentVersion>();	// Map to store ContentVersion Id respective to and ContentDocument Id 
		lstContentDocument = new List<RecentlyViewed>();		
		mapCDIdToCVId = new Map<String,String>();
		mapContentDocumentIdToFileType = new Map<String,String>();
		OfficesSpecification officesSpec = new OfficesSpecification(setLoggedinUserOfficesId);
		
		//creating Base of content query string
		String strQuery = ' SELECT ContentDocumentId, Selected_Offices_Ids__c, FileType FROM ContentVersion WHERE IsLatest = true ';
		// if contenttypes is not empty then we are adding the filter related to contentTypes
		if(!stContentTypes.isEmpty()) strQuery += ' AND Content_Types__c IN: stContentTypes ';
		
		/*Getting all the Content Document id in a set to filter the records while Querying the recently viewed records*/	
		for(ContentVersion objCV : DataBase.query(strQuery))
		{
			if(officesSpec.satisfiedBy(objCV))
			{
				setContentDocumentId.add(objCV.ContentDocumentId);
				mapContentDocumentIdToContentVersionId.put(objCV.ContentDocumentId,objCV);
			}
		}
		
		//set to store contentDocumentId
		Set<Id> setCDId = new Set<Id>();
		/*Querying all recently viewed records and filtering the records based on set of ContentDocumentId*/
		for(RecentlyViewed objRV : [SELECT Name, Id, LastViewedDate FROM RecentlyViewed WHERE type = 'ContentDocument' AND Id IN: setContentDocumentId])
		{
			if(!setCDId.contains(objRV.Id))
				setCDId.add(objRV.Id);
			else
			 continue;
			 
			if(setCDId.contains(objRV.Id))    
			{	
				lstContentDocument.add(objRV);
				mapCDIdToCVId.put(objRV.Id,mapContentDocumentIdToContentVersionId.get(objRV.Id).Id);
				mapContentDocumentIdToFileType.put(objRV.Id,mapContentDocumentIdToContentVersionId.get(objRV.Id).FileType);
			}
		}
	}
	
	/* @Name           - showMoreRecords
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for showing more records on click of show more.
	*/
	public void showMoreRecords()
	{
		if(Test.isRunningTest()) intNumberToDisplay = 2;
		
		noOfRecordToDisplay += intNumberToDisplay;
		
		if(noOfRecordToDisplay > totalRecordToDisplay) noOfRecordToDisplay = totalRecordToDisplay;
	}
    
    /* @Name           - newComponent
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for creating Component dynamically.
	*/
	public override ApexPages.Component newComponent() 
	{		
    	Component.c.SL_IntranetRecentDocuments c = new Component.c.SL_IntranetRecentDocuments();   
		c.aComponentImpl = this;
    	return c;
  	}
  	/* End : newComponent */
}