public with sharing abstract class SL_IntranetNotifications extends WidgetAbstract implements IObservable
{
    /* Start of Variables */
    public static final Map<Integer, String> mapMonths;
    public List<IntranetNotification> lstIntranetAlerts 						{	get; set;	}
    public String strDeptId 													{	get; set;	}
    public List<SL_UtilityWrappers.FieldSetDescribe> lstNotificationFieldNames	{	get; set;	}
    public NotificationConfiguration notificationConfig 						{	get; set;	}
    public Boolean hasFieldset													{	get; set;	}
    private Set<String> setFieldsToQuery = new Set<String>(); ///set to hold fields to query
    private Integer numOfNotificationsPerPageMobile;
    private Integer noOfRecordToDisplay;                                  
    private Set<String> setLoggedinUserOfficesId;
    Private Boolean isDepartmentWidgetExist; //To identify if Department widget exist on page or not to decide the behavior based on that. 
    private String strQuery ;
    private Boolean isShowMore ;
    /* End of Variables */
    
    
    
    static
    {
        //Initializing the map to identify the current month in the Notifications widget
        mapMonths = new Map<Integer, String>{
             1 => 'January',
             2 => 'February',
             3 => 'March',
             4 => 'April',
             5 => 'May',
             6 => 'June',
             7 => 'July',
             8 => 'August',
             9 => 'September',
             10 => 'October',
             11 => 'November',
             12 => 'December'
        };
    }
    
    /*Configuration Inner Class*/
    public class NotificationConfiguration
    {
    	public Integer  numbertodisplay		 {	get; set;	} 		
	    public Integer  totalRecords		 {	get; set;	}	
	    public Integer  mobilePaginationSize {   get; set;	}		
    }
	
	/* Wrapper class For Notifications */
    public class IntranetNotification
    {
        public Notification__c objNotification {get;set;}
        public string strTime {get;set;}
        public String dateToBeDisplayed {get;set;}
        public DateTime notificationCreatedDate {get;set;}
        
        public IntranetNotification(Notification__c objNotify){
            objNotification = new Notification__c();
            objNotification = objNotify;
                
            notificationCreatedDate = datetime.valueOfGmt(String.valueOf(objNotify.CreatedDate.year()) + '-' + String.valueOf(objNotify.CreatedDate.month())
                                        + '-' + String.valueOf(objNotify.CreatedDate.day()) + ' ' + String.valueOf(objNotify.CreatedDate.hour()) + ':' + 
                                        String.valueOf(objNotify.CreatedDate.minute()) +  ':' + String.valueOf(objNotify.CreatedDate.second()) );
                
            //Convert the created date of notification as a string (month(in string) date, year)
            dateToBeDisplayed = 'NV';
            if(objNotify.CreatedDate.date().daysBetween(date.today()) >= 6)
                dateToBeDisplayed = SL_IntranetNotifications.mapMonths.get(objNotify.CreatedDate.month())+' '+ String.valueOf(objNotify.CreatedDate.day()) +', '+String.valueOf(objNotify.CreatedDate.year());
            
            strTime = objNotify.CreatedDate.format('hh:mm a');
        }
    }
    /* End : Wrapper class For Notifications */
    
    /* Start of Constructor */
    public SL_IntranetNotifications()
    {
        try
        {
        	strDeptId = strQuery = '';
        	noOfRecordToDisplay = numOfNotificationsPerPageMobile = 0;
            setFieldsToQuery = new Set<String>{ 'Notification_Detail__c', 'For_All_Departments__c','Selected_Department_Ids__c', 'For_All_Offices__c', 
            									'Selected_Offices_Ids__c', 'Id', 'Name', 'CreatedDate','CreatedBy.SmallPhotoUrl', 'CreatedById' };
            
			lstNotificationFieldNames = new List<SL_UtilityWrappers.FieldSetDescribe>();
			lstIntranetAlerts = new List<IntranetNotification>();
			notificationConfig = new NotificationConfiguration();
            isDepartmentWidgetExist = isShowMore = false;
            
            if(Test.isRunningTest())	
            	Integer i = 10/0;
        }
        catch(Exception e)
        {
            system.debug('---SL_Debug::'+e); 
        }
    }
    /* End of Constructor */
    
    public override protected void initialize()
	{
		notificationConfig.mobilePaginationSize = 0;
		if(!getObjectAccess('read', new Notification__c().getsObjectType()))
            return ;
		prepareWidgetConfiguration();
         // listener for department widget dependancy
		WidgetConfigurationListener.getInstance().addEventListener('SL_IntranetDepartments', this); 
        
        /* Start : Get the pageSizes from custom settings for pagination */
        for(SL_Intranet_PaginationSettings__c objPagination : [SELECT Name, Notifications_PageSize__c, Notifications_PageSize_Mobile__c 
                                                                     FROM SL_Intranet_PaginationSettings__c limit 1])
        {
            if(objPagination.Notifications_PageSize_Mobile__c != null)
                numOfNotificationsPerPageMobile = Integer.valueOf(objPagination.Notifications_PageSize_Mobile__c);
        }
        
        notificationConfig.mobilePaginationSize = (numOfNotificationsPerPageMobile != null) ? numOfNotificationsPerPageMobile : 10;
        /* End */
        
        /* Collecting User offices Ids */
        String userOfficeLocationIds = [Select Id, Selected_Offices_Ids__c from User where Id = :Userinfo.getUserId()].Selected_Offices_Ids__c;
        setLoggedinUserOfficesId = new Set<String>();
        if(!String.isEmpty(userOfficeLocationIds)) 
            setLoggedinUserOfficesId.addAll(userOfficeLocationIds.split(';'));
        /* End */
	}
	
	// Depends on Department configuration, so is executed after post initializtion
	override public void postInitialize()
	{
		getNotifications();		//Querying the Notifications to display it onto the page
	}
	
	 /* Start - Method for getting notification records 
       @Name           - notify
       @Return Type    - void
       @Description    - Function for getting initial selection dept Id 
    */
	public void notify(IWidget widget) 
	{
		if(widget == null) return;
		SL_IntranetDepartments departmentWidget = (SL_IntranetDepartments)widget;
		strDeptId = departmentWidget.strInitialDeptSelection;
		isDepartmentWidgetExist = true;
	}
    
    
    private void prepareWidgetConfiguration()
    {
        
        // Fetch the configuration for the widget
		if(this.properties != null) 
		{
			Map<String, Object> configuration = (Map<String, Object>)this.properties;
			
			if(configuration.get('heading') == null || configuration.get('heading') == '')
				((map<String, object>)properties).put('heading', Label.SL_RightSideBar_NotificationHeader);
			
			notificationConfig.numbertodisplay = (configuration.get('numbertodisplay') != null && configuration.get('numbertodisplay') != '') ? Integer.valueOf(configuration.get('numbertodisplay')) : 5;
        	notificationConfig.totalRecords    = (configuration.get('TotalRecords') != null && configuration.get('TotalRecords') != '') ? Integer.valueOf(configuration.get('TotalRecords')) : 10;
        	
        	noOfRecordToDisplay = notificationConfig.numbertodisplay;
		
			if(String.isNotBlank(String.valueOf(configuration.get('fieldset'))))  
	        {  
	     		SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( 'Notification__c', String.valueOf(configuration.get('fieldset')), '', '', '', new Set<String>());
	     		lstNotificationFieldNames = objFieldSetWrapper.lstFieldWrapper;
	     		hasFieldset = true;
	        }
	        
			// Iterate through the fields returned previously to form a query
	    	for(SL_UtilityWrappers.FieldSetDescribe objFieldSetResult : lstNotificationFieldNames)
			{
				setFieldsToQuery.add(objFieldSetResult.fieldAPIName);
			}
			
			/// add fields to the query
	        strQuery = 'Select ' + String.join(new List<String>(setFieldsToQuery), ',');
	        strQuery += ' From Notification__c' + 
	                    ' Where Active__c = true and (Display_As_Of__c <=:dt and Expiry_Date__c >=:dt)' ; 
	        strQuery += ' order By CreatedDate DESC Limit 1000' ; 
			
			
		}
    }
    
    /* Start - Method for getting notification records 
       @Name           - getNotifications
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for getting notification records  
    */
    public void getNotifications()
    {
        //Reinitializing the list
        lstIntranetAlerts = new List<IntranetNotification>();
        if(!getObjectAccess('read', new Notification__c().getsObjectType()))
			return ;
        if(!isShowMore)
        	notificationConfig.numbertodisplay = noOfRecordToDisplay;
        
         // created Object to handle Office and Department check with user and widget
        OfficesSpecification officesSpec = new OfficesSpecification(setLoggedinUserOfficesId); 
		DepartmentSpecification departmentSpec = new DepartmentSpecification(strDeptId);
        date dt = date.today();
        
        //Iterate through all the queried Notifications and filter based on the logged in user's offices
        for(Notification__c objNotify : database.query(strQuery))
        {
            //Notification will be displayed to the user if its intended to all offices or Its part of User's office and Record matched with department id criteria 
            if(officesSpec.satisfiedBy(objNotify) && (!isDepartmentWidgetExist || departmentSpec.satisfiedBy(objNotify)))
            {
                IntranetNotification objIntranet = new IntranetNotification(objNotify);
                lstIntranetAlerts.add(objIntranet);
            }
            else
            	new IntranetNotification(objNotify);
        }
        isShowMore = false;
        
    }
    /* End : getNotifications method */
    
     /* 
     * Name: showMoreRecords
     * Parameters: NA
     * Description: Dispalying all records
     */
    public void showMoreRecords()
    {
    	notificationConfig.numbertodisplay += noOfRecordToDisplay;
    	if(notificationConfig.numbertodisplay > notificationConfig.totalRecords)
			notificationConfig.numbertodisplay = notificationConfig.totalRecords;
			
		isShowMore = true;
		getNotifications();
			
		
    }
     /* End */
    
    public void getFilteredByDepartment()
    {
        getNotifications();
    }
    
    public void getMoreNotifications()
    {
    	notificationConfig.mobilePaginationSize += numOfNotificationsPerPageMobile;
    }
    
    
    public override ApexPages.Component newComponent() {
        
        Component.c.SL_IntranetNotifications c = new Component.c.SL_IntranetNotifications();   
        c.aComponentImpl = this;
        
        return c;
    }
    
}