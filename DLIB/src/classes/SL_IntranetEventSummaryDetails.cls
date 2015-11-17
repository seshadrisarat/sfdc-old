public with sharing class SL_IntranetEventSummaryDetails extends WidgetAbstract implements IChatterable  
{
	/* Start of Variables */
	public SL_IntranetChatterPlugIn Chatter				{	get; set;	}
	public List<Intranet_Event__c> lstIntranetAlerts 	{	get; set;	}
	public String strEventId 							{	get; set;	}	//Used for setting event Id
	public String strFilterDate 						{	get; set;	}	//Used to set date for filtering the events
	public EventDetailConfig detailConfig				{	get; set;	}
	public Boolean initialState							{   get; set;	}
	public Boolean showFeed                         	{   get; set;    }	//This variable is used to decide whether to show the feeds.
	public Boolean isEventCalled						{	get; set;	}	// Used to check is event record is clicked from list
	public String strEventFieldSetName					{	get; set;	}   // This is used to store fieldset name which will be used for IFrame.
	
	private String strQuery;	//used for preparing query string for Office Detail widget

	public List<SL_UtilityWrappers.FieldSetDescribe> lstWrapperEventInfoFields 				{	get; set;	}
	/* End of Variables */
	
	/* Start of Constructor */
	public SL_IntranetEventSummaryDetails()
	{
        initializeVariables();
	}
	/* End of Constructor */
	
	private class EventDetailConfig
	{
		public Integer numOfEventsPerPage 	{	get; set;	}	//Used to set number of events to be displayed
		public Boolean hasFieldset 			{	get; set;	}
		
		private Integer intEventsPerPage;
		
		private EventDetailConfig()
		{
			hasFieldset = false;
			intEventsPerPage = numOfEventsPerPage = 10;
			
			//Getting pagination value for number of records needs to display per page for Event Summary Detail.
	        for(SL_Intranet_PaginationSettings__c objPagination : [ SELECT Name, Calendar_PageSize__c
	    															FROM SL_Intranet_PaginationSettings__c 
	    															WHERE Calendar_PageSize__c != null limit 1])
	        {
	            intEventsPerPage = numOfEventsPerPage = Integer.valueOf(objPagination.Calendar_PageSize__c);
	        }
		}
	}
	
	
	private void initializeVariables()
	{
		strEventId = strFilterDate = strEventFieldSetName = '';
		initialState = showFeed = isEventCalled = false;
        strQuery = 'SELECT Id';
        detailConfig = new EventDetailConfig();
	}
	
	/*Method to get instance of generic chatter component(SL_IntranetChatterPlugIn)*/
    public SL_IntranetChatterPlugIn initChatter() {
		
		SL_IntranetChatterPlugIn plugin = new SL_IntranetChatterPlugIn();
		plugin.initializeParam('Event',id);
		return plugin;
	}  

	public override protected void initialize()
	{
		if(!getObjectAccess('read', new Intranet_Event__c().getsObjectType()))
			return ;
		EventSummaryConfiguration();
		Chatter = initChatter();		//binding generic chatter instance to controller variable
    }

	/* 
	* Function for preparing configuration for Event Summary 
	*/
	public void EventSummaryConfiguration()
	{
		String strfieldsetname = '';
		
		Set<String> setQueryFields = new Set<String>{'Id', 'Name', 'Date_of_Event__c', 'End_Date__c','CreatedById'};
		
		//New Code  Start from Here
		if(this.properties != null) {
			Map<String, Object> configuration = (Map<String, Object>)this.properties;
			
			if(configuration.containsKey('fieldSet')) 		strfieldsetname 	= String.valueOf(configuration.get('fieldSet'));
			
			if(configuration.containsKey('showFeed'))		showFeed 			= Boolean.valueOf(configuration.get('showFeed'));
		}
		
		lstWrapperEventInfoFields = new List<SL_UtilityWrappers.FieldSetDescribe>();

		if(String.isNotBlank(strfieldsetname))
        {	
        	strEventFieldSetName = strfieldsetname;
        	detailConfig.hasFieldset = true;
     		SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( 'Intranet_Event__c', strfieldsetname, '', '', '', new Set<String>{});
     		lstWrapperEventInfoFields = objFieldSetWrapper.lstFieldWrapper;
        }

        // Iterate through the fields returned , to form a query
    	for(SL_UtilityWrappers.FieldSetDescribe objFieldSetResult : lstWrapperEventInfoFields)
		{
			setQueryFields.add(objFieldSetResult.fieldAPIName);
		}

		if(setQueryFields.contains('Id'))
			setQueryFields.remove('Id');

		for(String strFieldsFromFieldset : setQueryFields)
		{
		    strQuery += ', ' + strFieldsFromFieldset;  
		}
		
		strQuery += ' FROM Intranet_Event__c ';
	}
	
	/* Start - Method for getting IntranetEvents records 
	   @Name           - getEvents
	   @Parameters     - None 
	   @Return Type    - void  
	   @Description    - Function for getting event records  
	*/
	public void getEventSummaryDetailData()
	{
		if(!getObjectAccess('read', new Intranet_Event__c().getsObjectType()))
			return ;
		initialState = isEventCalled = true;
		detailConfig.numOfEventsPerPage = detailConfig.intEventsPerPage;
		String strQueryTemp = '';
		Date dateEvtsToDisplay;
		
		if(String.isNotBlank(strEventId))
			strQueryTemp = strQuery + ' WHERE Id =: strEventId';
		else 
			strQueryTemp = strQuery;

		lstIntranetAlerts = database.query(strQueryTemp);
		
	}
	/* End : getEvents method */
	
	/* Start - Method for getting IntranetEvents records 
	   @Name           - deleteEventRecord
	   @Parameters     - None 
	   @Return Type    - void  
	   @Description    - Function for deleting event records  
	*/
	public void deleteEventRecord()
	{
		//fetch the deleted record Id on Action Function call 
		Id eventRecordId = ApexPages.currentPage().getParameters().get('deletedRecordId');
		//Deleting the record
		Intranet_Event__c objER = new Intranet_Event__c(Id = eventRecordId);
		delete objER;
		
		isEventCalled = false;
		/*This section is use to remove the deleted record Id from the List*/
		Integer index = 0;
		for(Intranet_Event__c objEvent : lstIntranetAlerts)
		{
			if(objEvent.id == eventRecordId)
			{
				lstIntranetAlerts.remove(index);
				return;
			}
			index++;
		}
	}
	

	public override ApexPages.Component newComponent() 
	{
    	Component.c.SL_IntranetEventSummaryDetails c = new Component.c.SL_IntranetEventSummaryDetails();   
	    c.aComponentImpl = this;
    	return c;
  	}
}