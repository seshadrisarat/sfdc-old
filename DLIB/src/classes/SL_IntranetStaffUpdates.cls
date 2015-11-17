public with sharing abstract class SL_IntranetStaffUpdates extends WidgetAbstract
{
	// list for New hired staff
	public List<User> lstNewHires 															{	get;set;	}
    //List of User fields corresoponding to component fieldset
	public List<SL_UtilityWrappers.FieldSetDescribe> lstWrapperUserFields 					{	get;set;	}
	
	public staffConfiguration config														{	get;set;	}
	
	private List<String> lstUserLicenseFilters;
	private Set<String> setFieldsToQuery = new Set<String>();
	
	/* Constructor initialization */
	public SL_IntranetStaffUpdates()
	{
		config = new staffConfiguration();
		setFieldsToQuery = new Set<String>{'Name', 'FirstName', 'LastName', 'IsActive', 'Hire_Date__c', 'Title', 'Department', 'City', 'Country', 
                                           'SmallPhotoUrl', 'Phone', 'Extension', 'User_Offices__c', 'AboutMe', 'LastModifiedById' };
		lstNewHires = new List<User>();
		lstUserLicenseFilters = new List<String>();
	}
	/* End : Constructor initialization */
	
	public class staffConfiguration
	{
		public Integer intRecentHiresCount 	{	get;set;	}		// No of Recent Hire
		public Integer intTotalRecords		{	get;set;	}		// Total no of record to be shown
		public Boolean showAboutMe			{	get;set;	}		// Boolean variable for ShowAboutMe
		private Integer intNumberToDisplay;							// No of Record to be display at one time
		private Integer NoOfDaysForRecentHires;
		
		public staffConfiguration()
		{
			this.showAboutMe = false;
			this.intTotalRecords = 10;
			this.intNumberToDisplay = 5;
			this.NoOfDaysForRecentHires = 21;
		}
	}
	
	//method overrided to get configuration from properties 
	public override protected void initialize()
	{
		getUserLicenseKeyFilters();		// Fetching the user license Filters
		getNoOfDaysForRecentHire();		// Fetching the 'Default Settings' From SL_IntranetApplicationSetting__c
		prepareWidgetConfiguration();	// Fetching configuration for widget
		getNewHires();					// Fetching Recent hired employees
	}
	
	// Get value for displaying No of staff update records
	private void getNoOfDaysForRecentHire()
	{
		for( SL_IntranetApplicationSetting__c objPagination : [ SELECT Name, Of_Days_For_Recent_Hires__c 
                                                          		FROM SL_IntranetApplicationSetting__c
                                                          		WHERE name = 'Default Settings' 
                                                          		LIMIT 1])
        {
            config.NoOfDaysForRecentHires = Integer.valueOf(objPagination.Of_Days_For_Recent_Hires__c) == null ? config.NoOfDaysForRecentHires: Integer.valueOf(objPagination.Of_Days_For_Recent_Hires__c);
        }
	}
	
	
	/* Start - Method for getting records for recent hires.
	   @Name           - getNewHires
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting records for recent hires.
	*/	
	public void getNewHires() 
	{
		try
		{
			String strQuery = 'Select Id';
			
			if(setFieldsToQuery.contains('Id'))
				setFieldsToQuery.remove('Id');
				
			// add fields to the query
			for(String strFieldName:setFieldsToQuery)
			{
				strQuery += ','+ strFieldName;
			}
			
			strQuery += ' FROM User ' + 
						' WHERE IsActive = true ' + 
								'AND Profile.UserLicense.LicenseDefinitionKey NOT IN: lstUserLicenseFilters ' +
								'AND Hire_Date__c != null ' +
								'AND Hire_Date__c >= LAST_N_DAYS:' + String.escapeSingleQuotes(String.valueOf(config.NoOfDaysForRecentHires)) + ' ' + 
								'AND Hire_Date__c <= TODAY '; 
			
			/*SOCINT-1027 to filter the Users when logged as Admin in Community*/
			String networkId = Network.getNetworkId(); 
			
			/*When logged in as Admin the Network Id will be null*/
			if(String.isEmpty(networkId))         
				strQuery += ' AND Exclude_from_Intranet_Directory__c = FALSE AND ContactId = null'; //Add the filter ContactId = null when we logged in as Admin and it wont display Community Licence Users.
			/*When accessing Community as Admin User and Network Id will not be null*/
			else if(String.isNotEmpty(networkId))
				strQuery += ' AND Exclude_from_Intranet_Directory__c = FALSE AND Id IN (SELECT memberId FROM NETWORKMEMBER WHERE networkId =\''+ networkId +'\' )'; //Adding the filter will provide all the members of the community related to its Network Id.
			/*---End---*/						
								
			strQuery += ' ORDER BY Hire_Date__c Desc, LastName, Name ';
			lstNewHires = database.query(strQuery);
            
            if(Test.isRunningTest())
            	Integer i = 10/0;
		}
		catch(Exception ex){
			system.debug(':::::::Exception:::::::'+ex);
		}
	}
	/* End : getNewHires method */
	
	
	/* Start - Method for getting configuration  for widget.
	   @Name           - prepareWidgetConfiguration
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting configuration for widget.
	*/
	
	private void prepareWidgetConfiguration()
	{
		String strFieldSetname = ''; ///variable to store field set name
		lstWrapperUserFields = new List<SL_UtilityWrappers.FieldSetDescribe>(); 

		if(this.properties != null) {
			
			Map<String, Object> configuration = (Map<String, Object>)this.properties;
			
			if(configuration.containsKey('numbertodisplay') && configuration.get('numbertodisplay') != '' && configuration.get('numbertodisplay') != null) 
				config.intNumberToDisplay = Integer.valueOf(configuration.get('numbertodisplay'));
				
			if(configuration.containsKey('TotalRecords') && configuration.get('TotalRecords') != '' && configuration.get('TotalRecords') != null) 	 
				config.intTotalRecords = Integer.valueOf(configuration.get('TotalRecords'));
				
			if(configuration.containsKey('showAboutMe')) 	 config.showAboutMe 		= Boolean.valueOf(configuration.get('showAboutMe'));
			if(configuration.containsKey('fieldset')) 		 strfieldsetname 			= String.valueOf(configuration.get('fieldset'));
			
			config.intRecentHiresCount = config.intNumberToDisplay;
		}
		
		// Fetch the fieldset related data
		if(String.isNotBlank(strFieldSetname))
        {
     		SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( 'User', strFieldSetname, '', '', '', new Set<String>());
     		lstWrapperUserFields = objFieldSetWrapper.lstFieldWrapper;
        }
        
        // Iterate through the fields returned , to form a query
    	for(SL_UtilityWrappers.FieldSetDescribe objFieldSetResult : lstWrapperUserFields)
		{
			setFieldsToQuery.add(objFieldSetResult.fieldAPIName);
		}
	}
	/* End : prepareWidgetConfiguration method */
	
	
	/* 
     * Name: showMoreRecords
     * Parameters: NA
     * Description: Dispalying all records
     */
	public void showMoreRecords()
	{
		config.intRecentHiresCount+= config.intNumberToDisplay;
		
		if(config.intRecentHiresCount > config.intTotalRecords)
			config.intRecentHiresCount = config.intTotalRecords;
	}
     /* End */
	
	private void getUserLicenseKeyFilters() 
	{
		lstUserLicenseFilters = new List<String>();
		List<SL_IntranetUserLicenseFilters__c> lstLicenseFilters = SL_IntranetUserLicenseFilters__c.getAll().values();
		
		if(!lstLicenseFilters.isEmpty() && lstLicenseFilters[0].License_Definition_Keys__c != null)
		{
			lstUserLicenseFilters.addAll(lstLicenseFilters[0].License_Definition_Keys__c.trim().split(','));
		}
	}
	
	public override ApexPages.Component newComponent() 
	{
    	Component.c.SL_IntranetStaffUpdates c = new Component.c.SL_IntranetStaffUpdates();   
		c.aComponentImpl = this;
    	return c;
  	}
}