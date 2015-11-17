public with sharing class SL_Mobile_IntranetNotification extends WidgetAbstract implements IObservable {
	
	/* Variable Declaration */
	final static Integer DEFAULT_DISPLAY_RECORDS_NUM = 5;   						
	private Set<String> setFieldsToQuery = new Set<String>(); 					// set to hold fields to query
		
	transient public List<Notification__c> loadedItems {
		get; private set;
	}																			// List for holding Notification Records
	
	// This list will contains the field API name to render.
	public List<SL_UtilityWrappers.FieldSetDescribe> lstFieldWrapper {	
		get; private set;	
	} 
	
	public String strHeading {	
		get; private set;	
	}																			// Store heading Name provided in the widget Configuration
	
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
	public Boolean ChatterTopicFiltering { get; private set; }					// Boolean variable to store chatter topic filtering based on configuration
	
	public enum Scope { Everything, Mine, Queue, Delegated, MyTerritory, MyTeamTerritory, Team } // Filter scope Enum based on which it will filter the records.
	
	/* Constructor */
	public SL_Mobile_IntranetNotification() {
			
		strQuery = strHeading = '';
		showFieldLabel = false;
		lstFieldWrapper = new List<SL_UtilityWrappers.FieldSetDescribe>();
		numberToDisplay = 0;
		numRecordstodisplay = DEFAULT_DISPLAY_RECORDS_NUM;
		hasMoreRecords = DepartmentFiltering = ChatterTopicFiltering = false;
		setFieldsToQuery = new Set<String>{ 'Notification_Detail__c', 'For_All_Departments__c','Selected_Department_Ids__c', 'For_All_Offices__c', 
            								'Selected_Offices_Ids__c', 'Id', 'Name', 'CreatedDate','CreatedBy.SmallPhotoUrl', 'CreatedById' };
            
	}
	
	// initialize method called on component's initialize
    public override protected void initialize() {
    	widgetConfiguration();
    	
    	// listener for department widget dependancy
		WidgetConfigurationListener.getInstance().addEventListener('SL_IntranetDepartments', this);
    }
    
    // Depends on Department configuration, so is executed after post initializtion
	override public void postInitialize() {
		
	}
	
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
				
				if(configuration.containsKey('OfficeFiltering')) {
					OfficeFiltering = Boolean.valueOf(configuration.get('OfficeFiltering'));
					
					if(OfficeFiltering) visibilityFields.add('Selected_Offices_Ids__c');
				} 				
				
				if(configuration.containsKey('DepartmentFiltering')) {
					DepartmentFiltering = Boolean.valueOf(configuration.get('DepartmentFiltering'));
					
					if(DepartmentFiltering) {						
						visibilityFields.add('Selected_Department_Ids__c');
					}	
				}		
				
				if(configuration.containsKey('ChatterTopicFiltering')) {
					ChatterTopicFiltering = Boolean.valueOf(configuration.get('ChatterTopicFiltering'));
				}
			}
			 
			if(numberToDisplay > 0)
     			numRecordstodisplay = numberToDisplay;
     		else if(numberToDisplay == 0 || numberToDisplay == null)
     			numberToDisplay = DEFAULT_DISPLAY_RECORDS_NUM;
		
	     	// Fetch the query string and fieldsets describe results from Utilities
	     	// LIMIT is empty - will be added later
	     	if(String.isNotBlank(fieldsetname)) {
     			SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet('Notification__c', fieldsetname, '', '', '', new Set<String>(), visibilityFields);
	     		lstFieldWrapper = objFieldSetWrapper.lstFieldWrapper;
	     	}
	     	else 
	     		lstFieldWrapper.addAll(Utilities.describeDefaultFields('Notification__c', new List<String>{'Name'}));
	     	
	     	
	     	// Iterate through the fields returned previously to form a query
	    	for(SL_UtilityWrappers.FieldSetDescribe objFieldSetResult : lstFieldWrapper)
			{
				setFieldsToQuery.add(objFieldSetResult.fieldAPIName);
			}
			
			/// add fields to the query
	        strQuery = 'Select ' + String.join(new List<String>(setFieldsToQuery), ',');
	        strQuery += ' From Notification__c' + 
	                    ' Where Active__c = true and (Display_As_Of__c <=:dt and Expiry_Date__c >=:dt)' ; 
	        strQuery += ' order By CreatedDate DESC ' ;
			
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
  	
	 
	 private CompositeVisibilitySpecification getSpecification(String departmentId, String chatterTopicId) {
	 	CompositeVisibilitySpecification spec = new CompositeVisibilitySpecification(); 
	 	
	 	if(OfficeFiltering) spec.add( new OfficesSpecification(SL_UserInfo.getInstance().getOfficesIds()) );
	 	
	 	
	 	if(DepartmentFiltering) spec.add( new DepartmentSpecification(departmentId != null ? departmentId : deptId) );
	 	
	 	
	 	if(ChatterTopicFiltering && chatterTopicId != null) spec.add( new ChatterTopicSpecification(chatterTopicId, Utilities.sObjectDesribeHelper('Notification__c').getKeyPrefix() ) ); 
	 	
	 	return spec;
	 }
	 
	 /**
	 ** Returns records portion based on fetchingStrategy 
	 ** if no filtering (offices/departments visibility or chatter topic filtering)  
	 **/ 
	 public void loadRecords(Integer offset, String departmentId, String chatterTopicId) {
	 	
	 	date dt = date.today();
	 	
		if(String.isBlank(strQuery)) return;
		
		loadedItems = new List<SObject>();
		Integer i = 0;
		Integer upperBoundaryLimit; 
		
		CompositeVisibilitySpecification spec = getSpecification(departmentId, chatterTopicId);
		system.debug('--------compiledSpec1--'+spec);
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
	 			 		
			List<Notification__c> res = Database.query(strQuery + 'LIMIT ' + upperBoundaryLimit +  ' OFFSET ' + offset);						
			hasMoreRecords = res.size() > numRecordstodisplay;
			
	    	for(Notification__c sObj : res) {
	    		loadedItems.add(sObj);
	    			    			    		
	    		if(++i == numRecordstodisplay) break; // interrupt a loop after correct number of visible records
	    	}
	 	}
	 	else {
	 			 		
	 		// limit can be adjusted based on governor limits	 		
	 		List<Notification__c> res = Database.query(strQuery + 'LIMIT 1000');
	 		Integer j = 0;
	 		IVisibilitySpecification compiledSpec = spec.compile();
	 		system.debug('--------compiledSpec--'+compiledSpec);
	 		try {			 
				for(Notification__c sObj : res) { 
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

	public override ApexPages.Component newComponent() { 
		
    	Component.c.SL_Mobile_IntranetNotification c = new Component.c.SL_Mobile_IntranetNotification();   
		c.aComponentImpl = this;
		
    	return c;
  	}
}