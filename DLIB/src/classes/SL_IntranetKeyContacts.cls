public with sharing class SL_IntranetKeyContacts extends WidgetAbstract implements IObservable
{
	//List Of key Contacts
	public List<User> lstKeyContacts 													{	get;set;	}
	//List of User fields corresoponding to component fieldset
	public List<SL_UtilityWrappers.FieldSetDescribe> lstWrapperUserFields 				{	get;set;	}
	// department Id 
	public String strDeptId 															{	get;set;	}
	private Boolean isDepartmentWidgetExist; //To identify if Department widget exist on page or not to decide the behavior based on that.
	
	/* Constructor initialization */
	public SL_IntranetKeyContacts()
	{
		strDeptId = '';
		isDepartmentWidgetExist = false;
		lstKeyContacts = new List<User>();
	}
	/* End : Constructor initialization */
	
	public override protected void initialize()
	{
		// listen for department widget dependancy
		WidgetConfigurationListener.getInstance().addEventListener('SL_IntranetDepartments', this);
	}

	override public void postInitialize()
	{
		// Depends on Department configuration, so is executed after post initializtion
		getKeyContacts();		//Used for getting KeyContacts based on Department Id.
	}

	public void notify(IWidget widget) {
		if(widget == null) return;
			
		SL_IntranetDepartments departmentWidget = (SL_IntranetDepartments)widget;
		
		strDeptId = departmentWidget.strInitialDeptSelection;
		isDepartmentWidgetExist = true;
		System.debug('SL_DEBUG: System set department from configuration: ' + strDeptId);
	}
	
	/* Start - Method for getting records for recent hires.
	   @Name           - getKeyContacts
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting records for recent hires.
	*/	
	public void getKeyContacts() 
	{
		//global variable initialize
		lstWrapperUserFields = new List<SL_UtilityWrappers.FieldSetDescribe>(); 
		lstKeyContacts = new List<User>();
		
		String strFieldSetname = ''; 						//variable to store field set name
		String strquery; 									// String to store dynamic query
		Set<String> setFieldsToQuery = new Set<String>(); 	//set to hold  Default fields to query

    	setFieldsToQuery = new Set<String>{ 'Name', 'FirstName', 'LastName','All_Departments__c','Selected_Department_Ids__c', 
    		                                'IsActive', 'Hire_Date__c', 'Title', 'Department', 'City', 'Country', 'SmallPhotoUrl', 
    		                                'Phone', 'Extension', 'User_Offices__c', 'AboutMe'};
        
    	// Fetch the configuration for the widget
		if(this.properties != null) {
			Map<String, Object> configuration = (Map<String, Object>)this.properties;
			
			//if(configuration.containsKey('showAboutMe')) 	config.showAboutMe 	= Boolean.valueOf(configuration.get('showAboutMe'));
			if(configuration.containsKey('fieldset')) 		strFieldSetname 	= String.valueOf(configuration.get('fieldset'));
		}
			
		// If user has written a fieldset name in configuration
		if(String.isNotBlank(strFieldSetname))
        {
     		SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( 'User', strFieldSetname, '', '', '', new Set<String>());
     		lstWrapperUserFields = objFieldSetWrapper.lstFieldWrapper;
        }
	
		// Iterate through the fields returned previously to form a query
    	for(SL_UtilityWrappers.FieldSetDescribe objFieldSetResult : lstWrapperUserFields)
		{
			setFieldsToQuery.add(objFieldSetResult.fieldAPIName);
		}
		
    	// form dynamic query
    	strQuery = 'Select Id';
    	
    	if(setFieldsToQuery.contains('Id'))
    		setFieldsToQuery.remove('Id');
    		
    	/// add fields to the query
    	for(String strFieldName : setFieldsToQuery)
    	{
    		strQuery += ', '+  String.escapeSingleQuotes(strFieldName);
    	}
    	
    	strQuery += ' From User Where IsActive = true ';
    	
    	/*SOCINT-1027 to filter the Users when logged as Admin in Community*/
		String networkId = Network.getNetworkId(); 
		
		/*When logged in as Admin the Network Id will be null*/
		if(String.isEmpty(networkId))         
			strQuery += ' AND Exclude_from_Intranet_Directory__c = FALSE AND ContactId = null'; //Add the filter ContactId = null so when we logged in as Admin and it wont display Community Licence Users.
		/*When accessing Community as Admin User and Network Id will not be null*/
		else if(String.isNotEmpty(networkId))
			strQuery += ' AND Exclude_from_Intranet_Directory__c = FALSE AND Id IN (SELECT memberId FROM NETWORKMEMBER WHERE networkId =\''+ networkId +'\' )'; //Adding the filter will provide all the members of the community related to its Network Id.
		/*---End---*/
		
		strQuery += ' Order By Name ';
    	
		/// query user records
		for(User obj : database.query(strQuery))
		{
			DepartmentSpecification departmentSpec = new DepartmentSpecification(strDeptId);
			 
			if(!isDepartmentWidgetExist || departmentSpec.satisfiedBy(obj, false))
				lstKeyContacts.add(obj);
		}
		
	}
	/* End : getKeyContacts method */ 
	
	public void getFilteredByDepartment()
	{
		getKeyContacts();
	}
	
	public override ApexPages.Component newComponent() 
	{
    	Component.c.SL_IntranetKeyContacts c = new Component.c.SL_IntranetKeyContacts();   
		c.aComponentImpl = this;
    	return c;
  	}
}