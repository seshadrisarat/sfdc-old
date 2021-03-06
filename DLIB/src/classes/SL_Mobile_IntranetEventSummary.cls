public with sharing class SL_Mobile_IntranetEventSummary extends WidgetAbstract implements IObservable {
	
	// default contansts
	final static Integer DEFAULT_DISPLAY_RECORDS_NUM = 5;   
		
	transient public List<Intranet_Event__c> loadedItems {
		get; private set;
	}
	
	// This list will contains the field API name to render.
	public List<SL_UtilityWrappers.FieldSetDescribe> lstFieldWrapper {	
		get; private set;	
	} 
	
	public String strHeading {	
		get; private set;	
	}
	
	//public Boolean showFeed							{	get;set;	}//<! This variable is used to decide whether to show the feeds.
	public Boolean showFieldLabel					{	get;set;	}	
	
	public Integer numRecordstodisplay {   
		get; private set;    
	}
	
	public Boolean hasMoreRecords {
		get; private set;
	}
	
	// upper boundary restriction for returned records number (accomulated)
	private Integer totalRecords = 10;
		
	private String strQuery;
	private Integer numberToDisplay;
	
	// department id filter
	public String deptId {
		get; private set;
	} 
		
	private Boolean officeFiltering = true;
	public Boolean departmentFiltering   { get; private set; } 	
	public Boolean chatterTopicFiltering { get; private set; }	
	
	public enum Scope { Everything, Mine, Queue, Delegated, MyTerritory, MyTeamTerritory, Team }
	
	public SL_Mobile_IntranetEventSummary() {	
		//objResultWrapper = new InfoResultWrapper ();
		strQuery = strHeading = '';
		showFieldLabel = false;
		lstFieldWrapper = new List<SL_UtilityWrappers.FieldSetDescribe>();
		numberToDisplay = 0;
		numRecordstodisplay = DEFAULT_DISPLAY_RECORDS_NUM;
		hasMoreRecords = false;
		
		departmentFiltering = false;
		chatterTopicFiltering = false;
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
		Set<String> setFieldsToQuery = new Set<String>{'Selected_Offices_Ids__c', 'Selected_Department_Ids__c'};
		
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
				if(configuration.containsKey('showfieldlabel')) 	showfieldlabel 		= Boolean.valueOf(configuration.get('showfieldlabel'));
				
				if(configuration.containsKey('officeFiltering')) {
					officeFiltering = Boolean.valueOf(configuration.get('officeFiltering'));
					
					if(officeFiltering) visibilityFields.add('Selected_Offices_Ids__c');
				} 				
				
				if(configuration.containsKey('departmentFiltering')) {
					departmentFiltering = Boolean.valueOf(configuration.get('departmentFiltering'));
					
					if(departmentFiltering) 						
						visibilityFields.add('Selected_Department_Ids__c');
				}		
				
				if(configuration.containsKey('chatterTopicFiltering')) 
					chatterTopicFiltering = Boolean.valueOf(configuration.get('chatterTopicFiltering'));
			}
			 
			if(numberToDisplay > 0)
     			numRecordstodisplay = numberToDisplay;
     			
     		else if(numberToDisplay == 0 || numberToDisplay == null)
     			numberToDisplay = DEFAULT_DISPLAY_RECORDS_NUM;
		
	     	// Fetch the query string and fieldsets describe results from Utilities
     		if(String.isNotBlank(fieldsetname)) {
     			SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( 'Intranet_Event__c', fieldsetname, '', '', '', 
																											new Set<String>(), visibilityFields );
	     		lstFieldWrapper = objFieldSetWrapper.lstFieldWrapper;
     		}
     		else
     			lstFieldWrapper = Utilities.describeDefaultFields('Intranet_Event__c', new List<String>{'Name', 'Date_of_Event__c', 'End_Date__c'});
     		
     		for(SL_UtilityWrappers.FieldSetDescribe objField : lstFieldWrapper) {
     			setFieldsToQuery.add(objField.fieldAPIName);
     		}
     		
     		strQuery = 'Select ' + String.join(new List<String>(setFieldsToQuery), ',');
            strQuery += ' From Intranet_Event__c' + 
                        ' Where ((End_Date__c != null AND Date_of_Event__c != null AND End_Date__c >= TODAY) OR ' +
                        '(Date_of_Event__c != null AND End_Date__c = null AND Date_of_Event__c >= TODAY))' +
                        ' order By Date_of_Event__c ASC ' ;
     		
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
	 	
	 	if(officeFiltering)
	 		spec.add( new OfficesSpecification(SL_UserInfo.getInstance().getOfficesIds()) );
	 	
	 	if(departmentFiltering) 
	 		spec.add( new DepartmentSpecification(departmentId != null ? departmentId : deptId) );
	 	
	 	return spec;
	 }
	 
	 /**
	 ** Returns records portion based on fetchingStrategy 
	 ** if no filtering (offices/departments visibility or chatter topic filtering)  
	 **/ 
	 public void loadRecords(Integer offset, String departmentId, String chatterTopicId) {
	 	
		if(String.isBlank(strQuery)) return;
		
		loadedItems = new List<Intranet_Event__c>();
		Integer i = 0;
		Integer upperBoundaryLimit; 
		
		CompositeVisibilitySpecification spec = getSpecification(departmentId, chatterTopicId);
		
	 	if(spec.isEmpty()) { // simple fast fetch algorithm
	 		
	 		// get one more additional record to check for more
	 		upperBoundaryLimit = numRecordstodisplay + 1;
	 		
	 		// if upper boundary restriction is set
	 		if(totalRecords > 0) {
	 			// check if we need to lower the limit
	 			Integer maxRecordsForThisBatch = offset + numRecordstodisplay;
	 			if(totalRecords <= maxRecordsForThisBatch)
	 				upperBoundaryLimit = Math.max(0, totalRecords - offset );
	 		} 
	 			 		
			List<Intranet_Event__c> res = Database.query(strQuery + 'LIMIT ' + upperBoundaryLimit +  ' OFFSET ' + offset);						
			hasMoreRecords = res.size() > numRecordstodisplay;
			
	    	for(Intranet_Event__c sObj : res) {
	    		loadedItems.add(sObj);
	    			    			    		
	    		if(++i == numRecordstodisplay) break; // interrupt a loop after correct number of visible records
	    	}
	 	}
	 	else {	 		
	 		// limit can be adjusted based on governor limits	 		
	 		List<Intranet_Event__c> res = Database.query(strQuery + 'LIMIT 1000');
	 		Integer j = 0;
	 		IVisibilitySpecification compiledSpec = spec.compile();
	 		
	 		try {			 
				for(Intranet_Event__c sObj : res) { 
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
			}
			catch(System.SObjectException e) {
				system.debug('SL_DEBUG: error: ' + e.getMessage());
				// will return empty result of there is no such a custom field
			}
	 	}    		
 		 		
	 }
	
	

	public override ApexPages.Component newComponent(){ 
    	Component.c.SL_Mobile_IntranetEventSummary c = new Component.c.SL_Mobile_IntranetEventSummary();   
		c.aComponentImpl = this;
		
    	return c;
  	}

}