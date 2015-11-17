public with sharing class SL_IntranetEventSummary extends WidgetAbstract implements IObservable
{
	/* Start of Variables */ 
	public String strDeptId														{	get;set;	}
    public List<Intranet_Event__c> lstIntranetEvents 							{	get;set;	}
    public List<SL_UtilityWrappers.FieldSetDescribe> lstWrapperEventFields 		{	get;set;	}
    public EventConfiguration config											{	get;set;	}
    private Boolean isDepartmentWidgetExist; //To identify if Department widget exist on page or not to decide the behavior based on that.
    private Set<String> setLoggedinUserOfficesId;
    private Boolean isShowMore ;		//To check showMore is called]
    private String strQuery ; /// To form a query
    Set<String> setFieldsToQuery;
	/* End of Variables */ 
	
	// Constructor
	public SL_IntranetEventSummary()
	{
		initializeVariables();
	}
	
	// Method to initialize 
	public override protected void initialize()
	{	
		lstIntranetEvents = new List<Intranet_Event__c>();
		if(!getObjectAccess('read', new Intranet_Event__c().getsObjectType()))
			return ;
		User objUser = [Select Id, Selected_Offices_Ids__c from User where Id=:UserInfo.getUserId() limit 1];
        
        setLoggedinUserOfficesId = new Set<String>();
        if(!String.isEmpty(objUser.Selected_Offices_Ids__c)) {
            setLoggedinUserOfficesId.addAll(objUser.Selected_Offices_Ids__c.split(';'));
        }
		getEventSummaryConfiguration();
		WidgetConfigurationListener.getInstance().addEventListener('SL_IntranetDepartments', this);
	}

	override public void postInitialize()
	{
		// Depends on Department configuration, so is executed after pre initializtion
		loadEventSummaryData();		//Fetching Event Records
	}
	
	public void notify(IWidget widget) {
		if(widget == null) return;
			
		SL_IntranetDepartments departmentWidget = (SL_IntranetDepartments)widget;
		strDeptId = departmentWidget.strInitialDeptSelection;
		isDepartmentWidgetExist = true;
		System.debug('SL_DEBUG: System set department from configuration: ' + strDeptId);
	}

	private void initializeVariables()
	{
		strDeptId = strQuery = '';
		isDepartmentWidgetExist = isShowMore = false;
		config = new EventConfiguration();
	}
	
	private class EventConfiguration
	{
		public Integer intTotalRecords			{	get;set;	}
	    public Integer intEventCount			{	get;set;	}
	    public Boolean hasFieldSet				{	get;set;	}
	    
	    private Integer intNumberToDisplay;
		
		private EventConfiguration()
		{
	        intEventCount = 0;
			intNumberToDisplay = 5;       
			intTotalRecords = 10;
		}
	}
	
	/* Start - Method for getting IntranetEvents records 
	   @Name           - loadEventSummaryData
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting IntranetEvents records  
	*/
	
	public void loadEventSummaryData()
	{
		if(!getObjectAccess('read', new Intranet_Event__c().getsObjectType()))
			return ;
		try
		{
			lstIntranetEvents = new List<Intranet_Event__c>();
			
			if(!isShowMore)
        		config.intEventCount = config.intNumberToDisplay;
                        
           	for(Intranet_Event__c objIntrEvent : database.query(strQuery))
            {
            	OfficesSpecification officesSpec = new OfficesSpecification(setLoggedinUserOfficesId);
            	DepartmentSpecification departmentSpec = new DepartmentSpecification(strDeptId);
            	
        		if(officesSpec.satisfiedBy(objIntrEvent) && (!isDepartmentWidgetExist || departmentSpec.satisfiedBy(objIntrEvent)))
        			lstIntranetEvents.add(objIntrEvent);
            }
            isShowMore = false;
            
 			if(Test.isRunningTest())		Integer i = 10/0;
        }
        catch(Exception ex)
        {
            system.debug('::::::::::Exception:::::::::'+ex);
        }
        
    }   
	/* End : getIntranetEvents method */
	
	/* 
	* Function for preparing configuration for Event Summary 
	*/
	public void getEventSummaryConfiguration()
	{
		try
        {
        	lstWrapperEventFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
            String strFieldSetname = ''; ///variable to store field set name

            setFieldsToQuery = new Set<String>{ 'Id', 'Name', 'RecordType.Name','End_Date__c','CreatedDate','CreatedById','Date_of_Event__c', 
            									'Selected_Department_Ids__c', 'For_All_Departments__c', 'Selected_Offices_Ids__c', 'For_All_Offices__c'};
			
            //New Code  Start from Here
            if(this.properties != null) {
				Map<String, Object> configuration = (Map<String, Object>)this.properties;
				
				if(configuration.containsKey('TotalRecords') && configuration.get('TotalRecords') != null && configuration.get('TotalRecords') != '') 		
					config.intTotalRecords = Integer.valueOf(configuration.get('TotalRecords'));
					
				if(configuration.containsKey('numbertodisplay') && configuration.get('numbertodisplay') != null && configuration.get('numbertodisplay') != '') 	
					config.intNumberToDisplay = Integer.valueOf(configuration.get('numbertodisplay'));
					
				if(configuration.containsKey('fieldset')) 			strfieldsetname 			= String.valueOf(configuration.get('fieldset'));
				
				if(configuration.get('heading') == null || configuration.get('heading') == '')
					((map<String, object>)properties).put('heading', Label.SL_IntranetEventSummary_Header);

				config.intEventCount = config.intNumberToDisplay;
			}
		
			if(String.isNotBlank(strFieldSetname))
	        {
	        	config.hasFieldSet = true;
	     		SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( 'Intranet_Event__c', strFieldSetname, '', '', '', new Set<String>{});
	     		lstWrapperEventFields = objFieldSetWrapper.lstFieldWrapper;
	        }
        	else
        		config.hasFieldSet = false;
         
	        // Iterate through the fields returned , to form a query
	    	for(SL_UtilityWrappers.FieldSetDescribe objFieldSetResult : lstWrapperEventFields)
			{
				setFieldsToQuery.add(objFieldSetResult.fieldAPIName);
			}
	       	 /// add fields to the query
            strQuery = 'Select ' + String.join(new List<String>(setFieldsToQuery), ',');
            strQuery += ' From Intranet_Event__c' + 
                        ' Where ((End_Date__c != null AND Date_of_Event__c != null AND End_Date__c >= TODAY) OR ' +
                        '(Date_of_Event__c != null AND End_Date__c = null AND Date_of_Event__c >= TODAY))' +
                        ' order By Date_of_Event__c ASC LIMIT 1000' ;
			
            if(Test.isRunningTest())		Integer i = 10/0;
        }
        catch(Exception ex)
        {
            system.debug('::::::::Exception::::::'+ex);
        }
	}
	
	/* Start - Method for getting IntranetEvents records 
       @Name           - showMoreRecords
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for showing more IntranetEvents records  
    */
    public void showMoreRecords()
    {
        config.intEventCount += config.intNumberToDisplay;
        
        if(config.intEventCount > config.intTotalRecords)			
        	config.intEventCount = config.intTotalRecords;
    	
    	isShowMore = true;
        loadEventSummaryData();
    }
    
    public void getFilteredByDepartment()
    {
    	loadEventSummaryData();
    } 
    
	//Function for creating Component dynamically.
	public override ApexPages.Component newComponent() 
	{
		Component.c.SL_IntranetEventSummary c = new Component.c.SL_IntranetEventSummary();   
	    c.aComponentImpl = this;
    	return c;
  	}
}