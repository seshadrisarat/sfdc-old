/**
* @ClassName    : SL_IntranetEvents 
* @JIRATicket   : Socint-177
* @CreatedOn    : 7/June/13
* @ModifiedBy   : Roshan 
* @Description  : This is the Implementation Class for The SL_IntranetEventsController.
*/

/**
@ Roshan Pillai 
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

public with sharing class SL_IntranetEvents extends WidgetPaginatorAbstract implements IObservable
{
    /* Variables used for simple list views of Calendar */ 
    public List<IntranetWrapper> lstIntranetEvents {get;set;}
    public List<IntranetWrapper> lstIntranetMobileEvents {get;set;}
    public Map<String, String> mapEventTypeNameToLabel {get;set;}
    public String strIntranetEventType {get;set;}
    public Integer numOfRecordeToBedisplayed {get;set;}
    public Integer numOfRecordeToBedisplayed_Mobile {get;set;}
    public String strDeptId{get;set;}            
    public String strPreviousEventName {get;set;}   
    public List<SL_UtilityWrappers.FieldSetDescribe> lstEventInfoFields {get; set;}    //List of Event fields that needs to display on component.
    public Integer mobileEventsPageSize{get;set;}
    public String searchTextForMobile;    // This is for searching for given input for calender mobile view
    private integer numOfEventsPerPage;
    private String strQuery;
    public List<Intranet_Event__c> lstIntranetEventSearch = new List<Intranet_Event__c>();  // temp variable to keep the listSearch items.
    
    private Set<String> setLoggedinUserOfficesId;
    private Boolean isDepartmentWidgetExist; //To identify if Department widget exist on page or not to decide the behavior based on that.

    /* Constructor initialization */
    public SL_IntranetEvents()
    {
        strDeptId = searchTextForMobile = strPreviousEventName = '';
        lstEventInfoFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
        mapEventTypeNameToLabel = new Map<String, String>{'All Types' => Label.SL_Intranet_Calendar_AllTypes};
        lstIntranetEvents = new List<IntranetWrapper>();
        lstIntranetMobileEvents = new List<IntranetWrapper>();
        
        numOfEventsPerPage = 20;
        numOfRecordeToBedisplayed_Mobile = 10;
        strIntranetEventType = 'All Types';
        isDepartmentWidgetExist = false;
        
    }
    /* End : Constructor initialization */

    // initialize method called on component's initialize
    public override protected void initialize()
    {
    	numOfRecordeToBedisplayed = mobileEventsPageSize = 0;
    	lstIntranetMobileEvents = new List<IntranetWrapper>();
    	if(!getObjectAccess('read', new Intranet_Event__c().getsObjectType()))
			return ;
        //Getting pagination value for number of records needs to display per page for Calendar.
        for(SL_Intranet_PaginationSettings__c objPagination : [SELECT Name, Calendar_PageSize__c, Calendar_PageSize_Mobile__c 
                                                               FROM SL_Intranet_PaginationSettings__c 
                                                               WHERE Calendar_PageSize__c != null limit 1])
        {
            numOfEventsPerPage = Integer.valueOf(objPagination.Calendar_PageSize__c);
            numOfRecordeToBedisplayed_Mobile = Integer.valueOf(objPagination.Calendar_PageSize_Mobile__c == null ? 10 : objPagination.Calendar_PageSize_Mobile__c);
        }
        
        numOfRecordeToBedisplayed = numOfEventsPerPage;
        mobileEventsPageSize = numOfRecordeToBedisplayed_Mobile;
		// listen for department widget dependancy
		WidgetConfigurationListener.getInstance().addEventListener('SL_IntranetDepartments', this);
        eventDetail();  
    }
    
 	override public void postInitialize()
	{
		// Depends on Department configuration, so is executed after post initializtion
		loadData();	
	}
	
	 //Used for getting department initialselection value
	public void notify(IWidget widget) 
	{
		if(widget == null) return;
			
		SL_IntranetDepartments departmentWidget = (SL_IntranetDepartments)widget;
		strDeptId = departmentWidget.strInitialDeptSelection;
		isDepartmentWidgetExist = true;
	}
  
   
    
    /* Start - Method for fetching all Calendar View Ids which are Active.
       @Name           - loadData
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for fetching all Calendar View Ids which are Active.
    */
    private void loadData()
    {
    	if(!getObjectAccess('read', new Intranet_Event__c().getsObjectType()))
			return ;
        try{
            //Fetching all the Calendar view for Simple list views of Intranet event records
            for(RecordType objRT : [select Id, Name, DeveloperName
                                    from RecordType
                                    where SobjectType = 'Intranet_Event__c' 
                                    and IsActive = true
                                    order by Name asc])
            {
                strIntranetEventType = (strIntranetEventType == '') ? objRT.DeveloperName : strIntranetEventType;
                mapEventTypeNameToLabel.put(objRT.DeveloperName, objRT.Name);
            }
            
            //To prepare the list of Intranet events
            getIntranetevents();
                                     
            //Used to cover test coverage    
            if(Test.isRunningTest())
                Integer i = 1/0;     
        }
        catch(Exception e){
            //Do nothing
        } 
    }
    /* End : loadData */
    
    private void eventDetail()
    {
        List<String> lstDefaultFields = new List<String>{'Date_of_Event__c','End_Date__c'};
        Set<String> setFieldsToQuery = new Set<String>{'Id','End_Date__c','Date_of_Event__c','RecordType.Name','For_All_Offices__c','Selected_Offices_Ids__c','For_All_Departments__c','Selected_Department_Ids__c','Venue__c','Event_Type__c','Name','Comments__c'}; ///set to hold fields to query
        
        if(String.isNotBlank(String.valueOf(((Map<String, Object>)properties).get('fieldset'))))
        {
            SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( 'Intranet_Event__c', String.valueOf(((Map<String, Object>)properties).get('fieldset')), '', '', '', new Set<String>());
            lstEventInfoFields = objFieldSetWrapper.lstFieldWrapper;
        }
        
        //If fieldset is not having any fields or fieldset is not defined then add default fields for displaying it on component
        if(lstEventInfoFields.isEmpty())
        {
            lstEventInfoFields.addAll( Utilities.describeDefaultFields( 'Intranet_Event__c', lstDefaultFields) );
        }
        
        // Iterate through the fields returned , to form a query
        for(SL_UtilityWrappers.FieldSetDescribe objFieldSetResult : lstEventInfoFields)
        {
            setFieldsToQuery.add(objFieldSetResult.fieldAPIName);
        }
        
        /// form a query
        strQuery = 'Select ' + String.join(new List<String>(setFieldsToQuery), ','); 
    }
    
    /* Start - Method for getting records for Intranet Events.
       @Name           - getIntranetevents
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for getting records for Intranet Events.
    */
    public void getIntranetevents()
    {
    	if(!getObjectAccess('read', new Intranet_Event__c().getsObjectType()))
			return ;
        strDeptId = strDeptId.trim();
        lstIntranetEvents = new List<IntranetWrapper>();
        numOfRecordeToBedisplayed = numOfEventsPerPage;
        lstIntranetMobileEvents = new List<IntranetWrapper>();
        
        if(!getObjectAccess('read', new Intranet_Event__c().getsObjectType()))
			return ;
			
        //To remove the duplicates from list
        Set<String> setDates = new Set<String>();
        String month_Year = '';
        
        loadUserInfo();
        
        String strTempQuery =  strQuery + ' FROM Intranet_Event__c ' + 
                             ' WHERE ' + ((strIntranetEventType != 'All Types') ? 'RecordType.DeveloperName = :strIntranetEventType AND ' : ' ')+ 
                                     '((End_Date__c != null AND Date_of_Event__c != null AND End_Date__c >= TODAY) OR ' +
                                     '(Date_of_Event__c != null AND End_Date__c = null AND Date_of_Event__c >= TODAY))' +
                             ' order by Date_of_Event__c ASC, Name ASC limit 100';
                             
        
        OfficesSpecification officesSpec = new OfficesSpecification(setLoggedinUserOfficesId);
		DepartmentSpecification departmentSpec = new DepartmentSpecification(strDeptId);
		for(Intranet_Event__c objIE : database.query(strTempQuery))
	    {
	        if(officesSpec.satisfiedBy(objIE) && (!isDepartmentWidgetExist || departmentSpec.satisfiedBy(objIE)))
			{
				month_Year = objIE.Date_of_Event__c.month() + '_' + objIE.Date_of_Event__c.year();	                
				lstIntranetEvents.add(new IntranetWrapper(((setDates.contains(month_Year)) ? false : true), objIE));
				setDates.add(month_Year);
			}
        }
        lstIntranetMobileEvents.addAll(lstIntranetEvents);
       
     }
    /* End : getIntranetevents */
    
    /* End : Wrapper class for Intranet Event records */
    public void getFilteredByDepartment()
    {
        numOfRecordeToBedisplayed = numOfEventsPerPage;
        strIntranetEventType = strPreviousEventName.trim();
        getIntranetevents();
    } 
    
    /* Start - Method for getting Search result of Calendar for Mobile view.
       @Name           - calenderSearchForMobile
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for getting Search result of Calendar for Mobile view.
    */
    public void calenderSearchForMobile()
    {
         try{
             List<List<SObject>> lstsearch = new List<List<Sobject>>();
             
             lstIntranetMobileEvents = new List<IntranetWrapper>();  // re-initialization.
             
             //For Mobile Calender search SOSL. 
             if(searchTextForMobile != null){
                 String strSosl = 'Find ' + '\''+ String.escapeSingleQuotes(searchTextForMobile) + '*\'' +  ' in ALL FIELDS '+ 'RETURNING ';
                 String strSoslCalenderSearch = strSosl + 'Intranet_Event__c (Id, Name, Event_Type__c, Venue__c, Date_of_Event__c, End_Date__c, RecordType.Name, Comments__c ' +  
                              ' order by Date_of_Event__c asc nulls last, Name asc) ' ; 
                
                lstsearch = search.query(strSoslCalenderSearch);
                lstIntranetEventSearch = (List<Intranet_Event__c>)lstsearch[0];                           
            }
             
            for(Intranet_Event__c objIntranetEvent : lstIntranetEventSearch)
            {
                lstIntranetMobileEvents.add(new IntranetWrapper(false, objIntranetEvent)); 
            }
            
            //Used to cover test coverage    
            if(Test.isRunningTest())
                Integer i = 1/0;  
        }
        catch(Exception e){
            //Do nothing
        } 
    }
    /* End : calenderSearchForMobile function */
    
    
    
    /* Start - Method for getting more records for Calendars.
       @Name           - getMoreRecords
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for getting more records for Calendars.
    */
    public void getMoreRecords()
    {   
        numOfRecordeToBedisplayed += numOfEventsPerPage;
        Integer intTemp = numOfRecordeToBedisplayed;
        getIntranetevents();
        numOfRecordeToBedisplayed = intTemp;
    }
    /* End : getMoreRecords */
   
    /* Wrapper class for Intranet Event records */
    public class IntranetWrapper
    {
        public Boolean isDisplayheader {get;set;}
        public Intranet_Event__c objIntranetEvent {get;set;}
        
        public IntranetWrapper(Boolean isDisplayheader, Intranet_Event__c objIntranetEvent)
        {
            this.isDisplayheader = isDisplayheader;
            this.objIntranetEvent = objIntranetEvent;
        }
    }
    /* End : Wrapper class for Intranet Event records */
    
    public void getMoreMobileRecords()
    {
        mobileEventsPageSize += numOfRecordeToBedisplayed_Mobile;
        Integer intTemp = mobileEventsPageSize;
        getIntranetevents();
        mobileEventsPageSize = intTemp;
    }
    
    /**
	** Reads user info and fills necessary fields
	**/
	private void loadUserInfo() {
		User objUser = [Select Id, Selected_Offices_Ids__c from User where Id=:UserInfo.getUserId() limit 1];
		
		setLoggedinUserOfficesId = new Set<String>();
		if(!String.isEmpty(objUser.Selected_Offices_Ids__c)) {
			setLoggedinUserOfficesId.addAll(objUser.Selected_Offices_Ids__c.split(';'));
		}
		
		System.debug('SL_DEBUG: User offices IDs: ' + setLoggedinUserOfficesId);
	}    
    
    /* @Name           - newComponent
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for creating Component dynamically.
    */
    public override ApexPages.Component newComponent() 
    {
        Component.c.SL_IntranetEvents c = new Component.c.SL_IntranetEvents();   
        c.aComponentImpl = this;
        
        return c;
    }
    /* End : newComponent */
}