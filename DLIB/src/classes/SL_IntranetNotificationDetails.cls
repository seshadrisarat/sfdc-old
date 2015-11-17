public with sharing class SL_IntranetNotificationDetails extends WidgetPaginatorAbstract implements IObservable,IChatterable       
{   
	/* Start of Variables */
	// to make it compatible with String assignments (for example, from Action functions)	  
	public Id strNotificationId { 
		get; 
		set {
			strNotificationId = !String.isEmpty(value) ? value : null;			
		}	
	}	
	
	public SL_IntranetChatterPlugIn Chatter	{	get; set;	}         
	private Integer numOfNotificationsPerPage;
	public Boolean showNotifications												{	get; set;	}
	public Boolean hasFieldset														{	get; set;	} //this variable is used to decide whether we need to display fields from fieldset.
	public List<SL_UtilityWrappers.FieldSetDescribe> lstNotificationFieldNames 		{   get; set;   }
	
	public List<IntranetAlerts> lstWrapperNotifications {get;set;} //wrapper list of Notifications
	public string strPageName;
	public Boolean isNotifications {get; set;}
	public String strDeptId{get;set;}
	public Boolean isShowWidget {get; set;}
	public String strFieldSetName {get;set;}
	
	public ConfigNotification objConfig {get;set;}
	private Integer totalRecords;
	private Set<String>  setFieldsToQuery;
	private Set<String> setLoggedinUserOfficesId;
	private Boolean isDepartmentWidgetExist; //To identify if Department widget exist on page or not to decide the behavior based on that.
	/* End of Variables */
	
	/* Start of Constructor */
	public SL_IntranetNotificationDetails()
	{
		objConfig = new ConfigNotification();
		lstWrapperNotifications = new List<IntranetAlerts>();
		setLoggedinUserOfficesId = new Set<String>();
        isNotifications = false;
        isShowWidget = true;
        isDepartmentWidgetExist =  false;
        strFieldSetName = '';
        /* overriding the Paginator class vars */
		totalPages = pageNo = startIndex = 0;	
		/* End of overriding */
		
		strPageName = ApexPages.currentPage().getParameters().get('page');
        if(String.isBlank(strPageName))		strPageName = 'Home';
	}
	/* End of Constructor */
	
	//Inner class to hold configuration fields 
	public class ConfigNotification
	{
		String strFieldSetName;
		String strInitialState;
	} 

	public SL_IntranetChatterPlugIn initChatter() {
		
		SL_IntranetChatterPlugIn plugin = new SL_IntranetChatterPlugIn();
		plugin.initializeParam('Notification',id);
		return plugin;
	}  
	
	public override protected void initialize()
	{
		if(!getObjectAccess('read', new Notification__c().getsObjectType()))
            return ;
		strDeptId = '';
		getConfiguration();
		Chatter = initChatter();
		//getDepartmentFilter();	//Used for getting department initialselection value
		
		/*Getting USer Office location IDs */
		String userOfficeLocationIds = [Select Id, Selected_Offices_Ids__c from User where Id = :Userinfo.getUserId()].Selected_Offices_Ids__c;
            
        if(String.isNotBlank(userOfficeLocationIds)) 
            setLoggedinUserOfficesId.addAll(userOfficeLocationIds.split(';'));
        /* end */
        
        /* Getting records per page via custom setting */
        for(SL_Intranet_PaginationSettings__c objPagination : [SELECT Name, Notifications_PageSize__c, Notifications_PageSize_Mobile__c 
                                                                FROM SL_Intranet_PaginationSettings__c limit 1])
        {
            if(objPagination.Notifications_PageSize__c != null)
                rowsPerPage = Integer.valueOf(objPagination.Notifications_PageSize__c);
        }
        
        numOfNotificationsPerPage = (rowsPerPage != null) ? rowsPerPage : 20;
		/* End */

		// listen for department widget dependancy
		WidgetConfigurationListener.getInstance().addEventListener('SL_IntranetDepartments', this);
		
	}
   
	override public void postInitialize()
	{
		// Depends on Department configuration, so is executed after post initializtion
		getNotifications();		//Fetching the Notification records.
	}
	
	public void notify(IWidget widget) {
		if(widget == null) return;
			
		SL_IntranetDepartments departmentWidget = (SL_IntranetDepartments)widget;
		
		strDeptId = departmentWidget.strInitialDeptSelection;
		isDepartmentWidgetExist = true;
		System.debug('SL_DEBUG: System set department from configuration: ' + strDeptId);
	}
	
	
	private void getConfiguration()
	{
		setFieldsToQuery = new Set<String>{'Notification_Detail__c','Selected_Department_Ids__c','For_All_Departments__c', 
                                                       'For_All_Offices__c','Selected_Offices_Ids__c', 'Id','Name', 'CreatedDate', 
                                                       'CreatedBy.SmallPhotoUrl', 'CreatedById'};
        
        lstNotificationFieldNames = new List<SL_UtilityWrappers.FieldSetDescribe>();    
		
		List<String> lstDefaultFields = new List<String>{'Name', 'Notification_Detail__c'};
		// Fetch the configuration for the widget
		if(this.properties != null) {
		
			Map<String, Object> configuration = (Map<String, Object>)this.properties;
			
			objConfig.strFieldSetName		= String.valueOf(configuration.get('fieldset'));
			objConfig.strInitialState		= String.valueOf(configuration.get('initialstate')).toLowerCase();
		}
		
		if(String.isNotBlank(objConfig.strFieldSetName)) 
        {
        	strFieldSetName = objConfig.strFieldSetName;
     		SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( 'Notification__c', objConfig.strFieldSetName, '', '', '', new Set<String>());
     		lstNotificationFieldNames = objFieldSetWrapper.lstFieldWrapper;
     		hasFieldset = true;
        }
         
        if(lstNotificationFieldNames.isEmpty())
			lstNotificationFieldNames.addAll( Utilities.describeDefaultFields( 'Notification__c', lstDefaultFields) );
	
		// Iterate through the fields returned previously to form a query
    	for(SL_UtilityWrappers.FieldSetDescribe objFieldSetResult : lstNotificationFieldNames)
		{
			setFieldsToQuery.add(objFieldSetResult.fieldAPIName);
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
		lstWrapperNotifications = new List<IntranetAlerts>();
		if(!getObjectAccess('read', new Notification__c().getsObjectType()))
            return ;
		if(String.isBlank(strNotificationId) && String.isNotBlank(objConfig.strInitialState))
			showNotifications	= objConfig.strInitialState != 'hidden';
		else
			showNotifications = true;
				
      	String strQuery = 'SELECT Id';
      	
		if(setFieldsToQuery.contains('Id'))
        	setFieldsToQuery.remove('Id');
       
		setFieldsToQuery.add('Name');
        
        /// add fields to the query
        strQuery +=',' +String.join(new List<String>(setFieldsToQuery), ',');
      	
      	date dt = date.today();	
        strQuery += ' From Notification__c Where Active__c = true and (Display_As_Of__c <=:dt and Expiry_Date__c >=:dt)' ;
		
		if(strNotificationId != null)
			strQuery += ' AND Id = :strNotificationId ';
		
		strQuery += ' order By CreatedDate DESC Limit 1000' ; 
        
        //Iterate through all the queried Notifications and filter based on the logged in user's offices
        for(Notification__c objNotify : database.query(strQuery))
        {
        	OfficesSpecification officesSpec = new OfficesSpecification(setLoggedinUserOfficesId);
			DepartmentSpecification departmentSpec = new DepartmentSpecification(strDeptId);

			if(officesSpec.satisfiedBy(objNotify) && (!isDepartmentWidgetExist || departmentSpec.satisfiedBy(objNotify)))
	        	lstWrapperNotifications.add(new IntranetAlerts(objNotify)); 
        }
        
        totalRecords = lstWrapperNotifications.size();
        totalPages = Math.mod(totalRecords, rowsPerPage) == 0 ? totalRecords/rowsPerPage : (totalRecords/rowsPerPage) + 1;
        firstRecords();
        
		if(strNotificationId != null)
        {
            //feedParentId = (String)strNotificationId;
            //getFeedItems();
            isNotifications = true;
        }
        //else
        	//lstFeedItemsSearchResults = new List<FeedItem>();
        
        isShowWidget = true;
	}
	/* End : getNotifications method */
	
	/* Start - Method for getting notification records 
	   @Name           - deleteNotification
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for deleting notification records  
	*/
	public void deleteNotification()
	{
		//To store the Id of Notification record which needs to be deleted 
		Id notificationRecordId = ApexPages.currentPage().getParameters().get('deletedRecordId');
		
		Notification__c objNotification = new Notification__c(Id = notificationRecordId);
		delete objNotification;
		
		/*Iterating to remove the deleted Id record from this List and update it*/
		Integer index = 0;
		for(IntranetAlerts objIA : lstWrapperNotifications)
		{
			if(objIA.objNotification.Id == notificationRecordId)
			{	
               lstWrapperNotifications.remove(index);
               return;
            }
            index++;
		}
	}
	
	public void getFilteredByDepartment()
    {
    	isNotifications = false;
    	strNotificationId = null;
    	getNotifications();
    }

    public void toggleNotificationState()
    {
    	isShowWidget = (objConfig.strInitialState == 'hidden') ? false : true;
    }
    
    /* Wrapper class For Notifications */
	public class IntranetAlerts
	{
        public Notification__c objNotification {get;set;}
        public string strTime {get;set;}
        public DateTime notificationCreatedDate {get;set;}
        public String dateToBeDisplayed {get;set;}
        
        public IntranetAlerts(Notification__c objNotify)
        {
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
    
    public override ApexPages.Component newComponent() 
    {
    	Component.c.SL_IntranetNotificationDetails c = new Component.c.SL_IntranetNotificationDetails();   
		c.aComponentImpl = this;
    	return c;
  	}
}