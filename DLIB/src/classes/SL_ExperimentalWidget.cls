public with sharing class SL_ExperimentalWidget extends WidgetAbstract implements IObservable {
	
	// default contansts
	final static Integer DEFAULT_DISPLAY_RECORDS_NUM = 5;   
		
	transient public List<SObject> loadedItems {
		get; private set;
	}
	
	// This list will contains the field API name to render.
	public List<SL_UtilityWrappers.FieldSetDescribe> lstFieldWrapper {	
		get; private set;	
	} 
	
	public String sObjectName {	
		get; private set;	
	}
	
	public String strHeading {	
		get; private set;	
	}
	
	public Boolean showFeed							{	get;set;	}//<! This variable is used to decide whether to show the feeds.
	public Boolean showFieldLabel					{	get;set;	}	
	
	public Integer numRecordstodisplay {   
		get; private set;    
	}
	
	public Boolean hasMoreRecords {
		get; private set;
	}
	
	// upper boundary restriction for returned records number (accomulated)
	private Integer totalRecords = 0;
		
	private String strQuery;
	private Integer numberToDisplay;
	
	// department id filter
	public String deptId {
		get; private set;
	} 
		
	private Boolean IsRespectToOfficeVisibilityRules = false;
	public Boolean IsRespectToDepartmentVisibilityRules   { get; private set; } 	
	public Boolean IsRespectToChatterTopicVisibilityRules { get; private set; }	
	
	public enum Scope { Everything, Mine, Queue, Delegated, MyTerritory, MyTeamTerritory, Team }
	
	public SL_ExperimentalWidget() {	
		strQuery = sObjectName = strHeading = '';
		showFeed = showFieldLabel = false;
		lstFieldWrapper = new List<SL_UtilityWrappers.FieldSetDescribe>();
		numberToDisplay = 0;
		numRecordstodisplay = DEFAULT_DISPLAY_RECORDS_NUM;
		hasMoreRecords = false;
		
		IsRespectToDepartmentVisibilityRules = false;
		IsRespectToChatterTopicVisibilityRules = false;
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
		showFeed = true;
		
		try
		{
	     	String fieldsetname = '';
	     	String filtercriteria = '';
	     	String filterscope = null;
	     	
	     	// Fetch the configuration for the widget
			if(this.properties != null) {
				Map<String, Object> configuration = (Map<String, Object>)this.properties;
				
				if(configuration.containsKey('sobjectname')) {
					sObjectName = String.valueOf(configuration.get('sobjectname'));
				}
				
				if(configuration.containsKey('fieldsetname')) 		
					fieldsetname = String.valueOf(configuration.get('fieldsetname'));
					
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
					
				if(configuration.containsKey('filtercriteria')) { 	
					filtercriteria = String.valueOf(configuration.get('filtercriteria'));
					
					if(!String.isEmpty(filtercriteria) && filtercriteria.toUpperCase().contains(' LIMIT ')) {
						throw new WidgetParamConfigurationException(
							'There is no LIMIT allowed to be set in filtercriteria configuration property'
						);
					}
				}	
				
				if(configuration.containsKey('numbertodisplay') && configuration.get('numbertodisplay') != '') 	
					numberToDisplay	= Integer.valueOf(configuration.get('numbertodisplay'));
				
				if(configuration.containsKey('TotalRecords') && configuration.get('TotalRecords') != '') {
					totalRecords = Integer.valueOf(configuration.get('TotalRecords'));
					if(totalRecords < 0) totalRecords = 0; // validate negative
				}	
				
				if(configuration.containsKey('heading')) 			strHeading	 	 	= String.valueOf(configuration.get('heading'));
				if(configuration.containsKey('showfieldlabel')) 	showfieldlabel 		= Boolean.valueOf(configuration.get('showfieldlabel'));
				if(configuration.containsKey('showfeed')) 			showFeed 			= Boolean.valueOf(configuration.get('showfeed'));
				
				if(configuration.containsKey('RespectToOfficeVisibilityRules')) {
					IsRespectToOfficeVisibilityRules = Boolean.valueOf(configuration.get('RespectToOfficeVisibilityRules'));
					
					if(IsRespectToOfficeVisibilityRules) visibilityFields.add('Selected_Offices_Ids__c');
				} 				
				
				if(configuration.containsKey('RespectToDepartmentVisibilityRules')) {
					IsRespectToDepartmentVisibilityRules = Boolean.valueOf(configuration.get('RespectToDepartmentVisibilityRules'));
					
					if(IsRespectToDepartmentVisibilityRules) {						
						visibilityFields.add(!String.isEmpty(sObjectName) && sObjectName.tolowercase() == 'user' 
							? 'All_Departments__c' 
							: 'For_All_Departments__c');
						visibilityFields.add('Selected_Department_Ids__c');
					}	
				}		
				
				if(configuration.containsKey('RespectToChatterTopicVisibilityRules')) {
					IsRespectToChatterTopicVisibilityRules = Boolean.valueOf(configuration.get('RespectToChatterTopicVisibilityRules'));
				}
			}
			 
			
			
			if(numberToDisplay > 0)
     			numRecordstodisplay = numberToDisplay;
     			
     		else if(numberToDisplay == 0 || numberToDisplay == null)
     			numberToDisplay = DEFAULT_DISPLAY_RECORDS_NUM;
		
	     	// Fetch the query string and fieldsets describe results from Utilities
	     	// LIMIT is empty - will be added later
     		SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( 
     			sObjectName, fieldsetname, filtercriteria, 
				' ORDER BY CreatedDate DESC', '', 
				new Set<String>(), visibilityFields 
			);
     		
     		lstFieldWrapper = objFieldSetWrapper.lstFieldWrapper;
     		strQuery = objFieldSetWrapper.strQuery;
	     }
	     catch(WidgetParamConfigurationException e) {
	     	error = e.getMessage();
	     }
	     catch(SL_CustomException e) {
	     	error = e.getMessage();
	     }
	     catch(System.TypeException e) {
	     	error = e.getMessage();
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
	 	
	 	if(IsRespectToOfficeVisibilityRules) {
	 		spec.add( new OfficesSpecification(SL_UserInfo.getInstance().getOfficesIds()) );
	 	}
	 	
	 	if(IsRespectToDepartmentVisibilityRules) {
	 		spec.add( new DepartmentSpecification(departmentId != null ? departmentId : deptId) );
	 	}
	 	
	 	if(IsRespectToChatterTopicVisibilityRules && chatterTopicId != null) {
	 		spec.add( new ChatterTopicSpecification(chatterTopicId, Utilities.sObjectDesribeHelper(sObjectName).getKeyPrefix() ) ); 
	 	}
	 	
	 	return spec;
	 }
	 
	 /**
	 ** Returns records portion based on fetchingStrategy 
	 ** if no filtering (offices/departments visibility or chatter topic filtering)  
	 **/ 
	 public void loadRecords(Integer offset, String departmentId, String chatterTopicId) {
	 	
		if(String.isBlank(strQuery)) return;
		
		loadedItems = new List<SObject>();
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
	 			if(totalRecords <= maxRecordsForThisBatch) {
	 				upperBoundaryLimit = Math.max(0, totalRecords - offset );
	 			} 
	 		} 
	 			 		
			List<Sobject> res = Database.query(strQuery + 'LIMIT ' + upperBoundaryLimit +  ' OFFSET ' + offset);						
			hasMoreRecords = res.size() > numRecordstodisplay;
			
	    	for(Sobject sObj : res) {
	    		loadedItems.add(sObj);
	    			    			    		
	    		if(++i == numRecordstodisplay) break; // interrupt a loop after correct number of visible records
	    	}
	 	}
	 	else {	 		
	 		// limit can be adjusted based on governor limits	 		
	 		List<Sobject> res = Database.query(strQuery + 'LIMIT 1000');
	 		Integer j = 0;
	 		IVisibilitySpecification compiledSpec = spec.compile();
	 		
	 		try {			 
				for(Sobject sObj : res) { 
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
    	Component.c.SL_ExperimentalWidget c = new Component.c.SL_ExperimentalWidget();   
		c.aComponentImpl = this;
		
    	return c;
  	}
}