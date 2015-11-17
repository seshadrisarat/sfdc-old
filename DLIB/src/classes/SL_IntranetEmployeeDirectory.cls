/**
* @ClassName    : SL_IntranetEmployeeDirectory 
* @JIRATicket   : Socint-178
* @CreatedOn    : 10/June/13
* @ModifiedBy   : Ritika 
* @Description  : This is the Implementation class of SL_IntranetEmployeeDirectoryController Controller.
*/

/**
@ Pravin Sapkal 
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 6
No of collections used                  : 4
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 
*/

public with sharing class SL_IntranetEmployeeDirectory extends WidgetPaginatorAbstract implements IObservable
{
    // Global Variables
    public transient List<User> lstDirectoryUsers 							{	get; set;	}
    public transient List<User> lstDirectoryUsersMobile 					{	get; set;	}
    public List<SL_UtilityWrappers.FieldSetDescribe> lstWrapperUserFields 	{	get; set;	}
	public List<SL_UtilityWrappers.FieldSetDescribe> lstWrapperSortFields 	{	get; set;	} 					//Field for Sort section
    
    public String strMethodCalled 											{	get; set;	}
    public String selLocation 												{	get; set;	}
    public String selLocationName 											{	get; set;	}
    public String selSortPreference 										{	get; set;	}
    public String isRecentHires 											{	get; set;	}
    public Boolean isSmallPhotoSelected 									{	get; set;	}
	public String strDeptId 												{	get;set;	} //Store the Department id
	
    private String strQuery;
    private EmployeeConfig config;
    private List<String> lstUserLicenseFilters;
	private Boolean isDepartmentWidgetExist; //To identify if Department widget exist on page or not to decide the behavior based on that.
	private String strPreviousMethodCalled ;
	private String sortFieldSet;
	private String strNameSpace;
    
    // Constructor 
    public SL_IntranetEmployeeDirectory()
    {
    	isSmallPhotoSelected = false;
    	selSortPreference = 'LastName';
    	strQuery = strMethodCalled = '';
        selLocation = selLocationName = 'All Employees';
        
        // overriding the Paginator class vars
        rowsPerPage = 20;
        totalPages = startIndex = pageNo = 0;
        
        lstDirectoryUsers = lstDirectoryUsersMobile = new List<User>();
        lstWrapperUserFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
		lstWrapperSortFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
		
        //To get namespace of current org
        try
    	{
    		if(UserInfo.isCurrentUserLicensed('SLSI'))
    			strNameSpace = 'SLSI__';
    	}
    	catch(TypeException ex)
    	{
    		 strNameSpace = '';
    	}
    }
    
    // Wrapper class for maintaining configuration data
    private class EmployeeConfig
    {
    	private Integer noOfDaysForRecentHires;
	    private Integer numOfRecordeToBedisplayed;
	    private Integer numOfRecordToBedisplayed_Mobile;
	    
    	private EmployeeConfig()
    	{
            // Initialize the values in constructor
    		noOfDaysForRecentHires = 21;
    		numOfRecordToBedisplayed_Mobile = 20;
    		
    		SL_IntranetApplicationSetting__c objAppSettings = SL_IntranetApplicationSetting__c.getValues('Default Settings');
    		
    		//Get the # of days for recent hires from custom settings
    		if(objAppSettings != null)
    			noOfDaysForRecentHires = Integer.valueOf(objAppSettings.Of_Days_For_Recent_Hires__c);
    		
	        List<SL_Intranet_PaginationSettings__c> lstPaginationSetting = SL_Intranet_PaginationSettings__c.getAll().values();
        
	        if(!lstPaginationSetting.isEmpty() && lstPaginationSetting[0].EmployeeDirectory_PageSize_Mobile__c != null)
	            numOfRecordToBedisplayed_Mobile = Integer.valueOf(lstPaginationSetting[0].EmployeeDirectory_PageSize_Mobile__c);
	        
	        numOfRecordeToBedisplayed = numOfRecordToBedisplayed_Mobile;
    	}
    }
    
    // Initialize method
    public override protected void initialize()
    {
		strDeptId = strPreviousMethodCalled = sortFieldSet = '';
		isDepartmentWidgetExist = false;
    	config = new EmployeeConfig(); 
    	getUserLicenseKeyFilters();
    	
		/*Fetching the configuration and storing the value in a variable */
		if(this.properties != null) 
		{
			Map<String, Object> configuration = (Map<String, Object>)this.properties;
			if(configuration.containsKey('sortfieldset')) 				
				sortFieldSet = (String)configuration.get('sortfieldset');
		}
		
    	Set<String> setFieldsToQuery = new Set<String>{'Name', 'FirstName', 'LastName','All_Departments__c','Selected_Department_Ids__c'};
    	SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( 'User', strNameSpace+'SL_EmployeeDirectoryFieldSet', '', '', '', setFieldsToQuery);
		
		lstWrapperUserFields = objFieldSetWrapper.lstFieldWrapper;
		
		/*To get all the fields from sortable field-set*/
     	if(String.isNotBlank(sortFieldSet) || String.isBlank(sortFieldSet))
     	{
     		String fieldSetName = sortFieldSet != '' ? sortFieldSet : strNameSpace+'SL_EmployeeDirectoryFieldSet';
     		SL_UtilityWrappers.FieldSetResults objFieldSetWrapperForSortFields = Utilities.buildQueryUsingFieldSet( 'User', fieldSetName, '', '', '', new Set<String>{'LastName','Selected_Department_Ids__c','Selected_Offices_Ids__c','Select_Departments__c','Select_Offices__c'});
     		lstWrapperSortFields = objFieldSetWrapperForSortFields.lstFieldWrapper;
     	}
		
        List<SL_Intranet_PaginationSettings__c> lstPaginationSetting = SL_Intranet_PaginationSettings__c.getAll().values();
        
    	if(!lstPaginationSetting.isEmpty() && lstPaginationSetting[0].EmployeeDirectory_PageSize__c != null)
            rowsPerPage = Integer.valueOf(lstPaginationSetting[0].EmployeeDirectory_PageSize__c);
        
        Integer index = 0, smallPhotoUrlIndex = 0;        
        
		// Iterate through the fields returned previously to form a query
    	for(SL_UtilityWrappers.FieldSetDescribe objFieldSetResult : lstWrapperUserFields) {
			setFieldsToQuery.add(objFieldSetResult.fieldAPIName);
			
			// store index of this field for further removal
			if(objFieldSetResult.fieldAPIName == 'SmallPhotoUrl') {
				smallPhotoUrlIndex = index;
				isSmallPhotoSelected = true;
			}
			
			index++;			
		}
		
    	// form dynamic query
    	strQuery = 'Select Id';
    	
    	if(setFieldsToQuery.contains('Id')) setFieldsToQuery.remove('Id');
    		
    	if(isSmallPhotoSelected) {
    		// remove this field from collection that is used for display
    		lstWrapperUserFields.remove(smallPhotoUrlIndex); 		
    	}	
    	
    	setFieldsToQuery.addAll(new Set<String>{'All_Offices__c', 'Selected_Offices_Ids__c'});	// fields to be added to query but not shown on page by default
    	
    	/// add fields to the query
    	for(String strFieldName : setFieldsToQuery) {
    		strQuery += ', '+  String.escapeSingleQuotes(strFieldName);
    	}
    	
		strQuery += ' From User ' + 
					' where IsActive = true AND ' + 
						   'Exclude_from_Intranet_Directory__c != TRUE AND ' +
						   'Profile.UserLicense.LicenseDefinitionKey NOT IN: lstUserLicenseFilters ';
						   
		/*SOCINT-1027 to filter the Users when logged as Admin in Community*/
        String networkId = Network.getNetworkId(); 
        
        /*When logged in as Admin the Network Id will be null*/
        if(String.isEmpty(networkId))         
            strQuery += ' AND ContactId = null'; //Add the filter ContactId = null when we logged in as Admin and so it wont display Community Licence Users.
        /*When accessing Community as Admin User and Network Id will not be null*/
        else if(String.isNotEmpty(networkId))
            strQuery += ' AND Id IN (SELECT memberId FROM NETWORKMEMBER WHERE networkId =\''+ networkId +'\' )'; //Adding the filter will provide all the members of the community related to its Network Id.
        /*---End---*/
		
		// listener for department widget dependancy
		WidgetConfigurationListener.getInstance().addEventListener('SL_IntranetDepartments', this);
    }
	
	override public void postInitialize()
	{
		// Depends on Department configuration, so is executed after pre initializtion
		fetchEmployeeDirectoryUsers();		
	}
	
	public void notify(IWidget widget) 
	{
		if(widget == null) return;
		SL_IntranetDepartments departmentWidget = (SL_IntranetDepartments)widget;
		strDeptId = departmentWidget.strInitialDeptSelection;
		isDepartmentWidgetExist = true;
	}
    
    private List<User> fetchEmployeeDirectoryUsers()
    {
    	List<User> lstDirectoryUser = new List<User>();
        lstDirectoryUsers = lstDirectoryUsersMobile = new List<User>();

        // Getting employees records based on selected option from left side bar
        if(System.currentPageReference().getParameters().get('isRecentHire') != 'true')
        {
            if(System.currentPageReference().getParameters().get('loc') != null)
            {
                selLocationName = System.currentPageReference().getParameters().get('loc');
                
                //get the Office locations
		        for(Office_Locations__c objOffice : [Select Id 
		        									 From Office_Locations__c 
		        									 where Name = :selLocationName
		        									 limit 1])
		        {
		            selLocation = objOffice.Id;
		        }
                
                lstDirectoryUser = gtLocationUsers();
            }
            else
            {
            	isRecentHires = 'false';

                String strOrderBy;
                if(selSortPreference != null)
                    strOrderBy = ' ORDER BY '+String.escapeSingleQuotes(selSortPreference)+' ASC NULLS LAST';
                    
                DepartmentSpecification departmentSpec = new DepartmentSpecification(strDeptId);
                for(User objUser :database.query( strQuery + strOrderBy ))
                {
                	if(!isDepartmentWidgetExist || departmentSpec.satisfiedBy(objUser))
                    	lstDirectoryUser.add(objUser);
                }
                fetchRecords(lstDirectoryUser);
            }
        }
        else if(System.currentPageReference().getParameters().get('isRecentHire') == 'true')
        {
            isRecentHires = System.currentPageReference().getParameters().get('isRecentHire');
            lstDirectoryUser = gtRecentHires();
        }
        strMethodCalled = 'fetchEmployeeDirectoryUsers';
        
        return lstDirectoryUser;
    }
    
    
    /* Start - Method for getting more records of employees for mobile view
       @Name           - getMoreRecords
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for getting more records of employees for mobile view
    */   
    public void getMoreRecords()
    {
    	List<User> lstDirectoryUser = callSuitableMethodForRequery();
    	
        lstDirectoryUsersMobile = new List<User>();
        config.numOfRecordeToBedisplayed += config.numOfRecordToBedisplayed_Mobile;
        
        for(Integer i = 0; i < config.numOfRecordeToBedisplayed && i < lstDirectoryUser.size(); i++)
        {
            lstDirectoryUsersMobile.add(lstDirectoryUser[i]);
        }
    }
    /* End : getMoreRecords Method */
    
    
    /* Start - Method for getting Users based on selected location 
       @Name           - gtLocationUsers
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for getting Users based on selected location 
    */   
    public List<User> gtLocationUsers()
    {
        isRecentHires = 'false';
		strPreviousMethodCalled = 'gtLocationUsers';
        List<User> lstDirectoryUser = new List<User>();
        lstDirectoryUsers = lstDirectoryUsersMobile = new List<User>();
		DepartmentSpecification departmentSpec = new DepartmentSpecification(strDeptId);  
        OfficesSpecification officesSpec = new OfficesSpecification(new Set<String>{selLocation});
        config.numOfRecordeToBedisplayed = config.numOfRecordToBedisplayed_Mobile;		// Reset the number of records to be displayed counter
        
        String strOrderBy;
        if(selSortPreference != null)
            strOrderBy = ' ORDER BY ' + String.escapeSingleQuotes(selSortPreference) + ' ASC NULLS LAST';
            
        if(selLocation == 'All Employees')
        {
    		for(User objUser :database.query( strQuery + strOrderBy ))
            {
            	if(!isDepartmentWidgetExist || departmentSpec.satisfiedBy(objUser))
                	lstDirectoryUser.add(objUser);
            }
        }
    	else
    	{
	        for(User objUser : database.query(strQuery + strOrderBy))
	        {
	            if(officesSpec.satisfiedBy(objUser) && (!isDepartmentWidgetExist || departmentSpec.satisfiedBy(objUser)))
	            {   
	                lstDirectoryUser.add(objUser);
	            }
	        }
    	}     
        
        fetchRecords(lstDirectoryUser);
        strMethodCalled = 'gtLocationUsers';
        return lstDirectoryUser;
    }
    /* End of Method -  getLocationUsers*/
    
	
	/* Start - Method for getting List of Users based on selected Department 
       @Name           - getFilteredByDepartment
       @Parameters     - None 
       @Return Type    - List
       @Description    - Function for getting Users based on selected Department
    */
	public List<User>  getFilteredByDepartment()
    { 
        strMethodCalled = 'getFilteredByDepartment';
        if(isRecentHires == 'true'){
            gtRecentHires();
            return new List<User>();
        }
        else if(strPreviousMethodCalled == 'gtListViewUsers'){
            gtListViewUsers();
            return new List<User>();
        }
        else if(strPreviousMethodCalled == 'gtLocationUsers'){
            gtLocationUsers();
            return new List<User>();
        }
        else if(selLocation == 'All Employees'){
            gtLocationUsers();
            return new List<User>();
        }
        else
            return new List<User>();
    }
	/* End of Method -  getFilteredByDepartment*/
	
	
    /* Start - Method for getting List of Users based on selected List View 
       @Name           - gtListViewUsers
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for getting Users based on selected List View 
    */   
    public List<User> gtListViewUsers()
    {
        isRecentHires = 'false';
        strMethodCalled = 'gtListViewUsers';
		strPreviousMethodCalled = 'gtListViewUsers';
        Set<Id> setuserIds = new Set<Id>();
        List<User> lstDirectoryUser = new List<User>();
		List<User> lstDirectoryUserDeptFiltered = new List<User>();
        lstDirectoryUsers = lstDirectoryUsersMobile = new List<User>();
		DepartmentSpecification departmentSpec = new DepartmentSpecification(strDeptId); 
        config.numOfRecordeToBedisplayed = config.numOfRecordToBedisplayed_Mobile;		// Resetting the variable to default for page size
        
        String strOrderBy;
        if(selSortPreference != null)
            strOrderBy = ' ORDER BY '+String.escapeSingleQuotes(selSortPreference)+' ASC NULLS LAST';
    
        ApexPages.StandardSetController objSSC = new ApexPages.StandardSetController(database.getQueryLocator(strQuery));
        objSSC.setPageSize(1000);
         
        for(SelectOption objSS : objSSC.getListViewOptions())
        {
            if(objSS.getLabel() == selLocation)
            {
                objSSC.setFilterId(objSS.getValue());
                lstDirectoryUser.addAll((List<User>)objSSC.getRecords());	// Fetch the list to requery the users for second time
            }
        }

        lstDirectoryUser = database.query(strQuery + ' AND Id IN:lstDirectoryUser Order By '+ String.escapeSingleQuotes(selSortPreference) + ' ASC NULLS LAST');
        
		for(User objUser : lstDirectoryUser)
        {
            if(!isDepartmentWidgetExist || departmentSpec.satisfiedBy(objUser))
            {   
                lstDirectoryUserDeptFiltered.add(objUser);
            }
        }
        fetchRecords(lstDirectoryUserDeptFiltered);
        return lstDirectoryUserDeptFiltered;         
    }
    /* End of Method -  gtListViewUsers*/
    
    /* Start - Method for getting recent hired records.
       @Name           - gtRecentHires
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for getting recent hired records.
    */
    public List<User> gtRecentHires()
    {
    	selLocation = '';
    	isRecentHires = 'true';
		strPreviousMethodCalled = '';
    	strMethodCalled = 'gtRecentHires';
        config.numOfRecordeToBedisplayed = config.numOfRecordToBedisplayed_Mobile;
        
        String strQueryRecent = strQuery + ' and Hire_Date__c != null and Hire_Date__c >= LAST_N_DAYS:' + config.noOfDaysForRecentHires + ' and Hire_Date__c <= TODAY';
        String strOrderBy;
        
        if(selSortPreference != null)
            strOrderBy = ' ORDER BY ' + String.escapeSingleQuotes(selSortPreference) + ' ASC NULLS LAST';
        
        List<User> lstDirectoryUser = new List<User>();
        DepartmentSpecification departmentSpec = new DepartmentSpecification(strDeptId);
        for(User objUser : database.query( strQueryRecent + strOrderBy ))
        {
            if(!isDepartmentWidgetExist || departmentSpec.satisfiedBy(objUser))
            {   
                lstDirectoryUser.add(objUser);
            }
        }
		fetchRecords(lstDirectoryUser);
        return lstDirectoryUser;
    }
    /* End of Method -  getRecentHires*/
    
    public void fetchRecords(List<User> lstDirectoryUser)
    {
    	lstDirectoryUsers = new List<User>();
    	lstDirectoryUsersMobile = new List<User>();
        
        totalRecords = lstDirectoryUser.size();
        totalPages = Math.mod(totalRecords, rowsPerPage) == 0 ? totalRecords/rowsPerPage : (totalRecords/rowsPerPage) + 1;
	    firstRecords();
        
        for(Integer i = startIndex; i < (startIndex + rowsPerPage) && i < lstDirectoryUser.size(); i++)
        {
            lstDirectoryUsers.add(lstDirectoryUser[i]);
        }
        
        for(Integer i = 0; i < config.numOfRecordeToBedisplayed && i < lstDirectoryUser.size(); i++)
        {
            lstDirectoryUsersMobile.add(lstDirectoryUser[i]);
        }
        
    }
    
    /* Start - Method for sorting Users based on selected sort order.
       @Name           - gtSortPreference
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for sorting Users based on selected sort order.
    */
    public void gtSortPreference()
    {
       callSuitableMethodForRequery();
    }
    /* End of Method -  getRecentHires*/
    

    private List<User> callSuitableMethodForRequery()
    {
    	List<User> lstDirectoryUser = new List<User>();
    	
    	if(strMethodCalled == 'gtRecentHires')
    		lstDirectoryUser = gtRecentHires();
    	else if(strMethodCalled == 'fetchEmployeeDirectoryUsers')
    		lstDirectoryUser = fetchEmployeeDirectoryUsers();
    	else if(strMethodCalled == 'gtLocationUsers')
    		lstDirectoryUser = gtLocationUsers();
    	else if(strMethodCalled == 'gtListViewUsers')
    		lstDirectoryUser = gtListViewUsers();
		else if(strMethodCalled == 'getFilteredByDepartment')
    		lstDirectoryUser = getFilteredByDepartment();
    	
    	return lstDirectoryUser;
    }
    
    /*  Name:  firstRecords()
        Param: None
        Description: To get the records of first page
    */
    public void firstDirectoryRecords()
    {
    	Integer intTempStartIndex = startIndex;
    	Integer intTempPageNo = pageNo;
    	List<User> lstDirectoryUser = callSuitableMethodForRequery();
    	pageNo = intTempPageNo;
    	startIndex = intTempStartIndex;
    	
        firstRecords();
        
        lstDirectoryUsers = new List<User>();
        for(Integer i = startIndex; i < startIndex+rowsPerPage && i < lstDirectoryUser.size(); i++)
        {
            lstDirectoryUsers.add(lstDirectoryUser[i]);
        }
    }
    /* End : firstRecords Methods */ 
    
    
    /*  Name: lastRecords
        Param: None
        Description: To get the records of last page
    */
    public void lastDirectoryRecords()
    {
    	Integer intTempStartIndex = startIndex;
    	Integer intTempPageNo = pageNo;
    	List<User> lstDirectoryUser = callSuitableMethodForRequery();
    	pageNo = intTempPageNo;
    	startIndex = intTempStartIndex;
    	
        lastRecords();
        
        lstDirectoryUsers = new List<User>();
        for(Integer i = startIndex; i < startIndex+rowsPerPage && i < lstDirectoryUser.size(); i++)
        {
            lstDirectoryUsers.add(lstDirectoryUser[i]);
        }
    }
    /* End : lastRecords Methods */ 
    
    
    /*  Name: nextRecords
        Param: None
        description: To get the records of Next page
    */
    public void nextDirectoryRecords()
    {
        Integer intTempStartIndex = startIndex;
    	Integer intTempPageNo = pageNo;
    	List<User> lstDirectoryUser = callSuitableMethodForRequery();
    	pageNo = intTempPageNo;
    	startIndex = intTempStartIndex;
        nextRecords();
        
        lstDirectoryUsers = new List<User>();
        for(Integer i = startIndex; i < startIndex+rowsPerPage && i < lstDirectoryUser.size(); i++)
        {
            lstDirectoryUsers.add(lstDirectoryUser[i]);
        }
    }
    /* End : nextRecords Methods */
    
    
    /*  Name: prevRecords
        Param: None
        Description: To get the records of Previous page  
    */
    public void prevDirectoryRecords()
    {
    	Integer intTempStartIndex = startIndex;
    	Integer intTempPageNo = pageNo;
    	List<User> lstDirectoryUser = callSuitableMethodForRequery();
    	pageNo = intTempPageNo;
    	startIndex = intTempStartIndex;
    	
        prevRecords();
        
        lstDirectoryUsers = new List<User>();
        for(Integer i = startIndex; i < startIndex+rowsPerPage && i < lstDirectoryUser.size(); i++)
        {
            lstDirectoryUsers.add(lstDirectoryUser[i]);
        }
    }
    /* End : prevRecords Methods */
    
    
    /*  Name: goToPage
        param: None
        Description: To get the records of particulat page  
    */
    public void goToDirectoryPage()
    {
    	List<User> lstDirectoryUser = callSuitableMethodForRequery();

        goToPage();
        
        lstDirectoryUsers = new List<User>();
        for(Integer i = startIndex; i < startIndex+rowsPerPage && i < lstDirectoryUser.size(); i++)
        {
            lstDirectoryUsers.add(lstDirectoryUser[i]);
        }
    }
    
    /* @Name           - getUserLicenseKeyFilters
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for querying License Filters.
    */
    private void getUserLicenseKeyFilters()
	{
		lstUserLicenseFilters = new List<String>();
		List<SL_IntranetUserLicenseFilters__c> lstLicenseFilters = SL_IntranetUserLicenseFilters__c.getAll().values();
		
		if(!lstLicenseFilters.isEmpty() && lstLicenseFilters[0].License_Definition_Keys__c != null)
		{
			lstUserLicenseFilters.addAll(lstLicenseFilters[0].License_Definition_Keys__c.trim().split(','));
		}
	}
	
    /* @Name           - newComponent
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for creating Component dynamically.
    */
    public override ApexPages.Component newComponent() 
    {
        Component.c.SL_IntranetEmployeeDirectory c = new Component.c.SL_IntranetEmployeeDirectory();   
        c.aComponentImpl = this;
        return c;
    }
    /* End : newComponent */
}