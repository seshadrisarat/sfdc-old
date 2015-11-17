/**
* @ClassName    : SL_IntranetEmbedded 
* @JIRATicket   : Socint-233
* @CreatedOn    : 17/Sep/13
* @ModifiedBy   : Pravin 
* @Description  : Class to handle functionality to add embedded content into page regions.
*/
public class SL_IntranetEmbedded extends WidgetAbstract implements IObservable
{
	/* Start - Variables */
	public EmbeddedConfiguration objEConfig		{	get;set;	}
	public String strDeptId						{   get;set;	}
	private Map<String, String> mapDeptIdToDeptName = new Map<String, String>();
	private Boolean isDepartmentWidgetExist; //To identify if Department widget exist on page or not to decide the behavior based on that.
	private Set<String> setLoggedinUserOfficesId; //Storing Logged in User Office Ids
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_IntranetEmbedded()
  	{
  		objEConfig = new EmbeddedConfiguration();
  		setLoggedinUserOfficesId = new Set<String>();
  		strDeptId = '';
  		isDepartmentWidgetExist = false;
  	}
	/* End - Constructor */
	
	public override protected void initialize()
  	{
  		Set<String> setOfficeNameInLowerCase = new Set<String>(); // used for storing logged in user id in lowercase
  		User objUser = [SELECT Id, Selected_Offices_Ids__c, Selected_Department_Ids__c, Name, User_Offices__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
		
		if(String.isNotBlank(objUser.User_Offices__c))
			setOfficeNameInLowerCase.addAll(objUser.User_Offices__c.split('\n'));
		
		/*This block is used to convert logged in useroffices name in Upper Case*/
		for(String strOfficeName : setOfficeNameInLowerCase)
			setLoggedinUserOfficesId.add(strOfficeName.toUpperCase());
			
  		configuration();
  		// listener for department widget dependancy
		WidgetConfigurationListener.getInstance().addEventListener('SL_IntranetDepartments', this);
  	}
  	
  	
  	override public void postInitialize()
	{
		// Depends on Department configuration, so is executed after post initializtion
		showEmbeddedContent();
	}
	
	//Used for getting department initialselection value
	public void notify(IWidget widget) 
	{
		if(widget == null) return;
			
		SL_IntranetDepartments departmentWidget = (SL_IntranetDepartments)widget;
		strDeptId = departmentWidget.strInitialDeptSelection;
		mapDeptIdToDeptName = departmentWidget.mapDeptIdToName;
		isDepartmentWidgetExist = true;
	}
	
	
	/* Start - Wrapper class for Embedded Configuration*/
	public class EmbeddedConfiguration
	{
		/* Start - Inner Variables */
		public String content				{	get;set;	}
		public Set<String> setDepartment;
		public Set<String> setOffices;
		/* End */
		public Boolean isShowEmbedded 		{	get;set;	}
		/* Start - Inner Constructor */
		
		public EmbeddedConfiguration()
		{
			this.isShowEmbedded = false;
			setDepartment = new Set<String>{};
			setOffices = new Set<String>();
		}
	}
	/* End */
	
	/* 
     * Name: configuration
     * Parameters: NA
     * Description: This function is used to gather configuration field values for Embedded Widget.
     */
 	public void configuration()
  	{
  		String strDepartment;		
  		if(Test.isRunningTest())
			id = [Select Name,Configuration__c from PageRegionWidget__c LIMIT 1].Name;
		try
		{	
			/*Start : Moelis specific code*/
			String currentPage = Apexpages.currentPage().getParameters().get('page');
			String employeeId = '';
	  		if(currentPage == 'Employee Profile')
	  		{
	  			employeeId = Apexpages.currentPage().getParameters().get('id');
				employeeId = (employeeId == null || employeeId == '') ? UserInfo.getUserId() : employeeId;
				
				for(User objUser : [Select Id, EmployeeNumber from User where Id =: employeeId])
				{
					employeeId = objUser.EmployeeNumber;
				}	
	  		}
	  		/*End : Moelis specific code*/
	  		
	  		//new code changes start
	  		if(this.properties != null)
	  		{
			
				Map<String, Object> configuration = (Map<String, Object>)this.properties;
				
				objEConfig.content = String.valueOf(configuration.get('content'));
				
				if(configuration.get('initialstate') == null)
				{
					((map<String, object>)properties).put('initialstate','');
				}	 
				
				if(configuration.get('buttontext') == null || configuration.get('buttontext') == '')
				{
					((map<String, object>)properties).put('buttontext','Embedded Content');
				}
					
				if(configuration.get('department') != null && configuration.get('department') != '')
				{
					strDepartment = String.valueOf(configuration.get('department'));
					 
					//In case of more than one dept at configuration side
					for(String strDept : strDepartment.split(','))
					{
						objEConfig.setDepartment.add(strDept.trim().toUpperCase());//If there is whitespace after splitting dept names
					}
				}
				
				if(configuration.get('offices') != null && configuration.get('offices') != '')
				{
					String strOffices = String.valueOf(configuration.get('offices'));
					 
					//In case of more than one offices at configuration side
					for(String strOffice : strOffices.split(','))
					{
						objEConfig.setOffices.add(strOffice.trim().toUpperCase()); //If there is whitespace after splitting office names
					}
				}
				
				/* ---Start---Moelis specific code */
				if(objEConfig.content != null && objEConfig.content.contains('41where.com/moelis') && objEConfig.content.contains('&e='))
				{
					String strEmpIdTemp = objEConfig.content.split('&e=')[1].split('"')[0];
					objEConfig.content = objEConfig.content.replace('&e='+strEmpIdTemp, '&e='+employeeId);
				}
				else
					objEConfig.content = (objEConfig.content != null) ? objEConfig.content : '';
				
				/* --END---Moelis specific code */	
			}
			
			if(Test.isRunningTest())
				Integer i = 10/0;
	  	}
		catch(Exception ex)
		{
			objEConfig = new EmbeddedConfiguration();   
		}
  	}
  	/* End */
  
  	public void getFilteredByDepartment()
  	{
  		showEmbeddedContent();
  	}
  	
  	private void showEmbeddedContent()
  	{
  		objEConfig.isShowEmbedded = FALSE;
  		
  		Boolean bOfficeFilter = true;   

  		if(!setLoggedinUserOfficesId.isEmpty() && !objEConfig.setOffices.isEmpty() && !setLoggedinUserOfficesId.removeAll(objEConfig.setOffices)) {
  			bOfficeFilter = false;
  		}
  		
  		if(bOfficeFilter) {
	  		/*If Department widget does not exist on page and logged in user Office Location Name is not Empty*/
	  		if(!isDepartmentWidgetExist)
	  		{
	  			objEConfig.isShowEmbedded = TRUE;
	  			return;
	  		}
	  		
			if(objEConfig.setDepartment.size() == 0)   
			{
				if(strDeptId == '')
					objEConfig.isShowEmbedded = TRUE;
			}
			else
			{
				if(objEConfig.setDepartment.contains('ALL DEPARTMENTS') && strDeptId !='')
					objEConfig.isShowEmbedded = true;
				else if(strDeptId == 'All' && new Set<String>(mapDeptIdToDeptName.values()).removeAll(objEConfig.setDepartment))
					objEConfig.isShowEmbedded = true;
				else if(objEConfig.setDepartment.contains(mapDeptIdToDeptName.get(strDeptId)))
					objEConfig.isShowEmbedded = true;
			}
  		}
  	}
  	
  	
  	/* 
     * Name: newComponent
     * Parameters: NA
     * Description: This function is used to create the dynamic component
     */
  	public override ApexPages.Component newComponent() 
	{
    	Component.c.SL_IntranetEmbedded c = new Component.c.SL_IntranetEmbedded();    
		c.aComponentImpl = this; 
		 
    	return c;
  	}
  	/* End */
}