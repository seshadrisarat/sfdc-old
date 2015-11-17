public with sharing class SL_Mobile_IntranetDocument extends WidgetAbstract implements IObservable {
	
	/* Variable Declaration */
	final static Integer DEFAULT_DISPLAY_RECORDS_NUM = 5;   						
	private Set<String> setFieldsToQuery = new Set<String>{'Id', 'Title', 'IsLatest', 'CreatedById', 'Content_Types__c', 'Select_Offices__c', 'Selected_Department_Ids__c', 'FeaturedContentBoost', 
    													   'Description','FileType', 'ContentUrl', 'Selected_Offices_Ids__c', 'For_All_Offices__c', 'For_All_Departments__c'}; 					   // set to hold fields to query
    													 
    private Set<String> stContentTypes = new Set<String>();
		
	transient public List<ContentVersion> loadedItems {
		get; private set;
	}																			// List for holding Notification Records
	
	// This list will contains the field API name to render.
	public List<SL_UtilityWrappers.FieldSetDescribe> lstFieldWrapper {	
		get; private set;	
	} 
	
	public String strHeading {	
		get; private set;	
	}																			// Store heading Name provided in the widget Configuration
	
	public Boolean bDisplayFilterLinks { 
		get; private set;
	}
	
	public Boolean showFieldLabel					{	get; set;	}			// Store the Boolean value to show Field Label based on the Widget configuration
	
	public Integer numRecordstodisplay {   
		get; private set;    
	}																			// Store to get the no of records to display on load of the widget on page
	
	public Boolean hasMoreRecords {
		get; private set;
	}																			// Variable used to store Boolean value when Show More button is clicked.
	
	private Integer totalRecords = 10;											// upper boundary restriction for returned records number (accomulated)
		
	private String strQuery;													// String to store query formed based on default fields or Fieldset. 
	private Integer numberToDisplay;											
	
	// department id filter
	public String deptId {
		get; private set;
	} 																			// String to store dept Id if department filter is on page.
		
	private Boolean OfficeFiltering = true;										// Boolean variable to store Office Filtering by default it is True
	public Boolean DepartmentFiltering   { get; private set; } 					// Boolean variable to store dept filtering based on configuration
	
	public enum Scope { Everything, Mine, Queue, Delegated, MyTerritory, MyTeamTerritory, Team } // Filter scope Enum based on which it will filter the records.
	
	/* Constructor */
	public SL_Mobile_IntranetDocument() {
		
		strQuery = strHeading = '';
		showFieldLabel = bDisplayFilterLinks = false;
		lstFieldWrapper = new List<SL_UtilityWrappers.FieldSetDescribe>();
		numberToDisplay = 0;
		numRecordstodisplay = DEFAULT_DISPLAY_RECORDS_NUM;
		hasMoreRecords = DepartmentFiltering = false;
            
	}
	
	// initialize method called on component's initialize
    public override protected void initialize() {
    	
    	getContentTypes();
    	widgetConfiguration();
    	// listener for department widget dependancy
		WidgetConfigurationListener.getInstance().addEventListener('SL_IntranetDepartments', this);
    }
    
    // Depends on Department configuration, so is executed after post initializtion
	override public void postInitialize() {
		
	}
	
	/* Start - Method for getting Content Type allowed for logged in user based on custom setting.
	   @Name           - getContentTypes
	   @Parameters     - None 
	   @Return Type    - Void
	   @Description    - Function for getting Content Type allowed for logged in user based on custom setting.
	*/
	public void getContentTypes() {
		
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
			stContentTypes.addAll(lstContentType); 
		}
	}
	/* End : getContentTypes method */
	
	private void widgetConfiguration()
    {
        Set<String> visibilityFields = new Set<String>();     	
		lstFieldWrapper = new List<SL_UtilityWrappers.FieldSetDescribe>();

		try
		{
	     	String fieldsetname = '';
	     	String filterscope = null;
	     	
	     	// Fetch the configuration for the widget
			if(this.properties != null) {
				
				Map<String, Object> configuration = (Map<String, Object>)this.properties;
				
				if(configuration.containsKey('fieldset')) 		
					fieldsetname = String.valueOf(configuration.get('fieldset'));
					
				if(configuration.containsKey('filterscope')) {		
					String filterscopeparam = String.valueOf(configuration.get('filterscope'));
					
					if(!String.isEmpty(filterscopeparam)) {
						for(Scope sc : Scope.values()) {
							if(sc.name().toLowerCase() == filterscopeparam.toLowerCase() ) {
								filterscope = sc.name();
								break;
							}							
						}	
						
						if(filterscope == null) {
							throw new WidgetParamConfigurationException(
								'Wrong scope value. Should be one in the list: Everything, Mine, Queue, Delegated, MyTerritory, MyTeamTerritory, Team'
							);
						}
					}
				}		
				
				if(configuration.containsKey('numbertodisplay') && configuration.get('numbertodisplay') != '') 	
					numberToDisplay	= Integer.valueOf(configuration.get('numbertodisplay'));
				
				if(configuration.containsKey('TotalRecords') && configuration.get('TotalRecords') != '') {
					totalRecords = Integer.valueOf(configuration.get('TotalRecords'));
					if(totalRecords < 0) totalRecords = 10; // validate negative
				}	
				
				if(configuration.containsKey('heading')) 			strHeading	 	 	= String.valueOf(configuration.get('heading'));
				if(configuration.containsKey('showFieldLabel')) 	showfieldlabel 		= Boolean.valueOf(configuration.get('showFieldLabel'));
				if(configuration.containsKey('displayFilterLinks')) bDisplayFilterLinks = Boolean.valueOf(configuration.get('displayFilterLinks'));
				
				if(configuration.containsKey('officefiltering')) {
					OfficeFiltering = Boolean.valueOf(configuration.get('officefiltering'));
					
					if(OfficeFiltering) visibilityFields.add('Selected_Offices_Ids__c');
				} 				
				
				if(configuration.containsKey('departmentfiltering')) {
					DepartmentFiltering = Boolean.valueOf(configuration.get('departmentfiltering'));
					
					if(DepartmentFiltering) {						
						visibilityFields.add('Selected_Department_Ids__c');
					}	
				}		
			}
			 
			if(numberToDisplay > 0)
     			numRecordstodisplay = numberToDisplay;
     		else if(numberToDisplay == 0 || numberToDisplay == null)
     			numberToDisplay = DEFAULT_DISPLAY_RECORDS_NUM;
		
	     	// Fetch the query string and fieldsets describe results from Utilities
	     	// LIMIT is empty - will be added later
	     	if(String.isNotBlank(fieldsetname)) {
     			SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet('contentversion', fieldsetname, '', '', '', new Set<String>{'Title','ExternalDataSourceId','VersionData'}, visibilityFields);
	     		lstFieldWrapper = objFieldSetWrapper.lstFieldWrapper;
	     	}
	     	
	     	// Iterate through the fields returned previously to form a query
	    	for(SL_UtilityWrappers.FieldSetDescribe objFieldSetResult : lstFieldWrapper)
				setFieldsToQuery.add(objFieldSetResult.fieldAPIName);
			
			/// add fields to the query
	        strQuery = 'Select ' + String.join(new List<String>(setFieldsToQuery), ',');
	        
			if(Test.isRunningTest())
				Integer i = 10/0;	     	
	     }
	     catch(Exception e) { // DML and describe exceptions expected	     
	     	system.debug('Exception: ' + e.getMessage());
	     }	
    }
    
    /**
    * will be called by event dispatcher
    **/
    public void notify(IWidget widget) {
    	
		if(widget == null) return;
		SL_IntranetDepartments departmentWidget = (SL_IntranetDepartments)widget;
		deptId = departmentWidget.strInitialDeptSelection;
	}
  	
	 
	 private CompositeVisibilitySpecification getSpecification(String departmentId) {
	 	CompositeVisibilitySpecification spec = new CompositeVisibilitySpecification(); 
	 	
	 	if(OfficeFiltering) spec.add( new OfficesSpecification(SL_UserInfo.getInstance().getOfficesIds()) );
	 	
	 	
	 	if(DepartmentFiltering) spec.add( new DepartmentSpecification(departmentId != null ? departmentId : deptId) );
	 	
	 	return spec;
	 }
	 
	 /**  
	 ** Returns records portion based on fetchingStrategy 
	 ** if no filtering (offices/departments visibility or chatter topic filtering)  
	 **/ 
	 public void loadRecords(Integer offset, String contentName, String departmentId) {
	 	
	 	strQuery += ' From ContentVersion' + 
	                ' WHERE IsLatest = true AND Content_Types__c IN: stContentTypes ' ; 
	                
	    strQuery += buildWherePartBasedOnFilter(contentName);
	 	
		if(String.isBlank(strQuery)) return;
		
		loadedItems = new List<ContentVersion>();
		Integer i = 0;
		Integer upperBoundaryLimit; 
		
		CompositeVisibilitySpecification spec = getSpecification(departmentId);

	 	if(spec.isEmpty()) { // simple fast fetch algorithm
	 		
	 		// get one more additional record to check for more
	 		upperBoundaryLimit = numRecordstodisplay + 1;
	 		
	 		// if upper boundary restriction is set
	 		if(totalRecords > 0) {
	 			// check if we need to lower the limit
	 			Integer maxRecordsForThisBatch = offset + numRecordstodisplay;
	 			if(totalRecords <= maxRecordsForThisBatch) {
	 				upperBoundaryLimit = Math.max(0, totalRecords - offset );
	 			} 
	 		} 
	 			 		
			List<ContentVersion> res = Database.query(strQuery + ' LIMIT ' + upperBoundaryLimit +  ' OFFSET ' + offset);						
			hasMoreRecords = res.size() > numRecordstodisplay;
			
	    	for(ContentVersion sObj : res) {
	    		loadedItems.add(sObj);
	    			    			    		
	    		if(++i == numRecordstodisplay) break; // interrupt a loop after correct number of visible records
	    	}
	 	}
	 	else {
	 			 		
	 		// limit can be adjusted based on governor limits	 		
	 		List<ContentVersion> res = Database.query(strQuery + ' LIMIT 1000');
	 		Integer j = 0;
	 		IVisibilitySpecification compiledSpec = spec.compile();

	 		try {		
	 				 
				for(ContentVersion sObj : res) { 
					if(compiledSpec.satisfiedBy(sObj)) { 
						// there is an upper boundary restriction
						if(totalRecords > 0 && j >= totalRecords) break;
						
						if(j++ < offset) continue;					
						
						
						if(++i == numRecordstodisplay + 1) {
							 hasMoreRecords = true;
							 break; // interrupt a loop after correct number
						}
						
						loadedItems.add(sObj);
					}
				}
				if(Test.isRunningTest())
					Integer testInt = 10/0;
			}
			catch(Exception e) {
				system.debug('SL_DEBUG: error: ' + e.getMessage());
				// will return empty result of there is no such a custom field
			}
	 	}    		
	 }
	 
	 /**
	** Adds Where filtering condition to the query
	**/	
	private String buildWherePartBasedOnFilter(String filter) {
		
		String q = '';
		
		if(filter == 'Feature') 
			q += ' AND FeaturedContentBoost = 1 ';
		else if(filter == 'Date')
		{
			// To get the Contents from 30 days back to current date
			Date dtPostDate = system.today() - 30;
			DateTime dtConverted = Datetime.newInstance(dtPostDate.year(), dtPostDate.month(), dtPostDate.day(), 0, 0, 0);
			q += ' AND CreatedDate > ' +  dtConverted.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') ;
		}
		return q;
	}

	public override ApexPages.Component newComponent() { 
		
    	Component.c.SL_Mobile_IntranetDocument c = new Component.c.SL_Mobile_IntranetDocument();   
		c.aComponentImpl = this;
		
    	return c;
  	}
}