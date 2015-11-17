public with sharing abstract class SL_IntranetApplications extends WidgetAbstract implements IObservable
{
	public List<Intranet_App__c> lstApplications												{	get;set;    } //List to store the Application records.
	public String strDeptId 																	{	get;set;	} //Store the Department id
	public ApplicationWidgetConfiguration objApplicationConfig 									{	get;set;	} //Configuration for Application Widget
	private Set<String> setLoggedinUserOfficesId;																  //Storing Logged in User Office Ids
	private Boolean isDepartmentWidgetExist; //To identify if Department widget exist on page or not to decide the behavior based on that.
	
	/* Constructor initialization */
	public SL_IntranetApplications()
	{
		strDeptId = '';
		isDepartmentWidgetExist = false;
		objApplicationConfig = new ApplicationWidgetConfiguration();
		setLoggedinUserOfficesId = new Set<String>();
	}
	/* End : Constructor initialization */
	
	/* Inner Class */
	public class ApplicationWidgetConfiguration
	{
		public String initialstate {get;set;}
	}
	
	// initialize method called on component's initialize
	public override protected void initialize()
	{
		if(!getObjectAccess('read', new Intranet_App__c().getsObjectType()))
			return ;
		
		User objUser = [SELECT Id, Selected_Offices_Ids__c, Selected_Department_Ids__c, Name FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
		
		if(String.isNotBlank(objUser.Selected_Offices_Ids__c))
			setLoggedinUserOfficesId.addAll(objUser.Selected_Offices_Ids__c.split(';'));
			
		// Fetch the configuration for the widget
		if(this.properties != null) 
		{
			Map<String, Object> configuration = (Map<String, Object>)this.properties;
			
			if(configuration.containsKey('initialstate'))	objApplicationConfig.initialstate = String.valueOf(configuration.get('initialstate'));
		}
		// listen for department widget dependancy
		WidgetConfigurationListener.getInstance().addEventListener('SL_IntranetDepartments', this); 
		
	}
	
	override public void postInitialize()
	{
		// Depends on Department configuration, so is executed after pre initializtion
		fetchAppValues();		//Fetching App and link values
	}
	
	
	public void notify(IWidget widget) {
		if(widget == null) return;
			
		SL_IntranetDepartments departmentWidget = (SL_IntranetDepartments)widget;
		strDeptId = departmentWidget.strInitialDeptSelection;
		isDepartmentWidgetExist = true;
		System.debug('SL_DEBUG: System set department from configuration: ' + strDeptId);
	}
	
	
	/* Start - Method for getting options in selectlist of Apps&Links.
	   @Name           - fetchAppValues
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting options in selectlist of Apps&Links.
	*/ 
	public void fetchAppValues()
	{
		lstApplications = new List<Intranet_App__c>();
		
		if(!getObjectAccess('read', new Intranet_App__c().getsObjectType()))
			return ;
		 
		OfficesSpecification officesSpec = new OfficesSpecification(setLoggedinUserOfficesId);
		DepartmentSpecification departmentSpec = new DepartmentSpecification(strDeptId);
		
		
		//Getting records for App and Links widget
		for(Intranet_App__c obj : [SELECT Id, Name, For_All_Offices__c, For_All_Departments__c, Selected_Department_Ids__c, 
								   Selected_Office_Ids__c, URL__c, Active__c, IntranetApp_Offices__c 
								   FROM Intranet_App__c 
								   WHERE Active__c = true ORDER BY Name ASC 
								  ])
		{
			String strURL = obj.URL__c;
			if(obj.URL__c != null & obj.URL__c != '' && !obj.URL__c.toLowercase().contains('http'))
				strURL = 'http://' + obj.URL__c;
			
			if(officesSpec.satisfiedBy(obj) && (!isDepartmentWidgetExist || departmentSpec.satisfiedBy(obj)))
				lstApplications.add(new Intranet_App__c(Name = obj.Name, URL__c = strURL));
		}
	}
	/* End : fetchAppValues method */
	
	
	public void getFilteredByDepartment()
	{
		fetchAppValues();
	}
	
	public override ApexPages.Component newComponent() 
	{ 
    	Component.c.SL_IntranetApplications c = new Component.c.SL_IntranetApplications();   
		c.aComponentImpl = this;
		
    	return c;
  	}
}